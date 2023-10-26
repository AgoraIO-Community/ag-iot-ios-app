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

private let kCellID = "HomeMainDeviceCell"

//var sdk:IAgoraIotAppSdk?{get{return iotsdk}}



class HomePageMainVC: AGBaseVC {
    
    fileprivate var  doorbellVM = DoorBellManager.shared
    var mDevicesArray = [MDeviceModel]()
    var members:Int = 0
    
    var curIndex : IndexPath?
    var curTraceId : UInt = 0//用来过滤多余的返回数据


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
        checkLoginState()
        addObserver()
        setUpUI()
        // 监听网络状态
        startListeningNetStatus()
//        loadPreConfig()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            sdk?.release()
//        }
    }
    
    //初始化mqtt
    func loadPreConfig(){
        TDUserInforManager.shared.mqttInit()
    }
    //01GTKG1X7AEZWY7ACB7N2EV7C9
    func loadData(){
        mDevicesArray.removeAll()
        let tempArray = TDUserInforManager.shared.readMarkPeerNodeId()
        for item in tempArray{
            let mModel = MDeviceModel()
            mModel.peerNodeId = item
            mDevicesArray.append(mModel)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        initAgoraIot()
        // 隐藏导航栏
        navigationController?.navigationBar.isHidden = true
//        let callkitMgr = getDevSessionMgr("")
//        if((callkitMgr?.getNetworkStatus().isBusy) != nil){
//           callkitMgr?.mutePeerAudio(mute: false, result: {ec,msg in})
//        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 显示导航栏
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        let callkitMgr = getDevSessionMgr("")
//        if((callkitMgr?.getNetworkStatus().isBusy) != nil){
//            callkitMgr?.mutePeerAudio(mute: true, result: {ec,msg in
//                print("\(ec)---\(msg)")
//            })
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getDevSessionMgr(_ sessionId:String)->IDevPreviewMgr?{
        return sdk?.deviceSessionMgr.getDevPreviewMgr(sessionId: sessionId)
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
            self.goToDeciceDetailVC(indexPath:indexPath)
//            self.goToFullVC(indexPath:indexPath)
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


extension HomePageMainVC { //呼叫设备

    //---------设备控制相关-----------
    //呼叫设备
    func callDevice(indexPath : IndexPath){
        
        curIndex = indexPath
        requestConDeviceParam()
        
//        let device = mDevicesArray[indexPath.row]
//        callDialRequest(device)
        
  
    }
    
    //请求连接参数mRtmUid
    func requestConDeviceParam(){
        let deviceId = keyCenter.deviceId
        AGToolHUD.showNetWorkWait()
        ThirdAccountManager.getConnectDeviceParam { [weak self] success, msg,retData in
            AGToolHUD.disMiss()
            if success == 0{
                let connectParam = ConnectParam( mPeerDevId: deviceId, mLocalRtcUid: retData?.data?.uid ?? 0, mChannelName: retData?.data?.cname ?? "", mRtcToken: retData?.data?.rtcToken ?? "", mRtmUid: retData?.data?.userId ?? "",mRtmToken: retData?.data?.rtmToken ?? "")
                self?.connectDevice(connectParam: connectParam)
            }
            print("requestConDeviceParam:\(msg)---\(String(describing: retData))")
        }
    }
    
    private func onMqttDesired(sess:CallSession?){//呼叫mqtt回调

        guard let sess = sess else {
            log.e("onMqttDesired : sess is nil when call CallIncoming")
            return
        }
        if curTraceId == sess.traceId{
            print("过滤mqtt多余的返回数据")
            return
        }
        guard let nodeId = TDUserInforManager.shared.nodeData?.nodeId else{ return }
        
        curTraceId = sess.traceId
        let accountInfor = TDUserInforManager.shared.readKeyChainAccountAndPwd()
        let userId = nodeId //accountInfor.acc
        let connectParam = ConnectParam( mPeerDevId: sess.peerNodeId, mLocalRtcUid: sess.uid, mChannelName: sess.cname, mRtcToken: sess.token,mRtmUid: userId, mRtmToken: "")
        connectDevice(connectParam: connectParam)
    }
    
    func callDialRequest(_ dev:MDeviceModel) {
        
        guard let nodeToken = TDUserInforManager.shared.nodeData?.nodeToken else{ return }
        
        curTraceId = 0
        
        let curTimestamp:Int = String.dateTimeRounded()
        let appId = keyCenter.AppId
        let headerParam = ["traceId": curTimestamp, "timestamp": curTimestamp, "nodeToken": nodeToken, "method": "user-start-call"] as [String : Any]
        let payloadParam = ["appId": appId, "deviceId": dev.peerNodeId, "extraMsg": "attachMsg"] as [String : Any]
        let paramDic = ["header":headerParam,"payload":payloadParam]
        let jsonString = paramDic.convertDictionaryToJSONString()
        TDUserInforManager.shared.cocoaMqtt?.waitForActionDesired(actionDesired: onMqttDesired)
        TDUserInforManager.shared.cocoaMqtt?.publishCallData(data: jsonString)
        log.i("---callDial--发起呼叫,获取连接设备参数---")
        
    }
    
    //连接设备
    func connectDevice(connectParam : ConnectParam){
        
        guard let indexPath = curIndex else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? HomeMainDeviceCell
        let device = mDevicesArray[indexPath.row]
        
        log.i("connectDevice \(device.peerNodeId)")
        
        let connectResult =  doorbellVM.connectDevice(connectParam) { [weak self] sessionId, act in
 
            cell?.handelCallStateText(true)
            device.sessionId = sessionId
            TDUserInforManager.shared.curSessionId = sessionId
            cell?.tag = (self?.getTagFromSessionId(sessionId))!
            
            if(act == .onConnectDone){
                self?.handelUserMembers(1,sessionId)
                self?.previewStart(sessionId: sessionId)
                self?.devSetRtmRecvListener(sessionId)
            }else if(act == .onSessionTokenWillExpire){
                debugPrint("token 即将过期")
                self?.renewToken(sessionId)
            }else{
                self?.handelCallAct(sessionId,act)
            }
            
        } _: { [weak self] members,sessionId in
            self?.handelUserMembers(members,sessionId)
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
//            self.disconnectDevice(connectResult.mSessionId)
//        }
        
 
    }
    
    func disconnectDevice(_ sessionId : String){
        print("disconnectDevice:sessionId:\(sessionId)")
        doorbellVM.disConnectDevice(sessionId:sessionId)
    }
    
    func devSetRtmRecvListener(_ sessionId : String){
        doorbellVM.devRawMsgSetRecvListener(sessionId: sessionId)
    }
    
    func renewToken(_ sessionId : String){
        
        let deviceId = keyCenter.deviceId
        AGToolHUD.showNetWorkWait()
        ThirdAccountManager.getConnectDeviceParam { [weak self] success, msg,retData in
            AGToolHUD.disMiss()
            print("homePageMainVC:getConnectDeviceParam:retData:\(String(describing: retData))")
            if success == 0{
                let reParam = TokenRenewParam.init(mRtcToken: retData?.data?.rtcToken ?? "", mRtmToken: retData?.data?.rtmToken ?? "")
                self?.doorbellVM.renewToken(sessionId, reParam)
            }
        }
    }
    
    func handelUserMembers(_ members:Int,_ sessionId:String){
        let viewTag = getTagFromSessionId(sessionId)
        let cell = getCellWithTag(tag: viewTag)
        cell.handelUserMembers(members)
    }
    
    //处理连接设备返回
    func handelCallAct(_ sessionId:String,_ act:SessionCallback){
        
        if(act == .onDisconnected){
            log.i("handelCallAct:onDisconnected:连接断开")
            let cell = getCurrentCellWithTag(sessionId)
            let tempModel = getCurrentDataModel(indexPath: cell.indexPath ?? IndexPath(row: 0, section: 0))
            tempModel.sessionId = ""
            cell.handelCallTipType(.none)
            cell.handelCallStateText(false)
            cell.handelStateNone()
        }else if(act == .onError){
            debugPrint("连接错误")
            let cell = getCurrentCellWithTag(sessionId)
            cell.handelCallTipType(.loadFail)
            cell.handelCallStateText(false)
            AGToolHUD.showInfo(info: "连接超时,请检查设备状态")
        }
        
    }
    
    //挂断设备
    func handUpDevice(_ sessionId : String){
        
        doorbellVM.hangupDevice(sessionId:sessionId) { act, sessionId,errCode in
            debugPrint("调用挂断：\(errCode)")
            if act == .onSessionDisconnectDone{
                AGToolHUD.showInfo(info: "挂断成功")
            }
        }
    }
    
    func previewStart(sessionId:String){//获取到首帧
        
        let cell = getCurrentCellWithTag(sessionId)
        cell.configPeerView(sessionId)
        DoorBellManager.shared.previewStart(sessionId: sessionId) {[weak self] sessionId, videoWidth, videoHeight in
            
            debugPrint("previewStart：获取到首帧")
//            let cell = self?.getCurrentCellWithTag(sessionId)
//            cell?.configPeerView(sessionId)
//            cell?.handelCallTipType(.playing)
            if self?.isFullScreemVisible() == true{
                //首帧如果是详情页，则发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReceiveFirstVideoFrameNotify), object: nil, userInfo: nil)
            }
            
        }
    }
    
    func getTagFromSessionId(_ sessionId : String)->Int{//获取tag值
        let strArray = sessionId.split(separator: "&")
        print(strArray)
        guard strArray.count > 0 else {
            return 1000
        }
        let tag = strArray[1]
        return Int(tag) ?? 0
    }
    
    func getCellWithTag(tag:Int) -> HomeMainDeviceCell {//获取cell
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
    
    func getCurrentDataModel(indexPath : IndexPath)->MDeviceModel{//获取索引对应的数据
        
        if mDevicesArray.count == 0 {
            return MDeviceModel()
        }
        return mDevicesArray[indexPath.row]
    }
}


extension HomePageMainVC{
    
    func goToFullVC(indexPath : IndexPath){//跳转全屏页

        let device = mDevicesArray[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! HomeMainDeviceCell
        
        let sessionInfor = sdk?.deviceSessionMgr.getSessionInfo(sessionId: device.sessionId)
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
    
//    func initAgoraIot(){
//        log.i("AgoraIotManager app initialize()")
//        
//        let param:InitParam = InitParam()
//        
//        param.rtcAppId = "aab8b8f5a8cd4469a63042fcfafe7063" //AgoraIotConfig.appId
//        param.projectId = AgoraIotConfig.projectId
//        
//        if(ErrCode.XOK != iotsdk.initialize(initParam: param,callbackFilter:{ [weak self] ec, msg in
//            if(ec != ErrCode.XOK){
//                log.w("demo app recv api result \(msg)(\(ec))")
//            }
//            return (ec,msg)
//        })){
//            log.e("initialize failed")
//        }
//    }
    
    func goToDeciceDetailVC(indexPath : IndexPath){//跳转全屏页

        let deviceDetailVC = DeviceDetailVC()
        self.navigationController?.pushViewController(deviceDetailVC, animated: false)
    }
}


extension HomePageMainVC{ //设备删除，添加
    
    // 添加设备
    @objc private func addDevice(){
        print("点击添加设备")
        guard isDeviceEditing() == false else {
            AGToolHUD.showInfo(info: "请将删除操作完成，再进行添加!")
            return
        }
        AGEditAlertVC.showTitleTop("添加设备", editText: "",alertType:.modifyDeviceName ) {[weak self] nodeId in
            self?.addDeviceToArray(nodeId)
            print("-----\(nodeId)")
        }
    }
    
    func addDeviceToArray(_ nodeId : String){
        
        TDUserInforManager.shared.savePeerNodeId(nodeId)
        let mModel = MDeviceModel()
        mModel.peerNodeId = nodeId //01GTKG1X7AEZWY7ACB7N2EV7C9
        mDevicesArray.append(mModel)
        tableView.reloadData()
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

