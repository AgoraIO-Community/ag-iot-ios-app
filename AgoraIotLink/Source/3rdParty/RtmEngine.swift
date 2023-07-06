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
    
    var app  = Application.shared
    
    private var kit:AgoraRtmKit? = nil
    private var config:Config
    private var state:Int = IDLED
    
    var timer: Timer?
    var curSession: RtmSession?
    
    init(cfg:Config) {
        self.config = cfg
        self.state = RtmEngine.IDLED
    }
    
    deinit {
        log.i("RtmEngine 销毁了")
    }
    
    //rtm 初始化
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
    private func sendLoginCallback(_ e:AgoraRtmLoginErrorCode,_ cb:@escaping(TaskResult,String)->Void){
        var msg = "unknown error"
        var ec:Int = ErrCode.XERR_API_RET_FAIL
        switch(e){
        case .ok:
            ec = ErrCode.XOK
            msg = "login succ,connecting ..."
        case .unknown:
            ec = ErrCode.XERR_UNKNOWN
        case .rejected:
            msg = "rtm login rejected"
        case .invalidArgument:
            msg = "rtm argument invalid"
        case .invalidAppId:
            msg = "rtm appid invalid"
        case .invalidToken:
            msg = "rtm token invalid"
        case .tokenExpired:
            msg = "rtm token expired"
        case .notAuthorized:
            msg = "rtm not authorized"
        case .alreadyLogin:
            ec = ErrCode.XOK
            msg = "rtm alread login"
        case .timeout:
            msg = "rtm timeout"
        case .loginTooOften:
            msg = "rtm login too offten"
        case .loginNotInitialized:
            msg = "rtm not initialized"
        @unknown default:
            msg = "unknown error"
        }
        
        if(ec != ErrCode.XOK){
            log.e("rtm login result:\(msg)(\(e))")
            cb(.Fail,msg)
        }
        else{
            log.i("rtm login status:\(msg)(\(e.rawValue)) ...")
            self._enterCallback = cb
        }
    }

    private var _statusUpdated:((MessageChannelStatus,String,AgoraRtmMessage?)->Void)?  = nil
    private var _enterCallback:((TaskResult,String)->Void)? = nil
    private var _completionBlocks: [String: ((Int, String) -> Void)] = [:]
    private var _completionDicBlocks: [String: ((Int, Dictionary<String, Any>) -> Void)] = [:]
    
    public func waitForStatusUpdated(statusUpdated:@escaping(MessageChannelStatus,String,AgoraRtmMessage?)->Void){
        _statusUpdated = statusUpdated
    }
    
    func enter(_ sess:RtmSession,_ uid:String,_ cb:@escaping (TaskResult,String)->Void){
        log.i("rtm try enter with token:\(sess.token),local:\(uid)")
        curSession = sess
        if(self._statusUpdated != nil){
            log.w("rtm _statusChanged is not nil,should call sendMessageEnd() before sendMessageBegin()")
        }
        let ret = kit?.login(byToken: sess.token, user: uid) { err in
            self.sendLoginCallback(err,{tr,msg in
                if(tr == TaskResult.Succ){
                    self.state = RtmEngine.ENTERED
                }
                //todo:
                self.heartbeatTimer()
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
        
        kit?.agoraRtmDelegate = nil
        self._statusUpdated = nil
        stopTimer()
        if(self._enterCallback != nil){
            self._enterCallback?(.Abort,"abort login")
            self._enterCallback = nil
        }
        
        if(state != RtmEngine.ENTERED){
            log.e("rtm state : \(state) error for leave()")
            kit = nil
            cb(false)
            return
        }
        
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(false)
            return
        }
        kit.logout {[weak self] err in
            self?.state = RtmEngine.IDLED
            self?.kit = nil
            DispatchQueue.main.async {
                self?.sendLogoutCallback(err, cb)
            }
        }
    }
    private func sendCallback(_ sequenceId:String, _ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(Int,String)->Void){
        let reMsg = getRtmSendMsg(e)
        if(reMsg.errCode != ErrCode.XOK){
            log.e("rtm send message result:\(reMsg.msg)(\(reMsg))")
            cb(reMsg.errCode,reMsg.msg)
        }else{
            _completionBlocks[sequenceId] = cb
        }
       
    }
    
    private func sendCallback(_ sequenceId:String, _ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(Int,Dictionary<String, Any>)->Void){
        let reMsg = getRtmSendMsg(e)
        if(reMsg.errCode != ErrCode.XOK){
            log.e("rtm send message result:\(reMsg.msg)(\(reMsg.errCode))")
            cb(reMsg.errCode,[:])
        }else{
            _completionDicBlocks[sequenceId] = cb
        }
    }
    
    func getRtmSendMsg(_ e:AgoraRtmSendPeerMessageErrorCode)->(errCode:Int,msg:String){
        
        var msg = "unknown error"
        var ec:Int = ErrCode.XERR_API_RET_FAIL
        switch(e){
        case .ok:
            ec = ErrCode.XOK
            msg = "rtm send succ"
        case .failure:
            msg = "rtm snd fail"
        case .timeout:
            ec = ErrCode.XERR_TIMEOUT
            msg = "rtm send timeout"
        case .peerUnreachable:
            msg = "rtm unreachable"
        case .cachedByServer:
            msg = "rtm msg cached"
        case .tooOften:
            msg = "rtm send too often"
        case .invalidUserId:
            msg = "rtm userid invalid"
        case .invalidMessage:
            msg = "rtm msg invalid"
        case .imcompatibleMessage:
            msg = "rtm msg imcompatible"
        case .notInitialized:
            msg = "rtm not initialized"
        case .notLoggedIn:
            msg = "rtm not loggedin"
        @unknown default:
            msg = "unknown error"
            ec = ErrCode.XERR_UNKNOWN
        }
        return (ec,msg)
    }
    
    
    func sendStringMessage(sequenceId:String, toPeer:String,message:String,cb:@escaping(Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtm not initialized")
            return
        }
        if(message.count >= config.maxRtmPackage){
            log.e("rtm package size(\(message.count) exceeds limit(\(config.maxRtmPackage)")
            cb(ErrCode.XERR_BUFFER_OVERFLOW,"rtm msg length overflow")
            return
        }
        let package = AgoraRtmMessage(text: message)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            DispatchQueue.main.async {
                self.sendCallback(sequenceId,ec,cb)
            }
        }
    }
    func sendRawMessage(sequenceId:String, toPeer:String,data:Data,description:String,cb:@escaping(Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtm not initialized")
            return
        }
        if(data.count >= config.maxRtmPackage){
            log.e("rtm package size(\(data.count) exceeds limit(\(config.maxRtmPackage)")
            cb(ErrCode.XERR_BUFFER_OVERFLOW,"rtm msg length overfloat")
            return
        }
        let package = AgoraRtmRawMessage(rawData: data, description: description)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            DispatchQueue.main.async {
                self.sendCallback(sequenceId,ec,cb)
            }
        }
    }
    
    func sendRawMessageDic(sequenceId:String, toPeer:String,data:Data,description:String,cb:@escaping(Int,Dictionary<String, Any>)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,[:])
            return
        }
        if(data.count >= config.maxRtmPackage){
            log.e("rtm package size(\(data.count) exceeds limit(\(config.maxRtmPackage)")
            cb(ErrCode.XERR_BUFFER_OVERFLOW,[:])
            return
        }
        let package = AgoraRtmRawMessage(rawData: data, description: description)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            DispatchQueue.main.async {
                self.sendCallback(sequenceId,ec,cb)
            }
        }
    }
    
    func destroy(){
        log.i("rtm is destroying()")
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
    func createThenEnter(_ setting:RtmSetting,_ sess:RtmSession,_ uid:String,cb:@escaping (TaskResult,String)->Void){
        log.i("rtm createThenEnter when state:\(state)")
        if(!create(setting)){
            log.w("rtm create kit error when createAndEnter")
            cb(.Fail,"create rtm fail")
            return
        }
        enter(sess,uid, cb)
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
    
    func handelReceivedData(message: AgoraRtmMessage, fromPeer peerId: String) -> Void {
        
        if(message.type == .raw){
            if let msg = message as? AgoraRtmRawMessage{
                let dict = String.getDictionaryFromData(data: msg.rawData)
                log.i("handelReceivedData dict: \(dict)")
                guard let sequenceId = dict["sequenceId"] as? UInt else {
                    log.e("handelReceivedData: dict:\(dict))")
                    return
                }
                // 根据sequenceId获取对应的闭包
                let completionBlock = _completionBlocks["\(sequenceId)"]
                let completionDicBlock = _completionDicBlocks["\(sequenceId)"]
   
                if let resultDic = dict["data"] as? [String:Any] {
                    let code = dict["code"] as? Int ?? -9999
                    DispatchQueue.main.async {
                        completionDicBlock?(code, resultDic)
                    }
                }else{
                    guard let code = dict["code"] as? Int else{
                        log.e("handelReceivedData: dict:\(dict))")
                        completionBlock?(ErrCode.XERR_UNKNOWN, "")
                        return
                    }
                    DispatchQueue.main.async {
                        completionBlock?(ErrCode.XOK, "success")
                    }
                }
            }
            else{
                log.e("rtm message type cast error")
            }
        }else if (message.type == .text){
            
            let dict = String.getDictionaryFromJSONString(jsonString: message.text)
            
            guard let sequenceId = dict["sequenceId"] as? UInt else {
                log.e("handelReceivedData: dict:\(dict))")
                return
            }
            // 根据sequenceId获取对应的闭包
            let completionBlock = _completionBlocks["\(sequenceId)"]
            let completionDicBlock = _completionDicBlocks["\(sequenceId)"]
            
            guard let code = dict["code"] as? Int, code == 0 else{
                log.e("handelReceivedData: dict:\(dict))")
                completionBlock?(ErrCode.XERR_UNKNOWN, "")
                return
            }
            
            if let resultDic = dict["data"] as? [String:Any] {
                DispatchQueue.main.async {
                    completionDicBlock?(ErrCode.XOK,resultDic)
                }
            }else{
                DispatchQueue.main.async {
                    completionBlock?(ErrCode.XOK, "success")
                }
            }
            
            _completionBlocks["\(sequenceId)"] = nil
            _completionDicBlocks["\(sequenceId)"] = nil
            
        }
        else{
            log.w("rtm unhandled messate type \(message.type)")
        }
        
    }
}

extension RtmEngine : AgoraRtmDelegate{
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        log.i("rtm messageReceived from \(peerId) type:\(message.type) ts:\(message.serverReceivedTs) offline:\(message.isOfflineMessage)")
        
        handelReceivedData(message: message, fromPeer: peerId)
        
        
        
//        if(message.type == .raw){
//            if let raw = message as? AgoraRtmRawMessage{
//                DispatchQueue.main.async {
//                    self._statusUpdated?(.DataArrived,peerId,raw.rawData)
//                }
//            }
//            else{
//                log.e("rtm message type cast error")
//            }
//        }else if(message.type == .text){
//            DispatchQueue.main.async {
//                self._statusUpdated?(.DataArrived,peerId,message.text)
//            }
//        }
//        else{
//            log.w("rtm unhandled messate type \(message.type)")
//        }
    }
    private func sendStateUpdated(_ state: AgoraRtmConnectionState, _ reason: AgoraRtmConnectionChangeReason){
        switch(state){
        case .disconnected:
            self._statusUpdated?(.Disconnected,"disconnected",nil)
        case .connecting:
            self._statusUpdated?(.Connecting,"connecting",nil)
        case .connected:
            if(self._enterCallback != nil){
                self._enterCallback?(.Succ,"rtm redady to send msg")
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
    
    func rtmKit(_ kit: AgoraRtmKit, peersOnlineStatusChanged onlineStatus: [AgoraRtmPeerOnlineStatus]) {
        
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

extension RtmEngine{
    
    func  heartbeatTimer(){
        timer = Timer()
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(sendMessage), userInfo: nil, repeats: true)
    }
    
    @objc func sendMessage() {
        // 在这里实现发送消息的逻辑
        log.i("send heartbeat msg")
        guard let peer =  curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let curSequenceId : UInt32 = 1
        
        let paramDic = [:] as [String : Any]
        let jsonString = paramDic.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
//        sendStringMessage(sequenceId: "\(curTimestamp)", toPeer: peer, message: jsonString) { code, msg in
//            log.i("RtmEnginesendStringMessage")
//        }
        sendRawMessage(sequenceId: "\(curSequenceId)", toPeer: peer, data: data, description: "") { code, msg in
            log.i("RtmEnginesendStringMessage")
        }
    }
    
    func stopTimer() {
        log.i("RtmEngine timer is nil")
        timer?.invalidate()
        timer = nil
    }
    
    
}
