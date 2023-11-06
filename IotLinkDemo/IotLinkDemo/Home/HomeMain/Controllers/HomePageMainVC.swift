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


// 网络监测通知
let cNetChangeNotify = "cNetChangeNotify"
//添加新设备通知（蓝牙配网）
let cAddDeviceSuccessNotify = "cAddDeviceSuccessNotify"

private let kCellID = "HomeMainDeviceCell"

var sdk:IAgoraIotAppSdk?{get{return iotsdk}}



class HomePageMainVC: AGBaseVC {
    
    fileprivate var  doorbellVM = DoorBellManager.shared
    var mDevicesArray = [MDeviceModel]()
    var members:Int = 0
    
    // 告警消息时间
    var alarmDates = [String: UInt64]()

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
        tableView.register(HomeMainDeviceCell.self, forCellReuseIdentifier: kCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var selectAllView: DoorbellSelectAllSimpleView = {
        let selectAllView = DoorbellSelectAllSimpleView()
        selectAllView.clickSelectedButtonAction = { [weak self] button in
            button.isSelected = !button.isSelected
            if self == nil { return }
            for data in self!.mDevicesArray {
                data.isSelected = button.isSelected
            }
            self!.tableView.reloadData()
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
        // 监听收到的rtm消息
        setMsgListener()
        
    }
    
    func cheackAppIdIsExist(){
        //检查用户的masterAppId 是否为空
        if TDUserInforManager.shared.checkIsHaveMasterAppId() == true{
            initAgoraIot()
            registerIncomCall()
            checkLoginState()
        }else{
            showEditAppIdAlert()
        }
    }
    
    func showEditAppIdAlert(){
        AGConfirmEditAlertVC.showTitleTop("请输入AppId", editText: "请输入AppId") {[weak self] appId in
            TDUserInforManager.shared.saveUserMasterAppId(appId)
            self?.initAgoraIot()
            self?.registerIncomCall()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.checkLoginState()
            }
            print("-----\(appId)")
        }
    }
    
    func initAgoraIot(){
        log.i("AgoraIotManager app initialize()")
        
        
//        let param:InitParam = InitParam()
//        param.mAppId = TDUserInforManager.shared.curMasterAppId
//        param.mServerUrl = AgoraIotConfig.slaveServerUrl
//        let ret = iotsdk.initialize(initParam: param,OnSdkStateListener:{ [weak self] sdkState, reason in
//            print("OnSdkStateListener:\(sdkState)\(reason)")
//        }, onSignalingStateChanged:{ isReady in
//            print("onSignalingStateChanged:\(isReady)")
//        })
        
        
        
        let param:InitParam = InitParam()
        param.mAppId = TDUserInforManager.shared.curMasterAppId
        param.mServerUrl = AgoraIotConfig.slaveServerUrl
                                            
        let ret = iotsdk.initialize(initParam: param,OnSdkStateListener:{ [weak self] sdkState, reason in
            self?.handelCommonErrorCode(sdkState,reason)
        }, onSignalingStateChanged:{ isReady in
            debugPrint("onSignalingStateChanged:\(isReady)")
        })
        if(ret != ErrCode.XOK){
            log.e("initialize failed")
        }
        
    }
    
    //处理通用错误码
    func handelCommonErrorCode(_ sdkState : SdkState, _ reason : StateChangeReason) {
        
        if sdkState == .running {
            debugPrint("mqtt runing")
            if TDUserInforManager.shared.isLogin == true {
                AGToolHUD.showInfo(info: "网络重连成功")
            }
            
        }else if sdkState == .initialized {
            
            if reason == .abort{
                debugPrint("mqtt 连接断开 msg:\(reason)")
                AGToolHUD.disMiss()
                AGToolHUD.showInfo(info: "账号被抢占，需要重新登录!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    guard TDUserInforManager.shared.isLogin == true else { return }
                    TDUserInforManager.shared.isLogin = false
                    TDUserInforManager.shared.userSignOut()
                    DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
                }
            }
            
        }else if sdkState == .reconnecting{
            
            AGToolHUD.showInfo(info: "正在网络重连中......")
            
        }
        
    }
    
    func loadData(){
        mDevicesArray.removeAll()
        let tempArray = TDUserInforManager.shared.readMarkPeerNodeId()
        for item in tempArray{
            let mModel = MDeviceModel()
            mModel.peerNodeId = item
            mDevicesArray.append(mModel)
        }
        
//        for i in 0...5{
//            let mModel = MDeviceModel()
//            if i == 0 {
//                mModel.peerNodeId = "01GTKG1X7AEZWY7ACB7N2EV7C9"
//            }else{
//                mModel.peerNodeId = "11111111"
//            }
//
//            mDevicesArray.append(mModel)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏导航栏
        navigationController?.navigationBar.isHidden = true
//        if(AgoraIotLink.iotsdk.callkitMgr.getNetworkStatus().isBusy){
//            AgoraIotLink.iotsdk.callkitMgr.mutePeerAudio(sessionId: "", mute: false, result: {ec,msg in})
//        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 显示导航栏
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        if(AgoraIotLink.iotsdk.callkitMgr.getNetworkStatus().isBusy){
//            AgoraIotLink.iotsdk.callkitMgr.mutePeerAudio(sessionId: "", mute: true, result: {ec,msg in
//                print("\(ec)---\(msg)")
//            })
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //检查用户登录状态
   private func checkLoginState(){
       TDUserInforManager.shared.checkLoginState()
   }
    
    // 添加监听
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLoginSuccess), name: Notification.Name(cUserLoginSuccessNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLogoutSuccess), name: Notification.Name(cUserLoginOutNotify), object: nil)
    }
    
    @objc private func receiveLoginSuccess(){//登陆成功
        loadData()
        tableView.reloadData()
    }
    
    @objc private func receiveLogoutSuccess(){//退出登陆成功
        for data in mDevicesArray {
            if data.sessionId != ""{
                handUpDevice(data.sessionId)
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
        return 230
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDevicesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = mDevicesArray[indexPath.row]
        let cell:HomeMainDeviceCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! HomeMainDeviceCell
        cell.indexPath = indexPath
        cell.device = device
        cell.dailBlock = { index in
            self.callDevice(indexPath: index)
        }
        cell.fullScreenBlock = { index in
            self.goToFullVC(indexPath:indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = mDevicesArray[indexPath.row]
        if device.canEdit {
            device.isSelected = !device.isSelected
            self.selectAllView.selectedbutton.isSelected = isSelectedAll()
            tableView.reloadData()
        }
    }
}


extension HomePageMainVC { //呼叫
    
    func goToFullVC(indexPath : IndexPath){
        
//        let resourcePath = Bundle.main.path(forResource: "client-keycert", ofType: "p12")
        
//        let resourcePath = Bundle.main.path(forResource: "cacert", ofType: "crt")
//
//        guard let filePath = resourcePath, let p12Data = NSData(contentsOfFile: filePath) else {
//            print("Failed to open the certificate file: client-keycert.p12")
//            return
//        }
//
//        return
        
        let device = mDevicesArray[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! HomeMainDeviceCell
        
        let sessionInfor = sdk?.callkitMgr.getSessionInfo(sessionId: device.sessionId)
        if device.sessionId == "" ||  sessionInfor?.mState != .onCall{//未在通话中，返回
            return
        }
        
        let fullVC = CallFullScreemVC()
        fullVC.sessionId = device.sessionId
        fullVC.CallFullScreemBlock = { sessionId in
            cell.configPeerView(sessionId)
        }
        self.navigationController?.pushViewController(fullVC, animated: false)
    }
    
    //---------设备控制相关-----------
    //呼叫设备
    func callDevice(indexPath : IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as? HomeMainDeviceCell
        let device = mDevicesArray[indexPath.row]
        
        log.i("wakeup device \(device.peerNodeId)")
        
        doorbellVM.wakeupDevice(device) {[weak self] code, sessionId,peerNodeId in
            cell?.handelCallStateText(true)
            device.sessionId = sessionId
            cell?.tag = (self?.getTagFromSessionId(sessionId))!
            
            if(code == ErrCode.XOK){
                debugPrint("呼叫成功")
                
            }else if(code == ErrCode.XERR_CALLKIT_LOCAL_BUSY){
                
                debugPrint("呼叫失败,本地忙")
                cell?.handelCallStateText(false)
                cell?.handelCallTipType(.none)
                
            }else if(code == ErrCode.XERR_NETWORK){
                
                debugPrint("呼叫失败,网络断开")
                cell?.handelCallStateText(false)
                cell?.handelCallTipType(.none)
                AGToolHUD.showInfo(info: "呼叫失败,网络已断开")
                
            }else{
                
                debugPrint("呼叫失败")
                cell?.handelCallStateText(false)
                cell?.handelCallTipType(.none)
                AGToolHUD.showInfo(info: "呼叫失败,请检查设备状态")
                
            }
            
        } _: { [weak self] sessionId, act in
            self?.handelCallAct(sessionId,act)
        }_: { [weak self] members,sessionId in
            self?.handelUserMembers(members,sessionId)
        }
        
    }
    
    func setMsgListener(){
//        sdk?.callkitMgr.onReceivedCommand(receivedListener: { sessionId, cmd in
//            debugPrint("onReceivedCommand:sessionId:\(sessionId),cmd:\(cmd)")
//            AGToolHUD.showInfo(info: cmd)
//        })
    }
    
    func handelUserMembers(_ members:Int,_ sessionId:String){
        let viewTag = getTagFromSessionId(sessionId)
        let cell = getCellWithTag(tag: viewTag)
        cell.handelUserMembers(members)
    }
    
    //处理呼叫返回
    func handelCallAct(_ sessionId:String,_ act:ActionAck){
        
        if(act == .RemoteHangup){
            //设备休眠时会走此回调
            debugPrint("设备挂断")
            //如果设备挂断，发送通知停止录屏
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRecordVideoStateUpdated), object: nil, userInfo: nil)
            //对端挂断，如果为全屏状态，则通知全屏退出
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteHangupNotify), object: nil)
            AGToolHUD.showInfo(info: "对端挂断")
        }
        else if(act == .LocalHangup){
            debugPrint("本地挂断")
            let cell = getCurrentCellWithTag(sessionId)
            let tempModel = getCurrentDataModel(indexPath: cell.indexPath ?? IndexPath(row: 0, section: 0))
            tempModel.sessionId = ""
            cell.handelCallTipType(.none)
            cell.handelCallStateText(false)
            cell.handelStateNone()
        }
        else if(act == .RemoteAnswer){
            debugPrint("设备接听")
            handelUserMembers(1,sessionId)
        }
        else if(act == .RemoteVideoReady){
            
            debugPrint("获取到首帧")
            let cell = getCurrentCellWithTag(sessionId)
            cell.configPeerView(sessionId)
            cell.handelCallTipType(.playing)
            if isFullScreemVisible() == true{
                //首帧如果是详情页，则发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReceiveFirstVideoFrameNotify), object: nil, userInfo: nil)
            }
        }
        else if(act == .RemoteTimeout){
            debugPrint("接听超时")
            let cell = getCurrentCellWithTag(sessionId)
            cell.handelCallTipType(.loadFail)
            cell.handelCallStateText(false)
            AGToolHUD.showInfo(info: "对端接听超时,请检查设备状态")
        }
        else if(act == .UnknownAction){
            debugPrint("呼叫超时")
            let cell = getCurrentCellWithTag(sessionId)
            cell.handelCallTipType(.loadFail)
            cell.handelCallStateText(false)
            AGToolHUD.showInfo(info: "呼叫超时,请检查设备状态")
        }
        
    }
    
    //挂断设备
    func handUpDevice(_ sessionId : String){
        
        doorbellVM.hangupDevice(sessionId:sessionId) { success, msg in
            debugPrint("调用挂断：\(msg)")
            AGToolHUD.showInfo(info: "挂断成功")
        }
    }
    
    func getTagFromSessionId(_ sessionId : String)->Int{
        let strArray = sessionId.split(separator: "&")
        print(strArray)
        guard strArray.count > 0 else {
            return 1000
        }
        let tag = strArray[1]
        return Int(tag) ?? 0
    }
    
    func getCellWithTag(tag:Int) -> HomeMainDeviceCell {
        if let cell = tableView.viewWithTag(tag) as? HomeMainDeviceCell{
            return cell
        }
        debugPrint("未找到对应cell：\(tag)")
        return HomeMainDeviceCell()
    }
    
    func getCurrentCellWithTag(_ sessionId:String) -> HomeMainDeviceCell {
        let viewTag = getTagFromSessionId(sessionId)
        let cell = getCellWithTag(tag: viewTag)
        return cell
    }
    
    func getCurrentDataModel(indexPath : IndexPath)->MDeviceModel{
        
        if mDevicesArray.count == 0 {
            return MDeviceModel()
        }
        return mDevicesArray[indexPath.row]
    }
}

extension HomePageMainVC{ //来电
    
    func registerIncomCall(){
        
        
        
        AgoraIotSdk.iotsdk.callkitMgr.register(incoming: { sessionId,peerNodeId,action  in
            debugPrint("incoming:\(sessionId)\(peerNodeId)\(action.rawValue)")
        },memberState:{ s,a,sessionId in
            log.i("memberState:\(DoorBellManager.shared.members):\(s.rawValue) \(a)\(sessionId)")
        })
        
        
        
        
        sdk?.callkitMgr.register(incoming: {[weak self] sessionId,peerNodeId,callin  in
            debugPrint("---来电呼叫---\(callin.rawValue)")
            if (callin == .CallIncoming) {
                
                iotsdk.callkitMgr.muteLocalAudio(sessionId: "", mute: true) { ec, msg in}
                self?.receiveCall(sessionId,peerNodeId)
                
            }else if(callin == .RemoteHangup){
                
                log.i("demo app remote hangup")
                //被动呼叫挂断发通知
                self?.members = 0
                self?.handUpDevice(sessionId)
                //通知移除接听弹框
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AGAlertSimpleViewHiddenNotify), object: nil, userInfo: nil)
                
            }else if(callin == .RemoteVideoReady){
                
                log.i("demo app RemoteVideoReady")
                let cell = self?.getCurrentCellWithTag(sessionId)
                cell?.configPeerView(sessionId)

            }else if(callin == .LocalHangup){
                
                let cell = self?.getCurrentCellWithTag(sessionId)
                let tempModel = self?.getCurrentDataModel(indexPath:cell?.indexPath ?? IndexPath(row: 0, section: 0))
                tempModel?.sessionId = ""
                cell?.handelCallTipType(.none)
                cell?.handelCallStateText(false)
                cell?.handelStateNone()
                
            }
        },memberState:{ s,a,sessionId in
            if(s == .Enter){self.members = self.members + a.count}
            if(s == .Leave){self.members = self.members - a.count}
            if(s == .Exist){self.members = 0}
            
            log.i("demo app income member count \(DoorBellManager.shared.members):\(s.rawValue) \(a)")
            self.handelUserMembers(self.members,sessionId)
            
        })
        
    }
    
    func receiveCall(_ sessionId : String,_ deviceId : String){
        var curIndex = 0
        var curDevice = MDeviceModel()
        for i in 0...mDevicesArray.count-1{
            let tempDevice = mDevicesArray[i]
            if tempDevice.peerNodeId == deviceId {
                tempDevice.sessionId =  sessionId
                curDevice = tempDevice
                curIndex = i
                log.i("来电设备找到了")
            }
        }
        let index = IndexPath(row: curIndex, section: 0)
        let cell = tableView.cellForRow(at: index as IndexPath) as! HomeMainDeviceCell
        cell.tag = getTagFromSessionId(sessionId)
        cell.device = curDevice
        cell.handelUserMembers(1)
        cell.handelCallStateText(true)
        showIsAcceptAlert(curIndex,curDevice)
        log.i("获取来电cell：\(cell)")
    }
    
    func showIsAcceptAlert(_ curIndex:Int, _ device : MDeviceModel){
        AGAlertSimpleViewController.showTitle("提示", message: "来电中，请选择是否接听?", cancelTitle: "挂断", commitTitle: "接听") {[weak self] in
            self?.handelIncoming(curIndex,1,device)
        } cancelAction: { [weak self] in
            self?.handelIncoming(curIndex,0,device)
        }
    }
    
    func handelIncoming(_ curIndex:Int,_ tag : Int, _ device : MDeviceModel){
        
        let index = IndexPath(row: curIndex, section: 0)
        let cell = tableView.cellForRow(at: index as IndexPath) as! HomeMainDeviceCell
        
        if tag ==  0{
            debugPrint("挂断")
            DoorBellManager.shared.hungUpAnswer(sessionId: device.sessionId) { success, msg in
                if success {
                    debugPrint("挂断成功")
                    cell.handelUserMembers(0)
                    AGToolHUD.showInfo(info: msg)
                }else{
                    AGToolHUD.showInfo(info: msg)
                }
            }
            
        }else if tag ==  1{
            debugPrint("接听")
            DoorBellManager.shared.callAnswer(sessionId: device.sessionId) { success, msg in
                if success {
                    debugPrint("接听成功")
                }
            }
        }
    }
    
}

extension HomePageMainVC{ //删除，添加
    
    // 添加设备
    @objc private func addDevice(){
        print("点击添加设备")
        guard isDeviceEditing() == false else {
            AGToolHUD.showInfo(info: "请将删除操作完成，再进行添加!")
            return
        }
        AGEditAlertVC.showTitleTop("addDevices".L, editText: "please enter nodeId".L,alertType:.modifyDeviceName ) {[weak self] nodeId in
            self?.addDeviceToArray(nodeId)
            print("-----\(nodeId)")
        } cancelAction: {
            
        }
    }
    
    func addDeviceToArray(_ nodeId : String){
        guard isHaveDevice(nodeId) == false else{
            AGToolHUD.showInfo(info: "设备已存在！")
            return
        }
        TDUserInforManager.shared.savePeerNodeId(nodeId)
        let mModel = MDeviceModel()
        mModel.peerNodeId = nodeId //01GTKG1X7AEZWY7ACB7N2EV7C9
        mDevicesArray.append(mModel)
        tableView.reloadData()
    }
    
    func isHaveDevice(_ nodeId : String)->Bool{
        for item in mDevicesArray{
            if item.peerNodeId == nodeId{
                return true
            }
        }
        return false
    }
    
    // 开始编辑
    private func beginEditList() {
        for data in mDevicesArray {
            data.canEdit = true
        }
        showSelectAllView()
        tableView.reloadData()
    }
    
    // 结束编辑
    private func endEditMsgList() {
        for data in mDevicesArray {
            data.canEdit = false
        }
        hideSelectAllView()
        tableView.reloadData()
    }
    
    // 显示选中所有
    private func showSelectAllView(){
        if mDevicesArray.count == 0 {
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
            AGAlertViewController.showTitle("提示", message: "确定要删除所选中的设备吗", cancelTitle: "取消", commitTitle: "确定") {[weak self] in
                self?.selectAllView.disabled = false
                self?.endEditMsgList()
                self?.deleteMessages()
            } cancelAction: { [weak self] in
                self?.selectAllView.disabled = false
            }
        }else{
            SVProgressHUD.showInfo(withStatus: "请选择要删除的设备")
            SVProgressHUD.dismiss(withDelay: 2)
        }
    }
    
    // 删除消息
    private func deleteMessages(_ id: UInt64? = nil ){
        
        var deviceList = [MDeviceModel]()
        var peerNodeIdList = [String]()
        for item in mDevicesArray {
            if item.isSelected == false {
                deviceList.append(item)
                peerNodeIdList.append(item.peerNodeId)
            }else{
                if item.sessionId != ""{//如果选中的设备正在通话中，则先挂断
                    print("---delete calling device---")
                    handUpDevice(item.sessionId)
                }
            }
        }
        TDUserInforManager.shared.deletePeerNodeIdArray(peerNodeIdList)
        mDevicesArray.removeAll()
        mDevicesArray.append(contentsOf: deviceList)
        tableView.reloadData()
    }
    
    
    // 判断是否选中所有
    private func isSelectedAll() -> Bool {
        if mDevicesArray.count == 0 {
            return false
        }
        for data in mDevicesArray {
            if !data.isSelected {
                return false
            }
        }
        return true
    }
    
    // 判断是否有选中
    private func selectedIsNotEmpty() -> Bool {
        for data in mDevicesArray {
            if data.isSelected {
                return true
            }
        }
        return false
    }
    
    // 判断是否处于删除消息的状态
    private func isDeviceEditing() -> Bool {
        for data in mDevicesArray {
            if data.canEdit {
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
        titleLabel.text = "暂无设备"
        titleLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        customView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(customView.snp.centerY).offset(-20)
        }
        
        let button = UIButton(type: .custom)
        button.setTitle("添加设备", for: .normal)
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
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
//        getDevicesArray()
    }
}
