//
//  AppDelegate_ThidParty.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/21.
//

import Foundation
import AgoraIotLink

//配置IAgoraIotAppSdk 初始化
extension AppDelegate{
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    func initAgoraIot(){
        log.i("AgoraIotManager app initialize()")
        
        let param:InitParam = InitParam()
        param.rtcAppId = AgoraIotConfig.appId
        param.subscribeVideo = true
        param.subscribeAudio = true
        param.publishAudio = true
        param.publishVideo = true
        
        param.ntfApnsCertName = AgoraIotConfig.ntfApnsCertName
        param.ntfAppKey = AgoraIotConfig.ntfAppKey
        param.masterServerUrl = AgoraIotConfig.masterServerUrl
        param.slaveServerUrl = AgoraIotConfig.slaveServerUrl
        param.projectId = AgoraIotConfig.projectId
        
        if(ErrCode.XOK != iotsdk.initialize(initParam: param,sdkStatus: { sdkStatus, msg in
            if(sdkStatus == .AllReady){
                let eid = iotsdk.notificationMgr.getEid()
                log.i("demo eid is \(eid)")
            }
            
            debugPrint("------\(msg)")
        }, callbackFilter:{ [weak self] ec, msg in
            if(ec != ErrCode.XOK){
                log.w("demo app recv api result \(msg)(\(ec))")
            }
            self?.handelCommonErrorCode(ec)
            return (ec,msg)
        })){
            log.e("initialize failed")
        }
        
//        AgoraIotSdk.iotsdk.callkitMgr.register(incoming: {peerId,msg,action in})
        sdk?.callkitMgr.register(incoming: {[weak self] deviceId,msg,callin  in
            debugPrint("---来电呼叫---")
            if (callin == .CallIncoming) {
                iotsdk.callkitMgr.muteLocalAudio(mute: true) { ec, msg in}
                iotsdk.callkitMgr.muteLocalVideo(mute: true){ ec,msg in}
                self?.receiveCall(deviceId)
            }else if(callin == .RemoteHangup){
                log.i("demo app remote hangup")
                //被动呼叫挂断发通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteHangupNotify), object: nil)
            }else if(callin == .RemoteVideoReady){
                log.i("demo app RemoteVideoReady")
                //首帧成功可显示发通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteVideoReadyNotify), object: nil)

            }else if(callin == .AcceptFail){
                log.e("demo app accept error \(msg)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteHangupNotify), object: nil)
            }
        })
        sdk?.deviceMgr.register(listener: self)
    }
}

extension AppDelegate: IDeviceStateListener {//添加设备回调等
    
    func onDeviceOnOffline(online: Bool, deviceId: String, productId productKey: String) {
        
    }
    
    func onDeviceActionUpdated(deviceId: String, actionType: String) {
        if actionType == "add" {
            log.i("新增设备 update:\(actionType):\(deviceId)")
            guard  TDUserInforManager.shared.currentMatchNetType != 0 else {
                log.i("非操作配网流程消息 update:\(actionType):\(deviceId)")
                return
            }
            //如果当前为蓝牙配网，且已获取配网成功消息，则返回
            if TDUserInforManager.shared.currentMatchNetType == 2 && TDUserInforManager.shared.curBluefiSuc == true{
//                AGToolHUD.showInfo(info: "不使用获取的订阅消息：\(deviceId)")
                return
            }
            TDUserInforManager.shared.curBluefiSuc = true
            TDUserInforManager.shared.currentMatchNetType = 0
//            AGToolHUD.showInfo(info: "使用获取的订阅消息：\(deviceId)")
            
            let vc = DeviceAddSuccessVC()
            vc.deviceId = deviceId
            if currentViewController().navigationController != nil {
                currentViewController().navigationController?.pushViewController(vc, animated: false)
            }
        }
        if actionType == "delete" {
            let vc = DeviceDelSuccessVC()
            vc.deviceId = deviceId
            log.i("移除设备 update:\(actionType):\(deviceId)")
            if currentViewController().navigationController != nil {
                currentViewController().navigationController?.pushViewController(vc, animated: false)
            }
        }
            
    }
    
    func onDevicePropertyUpdated(deviceId: String, deviceNumber: String, props: [String : Any]?) {
        
    }
    
    
}

extension AppDelegate {//监听收到被动呼叫回调等
    
    private func receiveCall(_ deviceId : String){
        //self?.goToDoorBellContainerVC(device)
        DeviceManager.shared.queryDeviceWithId(deviceId) { [weak self] _, _, dev in
            guard let device = dev else {
                log.i("demo stranger is calling in:\(deviceId)")
                let stranger = IotDevice(userId: "", userType: 0, deviceId: deviceId, deviceName: "unknown", deviceNumber: "", tenantId: "", productId: "", productNumber: "", sharer: "", createTime: 0, updateTime: 0, alias: "unknown", connected: false, props: nil)

               self?.goToDoorBellContainerVC(stranger)
               return
            }
            self?.goToDoorBellContainerVC(device)
        }
    }
    
    func goToDoorBellContainerVC(_ device : IotDevice){
        
        if currentViewController().isKind(of: DoorbellContainerVC.self) {
            
            //呼叫中发通知（仅用户当前页已经是门铃控制页）
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cReceiveCallNotify), object: nil)
            
        }else{
            
            let dbVC = DoorbellContainerVC()
            dbVC.device = device
            dbVC.isReceiveCall = true
            if currentViewController().navigationController != nil {
                currentViewController().navigationController?.pushViewController(dbVC, animated: true)
            }
        }
    }
    
}

extension AppDelegate {//处理通用错误码，如token失效
    
    //处理通用错误码
    func handelCommonErrorCode(_ errorCode : Int) {
        
        if errorCode == ErrCode.XERR_TOKEN_INVALID {
            
            debugPrint("token失效，重新登陆")
            //如果不是处于登陆状态，直接返回
            guard TDUserInforManager.shared.isLogin == true else { return }
            TDUserInforManager.shared.userSignOut()
            DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
            
        }else if errorCode == ErrCode.XOK {
            
            //debugPrint("---请求成功----")
            
        }
    }
    
}
