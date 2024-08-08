//
//  HomePageMainVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit
import SnapKit
import DZNEmptyDataSet
import AgoraIotLink
import Alamofire
import MJRefresh
import SVProgressHUD
import SwiftDate
import CryptoKit

// 网络监测通知
let cNetChangeNotify = "cNetChangeNotify"
private let kCellID = "HomeMainDeviceCell"

class HomePageMainVC: AGBaseVC {
    private(set) var fileReceiveDataList : [String:Data] =  [String:Data]()
    private(set) var doorbellVM = DoorBellManager.shared
    private(set) var cellArray = [HomeMainDeviceCell]()
    private(set) var fullVC : CallFullScreemVC?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏导航栏
        navigationController?.navigationBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 显示导航栏
        navigationController?.navigationBar.isHidden = false
    }
    
    lazy var topView:MainTopView = {
        let topView = MainTopView()
        topView.clickAddButtonAction = {[weak self] in
            self?.addDevice()
        }
        topView.clickDeleteButtonAction = {[weak self] in
            self?.beginEditList()
        }
        return topView
    }()

    lazy var tipsView:NetworkTipsView = {
        let tips = NetworkTipsView()
        return tips
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 240
        return tableView
    }()
    
    lazy var selectAllView: DoorbellSelectAllSimpleView = {
        let selectAllView = DoorbellSelectAllSimpleView()
        selectAllView.clickSelectedButtonAction = { [weak self] button in
            button.isSelected = !button.isSelected
            if self == nil { return }
            for cell in self!.cellArray {
                let tempDevice = cell.device
                tempDevice?.isSelected = button.isSelected
                cell.device = tempDevice
            }
        }
        selectAllView.clickDeleteButtonAction = { [weak self] in
            self?.didClickDeleteButton()
        }
        selectAllView.clickCancelButtonAction = { [weak self] in
            self?.endEditMsgList()
        }
        return selectAllView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        cheackAppIdIsExist()
        addObserver()
        setUpUI()
        // 监听网络状态
        startListeningNetStatus()
        
    }
 
    func loadData(){
        cellArray.removeAll()
        let tempArray = TDUserInforManager.shared.readMarkPeerNodeId()
        // 初始化时创建单元格并保存在数组中
        for i in 0..<tempArray.count {
            let mModel = MDeviceModel()
            mModel.peerNodeId = tempArray[i]
            
            let cell = HomeMainDeviceCell(style: .default, reuseIdentifier: nil)
            cell.tag = 10000 + i
            cell.device = mModel
            cellArray.append(cell)
        }
    }
    
    // 添加监听
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLoginSuccess), name: Notification.Name(cUserLoginSuccessNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLogoutSuccess), name: Notification.Name(cUserLoginOutNotify), object: nil)
    }
    
    @objc private func receiveLoginSuccess(){//登陆成功
        loadData()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for cell in self.cellArray{
                self.callDevice(tag: cell.tag)
            }
        }
    }
    
    @objc private func receiveLogoutSuccess(){//退出登陆成功
        for cell in cellArray {
            if  cell.device?.connectObj != nil{
                handUpDevice((cell.device?.connectObj)!)
            }
        }
    }
    
    // 设置UI
    private func setUpUI(){
        view.addSubview(topView)
        view.addSubview(tipsView)
        view.addSubview(tableView)
        topView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view)
            make.height.equalTo(110)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tipsView.snp.bottom)
        }
    }
    
    // 监听网络状态
    private func startListeningNetStatus(){
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { [weak self] status in
            let height = status == .notReachable ? 44 : 0
            self?.tipsView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(self?.topView.snp.bottom ?? 0)
                make.height.equalTo(height)
            }
            self?.tipsView.isHidden = status != .notReachable
            
            var netType = "none"
            switch status {
                case .notReachable, .unknown:
                    netType = "none"
                case .reachable(.ethernetOrWiFi):
                    netType = "wifi"
                case .reachable(.cellular):
                    netType = "cellular"
             }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cNetChangeNotify), object: nil, userInfo: ["netType":netType])
        })
    }
}


extension HomePageMainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 直接从数组中获取对应的单元格对象
        let cell = cellArray[indexPath.row]
        cell.dailBlock = { tag in
            self.handelCallAction(tag: tag)
        }
        cell.fullScreenBlock = { tag in
            self.goToFullVC(tag: tag)
        }
        cell.aVStreamBlock = { tag in
            self.goToStreamVC(tag: tag)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = cellArray[indexPath.row]
        if cell.device?.canEdit == true {
            guard let tempDevice = cell.device  else { return }
            tempDevice.isSelected = !tempDevice.isSelected
            cell.device = tempDevice
            self.selectAllView.selectedbutton.isSelected = isSelectedAll()
        }
    }
}

extension HomePageMainVC {
    func cheackAppIdIsExist(){
        //检查用户的masterAppId 是否为空
        if TDUserInforManager.shared.checkIsHaveMasterAppId() == true{
            checkLoginState()
        }else{
            showEditAppIdAlert()
        }
    }
    
    //检查用户登录状态
   private func checkLoginState(){
       TDUserInforManager.shared.checkLoginState()
   }
    
    func showEditAppIdAlert(){
        AGConfirmEditMultiAlertVC.showTitleTop("Please enter project information".L, editText: "Please enter project information".L) {[weak self] appId,key,secret,region in
            TDUserInforManager.shared.saveUserMasterAppId(appId)
            TDUserInforManager.shared.saveUserCustomKeyAndSecret(key, secret)
            TDUserInforManager.shared.saveUserRegion(region)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.checkLoginState()
            }
            print("-----\(appId)")
        }
    }
    
    func handelReveiveData(_ connectObj: AgoraIotLink.IConnectionObj?,_ subData: Data){
        let connectInfor = connectObj?.getInfo()
        guard  let peerId = connectInfor?.mPeerNodeId, let tempData = fileReceiveDataList[peerId] else { return }
        fileReceiveDataList[peerId]?.append(subData)
        log.i("receive tempData.count:\(tempData.count) peerId:\(peerId) count:\(fileReceiveDataList.count)")
    }
    
    func calculateMD5(for data: Data) -> String {
        let md5 = Insecure.MD5.hash(data: data)
        return md5.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func getCellWithTag(tag:Int) -> HomeMainDeviceCell {
        if let cell = tableView.viewWithTag(tag) as? HomeMainDeviceCell{
            return cell
        }
        debugPrint("未找到对应cell：\(tag)")
        return HomeMainDeviceCell()
    }
        
    func getCellWithConnectObj(_ connectObj : IConnectionObj)->HomeMainDeviceCell?{
        for cell in cellArray {
            if cell.device?.connectObj === connectObj{
                return cell
            }
        }
        return nil
    }
}

//*********************----------链接创建和断开等------------*********************
extension HomePageMainVC {
    func goToStreamVC(tag : Int){
        let cell = getCellWithTag(tag: tag)
        guard let device = cell.device else {
            return
        }
        
        let sessionInfor = device.connectObj?.getInfo()
        if  sessionInfor?.mState != .connected{//未在通话中，返回
            AGToolHUD.showInfo(info: "Please enter the streaming page after connecting the device".L)
            return
        }
        
        let avStreamVC = AVStreamVC()
        avStreamVC.connectObj = device.connectObj
        avStreamVC.AVStreamVCBlock = { mainStreamModel in
            let streamStatus = device.connectObj?.getStreamStatus(peerStreamId: .BROADCAST_STREAM_1)
            let connInfor = device.connectObj?.getInfo()
            if streamStatus?.mSubscribed == true {
                cell.configPeerView(true)
            }else{
                cell.handelStateNone()
                if connInfor?.mState == .connected {
                    cell.handelCallTipType(.connected)
                }else{
                    cell.handelCallTipType(.none)
                }
            }
            cell.handelMuteAudioStateText(streamStatus?.mAudioMute ?? false)
            
        }
        self.navigationController?.pushViewController(avStreamVC, animated: false)
        
    }
    
    func goToFullVC(tag : Int){
        
        let cell = getCellWithTag(tag: tag)
        guard let device = cell.device else {
            return
        }
        
        guard let objInfor = device.connectObj?.getInfo(),objInfor.mState == .connected else {//未在通话中，返回
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "Please enter the full-screen page after previewing the video normally".L)
            return
        }
        fullVC = CallFullScreemVC()
        guard let tempFullVC = fullVC else { return }
        tempFullVC.connectObj = device.connectObj
        tempFullVC.CallFullScreemBlock = {
            cell.configPeerView(true)
            self.fullVC = nil
        }
        self.navigationController?.pushViewController(tempFullVC, animated: false)
    }
    func handelCallAction(tag : Int){
        
        let alert = UIAlertController(title: "Encrypt or not?".L, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "encry".L, style: .default, handler: {[weak self]  _ in
            print("加密")
            self?.callDevice(tag: tag,mEncrypt: true)
        }))
        alert.addAction(UIAlertAction(title: "noEncry".L, style: .default, handler: { [weak self] _ in
            print("不加密")
            self?.callDevice(tag:tag, mEncrypt:false)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //---------设备控制相关-----------
    //呼叫设备
    func callDevice(tag : Int, mEncrypt: Bool = true){
        
        let cell = getCellWithTag(tag: tag)
        cell.handelCallTipType(.loading)
        cell.handelCallStateText(true)
        guard let device = cell.device else { return }
        log.i("------callDevice------ peerNodeId:\(device.peerNodeId) tag:\(tag)")
        
        doorbellVM.registerConnectMgrListener(listener: self)
        let connectParam = ConnectCreateParam(mPeerNodeId: device.peerNodeId,mEncrypt: mEncrypt,mAttachMsg: "")
        let connectObj = doorbellVM.connectDevice(connectParam)
        guard let connectObj = connectObj  else {
            log.i("callDevice result connectObj is nil")
            return
        }
        
        device.connectObj = connectObj
        cell.device = device
        doorbellVM.registerConnectObjListener(connectObj: connectObj, listener: self)
        

//        iotsdk.connectionMgr.registerListener(connectionMgrListener:self)
//        let peerNodeId = "<DEVICE_NODE_ID>"
//        let connectParam = ConnectCreateParam(mPeerNodeId: peerNodeId,mEncrypt: true,mAttachMsg: "")
//        let connectObj = iotsdk.connectionMgr.connectionCreate(connectParam: connectParam)
//        guard let connectObj = connectObj  else {
//            print("connectObj is nil")
//            return
//        }
//        connectObj.registerListener(callBackListener: self)
//
//        // 使用 IConnectionObj 对象实例来断开相应的连接
//        let errCode = connectMgr.connectionDestroy(connectObj: connectObj)
        
//        iotsdk.release()
    }
    
    //挂断设备
    func handUpDevice(_ connectObj : IConnectionObj){
        doorbellVM.hangupDevice(connectObj) { success, msg in
            debugPrint("调用挂断：\(msg)")
            AGToolHUD.showInfo(info: "Hang up successfully".L)
        }
    }
}

//*********************----------链接操作的回调接口------------*********************
extension HomePageMainVC: IConnectionMgrListener {
    func onConnectionCreateDone(connectObj: AgoraIotLink.IConnectionObj?, errCode: Int) {
        if errCode == ErrCode.XOK {
            let cell = getCellWithConnectObj(connectObj!)
            cell?.handelCallTipType(.connected)
        }else{
            debugPrint("连接错误")
            let cell = getCellWithConnectObj(connectObj!)
            cell?.handelCallTipType(.loadFail)
            cell?.handelCallStateText(false)
            cell?.handelStateNone()
            AGToolHUD.showInfo(info: "Connection timed out, please check device status".L)
        }
    }
    
    func onPeerDisconnected(connectObj: AgoraIotLink.IConnectionObj?, errCode: Int) {
        log.i("handelCallAct:onDisconnected:连接断开")
        let cell = getCellWithConnectObj(connectObj!)
        cell?.device?.connectObj = nil
        cell?.handelCallTipType(.none)
        cell?.handelCallStateText(false)
        cell?.handelStateNone()
        
    }
    
    func onPeerAnswerOrReject(connectObj: AgoraIotLink.IConnectionObj?, answer: Bool) {
//        if !answer {
//            // 对端拒绝后，可以主动销毁本次链接，
//            // APP也可以不调用主动销毁方法，过一会对端也会断开，然后APP端也会得到通知并且自动销毁链接
//            connectMgr.connectionDestroy(connectObj: connectObj)
//        }
        let tips = answer == true ? "answer":"reject"
        guard let connectInfor = connectObj?.getInfo() else { return }
        AGToolHUD.showInfo(info: "peer \(connectInfor.mPeerNodeId):\(tips)")
    }
}

//*********************----------链接对象操作的回调接口------------*********************
extension HomePageMainVC:  ICallbackListener {
    func onFileTransError(connectObj: AgoraIotLink.IConnectionObj?, errCode: Int) {
        if errCode == ErrCode.XERR_NETWORK {
            AGToolHUD.showInfo(info: "Data transfer failed, please try again".L)
            fullVC?.isTransferEnd = true
        }
    }
    
    func onFileTransRecvStart(connectObj: AgoraIotLink.IConnectionObj?, startDescrption: Data) {
        log.i("收到开始接收数据回调：具体协议数据在startDescrption参数中")
        let subData = startDescrption.subdata(in: 14..<startDescrption.count)
        guard let myString = String(data: subData, encoding: .utf8) else {
            return
        }
        let connectInfor = connectObj?.getInfo()
        guard  let peerId = connectInfor?.mPeerNodeId else { return }
        fileReceiveDataList[peerId] = Data()
        fullVC?.transferCmdString = "fileStart: " + myString
    }
    
    func onFileTransRecvData(connectObj: AgoraIotLink.IConnectionObj?, recvedData: Data) {
        log.i("接收具体数据:\(recvedData.count)")
        let subData = recvedData.subdata(in: 14..<recvedData.count)
        handelReveiveData(connectObj,subData)
    }
    
    func onFileTransRecvDone(connectObj: AgoraIotLink.IConnectionObj?, transferEnd: Bool, doneDescrption: Data) {
        log.i("收到结束接收数据回调：具体协议数据在doneDescrption参数中:\(transferEnd)")
        let subData = doneDescrption.subdata(in: 14..<doneDescrption.count)
        guard let doneDescrptionString = String(data: subData, encoding: .utf8) else {
            return
        }
        let connectInfor = connectObj?.getInfo()
        guard  let peerId = connectInfor?.mPeerNodeId,let tempData = fileReceiveDataList[peerId] else { return }
        let realMd5String = calculateMD5(for: tempData)
        fileReceiveDataList[peerId] = nil
        
        var isCorrect = "false"
        if doneDescrptionString.contains(realMd5String) { isCorrect = "true" }
        fullVC?.transferCmdString = "fileEnd: " + doneDescrptionString + "(\(isCorrect))"
        if transferEnd == true {
            fullVC?.isTransferEnd = transferEnd
        }
    }
    
    func onStreamFirstFrame(connectObj: AgoraIotLink.IConnectionObj?, subStreamId: AgoraIotLink.StreamId, videoWidth: Int, videoHeight: Int) {
        //首帧回调
        log.i("首帧回调：onPreviewFirstFrame")
        let cell = getCellWithConnectObj(connectObj!)
        if subStreamId == .BROADCAST_STREAM_1 {
            cell?.handelCallTipType(.playing)
            cell?.handelPreviewBtnStateText(true)
        }
    }
    
    func onStreamVideoFrame(connectObj: AgoraIotLink.IConnectionObj?, subStreamId: AgoraIotLink.StreamId, pixelBuffer: CVPixelBuffer, videoWidth: Int, videoHeight: Int) {
        //视频帧回调，用于实现自渲染用户
    }
    
    func onStreamError(connectObj: AgoraIotLink.IConnectionObj?, subStreamId: AgoraIotLink.StreamId, errCode: Int) {
        //要通知cell 改变状态
        log.i("订阅预览时错误回调：onPreviewError errCode:\(errCode)")
        var tempTips = ""
        if errCode == ErrCode.XERR_RTMMGR_MSG_PEER_UNREACHABLE{
            tempTips = "The peer is offline and the message is unreachable".L
            AGToolHUD.showInfo(info: "Preview error，errCode：\(errCode) \(tempTips)")
        }
        if subStreamId == .BROADCAST_STREAM_1 {
            let cell = getCellWithConnectObj(connectObj!)
            cell?.handelPreviewBtnStateText(false)
        }
        
    }
    
    func onMessageSendDone(connectObj: AgoraIotLink.IConnectionObj?, errCode: Int, signalId: UInt32) {
        //TODO:消息发送完成
    }
    
    func onMessageRecved(connectObj: AgoraIotLink.IConnectionObj?, recvedSignalData: Data) {
        //接收到对端的消息事件
        guard let recvedSignalDataString = String(data: recvedSignalData, encoding: .utf8) else {
            return
        }
        AGToolHUD.showInfo(info: "Received the news".L + ":\(recvedSignalDataString)")
    }
}


/*
*********************----------设备管理------------*********************
*********************----------设备管理------------*********************
*********************----------设备管理------------*********************
 */
extension HomePageMainVC{ //设备删除，添加
    // 添加设备
    @objc private func addDevice(){
        guard isDeviceEditing() == false else {
            AGToolHUD.showInfo(info: "Please complete the deletion operation before adding".L)
            return
        }
        AGEditAlertVC.showTitleTop("addDevices".L, editText: "please enter nodeId".L,alertType:.modifyDeviceName ) {[weak self] nodeId in
            self?.addDeviceToArray(nodeId)
        } cancelAction: {}
    }
    
    func addDeviceToArray(_ nodeId : String){
        guard isHaveDevice(nodeId) == false else{
            AGToolHUD.showInfo(info: "Device already exists".L)
            return
        }
        TDUserInforManager.shared.savePeerNodeId(nodeId)
        let mModel = MDeviceModel()
        mModel.peerNodeId = nodeId
        
        let cell = HomeMainDeviceCell(style: .default, reuseIdentifier: nil)
        cell.device = mModel
        cell.tag = 10000 + cellArray.count
        cellArray.append(cell)
        
        tableView.reloadData()
    }
    
    func isHaveDevice(_ nodeId : String)->Bool{
        for cell in cellArray{
            if cell.device?.peerNodeId == nodeId{
                return true
            }
        }
        return false
    }
    
    // 开始编辑
    private func beginEditList() {

        for cell in cellArray {
            let tempDevice = cell.device
            tempDevice?.canEdit = true
            cell.device = tempDevice
        }
        showSelectAllView()
    }
    
    // 结束编辑
    private func endEditMsgList() {
        for cell in cellArray {
            let tempDevice = cell.device
            tempDevice?.canEdit = false
            cell.device = tempDevice
        }
        hideSelectAllView()
    }
    
    // 显示选中所有
    private func showSelectAllView(){
        if cellArray.count == 0 {
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
    
    private func didClickDeleteButton()  {
        // 选中的数量大于0
        if selectedIsNotEmpty() {
            selectAllView.disabled = true
            AGAlertViewController.showTitle("tips".L, message: "Are you sure you want to delete the selected device?".L, cancelTitle: "cancel".L, commitTitle: "confirm".L) {[weak self] in
                self?.selectAllView.disabled = false
                self?.endEditMsgList()
                self?.deleteMessages()
            } cancelAction: { [weak self] in
                self?.selectAllView.disabled = false
            }
        }else{
            SVProgressHUD.showInfo(withStatus: "Please select a device to delete".L)
            SVProgressHUD.dismiss(withDelay: 2)
        }
    }
    
    // 删除
    private func deleteMessages(_ id: UInt64? = nil ){
        
        var newCellList = [HomeMainDeviceCell]()
        var peerNodeIdList = [String]()
        for cell in cellArray {
            if cell.device?.isSelected == false {
                newCellList.append(cell)
                peerNodeIdList.append((cell.device?.peerNodeId)!)
            }else{
                if cell.device?.connectObj != nil{//如果选中的设备正在通话中，则先挂断
                    print("---delete calling device---")
                    handUpDevice((cell.device?.connectObj)!)
                }
            }
        }
        TDUserInforManager.shared.deletePeerNodeIdArray(peerNodeIdList)
        cellArray.removeAll()
        cellArray.append(contentsOf: newCellList)
        tableView.reloadData()
    }
    
    
    // 判断是否选中所有
    private func isSelectedAll() -> Bool {
        if cellArray.count == 0 {
            return false
        }
        for cell in cellArray {
            if cell.device?.isSelected == false {
                return false
            }
        }
        return true
    }
    
    // 判断是否有选中
    private func selectedIsNotEmpty() -> Bool {
        for cell in cellArray {
            if cell.device?.isSelected == true {
                return true
            }
        }
        return false
    }
    
    // 判断是否处于删除消息的状态
    private func isDeviceEditing() -> Bool {
        for cell in cellArray {
            if cell.device?.canEdit == true {
                return true
            }
        }
        return false
    }
    
    func isFullScreemVisible()->Bool{
        guard let topViewController = UIApplication.topViewController() else { return false}
        guard topViewController.isKind(of: CallFullScreemVC.self) == true else { return false}
        return true
    }
}
                                

extension HomePageMainVC: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let customView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "noDevices".L
        titleLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        customView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(customView.snp.centerY).offset(-20)
        }
        
        let button = UIButton(type: .custom)
        button.setTitle("addDevices".L, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.addTarget(self, action: #selector(addDevice), for: .touchUpInside)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(hexRGB: 0x1a1a1a)
        customView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(customView.snp.centerY).offset(20)
            make.width.equalTo(140)
            make.height.equalTo(56)
        }
        
        customView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        return customView
    }
}
