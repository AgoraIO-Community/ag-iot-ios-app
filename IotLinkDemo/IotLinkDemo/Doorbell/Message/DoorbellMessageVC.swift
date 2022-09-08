//
//  DoorbellMessageVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/5.
//

import UIKit
import JXSegmentedView
import DZNEmptyDataSet
import SwiftDate
import AgoraIotLink
import SVProgressHUD
//import SJVideoPlayer
import Alamofire
import MJRefresh
import IJKMediaFramework
import SJUIKit
import SJBaseVideoPlayer


private let kCellID = "DoorbellMsgCell"
private let kDownloadMaxCount = 1

// 是否有播放器
enum AlamMsgVCPlayerStyle {
    case normal // 有播放器
    case none   // 无播放器
}

class DoorbellMessageVC: UIViewController {
    
    var device:IotDevice?
    
    // 设置背景色样式
    var bgStyle:AlamMsgVCBgStyle = .black
    
    var playerStyle:AlamMsgVCPlayerStyle = .normal
    
    var unreadValueChanged:(()->(Void))?
    
    // 当前页码
    private var currentPage = 1
    
    private lazy var playerView: DoorbellPlayerView = {
        let playerView = DoorbellPlayerView()
        playerView.clickDeleteButtonAction = { [weak self] in
            self?.playerView.pause()
            self?.tryDeleteCurrentPlayingMsg()
        }
        playerView.clickDownloadButtonAction = {[weak self] in
            self?.downloadCurrentPlayingVideo()
            DownloadProgressVC.show()
        }
        playerView.clickDefinationButtonAction = {[weak self] in
            if let defination = self?.playerView.defination {
                AGActionSheetVC.showTitle("画质设置", items: ["标清","高清"], selectIndex: defination) {[weak self] item, index in
                    self?.playerView.defination = index
                }
            }
        }
        return playerView
    }()
    
    private lazy var player = {
        return playerView.player
    }()
    
    // 正在播放的消息
    private var currentPlayingMsg:MsgData? {
        didSet{
            oldValue?.isPlaying = false
            currentPlayingMsg?.isPlaying = true
            playerView.isDownloading = currentPlayingMsg?.isDownloading ?? false
        }
    }
    
    // 当前选中的index
    private var selectedTypeIndex = 0
    // 当前选中的msgtype
    private var selectedMessageType: Int?
    // 当前选择的日期
    private var selectedDate:Date?
    // 所有消息
    private var dataSource = [MsgData]()
    // 当前下载数量
    private var currentDownloadCount = 0
    
    private let messageTypeKeyValues: [String: Int] = [
        "声音侦测" : 0,
        "移动侦测" : 1,
        "PIR红外检测" : 2,
        "按钮报警" : 4,
        "其他告警" : 99
    ]
    private let messageTypeKeys:[String] =  ["全部类型","声音侦测","移动侦测","PIR红外检测","按钮报警"]
    
    private lazy var selectAllView: DoorbellSelectAllView = {
        let selectAllView = DoorbellSelectAllView()
        selectAllView.clickSelectedButtonAction = { [weak self] button in
            button.isSelected = !button.isSelected
            if self == nil { return }
            for data in self!.dataSource {
                data.isSelected = button.isSelected
            }
            self!.tableView.reloadData()
        }
        
        selectAllView.clickDeleteButtonAction = { [weak self] in
            self?.didClickDeleteButton()
        }
        return selectAllView
    }()
    
    private lazy var sectionHeaderView:DoorbellSectionView = {
        let sectionHeaderView = DoorbellSectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 65))
        sectionHeaderView.editButton.isEnabled = false
        sectionHeaderView.bgStyle = bgStyle
        sectionHeaderView.clickDateButtonAction = { [weak self] in
            if self == nil { return }
            let button = self!.sectionHeaderView.editButton
            if button.isSelected {
                self!.endEditMsgList()
                return
            }
            
            AGDatePickerVC.show(defaultDate: self!.selectedDate ?? Date()) { [weak self] selectedDate in
                if self == nil { return }
                self!.selectedDate = selectedDate
                self!.sectionHeaderView.setDate(selectedDate)
                self!.loadMsgList()
            }
        }
        sectionHeaderView.clickTypeButtonAction = {[weak self] in
            if self == nil { return }
            let button = self!.sectionHeaderView.editButton
            if button.isSelected {
                self!.endEditMsgList()
                return
            }
            
            AGActionSheetVC.showTitle("类型", items: self!.messageTypeKeys, selectIndex: self!.selectedTypeIndex) {[weak self] item, index in
                if self == nil { return }
                self!.sectionHeaderView.setType(item)
                self!.selectedTypeIndex = index
                self!.selectedMessageType = self!.messageTypeKeyValues[item]
                self!.loadMsgList()
            }
        }
        
        sectionHeaderView.clickDeviceButtonAction = {[weak self] in
            
        }
        
        sectionHeaderView.clickEditButtonAction = { [weak self] button in
            if button.isSelected {
                self?.endEditMsgList()
            }else{
                self?.beginEditMsgList()
            }
        }
        return sectionHeaderView
    }()

    private lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(DoorbellMsgCell.self, forCellReuseIdentifier: kCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = bgStyle == .black ? UIColor(hexRGB: 0x000000) : UIColor(hexRGB: 0xF8F8F8)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPowerData()
        loadMsgList()
        addRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.vc_viewWillDisappear()
//        player.pause()
        endEditMsgList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
//        player.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //player.vc_viewDidDisappear()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    private func setupUI(){
        
        view.backgroundColor = bgStyle == .black ? UIColor(hexRGB: 0x000000) : UIColor(hexRGB: 0xF8F8F8)
        if playerStyle == .normal {
            view.addSubview(playerView)
            playerView.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(0)
            }
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(playerView.snp.bottom)
            }
        }else{
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.left.right.bottom.equalToSuperview()
            }
        }
    }
    
    // 下拉刷新
    private func addRefresh(){
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.loadMsgList()
        })
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMsgList(isLoadMore: true)
        })
    }
    
    // 下载
    private func downloadCurrentPlayingVideo(){
        if currentDownloadCount >= kDownloadMaxCount {
            debugPrint("达到最大下载数量：\(kDownloadMaxCount)")
            return
        }
        currentDownloadCount += 1
//        if let url = self.player.assetURL {
//            guard let msg = self.currentPlayingMsg else { return }
//            playerView.isDownloading = true
//            msg.isDownloading = true
//            DoorbellDownlaodManager.shared.download(url: url, completion: { [weak self] in
//                guard let wSelf = self else { return }
//                msg.isDownloading = false
//                wSelf.playerView.isDownloading = wSelf.currentPlayingMsg?.isDownloading ?? false
//            })
//        }else{
//            SVProgressHUD.showInfo(withStatus: "下载地址错误")
//        }
    }
    
    // 尝试删除当前播放的消息
    private func tryDeleteCurrentPlayingMsg(){
        if self.currentPlayingMsg == nil {
            return
        }
        AGAlertViewController.showTitle("提示", message: "确定要删除正在播放的消息吗", cancelTitle: "取消", commitTitle: "确定") {[weak self] in
            if let id = self?.currentPlayingMsg?.alarm.alertMessageId {
                self?.deleteMessages(id)
            }
        }
    }
    
    private func didClickDeleteButton()  {
        // 选中的数量大于0
        if selectedIsNotEmpty() {
            selectAllView.disabled = true
            AGAlertViewController.showTitle("提示", message: "确定要删除所选中的消息吗", cancelTitle: "取消", commitTitle: "确定") {[weak self] in
                self?.selectAllView.disabled = false
                self?.endEditMsgList()
                self?.deleteMessages()
            } cancelAction: { [weak self] in
                self?.selectAllView.disabled = false
            }
        }else{
            SVProgressHUD.showInfo(withStatus: "请选择要删除的消息")
            SVProgressHUD.dismiss(withDelay: 2)
        }
    }
    
    // 结束编辑
    private func endEditMsgList() {
        let button = sectionHeaderView.editButton
        button.isSelected = false
        for data in dataSource {
            data.canEdit = false
        }
        hideSelectAllView()
        tableView.reloadData()
    }
    
    private func beginEditMsgList() {
        let button = sectionHeaderView.editButton
        button.isSelected = true
        for data in dataSource {
            data.canEdit = true
        }
        showSelectAllView()
        tableView.reloadData()
    }
    
    // 显示选中所有
    private func showSelectAllView(){
        if dataSource.count == 0 {
            return
        }
        
        UIApplication.shared.keyWindow?.addSubview(selectAllView)
        selectAllView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(103.S)
        }
    }
    
    // 隐藏选中所有
    private func hideSelectAllView(){
        selectAllView.removeFromSuperview()
    }
    
    // 判断是否选中所有
    private func isSelectedAll() -> Bool {
        if dataSource.count == 0 {
            return false
        }
        for data in dataSource {
            if !data.isSelected {
                return false
            }
        }
        return true
    }
    
    // 判断是否有选中的消息
    private func selectedIsNotEmpty() -> Bool {
        for data in dataSource {
            if data.isSelected {
                return true
            }
        }
        return false
    }
    
    // 标记为已读
    private func markAsRead(msgIds:[UInt64]){
        AgoraIotManager.shared.sdk?.alarmMgr.mark(alarmIdList: msgIds, result: {[weak self] ec, msg in
            DispatchQueue.main.async {
                self?.unreadValueChanged?()
            }
        })
    }
    
    // 获取电量信息
    private func loadPowerData(){
        guard let device = device else { return }
        DoorBellManager.shared.getDeviceProperty(device) { [weak self] success, msg, desired,reported in
            if success {
                guard let dict = desired else { return }
                if let value = dict["106"] as? Int{
                    self?.playerView.quantityValue = value
                }
            }
        }
    }
    
    // 获取消息列表
    private func loadMsgList(isLoadMore:Bool = false) {
        let sdk = AgoraIotManager.shared.sdk
        guard let alarmMgr = sdk?.alarmMgr else{ return }
        var query:IAlarmMgr.QueryParam
        if let date = selectedDate {
            let beginDate = Date(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0,second: 0)
            let endDate = Date(year: date.year, month: date.month, day: date.day, hour: 23, minute: 59,second: 59)
            query = IAlarmMgr.QueryParam(dateBegin: beginDate)
            query.createdDateEnd = endDate
        }else{
            query = IAlarmMgr.QueryParam()
        }
        query.status = nil
        if isLoadMore {
            currentPage += 1
        }else{
            currentPage = 1
        }
        query.currentPage = currentPage
        query.pageSize = 10
        query.messageType = self.selectedMessageType
        SVProgressHUD.show()
        query.productId = device?.productId
        query.deviceId = device?.deviceId
        alarmMgr.queryByParam(queryParam: query) { [weak self] ec, msg, alarms in
            
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.mj_footer?.endRefreshing()
            if(ec != ErrCode.XOK){
                debugPrint("查询告警记录失败")
                SVProgressHUD.showError(withStatus: msg)
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            guard let alarmList = alarms else {
                SVProgressHUD.dismiss()
                return
            }
            SVProgressHUD.dismiss()
            if alarmList.count < 10 {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            if !isLoadMore {
                self?.dataSource.removeAll()
            }
            for alarm:IotAlarm in alarmList {
                let data = MsgData(alarm: alarm)
                self?.dataSource.append(data)
                Utils.loadAlertImage(alarm.imageId) { ec, msg, img in
                    data.uiImage = img
                    self?.tableView.reloadData()
                }
            }
            
            /*
            for _ in 0...4 {
                let alarm = IotAlarm(messageId: 123)
                let data = MsgData(alarm: alarm)
                data.alarm.fileUrl = "http://192.168.1.5:8080/1.mp4"
                self?.dataSource.append(data)
            }
             */
             
            
            if self?.dataSource.count == 0 {
                self?.playerView.snp.updateConstraints({ make in
                    make.height.equalTo(0)
                })
            }else{
                self?.playerView.snp.updateConstraints({ make in
                    make.height.equalTo(356.S)
                })
            }
            self?.sectionHeaderView.editButton.isEnabled = self?.dataSource.count ?? 0 > 0
            if self?.playerStyle == .normal {
                // 默认播放第一条
                if let firstMsg = self?.dataSource.first {
                    self?.currentPlayingMsg = firstMsg
                    self?.loadMsgDetailForId(firstMsg.alarm.alertMessageId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                }
            }
            self?.tableView.reloadData()
        }
    }
    
    // 获取消息详情
    private func loadMsgDetailForId(_ msgId:UInt64) {
        /*
        if let url = URL(string: "http://192.168.1.5:8080/2.MOV") {
            player.urlAsset =  SJVideoPlayerURLAsset(url: url)
        }
        return
        */
        
        let sdk = AgoraIotManager.shared.sdk
        guard let alarmMgr = sdk?.alarmMgr else{ return }
        SVProgressHUD.show()
        alarmMgr.queryById(alertMessageId:msgId, result: {[weak self] ec, err, alert in
            if(ec != ErrCode.XOK){
                SVProgressHUD.showError(withStatus: "查询信息详情失败\(err)")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            guard let msg = alert else {
                SVProgressHUD.dismiss()
                return
            }
            
//            guard let url = URL(string: msg.fileUrl) else {
//                SVProgressHUD.showError(withStatus: "获取播放地址失败")
//                SVProgressHUD.dismiss(withDelay: 2)
//                return
//            }
            guard let alert = alert else{
                SVProgressHUD.showError(withStatus: "获取播放地址失败")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            
            Utils.loadAlertVideoUrl(alert.deviceId, alert.beginTime) { ec, msg, url in
                if(ec == ErrCode.XOK && url != nil){
                    let ijkVC : SJIJKMediaPlaybackController = SJIJKMediaPlaybackController()
                    let options = IJKFFOptions.byDefault()
                    ijkVC.options = options
                    self?.player.playbackController = ijkVC
                    
                    guard let url = URL(string: url!) else {
                                    SVProgressHUD.showError(withStatus: "获取播放地址失败")
                                    SVProgressHUD.dismiss(withDelay: 2)
                                    return
                                }
                    self?.player.urlAsset = SJVideoPlayerURLAsset(url: url)
                    
                    
        //            self?.player.play(alarm: alert!)
                    //self?.player.play(url: "https://aios-personalized-wuw.oss-cn-beijing.aliyuncs.com/ts_muxer.m3u8")
                    SVProgressHUD.dismiss()
                }
                else{
                    SVProgressHUD.showError(withStatus: "获取播放地址失败")
                    SVProgressHUD.dismiss(withDelay: 2)
                }
            }
            
            
        })
    }
    
    // 删除消息
    private func deleteMessages(_ id: UInt64? = nil ){
        var msgidList = [UInt64]()
        if id != nil {
            msgidList.append(id!)
        }else{
            for data in dataSource {
                if data.isSelected {
                    msgidList.append(data.alarm.alertMessageId)
                }
            }
        }
        let sdk = AgoraIotManager.shared.sdk
        guard let alarmMgr = sdk?.alarmMgr else{ return }
        alarmMgr.delete(alarmIdList: msgidList) {[weak self] ec, err in
            if(ec != ErrCode.XOK){
                SVProgressHUD.showError(withStatus: "删除警告失败\(err)")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            SVProgressHUD.showSuccess(withStatus: "删除成功")
            self?.loadMsgList()
        }
    }
    
    
}

extension DoorbellMessageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.dataSource[indexPath.row]
        let cell:DoorbellMsgCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! DoorbellMsgCell
        cell.bgStyle = bgStyle
        cell.deviceStyle = playerStyle == .normal ? .none : .some
        cell.selectionStyle = .none
        cell.setMsgData(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let msg = self.dataSource[indexPath.row]
        if msg.canEdit {
            msg.isSelected = !msg.isSelected
            self.selectAllView.selectedbutton.isSelected = isSelectedAll()
            tableView.reloadRows(at: [indexPath], with: .none)
        }else{
            if playerStyle == .normal {
                if !msg.isPlaying {
                    self.currentPlayingMsg = msg
                    loadMsgDetailForId(msg.alarm.alertMessageId)
                    tableView.reloadData()
                }
            }else{
                let playerVC = MessagePlayerVC()
                playerVC.msgId = msg.alarm.alertMessageId
                self.navigationController?.pushViewController(playerVC, animated: true)
            }
            // 如果未读标记为已读
            if msg.alarm.status == 0 {
                markAsRead(msgIds: [msg.alarm.alertMessageId])
                msg.alarm.status = 1
            }
        }
    }
}

extension DoorbellMessageVC: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let customView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "暂无消息"
        titleLabel.textColor = bgStyle == AlamMsgVCBgStyle.black ? UIColor.white : UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        customView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(customView.snp.centerY).offset(-20.S)
        }
        
        customView.snp.makeConstraints { make in
            make.height.equalTo(200.S)
        }
        return customView
    }
}



extension DoorbellMessageVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}


