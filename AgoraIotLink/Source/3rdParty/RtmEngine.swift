//
//  RtmEngine.swift
//  AgoraIotLink
//
//  Created by ADMIN on 2022/8/8.
//

import Foundation
import AgoraRtmKit

/*
 * @brief rtm通信时的状态事件
 */
@objc public enum MessageChannelStatus : Int{
    case DataArrived                                    //收到数据
    case Disconnected                                   //连接断开
    case Connecting                                     //连接中
    case Connected                                      //连接成功
    case Reconnecting                                   //重连中
    case Aborted                                        //中断
    case TokenWillExpire                                //token将要过期
    case TokenDidExpire                                 //token已经过期
    case UnknownError                                   //未知错误
}

/*
 * @brief 连接返回
 */
@objc public class RtmMsgObj : NSObject{
    
    @objc public var sequenceId: String = ""            //标记Id
    @objc public var  timeStamp: TimeInterval = 0       //标记时间戳
    public typealias ReaultAck = (Int,Any)->Void     //返回类型，字符串
    @objc public var msgObj :ReaultAck = {a,c in log.w("msgObj not inited")}
    
    @objc public init(sequenceId:String ,
                      timeStamp:TimeInterval,
                      msgObj:@escaping ReaultAck
    ){
        self.sequenceId = sequenceId
        self.timeStamp = timeStamp
        self.msgObj = msgObj
    }
}

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
    var curUpdateState : MessageChannelStatus?
    
    var timerTimeout: Timer?
    
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
    private var _onReceivedCommandCallback:((_ sessionId:String,_ cmd:String)->Void)? = nil
    
    private var _completionBlocks: [String: ((Int, String) -> Void)] = [:]
    private var _completionDicBlocks: [String: ((Int, Dictionary<String, Any>) -> Void)] = [:]
    
    
    
    private var _completionMsgObjs: [String: RtmMsgObj] = [:]
    
    public func waitForStatusUpdated(statusUpdated:@escaping(MessageChannelStatus,String,AgoraRtmMessage?)->Void){
        _statusUpdated = statusUpdated
    }
    
    public func waitReceivedCommandCallback(_ receivedListener: @escaping (_ sessionId:String,_ cmd:String) -> Void){
        _onReceivedCommandCallback = receivedListener
    }
    
    
    func enter(_ sess:RtmSession,_ uid:String,_ cb:@escaping (TaskResult,String)->Void){
        log.i("rtm try enter with token:\(sess.token),local:\(uid)")
        curSession = sess
        if(self._statusUpdated != nil){
            log.w("rtm _statusChanged is not nil,should call sendMessageEnd() before sendMessageBegin()")
        }
        kit?.login(byToken: sess.token, user: uid) { err in
            self.sendLoginCallback(err,{tr,msg in
                if(tr == TaskResult.Succ){
                    self.state = RtmEngine.ENTERED
                }
                self.heartbeatTimer()
                cb(tr,msg)
            })
        }
    }
    
    func renewToken(_ token : String){
        log.i("rtm renewToken:")
        kit?.renewToken(token)
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
    
    private func sendCallDicback(_ sequenceId:String, _ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(Int,Dictionary<String, Any>)->Void){
        let reMsg = getRtmSendMsg(e)
        if(reMsg.errCode != ErrCode.XOK){
            log.e("rtm send dic message result:\(reMsg.msg)(\(reMsg.errCode))")
            _completionMsgObjs[sequenceId] = nil
            cb(reMsg.errCode,[:])
        }
    }
    
    private func setCallDicback(_ sequenceId:String,_ cb:@escaping(Int,Dictionary<String, Any>)->Void){

        log.i("setCallDicback 开始 cb:\(String(describing: cb))")
        let rtmMsgObj = RtmMsgObj(sequenceId: sequenceId, timeStamp: String.dateCurrentTime()) { code, result in
            if let strResult = result as? Dictionary<String, Any>{
                log.i("setCallDicback 结果)")
                cb(code,strResult)
            }else{
                cb(code,[:])
            }
        }
        _completionMsgObjs[sequenceId] = rtmMsgObj
        log.e("setCallDicback  sequenceId:\(sequenceId) _completionBlocks:\(_completionMsgObjs) count:\(_completionMsgObjs.count)")
        
    }
    
    private func sendCallStringback(_ sequenceId:String, _ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(Int,String)->Void){
        let reMsg = getRtmSendMsg(e)
        if(reMsg.errCode != ErrCode.XOK){
            log.e("rtm send string message result:\(reMsg.msg)(\(reMsg) sequenceId:\(sequenceId) _completionBlocks:\(_completionBlocks))")
            _completionMsgObjs[sequenceId] = nil
            cb(reMsg.errCode,reMsg.msg)
        }
    }
    
    private func setCallStringback(_ sequenceId:String,_ cb:@escaping(Int,String)->Void){

        log.i("setCallStringback 开始 cb:\(String(describing: cb))")
        let rtmMsgObj = RtmMsgObj(sequenceId: sequenceId, timeStamp: String.dateCurrentTime()) { code, result in
            if let strResult = result as? String{
                log.i("setCallStringback 结果)")
                cb(code,strResult)
            }
        }
        _completionMsgObjs[sequenceId] = rtmMsgObj
        log.e("setCallStringback  sequenceId:\(sequenceId) _completionBlocks:\(_completionMsgObjs) count:\(_completionMsgObjs.count)")
        
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
            if ec != .ok{
                self.sendCallStringback(sequenceId,ec,cb)
            }
        }
        setCallStringback(sequenceId, cb)
        
    }
    
    func sendRawGenerlMessage(toPeer:String,data:Data,description:String,cb:@escaping(Int,String)->Void){
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
            cb(ec.rawValue,"msg")
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
            if ec != .ok{
                self.sendCallStringback(sequenceId,ec,cb)
            }
        }
        setCallStringback(sequenceId, cb)
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
            if ec != .ok{
                self.sendCallDicback(sequenceId,ec,cb)
            }
        }
        setCallDicback(sequenceId, cb)
    }
    
    func destroy(){
        log.i("rtm is destroying()")
        if(kit == nil){
            log.e("rtm engine is nil")
            return
        }
        if(state != RtmEngine.CREATED){
            log.e("rtm state:\(state) not correct")
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
                    log.w("rtm leave channel error when leaveAndDestroy")
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
    
    func getSessionId(peerId:String)->String{
        guard let callObj = CallListenerManager.sharedInstance.getCurrentCallObjetWithPeerId(peerId) else{
            return ""
        }
        return callObj.callSession?.mSessionId ?? ""
    }
    
    func handelReceivedData(message: AgoraRtmMessage, fromPeer peerId: String) -> Void {
        
        if(message.type == .raw){
            if let msg = message as? AgoraRtmRawMessage{
                let jsonString = msg.rawData.convertDataToJSONString().replacingOccurrences(of: "\0", with: "")
                log.i("handelReceivedData:\(jsonString)")
                DispatchQueue.main.async { [weak self] in
                    let sessionId = self?.getSessionId(peerId: peerId) ?? ""
                    self?._onReceivedCommandCallback?(sessionId,jsonString)
                }
                return
                
//                let dict = String.getDictionaryFromData(data: msg.rawData)
//                log.i("handelReceivedData type:raw dict: \(dict)")
//                guard let sequenceId = dict["sequenceId"] as? UInt else {
//                    log.e("handelReceivedData: dict:\(dict))")
//                    return
//                }
//                // 根据sequenceId获取对应的闭包
//                let cbMsgObj = _completionMsgObjs["\(sequenceId)"]
//
//
//                //判断是否正确返回，code = 0
//                guard let code = dict["code"] as? Int, code == 0 else{
//                    log.e("handelReceivedData: dict:\(dict))")
//                    guard let cbBlock = cbMsgObj?.msgObj else {
//                        log.e("handelReceivedData: cbBlock nil )")
//                        return
//                    }
//                    cbBlock(dict["code"] as? Int ?? -1, "fail")
//                    _completionMsgObjs["\(sequenceId)"] = nil
//                    return
//                }
//
//                //判断是否带字典的返回
//                if let resultDic = dict["data"] as? [String:Any] {
//                    DispatchQueue.main.async { [weak self] in
//
//                        guard let cbBlock = cbMsgObj?.msgObj else {
//                            log.e("handelReceivedData: cbBlock nil )")
//                            return
//                        }
//                        cbBlock(code, resultDic)
//                        self?._completionMsgObjs["\(sequenceId)"] = nil
//                    }
//                }else{
//                    DispatchQueue.main.async { [weak self] in
//                        guard let cbBlock = cbMsgObj?.msgObj else {
//                            log.e("handelReceivedData: cbBlock nil )")
//                            return
//                        }
//                        cbBlock(code, "success")
//                        self?._completionMsgObjs["\(sequenceId)"] = nil
//                    }
//
//                }
            }
            else{
                log.e("rtm message type cast error")
            }
        }
        else if (message.type == .text){
            
            let dict = String.getDictionaryFromJSONString(jsonString: message.text)
            log.i("handelReceivedData type:text dict: \(dict)")
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
                _completionDicBlocks["\(sequenceId)"] = nil
            }else{
                DispatchQueue.main.async {
                    completionBlock?(ErrCode.XOK, "success")
                }
                _completionBlocks["\(sequenceId)"] = nil
            }
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
            curUpdateState = .Disconnected
            self._statusUpdated?(.Disconnected,"disconnected",nil)
        case .connecting:
            curUpdateState = .Connecting
            self._statusUpdated?(.Connecting,"connecting",nil)
        case .connected:
            curUpdateState = .Connected
            if(self._enterCallback != nil){
                self._enterCallback?(.Succ,"rtm redady to send msg")
                self._enterCallback = nil
            }
            else{
                self._statusUpdated?(.Connected,"connected",nil)
            }
        case .reconnecting:
            curUpdateState = .Reconnecting
            self._statusUpdated?(.Reconnecting,"reconnecting",nil)
        case .aborted:
            curUpdateState = .Aborted
            self._statusUpdated?(.Aborted,"aborted",nil)
        @unknown default:
            curUpdateState = .UnknownError
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
            self.curUpdateState = .TokenDidExpire
            self._statusUpdated?(.TokenDidExpire,"",nil)
        }
    }
    
    func rtmKitTokenPrivilegeWillExpire(_ kit: AgoraRtmKit) {
        log.i("rtm rtmKitTokenPrivilegeWillExpire")
        DispatchQueue.main.async {
            self.curUpdateState = .TokenWillExpire
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
        timer = Timer.scheduledTimer(timeInterval: 5*60, target: self, selector: #selector(sendMessage), userInfo: nil, repeats: true)
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

extension RtmEngine{
    
    func  timeOutTimer(){
        timerTimeout = Timer()
        startTimeOut()
    }
    
    func startTimeOut() {
        timerTimeout = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(handelTimeOut), userInfo: nil, repeats: true)
    }
    
    @objc func handelTimeOut() {
        // 在这里实现发送消息的逻辑
        log.i("send heartbeat msg")
        handelRtmMsgTimeout()
        
    }
    
    func handelRtmMsgTimeout(){
        
        for (key,obj) in _completionMsgObjs{
            let lastTime = obj.timeStamp
            let timeSpace = String.dateTimeSpaceMillion(lastTime)
            if timeSpace > 10{
                let callBack = obj.msgObj
                callBack(0,"resut string")
                _completionMsgObjs["\(key)"] = nil
            }
        }
    }
    
    func stopTimerOut() {
        log.i("RtmEngine timer is nil")
        timerTimeout?.invalidate()
        timerTimeout = nil
    }
    
}
