//
//  RtmEngine.swift
//  AgoraIotLink
//
//  Created by ADMIN on 2022/8/8.
//

import Foundation
import AgoraRtmKit

class RtmEngine : NSObject{
    static private let IDLED = 0
    static private let CREATED = 1
    static private let ENTERED = 2
    
    private var kit:AgoraRtmKit? = nil
    private var config:Config
    private var state:Int = IDLED
    
    init(cfg:Config) {
        self.config = cfg
        self.state = RtmEngine.IDLED
    }
    
    func create(_ setting:RtmSetting)->Bool{
        let version = AgoraRtmKit.getSDKVersion()
        log.i("rtm is creating,version:\(version)")
        kit = AgoraRtmKit(appId: setting.appId, delegate: self)
        if(kit == nil){
            log.e("rtm create engine kit fail")
            return false
        }
        state = RtmEngine.CREATED
        log.i("rtm created")
        return true
    }
    private func sendLoginCallback(_ e:AgoraRtmLoginErrorCode,_ statusUpdated:@escaping(MessageChannelStatus,String,Data?)->Void,_ cb:@escaping(TaskResult,String)->Void){
        var msg = "未知错误"
        var ec:Int = ErrCode.XERR_API_RET_FAIL
        switch(e){
        case .ok:
            ec = ErrCode.XOK
            msg = "登录成功,开始连接..."
        case .unknown:
            ec = ErrCode.XERR_UNKNOWN
        case .rejected:
            msg = "登录rtm被拒绝"
        case .invalidArgument:
            msg = "无效的rtm参数"
        case .invalidAppId:
            msg = "无效的AppId"
        case .invalidToken:
            msg = "无效的Token"
        case .tokenExpired:
            msg = "Token过期"
        case .notAuthorized:
            msg = "未通过认证"
        case .alreadyLogin:
            ec = ErrCode.XOK
            msg = "已经登录"
        case .timeout:
            msg = "登录超时"
        case .loginTooOften:
            msg = "登录过于频繁"
        case .loginNotInitialized:
            msg = "登录未初始化"
        @unknown default:
            msg = "未知错误"
        }
        
        if(ec != ErrCode.XOK){
            log.e("rtm login result:\(msg)(\(e))")
            cb(.Fail,msg)
        }
        else{
            log.i("rtm login status:\(msg)(\(e.rawValue)) ...")
            self._statusUpdated = statusUpdated
            self._enterCallback = cb
        }
    }

    private var _statusUpdated:((MessageChannelStatus,String,Data?)->Void)?  = nil
    private var _enterCallback:((TaskResult,String)->Void)? = nil
    func enter(_ sess:RtmSession,_ uid:String,_ statusUpdated:@escaping(MessageChannelStatus,String,Data?)->Void, _ cb:@escaping (TaskResult,String)->Void){
        log.i("rtm try enter with token:\(sess.token),local:\(uid)")
        if(self._statusUpdated != nil){
            log.w("rtm _statusChanged is not nil,should call sendMessageEnd() before sendMessageBegin()")
        }
        let ret = kit?.login(byToken: sess.token, user: uid) { err in
            self.sendLoginCallback(err,statusUpdated,{tr,msg in
                if(tr == TaskResult.Succ){
                    self.state = RtmEngine.ENTERED
                }
                cb(tr,msg)
            })
        }
    }
    private func sendLogoutCallback(_ e:AgoraRtmLogoutErrorCode,_ cb:@escaping(Bool)->Void){
        switch(e){
        case .ok:
            log.i("rtm leave succ")
        case .rejected:
            log.w("rtm leave rejected")
        case .notInitialized:
            log.w("rtm leave notInitialized")
        case .notLoggedIn:
            log.w("rtm leave notLoggedIn")
        @unknown default:
            log.w("rtm leave unknown result")
        }
        cb(true)
    }
    func leave(cb:@escaping (Bool)->Void){
        log.i("rtm try leaveChannel ...")
        self._statusUpdated = nil
        if(self._enterCallback != nil){
            self._enterCallback?(.Abort,"取消登录")
            self._enterCallback = nil
        }
        if(state != RtmEngine.ENTERED){
            log.e("rtm state : \(state) error for leave()")
            cb(false)
            return
        }
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(false)
            return
        }
        kit.logout { err in
            self.state = RtmEngine.IDLED
            DispatchQueue.main.async {
                self.sendLogoutCallback(err, cb)
            }
        }
    }
    private func sendCallback(_ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(Int,String)->Void){
        var msg = "未知错误"
        var ec:Int = ErrCode.XERR_API_RET_FAIL
        switch(e){
        case .ok:
            ec = ErrCode.XOK
            msg = "发送成功"
        case .failure:
            msg = "发送失败"
        case .timeout:
            ec = ErrCode.XERR_TIMEOUT
            msg = "发送超时"
        case .peerUnreachable:
            msg = "无法连接对端"
        case .cachedByServer:
            msg = "消息被服务器缓存"
        case .tooOften:
            msg = "发送太频繁"
        case .invalidUserId:
            msg = "无效用户Id"
        case .invalidMessage:
            msg = "无效消息"
        case .imcompatibleMessage:
            msg = "消息不兼容"
        case .notInitialized:
            msg = "未初始化rtm"
        case .notLoggedIn:
            msg = "未登录rtm"
        @unknown default:
            msg = "未知错误"
            ec = ErrCode.XERR_UNKNOWN
        }
        if(ec != ErrCode.XOK){
            log.e("rtm send message result:\(msg)(\(e))")
        }
        cb(ec,msg)
    }
    func sendStringMessage(toPeer:String,message:String,cb:@escaping(Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtm未初始化")
            return
        }
        if(message.count >= config.maxRtmPackage){
            log.e("rtm package size(\(message.count) exceeds limit(\(config.maxRtmPackage)")
            cb(ErrCode.XERR_BUFFER_OVERFLOW,"rtm消息长度超过限制")
            return
        }
        let package = AgoraRtmMessage(text: message)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            DispatchQueue.main.async {
                self.sendCallback(ec,cb)
            }
        }
    }
    func sendRawMessage(toPeer:String,data:Data,description:String,cb:@escaping(Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtm未初始化")
            return
        }
        if(data.count >= config.maxRtmPackage){
            log.e("rtm package size(\(data.count) exceeds limit(\(config.maxRtmPackage)")
            cb(ErrCode.XERR_BUFFER_OVERFLOW,"rtm消息长度超过限制")
            return
        }
        let package = AgoraRtmRawMessage(rawData: data, description: description)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            DispatchQueue.main.async {
                self.sendCallback(ec,cb)
            }
        }
    }
    func destroy(){
        log.i("rt=m is destroying()")
        if(kit == nil){
            log.e("rtc engine is nil")
            return
        }
        if(state != RtmEngine.CREATED){
            log.e("rtc state:\(state) not correct")
            return
        }
        
        state = RtmEngine.IDLED
    }
    func createThenEnter(_ setting:RtmSetting,_ sess:RtmSession,_ uid:String,_ statusUpdated:@escaping(MessageChannelStatus,String,Data?)->Void,cb:@escaping (TaskResult,String)->Void){
        log.i("rtm createThenEnter when state:\(state)")
        if(!create(setting)){
            log.w("rtm create kit error when createAndEnter")
            cb(.Fail,"create rtm fail")
            return
        }
        enter(sess,uid,statusUpdated, cb)
    }
    
    func leaveThenDestroy(cb:@escaping (Bool)->Void){
        log.i("rtm leaveThenDestroy when state:\(state)")
        if(state == RtmEngine.ENTERED){
            let cbLeave = {(b:Bool) in
                if(!b){
                    log.w("rtc leave channel error when leaveAndDestroy")
                }
                self.destroy()
                cb(b)
            }
            leave(cb:cbLeave)
        }
        else if(state == RtmEngine.CREATED){
            destroy()
            cb(true)
        }
        else{
            cb(true)
        }
    }
}

extension RtmEngine : AgoraRtmDelegate{
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        log.i("rtm messageReceived from \(peerId) type:\(message.type) ts:\(message.serverReceivedTs) offline:\(message.isOfflineMessage)")
        if(message.type == .raw){
            if let raw = message as? AgoraRtmRawMessage{
                DispatchQueue.main.async {
                    self._statusUpdated?(.DataArrived,peerId,raw.rawData)
                }
            }
            else{
                log.e("rtm message type cast error")
            }
        }
        else{
            log.w("rtm unhandled messate type \(message.type)")
        }
    }
    private func sendStateUpdated(_ state: AgoraRtmConnectionState, _ reason: AgoraRtmConnectionChangeReason){
        switch(state){
        case .disconnected:
            self._statusUpdated?(.Disconnected,"disconnected",nil)
        case .connecting:
            self._statusUpdated?(.Connecting,"connecting",nil)
        case .connected:
            if(self._enterCallback != nil){
                self._enterCallback?(.Succ,"连接完成,可以发送消息")
                self._enterCallback = nil
            }
            else{
                self._statusUpdated?(.Connected,"connected",nil)
            }
        case .reconnecting:
            self._statusUpdated?(.Reconnecting,"reconnecting",nil)
        case .aborted:
            self._statusUpdated?(.Aborted,"aborted",nil)
        @unknown default:
            self._statusUpdated?(.UnknownError,"unknown",nil)
        }
    }
    
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        log.i("rtm connectionStateChanged to \(state.rawValue) reason \(reason.rawValue)")
        DispatchQueue.main.async {
            self.sendStateUpdated(state,reason)
        }
    }
    
    func rtmKitTokenDidExpire(_ kit: AgoraRtmKit) {
        log.e("rtm rtmKitTokenDidExpire")
        DispatchQueue.main.async {
            self._statusUpdated?(.TokenDidExpire,"",nil)
        }
    }
    
    func rtmKitTokenPrivilegeWillExpire(_ kit: AgoraRtmKit) {
        log.i("rtm rtmKitTokenPrivilegeWillExpire")
        DispatchQueue.main.async {
            self._statusUpdated?(.TokenWillExpire,"",nil)
        }
    }
}
