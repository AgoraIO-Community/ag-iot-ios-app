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
 * @brief rtm 自身状态
 */
@objc public enum RtmStatus : Int{
    case IDLED                                    //空闲
    case CREATED                                  //已创建sdk
    case ENTERING                                 //登陆中
    case ENTERED                                  //登陆成功
}

/*
 * @brief 连接返回
 */
@objc public class RtmMsgObj : NSObject{
    
    @objc public var sequenceId: String = ""            //标记Id
    @objc public var playingId: String = ""             //标记SD卡播放Id
    @objc public var  timeStamp: TimeInterval = 0       //标记时间戳
    public typealias ReaultAck = (Int,String,Any)->Void     //返回类型，字符串
    @objc public var msgObj :ReaultAck = {c,p,a in log.w("msgObj not inited")}
    
    @objc public init(sequenceId:String ,
                      playingId:String ,
                      timeStamp:TimeInterval,
                      msgObj:@escaping ReaultAck
    ){
        self.sequenceId = sequenceId
        self.playingId = playingId
        self.timeStamp = timeStamp
        self.msgObj = msgObj
    }
}

class RtmEngine : NSObject{
    
    var app  = Application.shared
    var timerTimeout: Timer?                       //超时定时器
    let commandTimeOut   : TimeInterval = 10*1000  //命令超时时间 ms
    let commandCheckTime : TimeInterval = 4        //命令检测时间 s
    
    private var kit:AgoraRtmKit? = nil
    private var state:RtmStatus  = .IDLED
    var timer: Timer?             //心跳定时器
    var curSession: RtmSession?
    
    var curPlayingId: String = ""        //当前SD卡播放ID
    //--------sdcard播放及停止命令--------
    let  sd_play_video: String = "sd_play_video"
    let  sd_play_timeline_video: String = "sd_play_timeline_video"
    let  sd_stop_video: String = "sd_stop_video"
    let  sd_stop_timeline_video: String = "sd_stop_timeline_video"

    
    init(cfg:Config) {
        self.state = .IDLED
    }
    
    deinit {
        app.sdkState = .invalid
        log.i("RtmEngine 销毁了")
    }
    
    //rtm 初始化
    func create(_ setting:RtmSetting)->Bool{
        let version = AgoraRtmKit.getSDKVersion()
        log.i("rtm is creating,version:\(String(describing: version))")
        kit = AgoraRtmKit(appId: setting.appId, delegate: self)
        if(kit == nil){
            log.e("rtm create engine kit fail")
            return false
        }
        state = .CREATED
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
    private var _completionMsgObjs: [String: RtmMsgObj] = [:]
    private var _customDataReceiveBack:((String, Data)->Void)?  = nil
    
//    private var _completionBlocks: [String: ((Int, String) -> Void)]? = nil
//    private var _completionDicBlocks: [String: ((Int, Dictionary<String, Any>) -> Void)]? = nil
    
    //监听rtm连接状态
    public func waitForStatusUpdated(statusUpdated:@escaping(MessageChannelStatus,String,AgoraRtmMessage?)->Void){
        _statusUpdated = statusUpdated
    }
    
    //监听收到自定义数据
    func devRawMsgSetRecvListener(dataListener: @escaping (_ deviceRtmUid :String,_ data:Data) -> Void){
        _customDataReceiveBack = dataListener
    }
    
    
    func enter(_ sess:RtmSession,_ uid:String,_ cb:@escaping (TaskResult,String)->Void){
        log.i("rtm try enter with loca uid:\(uid)")
        self.state = .ENTERING
        curSession = sess
        kit?.login(byToken: sess.token, user: uid) {[weak self] err in
            self?.sendLoginCallback(err,{tr,msg in
                if(tr == TaskResult.Succ){
                    self?.state = .ENTERED
                }else{
                    self?.state = .CREATED
                }
                log.i("rtm try enter result:\(tr) msg:\(msg)")
                self?.heartbeatTimer()
                self?.timeOutTimer()
                
                cb(tr,msg)
            })
        }
    }
    
    func renewToken(_ token:String, _ peerNodeId:String){//刷新token
        log.i("rtm renewToken peerNodeId:\(peerNodeId)")
        if peerNodeId != "" {//如果换了设备，则需要重新赋值peerNodeId，若当前设备token过期，则只需要刷新token
            curSession?.peerVirtualNumber = peerNodeId
        }
        curSession?.token = token
        kit?.renewToken(token,completion: { token, errorCode in
            log.i("rtm renewToken result ret:\(errorCode)")
        })
    }
    
    func getRtmState()->RtmStatus{
        return state
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
        _statusUpdated = nil
        _customDataReceiveBack = nil
        _enterCallback = nil
        curSession = nil
        curPlayingId = ""
//        _completionBlocks = nil
//        _completionDicBlocks = nil
        
        stopTimer()
        stopTimerOut()
        
        if(state != .ENTERED){
            log.e("rtm state : \(String(describing: state)) error for leave()")
            kit = nil
            cb(false)
            return
        }
        
        log.i("rtm try leaveChannel kit logout ...")
        kit?.logout {[weak self] err in
            log.i("rtm try leaveChannel kit logout finished ...")
            self?.kit = nil
            if err == .ok{
                cb(true)
            }else{
                cb(false)
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
    
    private func sendCallStringback(_ sequenceId:String, _ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(Int,String)->Void){
        let reMsg = getRtmSendMsg(e)
        if(reMsg.errCode != ErrCode.XOK){
            log.e("rtm send string message result:\(reMsg.msg)(\(reMsg) sequenceId:\(sequenceId))")
            _completionMsgObjs[sequenceId] = nil
            cb(reMsg.errCode,reMsg.msg)
        }
    }
    
    private func setCallDicback(_ sequenceId:String,_ cb:@escaping(Int,Dictionary<String, Any>)->Void){

        log.i("setCallDicback start")
        let rtmMsgObj = RtmMsgObj(sequenceId: sequenceId,playingId: "", timeStamp: String.dateCurrentTime()) { code,playId,result in
            if let strResult = result as? Dictionary<String, Any>{
                log.i("setCallDicback result:\(result)")
                cb(code,strResult)
            }else{
                cb(code,[:])
            }
        }
        _completionMsgObjs[sequenceId] = rtmMsgObj
        log.e("setCallDicback  sequenceId:\(sequenceId) _completionBlocks:\(String(describing: _completionMsgObjs)) count:\(String(describing: _completionMsgObjs.count))")
        
    }
    
    private func setCallStringback(_ sequenceId:String,_ cb:@escaping(Int,String)->Void){

        log.i("setCallStringback start")
        let rtmMsgObj = RtmMsgObj(sequenceId: sequenceId,playingId: "", timeStamp: String.dateCurrentTime()) { code,playId, result in
            if let strResult = result as? String{
                log.i("setCallStringback result code:\(code)")
                cb(code,strResult)
            }
        }
        _completionMsgObjs[sequenceId] = rtmMsgObj
        log.i("setCallStringback  sequenceId:\(sequenceId) _completionBlocks:\(String(describing: _completionMsgObjs)) count:\(String(describing: _completionMsgObjs.count))")
        
    }

    func sendRawMessage(sequenceId:String, toPeer:String,data:Data,description:String,cb:@escaping(Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtm not initialized")
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
    
    func sendRawMessageCustomData(toPeer:String,data:Data,description:String,cb:@escaping(Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"")
            return
        }
        
        let package = AgoraRtmRawMessage(rawData: data, description: description)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            let reMsg = self.getRtmSendMsg(ec)
            cb(reMsg.errCode,reMsg.msg)
        }
    }
    
    func handelReceivedData(message: AgoraRtmMessage, fromPeer peerId: String) -> Void {
        
        if(message.type == .raw){
            if let msg = message as? AgoraRtmRawMessage{
                
                let dict = String.getDictionaryFromData(data: msg.rawData)
                
                log.i("handelReceivedData type:raw dict: \(dict)")
                
                //jd_判断 commandId 是否为空，为空则认为是自定义的raw消息，裸数据返回
                guard let commandId = dict["commandId"] as? String else{
                    _customDataReceiveBack?(peerId, msg.rawData)
                    return
                }
                log.i("handelReceivedData:commandId:\(commandId))")
                
                //判断 sequenceId 是否为空
                guard let sequenceId = dict["sequenceId"] as? UInt else {
                    log.i("handelReceivedData: sequenceId is nil dict:\(dict))")
                    return
                }
                // 根据sequenceId获取对应的闭包
                let cbMsgObj = _completionMsgObjs["\(sequenceId)"]
                // 获取SD卡回看中的playingId，若是其他控制命令，该字段为空
                let playingId = cbMsgObj?.playingId ?? ""
   
               
                //判断是否正确返回，code = 0
                guard let code = dict["code"] as? Int, code >= 0 else{
                    log.e("handelReceivedData: dict:\(dict))")
                    guard let cbBlock = cbMsgObj?.msgObj else {
                        log.e("handelReceivedData: cbBlock nil )")
                        return
                    }
                    cbBlock(dict["code"] as? Int ?? -1,playingId,"fail")
                    _completionMsgObjs["\(sequenceId)"] = nil
                    return
                }
   
                //判断是否带字典的返回
                if let resultDic = dict["data"] as? [String:Any] {
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let cbBlock = cbMsgObj?.msgObj else {
                            log.e("handelReceivedData: cbBlock nil )")
                            return
                        }
                        cbBlock(code,playingId, resultDic)
                        self?._completionMsgObjs["\(sequenceId)"] = nil
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        guard let cbBlock = cbMsgObj?.msgObj else {
                            log.e("handelReceivedData: cbBlock nil )")
                            return
                        }
                        cbBlock(code,playingId,"success")
                        self?._completionMsgObjs["\(sequenceId)"] = nil
                    }
                    
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

}

//sdCard播放命令相关
extension RtmEngine{
    
    private func isSDPlayAction(_ cmdId: String)->Bool{
        
//        if cmdId == 2006  {
//            return true
//        }
        if cmdId == sd_play_video || cmdId == sd_play_timeline_video{
            return true
        }
        return false
    }
    
    private func isSDStopAction(_ cmdId: String)->Bool{
        
//        if cmdId == 2007 {
//            return true
//        }
        if cmdId == sd_stop_video || cmdId == sd_stop_timeline_video{
            return true
        }
        return false
    }
    
    private func isSDCurrentPlaying(_ playId: String)->Bool{
        if  playId == curPlayingId {
            return true
        }
        return false
    }
    
    private func setCallMediaSDCardback(_ sequenceId:String,_ cmdId:String, _ cb:@escaping(Int,Dictionary<String, Any>)->Void){

        log.i("setCallMediaSDCardback 开始 sequenceId:\(sequenceId)  cmdId:\(cmdId))")
        var playingId = curPlayingId
        
        if isSDPlayAction(cmdId) == true  {
            let curTimestamp:Int = String.dateCurrentIntTime()
            playingId = "\(curTimestamp)" + "&" + "\(sequenceId)"
            curPlayingId = playingId
            log.i("curSDCardPlayingId:\(curPlayingId)")
        }
        if isSDStopAction(cmdId) == true {
            playingId = ""
            curPlayingId = ""
        }
        
        let rtmMsgObj = RtmMsgObj(sequenceId: sequenceId,playingId: playingId, timeStamp: String.dateCurrentTime()) {[weak self] code,playId, result in
            
            guard self?.isSDCurrentPlaying(playId) == true else {
                log.i("not current sdcard playing--- playId:\(playId) curSDCardPlayingId:\(String(describing: self?.curPlayingId))--- code:\(code) result:\(result)")
                return
            }
            if let strResult = result as? Dictionary<String, Any>{
                log.i("setCallMediaSDCardback result dic")
                cb(code,strResult)
            }else if let strResult = result as? String{
                log.i("setCallMediaSDCardback result string")
                cb(code,[:])
            }else{
                cb(code,[:])
            }
        }
        _completionMsgObjs[sequenceId] = rtmMsgObj
        log.i("setCallDicback  sequenceId:\(sequenceId) _completionBlocks:\(String(describing: _completionMsgObjs)) count:\(String(describing: _completionMsgObjs.count))")
        
    }
    
    func sendMediaSDPlayMessage(sequenceId:String, toPeer:String,param:[String:Any],description:String,cb:@escaping(Int,Dictionary<String, Any>)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(ErrCode.XERR_BAD_STATE,[:])
            return
        }
        
//        guard let cmdId = param["commandId"] as? Int else {
//            log.e("commandId is nil")
//            cb(ErrCode.XERR_INVALID_PARAM,[:])
//            return
//        }
        
        guard let cmdId = param["commandId"] as? String else {
            log.e("commandId is nil")
            cb(ErrCode.XERR_INVALID_PARAM,[:])
            return
        }
        
        setCallMediaSDCardback(sequenceId,cmdId,cb)
        
        let jsonString = param.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
        
        let package = AgoraRtmRawMessage(rawData: data, description: description)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        kit.send(package, toPeer: toPeer, sendMessageOptions: option) { ec in
            if ec != .ok{
                self.sendCallDicback(sequenceId,ec,cb)
            }
        }
    }
    
}

extension RtmEngine : AgoraRtmDelegate{
    
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        log.i("rtm messageReceived from \(peerId) type:\(message.type) ts:\(message.serverReceivedTs) offline:\(message.isOfflineMessage)")
        
        handelReceivedData(message: message, fromPeer: peerId)
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
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(sendMessage), userInfo: nil, repeats: true)
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
            log.i("RtmEngine sendHeartBeatMessage suc")
        }
    }
    
    func stopTimer() {
        log.i("RtmEngine timer is nil")
        timer?.invalidate()
        timer = nil
    }
    
}

extension RtmEngine{//超时处理

    func  timeOutTimer(){
        startTimeOut()
    }

    func startTimeOut() {
        timerTimeout = Timer.scheduledTimer(timeInterval: commandCheckTime, target: self, selector: #selector(handelTimeOut), userInfo: nil, repeats: true)
    }

    @objc func handelTimeOut() {
        // 在这里实现发送消息的逻辑
        handelRtmMsgTimeout()

    }

    func handelRtmMsgTimeout(){
        
        guard _completionMsgObjs.count > 0 else{ return }
        
        var keysToRemove: [String] = []
        for (key,obj) in _completionMsgObjs{
            let lastTime = obj.timeStamp
            let timeSpace = String.dateTimeSpaceMillion(lastTime)
            if timeSpace > commandTimeOut{
                let callBack = obj.msgObj
                let playingId = obj.playingId
                callBack(ErrCode.XERR_TIMEOUT,playingId,"resut TimeOut")
                keysToRemove.append(key)
            }
        }
        
        for key in keysToRemove {
            _completionMsgObjs.removeValue(forKey: key)
        }
        
    }

    func stopTimerOut() {
        log.i("RtmEngine timerOut is nil")
        timerTimeout?.invalidate()
        timerTimeout = nil
    }

}
