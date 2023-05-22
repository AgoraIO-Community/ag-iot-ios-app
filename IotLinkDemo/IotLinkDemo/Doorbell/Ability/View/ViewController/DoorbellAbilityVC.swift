//
//  DoorbellAbilityVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/5.
//

import UIKit
import JXSegmentedView
import AgoraIotLink

//首帧可显示成功的通知（被动呼叫）
let cRemoteVideoReadyNotify = "cRemoteVideoReadyNotify"
let cLocalHangupNotify = "cLocalHangupNotify"

class DoorbellAbilityVC: UIViewController {
    
    var device: IotDevice?
    weak var containerVC : UIViewController?
    
    //是否来自被动呼叫
    var isReceiveCall : Bool = false
    
    fileprivate var  doorbellVM = DoorBellManager.shared
    fileprivate var dataArr = [DoorbellAbilityModel]()
    
    var doorVCBackVBlock:(() -> (Void))? //转回竖屏
    var doorVCFullHBlock:(() -> (Void))? //转为横屏
    
    //是否横屏
    var isHorizonFull : Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addObserver()
        
        if isReceiveCall == false {
            callDevice()
            getCurrentDeviceProperty()
        }
        
        loadData()
        setUpUI()
    }
    
    // 注册通知
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRemoteVideoReady), name: Notification.Name(cRemoteVideoReadyNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLocalHangupNotify), name: Notification.Name(cLocalHangupNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange(notification:)), name: Notification.Name(cNetChangeNotify), object: nil)
    }
    
    @objc private func receiveRemoteVideoReady(){
        // 设置视频view
        self.handelAnswerVideoView()
    }
    
    @objc private func receiveLocalHangupNotify(){
        // 设置视频view
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":0])
        self.handelCallAct(.LocalHangup)
    }

    @objc private func netWorkChange(notification: NSNotification){
        //网络状态变化通知
        guard let netType = notification.userInfo?["netType"] as? String else { return }
        debugPrint("当前网络状态：\(netType)")
        if netType == "none" {
            //todo:
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(AgoraIotLink.iotsdk.callkitMgr.getNetworkStatus().isBusy){
//            AgoraIotLink.iotsdk.callkitMgr.muteLocalAudio(mute: false, result: {ec,msg in
//                print("\(ec)---\(msg)")
//
//            })
            AgoraIotLink.iotsdk.callkitMgr.mutePeerAudio(mute: false, result: {ec,msg in})
            
        }
//        if isReceiveCall == false {
//            shutDownAudio(false)
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if(AgoraIotLink.iotsdk.callkitMgr.getNetworkStatus().isBusy){
            
//            AgoraIotLink.iotsdk.callkitMgr.muteLocalAudio(mute: true, result: {ec,msg in
//                print("\(ec)---\(msg)")
//
//            })
            AgoraIotLink.iotsdk.callkitMgr.mutePeerAudio(mute: true, result: {ec,msg in
                print("\(ec)---\(msg)")

            })

        }
        //如果设备挂断，发送通知停止录屏
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRecordVideoStateUpdated), object: nil, userInfo: nil)
        jumpBackOrNext()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("门铃控制页面销毁了")
    }
    
    func setUpUI() {
        
        view.backgroundColor = UIColor(hexString: "#000000")
        
        view.addSubview(topAbilityV)
        topAbilityV.snp.makeConstraints { (make) in
            make.height.equalTo(338.VS)
            make.top.left.right.equalToSuperview()
        }
        
        view.addSubview(doolAbilityV)
        doolAbilityV.snp.makeConstraints { (make) in
            make.top.equalTo(topAbilityV.snp.bottom).offset(28.VS).priority(.low)
            make.left.right.bottom.equalToSuperview()
        }
 
    }
    
    lazy var topAbilityV : DoorbellAbilityTopView = {
        
        let view = DoorbellAbilityTopView()
        view.isReceiveCall = isReceiveCall
        view.device = device
        view.delegate = self
        view.fullHBtnClickBlock = { [weak self] in
            self?.fullHBtnClick()
        }
        view.backVBtnClickBlock = { [weak self] in
            self?.backVBtnClick()
        }
        return view
        
    }()
    
    lazy var doolAbilityV : DoorbellAbilityView = {
        
        let view = DoorbellAbilityView()
        view.device = device
        return view
        
    }()
    
    func loadData() {
        
        doorbellVM.loadDoorbellAbilityPropertyData {[weak self] modelArr, isSuccess in
            if isSuccess {
                self?.doolAbilityV.dataArr = modelArr
            }
        }
    }

}

extension DoorbellAbilityVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

//头部视图代理方法
extension DoorbellAbilityVC : DoorbellAbilityTopViewDelegate{
    
    //------视频异常视图回调------
    func reCallBtnClick() {
        debugPrint("重新呼叫")
        topAbilityV.handelVideoTopView(tipsType: .loading)
        callDevice()
    }
    
    func checkDeviceBtnClick() {
        debugPrint("请检查设备")
    }
    
    func resetDeviceBtnClick() {
        debugPrint("设备重启")
        setEnergyConProperty()
    }
    
}

//控制相关
extension DoorbellAbilityVC {
    
    //---------设备控制相关-----------
    //呼叫设备
    func callDevice(){

        guard let device = device else { return }
        
        log.i("wakeup device \(device.deviceName)")
        
//        if device.connected == false {//设备离线,不再继续呼叫
//            topAbilityV.handelVideoTopView(tipsType: .deviceOffLine)
//            AGToolHUD.showInfo(info: "设备离线,请检查设备状态")
//            return
//        }
        if(!device.connected){
            //videoTipView.tipType = .deviceOffLine
            return;
        }
        
        topAbilityV.handelVideoTopView(tipsType: .loading)
        
//        AGToolHUD.showNetWorkWait(20)
        doorbellVM.wakeupDevice(device) {[weak self] success, msg in
            if(!success){
                debugPrint("呼叫失败")
                AGToolHUD.showInfo(info: "呼叫失败,请检查设备状态")
                self?.topAbilityV.handelVideoTopView(tipsType: .loadFail)
            }else{
                debugPrint("呼叫成功")
            }
            
        } _: { [weak self] act in
            self?.handelCallAct(act)
        }
        
    }
    
    //处理呼叫返回
    func handelCallAct(_ act:ActionAck){
        
        //AGToolHUD.disMiss()
        
        if(act == .CallOutgoing){
            debugPrint("本地去电振铃")
        }
        else if(act == .RemoteBusy){
            debugPrint("设备忙碌")
            topAbilityV.handelVideoTopView(tipsType: .loadFail)
            AGToolHUD.disMiss()
        }
        else if(act == .RemoteHangup){
            //设备休眠时会走此回调
            debugPrint("设备挂断")
            topAbilityV.handelVideoTopView(tipsType: .deviceSleep)
            AGToolHUD.disMiss()
            //如果设备挂断，发送通知停止录屏
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRecordVideoStateUpdated), object: nil, userInfo: nil)
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteHangupNotify), object: nil)
        }
        else if(act == .LocalHangup){
            //设备休眠时会走此回调
            debugPrint("本地挂断")
            topAbilityV.handelVideoTopView(tipsType: .deviceSleep)
            AGToolHUD.disMiss()
        }
        else if(act == .RemoteAnswer){
            debugPrint("设备接听")
            AGToolHUD.disMiss()
        }
        else if(act == .CallForward){
            debugPrint("呼叫中")
        }
        else if(act == .RemoteVideoReady){
            debugPrint("获取到首帧")
            topAbilityV.configPeerView()
            topAbilityV.handelVideoTopView(tipsType: .playing)
            AGToolHUD.disMiss()
        }
        else if(act == .RemoteTimeout){
            topAbilityV.handelVideoTopView(tipsType: .loadFail)
            debugPrint("接听超时")
            //AGToolHUD.disMiss()
            AGToolHUD.showInfo(info: "对端接听超时,请检查设备状态")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteHangupNotify), object: nil)
        }
        else if(act == .LocalTimeout || act == .UnknownAction){
            topAbilityV.handelVideoTopView(tipsType: .loadFail)
            debugPrint("呼叫超时")
            //AGToolHUD.disMiss()
            AGToolHUD.showInfo(info: "呼叫超时,请检查设备状态")

        }else{
            topAbilityV.handelVideoTopView(tipsType: .loading)
            AGToolHUD.disMiss()
        }
    }
    
    //挂断设备
    func handUpDevice(){
        
        doorbellVM.hangupDevice { success, msg in
            debugPrint("调用挂断：\(msg)")
        }
    }
    
    //获取设备属性
    func getCurrentDeviceProperty(){
        
        guard let device = device else { return }
        DoorBellManager.shared.getDeviceProperty(device) { [weak self] success, msg, desired,reported in
            
            if success == true{
                
                guard let dict = desired else { return }
                self?.handelDeviceProperty(dict)
                
            }
        }
    }
    
    func handelDeviceProperty(_ dict : Dictionary<String,Any>){
        
        if let value = dict["1000"] as? Int, value == 1{//1位低功耗模式
            topAbilityV.handelVideoTopView(tipsType: .deviceSleep)
        }else if let value = dict["106"] as? Int{//电池电量
            debugPrint("\(String(value))")
            topAbilityV.setQuantityValue(value)
        }
 
    }
    
    //设置功耗模式为正常，即唤醒设备
    func setEnergyConProperty(){
       
        //setDevicecProperty(pointId: 1000, value: 2)
        callDevice()
        
    }
        
    //设置设备属性
    func setDevicecProperty(pointId:Int,value:Int){
        
        guard let device = device else { return }
        DoorBellManager.shared.setSynDevicecProperty(device,pointId:pointId,value: value) { success, msg in
            
            if success == true {
                
                debugPrint("设置成功")
                AGToolHUD.showInfo(info:"设置成功" )
                
            }else{
                
                AGToolHUD.showFaild(info: "\(msg)")
                
            }
        }
        
    }
     
    //设置静音
    func shutDownAudio(_ isShutAudio : Bool){

        DoorBellManager.shared.mutePeerAudio(mute: isShutAudio) { success, msg in
            if success{
                log.i("设置静音成功")
            }
         }
    }
    
    //设置接听呼叫视频view
    func handelAnswerVideoView(){
        
        topAbilityV.configPeerView()
        topAbilityV.handelVideoTopView(tipsType: .playing)
        
    }
}

extension DoorbellAbilityVC{
    
    //返回上一个或跳转下个页面
    func jumpBackOrNext(){
        
        let viewControllers = self.navigationController?.viewControllers
        if let count = viewControllers?.count, count == 1{
            //返回上个页面
            handUpDevice()
        }else if let count = viewControllers?.count, count > 0, viewControllers?[count-2] == containerVC {
            //push跳转到下个页面
            //shutDownAudio(true)
        }else if let count = viewControllers?.count, count > 0, viewControllers?[count-1] == containerVC {
            //present跳转到下个页面
            //shutDownAudio(true)
        }else{
            //返回上个页面
            //handUpDevice()
        }
    }
}
