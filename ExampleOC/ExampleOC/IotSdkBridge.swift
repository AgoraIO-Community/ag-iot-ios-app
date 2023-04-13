//
//  IotSdkBridge.swift
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

import Foundation
import AgoraIotLink

public class CallkitManager : NSObject,ICallkitMgr{
    
    @objc public func talkingRecordStop(result: @escaping (Int, String) -> Void) {
        return mgr.talkingRecordStop(result: result)
    }
    
    @objc public func talkingRecordStart(result: @escaping (Int, String) -> Void) {
        return mgr.talkingRecordStart(result: result)
    }
    
    @objc public func capturePeerVideoFrame(result: @escaping (Int, String, UIImage?) -> Void) {
        return mgr.capturePeerVideoFrame(result: result)
    }
    
    @objc public func register(incoming: @escaping (String,String, ActionAck) -> Void) {
        return mgr.register(incoming: incoming)
    }
    
    @objc public func callDial(device: IotDevice, attachMsg: String, result: @escaping (Int, String) -> Void, actionAck: @escaping (ActionAck) -> Void, memberState: (((MemberState, [UInt]) -> Void)?)) {
        return mgr.callDial(device: device, attachMsg: attachMsg, result: result, actionAck: actionAck, memberState: memberState)
    }
    
    @objc public func callAnswer(result: @escaping (Int, String) -> Void, actionAck: @escaping (ActionAck) -> Void, memberState: ((MemberState, [UInt]) -> Void)?) {
        return mgr.callAnswer(result: result, actionAck: actionAck, memberState: memberState)
    }
    
    @objc public func callHangup(result: @escaping (Int, String) -> Void) {
        return mgr.callHangup(result: result)
    }
    
    @objc public func setLocalVideoView(localView: UIView?) -> Int {
        return mgr.setLocalVideoView(localView: localView)
    }
    
    @objc public func setPeerVideoView(peerView: UIView?) -> Int {
        return mgr.setPeerVideoView(peerView: peerView)
    }
    
    @objc public func muteLocalAudio(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.muteLocalAudio(mute: mute, result: result)
    }
    
    @objc public func muteLocalVideo(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.muteLocalVideo(mute: mute, result: result)
    }
    
    @objc public func mutePeerVideo(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.mutePeerVideo(mute: mute, result: result)
    }
    
    @objc public func mutePeerAudio(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.mutePeerAudio(mute: mute, result: result)
    }
    
    @objc public func setVolume(volumeLevel: Int, result: @escaping (Int, String) -> Void) {
        return mgr.setVolume(volumeLevel: volumeLevel, result: result)
    }
    
    @objc public func setAudioEffect(effectId: AudioEffectId, result: @escaping (Int, String) -> Void) {
        return mgr.setAudioEffect(effectId: effectId, result: result)
    }
    
    @objc public func getNetworkStatus() -> RtcNetworkStatus {
        return mgr.getNetworkStatus()
    }
    
    public init(mgr:ICallkitMgr) {
        self.mgr = mgr
    }
    
    let mgr:ICallkitMgr
}

public class DeviceManager : NSObject,IDeviceMgr,IDeviceStateListener{
    
    @objc public func sendMessageBegin(deviceId: String, result: @escaping (Int, String) -> Void, statusUpdated: @escaping (MessageChannelStatus, String, Data?) -> Void) {
        return mgr.sendMessageBegin(deviceId: deviceId, result: result, statusUpdated: statusUpdated)
    }
    
    @objc public func otaGetInfo(deviceId: String, result: @escaping (Int, String, FirmwareInfo?) -> Void) {
        return mgr.otaGetInfo(deviceId: deviceId, result: result)
    }
    
    @objc public func otaUpgrade(upgradeId: String, result: @escaping (Int, String) -> Void) {
        return mgr.otaUpgrade(upgradeId: upgradeId, result: result)
    }
    
    @objc public func otaQuery(upgradeId: String, result: @escaping (Int, String, FirmwareStatus?) -> Void) {
        return mgr.otaQuery(upgradeId: upgradeId, result: result)
    }
    
    @objc public func sendMessageEnd() {
        return mgr.sendMessageEnd()
    }
    
    @objc public func sendMessage(data: Data, description: String, result: @escaping (Int, String) -> Void) {
        return mgr.sendMessage(data: data, description: description, result: result)
    }
    
//    public func otaGetInfo(device: IotDevice, result: @escaping (Int, String, FirmwareInfo?) -> Void) {
//        return mgr.otaGetInfo(device: device, result: result)
//    }
//
//    public func otaUpgrade(upgradeId: String, decide: Int, result: @escaping (Int, String) -> Void) {
//        return mgr.otaUpgrade(upgradeId: upgradeId, decide: decide, result: result)
//    }
    
//    @objc public func shareDeviceAccept(deviceNickName: String, order: String, result: @escaping (Int, String) -> Void) {
//        return mgr.shareDeviceAccept(deviceNickName: deviceNickName, order: order, result: result)
//    }
//
//    @objc public func sharePushDetail(id: String, result: @escaping (Int, String, ShareDetail?) -> Void) {
//        return mgr.sharePushDetail(id: id, result: result)
//    }
    
    
    @objc public func shareDeviceTo(deviceId: String, userId account: String, type: String, result: @escaping (Int, String) -> Void) {
        return mgr.shareDeviceTo(deviceId: deviceId, userId: account, type: type, result: result)
    }
    
    @objc public func shareGetOwnDevices(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        return mgr.shareGetOwnDevices(result: result)
    }
    
    @objc public func shareCancelable(deviceId: String, result: @escaping (Int, String, [DeviceCancelable]?) -> Void) {
        return mgr.shareCancelable(deviceId: deviceId, result: result)
    }
    
    @objc public func shareRemoveMember(deviceId: String, userId: String, result: @escaping (Int, String) -> Void) {
        return mgr.shareRemoveMember(deviceId: deviceId, userId: userId, result: result)
    }
    
//    @objc public func sharePushAdd(deviceNumber: String, email: String, type: String, result: @escaping (Int, String) -> Void) {
//        return mgr.sharePushAdd(deviceNumber: deviceNumber, email: email, type: type, result: result)
//    }
//    
//    @objc public func sharePushList(pageNo: Int, pageSize: Int, auditStatus: String, result: @escaping (Int, String, [ShareItem]?, PageTurn?) -> Void) {
//        return mgr.sharePushList(pageNo: pageNo, pageSize: pageSize, auditStatus: auditStatus, result: result)
//        
//    }
    
    @objc public func getOwnDevices(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        return mgr.shareGetOwnDevices(result: result)
    }
    
    @objc public func shareWithMe(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        return mgr.shareWithMe(result: result)
    }
    
    @objc public func removeMember(deviceId: String, userId: String, result: @escaping (Int, String) -> Void) {
        return mgr.shareRemoveMember(deviceId: deviceId, userId: userId, result: result)
    }

    
//    @objc public func sharePushDel(id: String, result: @escaping (Int, String) -> Void) {
//        return mgr.sharePushDel(id: id, result: result)
//    }
    
    public func register(listener: IDeviceStateListener) {
        //listener.onDeviceActionUpdated(deviceId: "abcd", actionType: "eft")
        return mgr.register(listener: listener)
    }
    
    public func onDeviceOnOffline(online: Bool, deviceId: String, productId: String) {
        dele?.deviceStateUpdate(online, deviceId: deviceId, productId: productId)
    }
    
    public func onDeviceActionUpdated(deviceId: String, actionType: String) {
        dele?.deviceActionUpdated(deviceId, actionType: actionType)
    }
    
    public func onDevicePropertyUpdated(deviceId: String, deviceNumber: String, props: [String : Any]?) {
        dele?.devicePropertyUpdated(deviceId, deviceNumber: deviceNumber, props: props)
    }
    
    var dele:IotStateDelegate? = nil
    @objc public func register(listener: IotStateDelegate) {
        dele = listener
        self.register(listener: self)
    }
    
    @objc public func addDevice(productId: String, deviceId: String, result: @escaping (Int, String) -> Void) {
        mgr.addDevice(productId: productId, deviceId: deviceId, result: result)
    }
    
    @objc public func queryProductList(query: ProductQueryParam, result: @escaping (Int, String, [ProductInfo]) -> Void) {
        return mgr.queryProductList(query:query,result: result)
    }
    
    @objc public func queryAllDevices(result: @escaping (Int, String, [IotDevice]) -> Void) {
        return mgr.queryAllDevices(result: result)
    }
    
    @objc public func removeDevice(deviceId: String, result: @escaping (Int, String) -> Void) {
        return mgr.removeDevice(deviceId: deviceId, result: result)
    }
    
    @objc public func renameDevice(deviceId: String, newName: String, result: @escaping (Int, String) -> Void) {
        return mgr.renameDevice(deviceId: deviceId, newName: newName, result: result)
    }
    
    @objc public func setDeviceProperty(deviceId: String, properties: Dictionary<String, Any>, result: @escaping (Int, String) -> Void) {
        return mgr.setDeviceProperty(deviceId: deviceId, properties: properties, result: result)
    }
    
    @objc public func getDeviceProperty(deviceId: String, result: @escaping (Int, String, Dictionary<String, Any>?,Dictionary<String, Any>?) -> Void) {
        return mgr.getDeviceProperty(deviceId: deviceId, result: result)
    }
    
    @objc public func getPropertyDescription(deviceId:String, productNumber: String, result: @escaping (Int, String, [Property]) -> Void) {
        return mgr.getPropertyDescription(deviceId:deviceId, productNumber: productNumber, result: result)
    }
    
    @objc public func startPlayback(channelName:String, result: @escaping (Int, String) -> Void, stateChanged: @escaping (PlaybackStatus, String) -> Void) {
        return mgr.startPlayback(channelName: channelName, result: result, stateChanged: stateChanged)
    }
    
    @objc public func setPlaybackView(peerView: UIView?) -> Int {
        return mgr.setPlaybackView(peerView: peerView)
    }
    
    @objc public func stopPlayback() {
        return mgr.stopPlayback()
    }
    
    public init(mgr:IDeviceMgr) {
        self.mgr = mgr
    }
    
    let mgr:IDeviceMgr
}

public class AlarmManager : NSObject,IAlarmMgr{
    
    public func queryAlarmVideoUrl(deviceId: String, tenantId: String, beginTime: UInt64, result: @escaping (Int, String, AgoraIotLink.AlarmVideoInfo?) -> Void) {
        return mgr.queryAlarmVideoUrl(deviceId: deviceId,tenantId:tenantId, beginTime: beginTime, result: result)
    }
    
    @objc public func addAlarm(device: IotDevice, desc: String, result: @escaping (Int, String) -> Void) {
        return mgr.addAlarm(device: device, desc: desc, result: result)
    }
    
    @objc public func queryAlarmImage(alertImageId: String, result: @escaping (Int, String, String?) -> Void) {
        return mgr.queryAlarmImage(alertImageId: alertImageId, result: result)
    }
    
    
    public func querySysCount(productId: String?, deviceIds: [String], messageType: Int?, status: Int?, createDateBegin: Date?, createDateEnd: Date?, result: @escaping (Int, String, UInt) -> Void) {
        return mgr.querySysCount(productId: productId, deviceIds: deviceIds, messageType: messageType, status: status, createDateBegin: createDateBegin, createDateEnd: createDateEnd, result: result)
    }
    
    @objc public func querySysCount(productId: String?, deviceIds: [String], messageType: Int, status: Int, createDateBegin: Date?, createDateEnd: Date?, result: @escaping (Int, String, UInt) -> Void) {
        let msgType = messageType < 0 ? nil : messageType
        let stat = status < 0 ? nil : status
        return mgr.querySysCount(productId: productId, deviceIds: deviceIds, messageType: msgType, status: stat, createDateBegin: createDateBegin, createDateEnd: createDateEnd, result: result)
    }
    
    public func queryCount(productId: String?, deviceId: String?, messageType: Int?, status: Int?, createDateBegin: Date?, createDateEnd: Date?, result: @escaping (Int, String, UInt) -> Void) {
        return mgr.queryCount(productId: productId, deviceId: deviceId, messageType: messageType, status: status, createDateBegin: createDateBegin, createDateEnd: createDateEnd, result: result)
    }
    
    @objc public func queryCount(productId: String?, deviceId: String?, messageType: Int, status: Int, createDateBegin: Date?, createDateEnd: Date?, result: @escaping (Int, String, UInt) -> Void) {
        let msgType = messageType < 0 ? nil : messageType
        let stat = status < 0 ? nil : status
        return mgr.queryCount(productId: productId, deviceId: deviceId, messageType: msgType, status: stat, createDateBegin: createDateBegin, createDateEnd: createDateEnd, result: result)
    }
    
    //for object c,please use another queryByParam()
    public func queryByParam(queryParam: QueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        return mgr.queryByParam(queryParam: queryParam, result: result)
    }
    
//    @objc public func queryByParam(type:Int,status:Int,dateBegin:Date?,dateEnd:Date = Date(),currPage:Int = 1,pageSize:Int = 5,desc:Bool = false,device:IotDevice? = nil,result:@escaping(Int,String,[IotAlarm]?)->Void){
//        let queryParam:QueryParam = QueryParam(dateBegin: dateBegin)
//        queryParam.messageType = type < 0 ? nil : type
//        queryParam.status = status < 0 ? nil : status
//        queryParam.createdDateEnd = dateEnd
//        queryParam.currentPage = currPage
//        queryParam.pageSize = pageSize
//        queryParam.desc = desc
//        queryParam.deviceId = device
//        return mgr.queryByParam(queryParam: queryParam, result: result)
//    }
    
    @objc public func querySysByParam(type:Int,status:Int,dateBegin:Date?,dateEnd:Date = Date(),currPage:Int = 1,pageSize:Int = 5,desc:Bool = false,deviceIds:[String] = [],result:@escaping(Int,String,[IotAlarm]?)->Void){
        let queryParam:SysQueryParam = SysQueryParam(dateBegin: dateBegin)
        queryParam.messageType = type < 0 ? nil : type ////系统告警：1:设备上线 2:设备下线 3:设备绑定 4:设备解绑 99 其他
        queryParam.status = status < 0 ? nil : status
        queryParam.createdDateEnd = dateEnd
        queryParam.currentPage = currPage
        queryParam.pageSize = pageSize
        queryParam.desc = desc
        queryParam.deviceIds = deviceIds
        return mgr.querySysByParam(queryParam: queryParam, result: result)
    }

    
    @objc public func querySysById(alertMessageId: UInt64, result: @escaping (Int, String, IotAlarm?) -> Void) {
        return mgr.querySysById(alertMessageId: alertMessageId, result: result)
    }
    //for object c,please use another querySysByParam()
    public func querySysByParam(queryParam: SysQueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        return mgr.querySysByParam(queryParam: queryParam, result: result)
    }
    
    
    @objc public func markSys(alarmIdList: [UInt64], result: @escaping (Int, String) -> Void) {
        return mgr.markSys(alarmIdList: alarmIdList, result: result)
    }
    
    
    @objc public func queryById(alertMessageId: UInt64, result: @escaping (Int, String, IotAlarm?) -> Void) {
        return mgr.queryById(alertMessageId: alertMessageId, result: result)
    }
    
    @objc public func delete(alarmIdList: [UInt64], result: @escaping (Int, String) -> Void) {
        return mgr.delete(alarmIdList: alarmIdList, result: result)
    }
    
    @objc public func mark(alarmIdList: [UInt64], result: @escaping (Int, String) -> Void) {
        return mgr.mark(alarmIdList: alarmIdList, result: result)
    }
    
    public init(mgr:IAlarmMgr) {
        self.mgr = mgr
    }
    
    let mgr:IAlarmMgr
}

public class NotificationManager : NSObject,INotificationMgr{
    @objc public func getEid() -> String {
        return mgr.getEid()
    }
    
    @objc public func enableNotify(enable: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.enableNotify(enable: enable, result: result)
    }
    
    @objc public func notifyEnabled() -> Bool {
        return notifyEnabled()
    }
    
    @objc public func queryAll(result:@escaping(Int,String)->Void) {
        return mgr.queryAll(result: result)
    }
    
    @objc public func queryByDevice(productKey: String, deviceId: String,result:@escaping(Int,String)->Void) {
        return mgr.queryByDevice(productKey: productKey, deviceId: deviceId, result: result)
    }
    
    @objc public func delete(notificationIdList: [String],result:@escaping(Int,String)->Void) {
        return mgr.delete(notificationIdList: notificationIdList,result: result)
    }
    
    @objc public func mark(markFlag: Int, notificationIdList: [String],result:@escaping(Int,String)->Void) {
        return mgr.mark(markFlag: markFlag, notificationIdList: notificationIdList, result: result)
    }
    
    @objc public func updateToken(_ deviceToken: Data) {
        mgr.updateToken(deviceToken)
    }
    public init(mgr:INotificationMgr) {
        self.mgr = mgr
    }
    
    let mgr:INotificationMgr
}

public class AccountManager : NSObject,IAccountMgr{
    
    @objc public func publicKeySet(publicKey: String, _ result: @escaping (Int, String) -> Void) {
        return mgr.publicKeySet(publicKey: publicKey, result)
    }
    
    @objc public func login(param: LoginParam, result: @escaping (Int, String) -> Void) {
        return mgr.login(param: param, result: result)
    }
    
    @objc public func updateHeadIcon(image: UIImage, result: @escaping (Int, String, String?) -> Void) {
        return mgr.updateHeadIcon(image: image, result: result)
    }
    
//    @objc public func getSms(phone: String, type: String, lang: String, result: @escaping (Int, String) -> Void) {
//        return mgr.getSms(phone: phone, type: type, lang: lang, result: result)
//    }
//
//    @objc public func unregister(result: @escaping (Int, String) -> Void) {
//        return mgr.unregister(result: result)
//    }
    
    @objc public func updateAccountInfo(info: AccountInfo, result: @escaping (Int, String) -> Void) {
        return mgr.updateAccountInfo(info: info, result: result)
    }
    
    @objc public func getAccountInfo(result: @escaping (Int, String, AccountInfo?) -> Void) {
        return mgr.getAccountInfo(result: result)
    }
    
    @objc public func register(account: String, password: String,result: @escaping (Int, String) -> Void) {
        ThirdAccountManager.reqRegister(account, password,result)
    }
    
    @objc public func urregister(account: String, password: String,result: @escaping (Int, String) -> Void) {
        ThirdAccountManager.reqUnRegister(account, password,result)
    }
    
    @objc public func login(account: String, password: String, result: @escaping (Int, String) -> Void) {
        ThirdAccountManager.reqLogin(account, password) { ec, msg, param in
            if(ec != ErrCode.XOK){
                log.e("第三方 login failed:\(msg)(\(ec))")
                result(ec,msg)
                return
            }
            guard let param = param else {
                log.e("第三方 login return error data")
                result(ErrCode.XERR_ACCOUNT_LOGIN,"登录返回数据为空")
                return
            }
            return self.mgr.login(param:param, result: result)
        }
    }
    
    @objc public func logout(result: @escaping (Int, String) -> Void) {
        ThirdAccountManager.reqLogout { ec, msg in
            if(ec != ErrCode.XOK){
                log.e("第三方 logout failed:\(msg)(\(ec))")
                result(ec,msg)
                return
            }
            self.mgr.logoutAccount(result: result)
        }
    }
    
    @objc public func logoutAccount(result: @escaping (Int, String) -> Void) {
        self.mgr.logoutAccount(result: result)
    }

    @objc public func getUserId() -> String {
        return mgr.getUserId()
    }
    
    public init(mgr:IAccountMgr) {
        self.mgr = mgr
    }
    
    let mgr:IAccountMgr
}

public class IotSdk: NSObject {
    private static var sdk = IotSdk()
    
    @objc public static func shared()->IotSdk{
        return sdk
    }
    
    @objc func initialize(initParam: InitParam,
                          sdkStatus:@escaping(SdkStatus,String)->Void,callback:IotCallbackDelegate?)->Int{
        return iotsdk.initialize(initParam: initParam, sdkStatus: sdkStatus, callbackFilter: {ec,msg in
            if(callback != nil){
                callback!.filterResult(Int32(ec), errMessage: msg)
                return (ec,msg)
            }
            return (ec,msg)}
        )
    }

    /*
     * @brief 释放SDK所有资源
     */
    @objc func deinitialize(){
        return iotsdk.release()
    }

    @objc public func getAccountMgr()->AccountManager{
        return AccountManager(mgr:iotsdk.accountMgr)
    }

    @objc public func getDeviceMgr() -> DeviceManager {
        return DeviceManager(mgr:iotsdk.deviceMgr)
    }

    @objc public func getCallManager()->CallkitManager {
        return CallkitManager(mgr:iotsdk.callkitMgr)
    }
    
    @objc public func getAlarmManager()->AlarmManager{
        return AlarmManager(mgr:iotsdk.alarmMgr)
    }
    
    @objc public func getNotificationManager()->NotificationManager{
        return NotificationManager(mgr:iotsdk.notificationMgr)
    }
    
    @objc public func getMqttIsConnected()->Bool{
        return iotsdk.getMqttIsConnected()
    }
}
