////
////  NotifyMessageVC.swift
////  AgoraIoT
////
////  Created by FanPengpeng on 2022/5/12.
////
//
//import UIKit
//import JXSegmentedView
//import DZNEmptyDataSet
//import SVProgressHUD
//import AgoraIotLink
//import MJRefresh
//
//private let kCellID = "NotifyMessageCell"
//
//class NotifyMessageVC: UIViewController {
//
//    var unreadValueChanged:(()->(Void))?
//
//    // 所有消息
//    private var dataSource = [MsgData]()
//
//    // 当前页码
//    private var currentPage = 1
//
//
//    private lazy var selectAllView: DoorbellSelectAllView = {
//        let selectAllView = DoorbellSelectAllView()
//        selectAllView.clickSelectedButtonAction = { [weak self] button in
//            button.isSelected = !button.isSelected
//            if self == nil { return }
//            for data in self!.dataSource {
//                data.isSelected = button.isSelected
//            }
//            self!.tableView.reloadData()
//        }
//
//        selectAllView.clickDeleteButtonAction = { [weak self] in
//            self?.didClickDeleteButton()
//        }
//        return selectAllView
//    }()
//
//    private lazy var sectionHeaderView:NotifyMsgSectionHeaderView = {
//        let sectionHeaderView = NotifyMsgSectionHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 65))
//        sectionHeaderView.editButton.isHidden = true
//        sectionHeaderView.editButton.isEnabled = false
//        sectionHeaderView.clickEditButtonAction = { [weak self] button in
//            if button.isSelected {
//                self?.endEditMsgList()
//            }else{
//                self?.beginEditMsgList()
//            }
//        }
//        return sectionHeaderView
//    }()
//
//    private lazy var tableView:UITableView = {
//        let tableView = UITableView()
//        tableView.register(NotifyMsgCell.self, forCellReuseIdentifier: kCellID)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
//        tableView.separatorStyle = .none
//        tableView.tableFooterView = UIView()
//        return tableView
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadMsgList()
//        addRefresh()
//    }
//
//    private func setupUI(){
//        view.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.top.left.right.bottom.equalToSuperview()
//        }
//    }
//
//    // 下拉刷新
//    private func addRefresh(){
//        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
//            self?.loadMsgList()
//        })
//        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {[weak self] in
//            self?.loadMsgList(isLoadMore: true)
//        })
//    }
//
//    private func didClickDeleteButton()  {
//        // 选中的数量大于0
//        if selectedIsNotEmpty() {
//            selectAllView.disabled = true
//            AGAlertViewController.showTitle("提示", message: "确定要删除所选中的消息吗", cancelTitle: "取消", commitTitle: "确定") {[weak self] in
//                self?.selectAllView.disabled = false
//                self?.endEditMsgList()
//                self?.deleteMessages()
//            } cancelAction: { [weak self] in
//                self?.selectAllView.disabled = false
//            }
//        }else{
//            SVProgressHUD.showInfo(withStatus: "请选择要删除的消息")
//            SVProgressHUD.dismiss(withDelay: 2)
//        }
//    }
//
//    // 结束编辑
//    private func endEditMsgList() {
//        let button = sectionHeaderView.editButton
//        button.isSelected = false
//        for data in dataSource {
//            data.canEdit = false
//        }
//        hideSelectAllView()
//        tableView.reloadData()
//    }
//
//    private func beginEditMsgList() {
//        let button = sectionHeaderView.editButton
//        button.isSelected = true
//        for data in dataSource {
//            data.canEdit = true
//        }
//        showSelectAllView()
//        tableView.reloadData()
//    }
//
//    // 显示选中所有
//    private func showSelectAllView(){
//        if dataSource.count == 0 {
//            return
//        }
//
//        UIApplication.shared.keyWindow?.addSubview(selectAllView)
//        selectAllView.snp.makeConstraints { make in
//            make.left.bottom.right.equalToSuperview()
//            make.height.equalTo(103.S)
//        }
//    }
//
//    // 隐藏选中所有
//    private func hideSelectAllView(){
//        selectAllView.removeFromSuperview()
//    }
//
//    // 判断是否选中所有
//    private func isSelectedAll() -> Bool {
//        if dataSource.count == 0 {
//            return false
//        }
//        for data in dataSource {
//            if !data.isSelected {
//                return false
//            }
//        }
//        return true
//    }
//
//    // 判断是否有选中的消息
//    private func selectedIsNotEmpty() -> Bool {
//        for data in dataSource {
//            if data.isSelected {
//                return true
//            }
//        }
//        return false
//    }
//
//    // 标记为已读
//    private func markAsRead(msgIds:[UInt64]){
//        AgoraIotManager.shared.sdk?.alarmMgr.markSys(alarmIdList: msgIds, result: {[weak self] ec, msg in
//            DispatchQueue.main.async {
//                self?.unreadValueChanged?()
//            }
//        })
//    }
//
//    // 获取消息列表
//    private func loadMsgList(isLoadMore:Bool = false) {
//        let sdk = AgoraIotManager.shared.sdk
//        guard let alarmMgr = sdk?.alarmMgr else{ return }
//        SVProgressHUD.show()
//        let query:IAlarmMgr.SysQueryParam = IAlarmMgr.SysQueryParam()
//        query.status = 0
//        if isLoadMore {
//            currentPage += 1
//        }else{
//            currentPage = 1
//        }
//        query.currentPage = currentPage
//        query.pageSize = 10
//        alarmMgr.querySysByParam(queryParam: query) { [weak self] ec, msg, alarms in
//            SVProgressHUD.dismiss()
//            self?.tableView.mj_header?.endRefreshing()
//            self?.tableView.mj_footer?.endRefreshing()
//            if(ec != ErrCode.XOK){
//                debugPrint("查询告警记录失败")
//                SVProgressHUD.showError(withStatus: "查询告警记录失败")
//                SVProgressHUD.dismiss(withDelay: 2)
//                return
//            }
//            guard let alarmList = alarms else {
//                SVProgressHUD.dismiss()
//                return
//            }
//            if alarmList.count < 10 {
//                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
//            }
//            if !isLoadMore {
//                self?.dataSource.removeAll()
//            }
//            for alarm:IotAlarm in alarmList {
//                let data = MsgData(alarm: alarm)
//                self?.dataSource.append(data)
//            }
//
//            self?.sectionHeaderView.editButton.isEnabled = self?.dataSource.count ?? 0 > 0
//
//            self?.tableView.reloadData()
//        }
//    }
//
//    // 删除消息
//    private func deleteMessages(_ id: UInt64? = nil ){
//        var msgidList = [UInt64]()
//        if id != nil {
//            msgidList.append(id!)
//        }else{
//            for data in dataSource {
//                if data.isSelected {
//                    msgidList.append(data.alarm.alertMessageId)
//                }
//            }
//        }
//        let sdk = AgoraIotManager.shared.sdk
//        guard let alarmMgr = sdk?.alarmMgr else{ return }
//        alarmMgr.delete(alarmIdList: msgidList) {[weak self] ec, err in
//            if(ec != ErrCode.XOK){
//                SVProgressHUD.showError(withStatus: "删除警告失败\(err)")
//                SVProgressHUD.dismiss(withDelay: 2)
//                return
//            }
//            SVProgressHUD.showSuccess(withStatus: "删除成功")
//            self?.loadMsgList()
//        }
//    }
//
//
//}
//
//extension NotifyMessageVC: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 108
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource.count
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return sectionHeaderView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 65
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let data = self.dataSource[indexPath.row]
//        let cell:NotifyMsgCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! NotifyMsgCell
//        cell.selectionStyle = .none
//        cell.setMsgData(data)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let msg = self.dataSource[indexPath.row]
//        if msg.canEdit {
//            msg.isSelected = !msg.isSelected
//            self.selectAllView.selectedbutton.isSelected = isSelectedAll()
//            tableView.reloadRows(at: [indexPath], with: .none)
//        }else{
//            if msg.alarm.status == 0 {
//                markAsRead(msgIds: [msg.alarm.alertMessageId])
//                msg.alarm.status = 1
//            }
//        }
//    }
//}
//
//extension NotifyMessageVC: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
//
//    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
//        let customView = UIView()
//        let titleLabel = UILabel()
//        titleLabel.text = "暂无消息"
//        titleLabel.textColor = .white
//        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        customView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalTo(customView.snp.centerY).offset(-20.S)
//        }
//
//        customView.snp.makeConstraints { make in
//            make.height.equalTo(200.S)
//        }
//        return customView
//    }
//}
//
//extension NotifyMessageVC: JXSegmentedListContainerViewListDelegate {
//    func listView() -> UIView {
//        return view
//    }
//}
//
//
