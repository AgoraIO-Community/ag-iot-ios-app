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
 * @brief 信令对象
 */
@objc public class RtmMsgObj : NSObject{
    
    @objc public var sequenceId: UInt32 = 0             //信令标记Id
    @objc public     var peerId: String = ""            //对端Id
    @objc public     var msgObj: Data?                  //信令内容
    @objc public var  timeStamp: TimeInterval = 0       //标记时间戳
    public typealias ReqAck = (UInt32,Int,String)->Void        //返回类型
    @objc public var reqCbObj :ReqAck = {s,c,m in log.w("reqCbObj not inited")}
    
    @objc public init(sequenceId:UInt32 ,
                          peerId:String,
                          msgObj:Data,
                       timeStamp:TimeInterval,
                      reqCbObj:@escaping ReqAck
    ){
        self.sequenceId = sequenceId
        self.peerId = peerId
        self.msgObj = msgObj
        self.timeStamp = timeStamp
        self.reqCbObj = reqCbObj
    }
}

class RtmEngine : NSObject{
    
    var app  = IotLibrary.shared
    var timerTimeout: Timer?
    let commandTimeOut   : TimeInterval = 10*1000  //命令超时时间 ms
    let commandCheckTime : TimeInterval = 4        //命令检测时间 s
    
    private var kit:AgoraRtmKit? = nil
    private var config:Config
    private var state:RtmStatus = .IDLED
    var curSession: RtmSession?
    private var curUpdateState : MessageChannelStatus?
    
    private var _statusUpdated:((MessageChannelStatus,String,AgoraRtmMessage?)->Void)?  = nil
    private var _enterCallback:((Int,String)->Void)? = nil
    
    private var _onReceivedCommandCallback:((_ sessionId:String,_ receiveData:Data)->Void)? = nil
    
//    private var _notSendMsgMsgObjs: [String: RtmMsgObj] = [:]
    private var _notSendMsgMsgObjs = ThreadSafeDictionary<String,RtmMsgObj>()
        
    
    init(cfg:Config) {
        self.config = cfg
        self.state = .IDLED
    }
    
    deinit {
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
    
    func enter(_ sess:RtmSession,_ uid:String,_ cb:@escaping (Int,String)->Void){
        log.i("rtm try enter with token:\(sess.token),local:\(uid)")
        self.state = .ENTERING
        curSession = sess
        if(self._statusUpdated != nil){
            log.w("rtm _statusChanged is not nil,should call sendMessageEnd() before sendMessageBegin()")
        }
        kit?.login(byToken: sess.token, user: uid) {[weak self] err in
            self?.sendLoginCallback(err,{tr,msg in
                if(tr == ErrCode.XOK){
                    self?.state = .ENTERED
                }else{
                    self?.state = .CREATED
                }
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
    
    func leave(cb:@escaping (Bool)->Void){
        log.i("rtm try leaveChannel ...")
        
        kit?.agoraRtmDelegate = nil
        _statusUpdated = nil
        _enterCallback = nil
        curSession = nil
        stopTimerOut()
        
        if(state != .ENTERED){
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
        
        log.i("rtm try leaveChannel kit logout ...")
        kit.logout {[weak self] err in
            log.i("rtm try leaveChannel kit logout finished ...")
            self?.kit = nil
            self?.state = .IDLED
            if err == .ok{
                cb(true)
            }else{
                //可以判断失败原因并打印
                self?.sendLogoutCallback(err, cb)
                cb(false)
            }
        }
    }
    
    private func sendLoginCallback(_ e:AgoraRtmLoginErrorCode,_ cb:@escaping(Int,String)->Void){
        var msg = "unknown error"
        var ec:Int = ErrCode.XERR_SYSTEM
        switch(e){
        case .ok:
            ec = ErrCode.XOK
            msg = "login succ,connecting ..."
        case .unknown:
            ec = ErrCode.XERR_UNKNOWN
        case .rejected:
            msg = "rtm login rejected"
            ec = ErrCode.XERR_RTMMGR_LOGIN_REJECTED
        case .invalidArgument:
            msg = "rtm argument invalid"
            ec = ErrCode.XERR_RTMMGR_LOGIN_INVALID_ARGUMENT
        case .invalidAppId:
            msg = "rtm appid invalid"
            ec = ErrCode.XERR_RTMMGR_LOGIN_INVALID_APP_ID
        case .invalidToken:
            msg = "rtm token invalid"
            ec = ErrCode.XERR_RTMMGR_LOGIN_INVALID_TOKEN
        case .tokenExpired:
            msg = "rtm token expired"
            ec = ErrCode.XERR_RTMMGR_LOGIN_TOKEN_EXPIRED
        case .notAuthorized:
            msg = "rtm not authorized"
            ec = ErrCode.XERR_RTMMGR_LOGIN_NOT_AUTHORIZED
        case .alreadyLogin:
            ec = ErrCode.XERR_RTMMGR_LOGIN_ALREADY_LOGIN
            msg = "rtm alread login"
        case .timeout:
            msg = "rtm timeout"
            ec = ErrCode.XERR_RTMMGR_LOGIN_TIMEOUT
        case .loginTooOften:
            msg = "rtm login too offten"
            ec = ErrCode.XERR_RTMMGR_LOGIN_TOO_OFTEN
        case .loginNotInitialized:
            msg = "rtm not initialized"
            ec = ErrCode.XERR_RTMMGR_LOGIN_NOT_INITIALIZED
        @unknown default:
            msg = "unknown error"
            ec = ErrCode.XERR_RTMMGR_LOGIN_UNKNOWN
        }
        
        if(ec != ErrCode.XOK){
            log.e("rtm login result:\(msg)(\(e))")
            cb(ec,msg)
        }
        else{
            log.i("rtm login status:\(msg)(\(e.rawValue)) ...")
            self._enterCallback = cb
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
    }

    //连接状态更新处理
    private func sendStateUpdated(_ state: AgoraRtmConnectionState, _ reason: AgoraRtmConnectionChangeReason){
        switch(state){
        case .disconnected:
            log.i("sendStateUpdated: 💔💔💔💔💔💔 rtm disconnected 💔💔💔💔💔💔")
            curUpdateState = .Disconnected
            self._statusUpdated?(.Disconnected,"disconnected",nil)
        case .connecting:
            curUpdateState = .Connecting
            self._statusUpdated?(.Connecting,"connecting",nil)
        case .connected:
            log.i("sendStateUpdated: ❤️❤️❤️❤️❤️❤️ rtm connected ❤️❤️❤️❤️❤️❤️")
            curUpdateState = .Connected
            sendAlreadyMsg()
            if(self._enterCallback != nil){
                self._enterCallback?(ErrCode.XOK,"rtm redady to send msg")
                self._enterCallback = nil
            }
            else{
                self._statusUpdated?(.Connected,"connected",nil)
            }
        case .reconnecting:
            log.i("sendStateUpdated: 💔💔💔💔💔💔 rtm reconnecting 💔💔💔💔💔💔")
            curUpdateState = .Reconnecting
            self._statusUpdated?(.Reconnecting,"reconnecting",nil)
        case .aborted:
            log.e("sendStateUpdated: 💔💔💔💔💔💔 rtm aborted 💔💔💔💔💔💔")
            curUpdateState = .Aborted
            self._statusUpdated?(.Aborted,"aborted",nil)
        @unknown default:
            curUpdateState = .UnknownError
            self._statusUpdated?(.UnknownError,"unknown",nil)
        }
    }
    
    func getSessionId(peerId:String)->String{
        guard let callObj = ConnectListenerManager.sharedInstance.getCurrentCallObjetWithPeerId(peerId) else{
            return ""
        }
        return callObj.callSession?.mConnectId ?? ""
    }
    
    func getRtmState()->RtmStatus{
        return state
    }
    
    
}

//rtm引擎回调
extension RtmEngine : AgoraRtmDelegate{

    //接收到对端消息回调
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        log.i("rtm messageReceived from \(peerId) type:\(message.type) ts:\(message.serverReceivedTs) offline:\(message.isOfflineMessage)")
        handelReceivedData(message: message, fromPeer: peerId)
    }
    
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        log.i("rtm connectionStateChanged to  reason: \(reason.rawValue)  state:\(state.rawValue) ")
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

//注册监听
extension RtmEngine{
    
    //注册连接状态监听
    public func waitForStatusUpdated(statusUpdated:@escaping(MessageChannelStatus,String,AgoraRtmMessage?)->Void){
        _statusUpdated = statusUpdated
    }
    
    //注册收到消息监听
    public func waitReceivedCommandCallback(_ receivedListener: @escaping (_ sessionId:String,_ receiveData:Data) -> Void){
        _onReceivedCommandCallback = receivedListener
    }
    
}

//消息的发送，接收处理
extension RtmEngine{
    
    func getRtmSendMsg(_ e:AgoraRtmSendPeerMessageErrorCode)->(errCode:Int,msg:String){
        
        var msg = "unknown error"
        var ec:Int = ErrCode.XERR_SYSTEM
        switch(e){
        case .ok:
            ec = ErrCode.XOK
            msg = "rtm send succ"
        case .failure:
            ec = ErrCode.XERR_RTMMGR_MSG_FAILURE
            msg = "rtm snd fail"
        case .timeout:
            ec = ErrCode.XERR_TIMEOUT
            msg = "rtm send timeout"
        case .peerUnreachable:
            ec = ErrCode.XERR_RTMMGR_MSG_PEER_UNREACHABLE
            msg = "rtm unreachable"
        case .cachedByServer:
            ec = ErrCode.XERR_RTMMGR_MSG_CACHED_BY_SERVER
            msg = "rtm msg cached"
        case .tooOften:
            ec = ErrCode.XERR_RTMMGR_MSG_TOO_OFTEN
            msg = "rtm send too often"
        case .invalidUserId:
            ec = ErrCode.XERR_RTMMGR_MSG_INVALID_USERID
            msg = "rtm userid invalid"
        case .invalidMessage:
            ec = ErrCode.XERR_RTMMGR_MSG_INVALID_MESSAGE
            msg = "rtm msg invalid"
        case .imcompatibleMessage:
            ec = ErrCode.XERR_RTMMGR_MSG_IMCOMPATIBLE_MESSAGE
            msg = "rtm msg imcompatible"
        case .notInitialized:
            ec = ErrCode.XERR_RTMMGR_MSG_NOT_INITIALIZED
            msg = "rtm not initialized"
        case .notLoggedIn:
            ec = ErrCode.XERR_RTMMGR_MSG_USER_NOT_LOGGED_IN
            msg = "rtm not loggedin"
        @unknown default:
            ec = ErrCode.XERR_UNKNOWN
            msg = "unknown error"
        }
        return (ec,msg)
    }
    
    private func sendCallGeneralback(_ sequenceId:UInt32, _ e:AgoraRtmSendPeerMessageErrorCode,_ cb:@escaping(UInt32,Int,String)->Void){
        let reMsg = getRtmSendMsg(e)
        log.i("sendCallGeneralback:\(reMsg.msg)(\(reMsg) sequenceId:\(sequenceId)")
        cb(sequenceId,reMsg.errCode,reMsg.msg)
    }
    
    private func setNotSendGeneralMsg(_ sequenceId:UInt32,_ peerId:String, _ msgObj:Data,_ cb:@escaping(UInt32,Int,String)->Void){
        
        let rtmMsgObj = RtmMsgObj(sequenceId: sequenceId,peerId: peerId, msgObj: msgObj, timeStamp: String.dateCurrentTime(),reqCbObj: cb)
        _notSendMsgMsgObjs.setValue(rtmMsgObj, forKey: "\(sequenceId)")
        log.e("setNotSendGeneralMsg: rtm not Connected, Cache unsent message sequenceId:\(sequenceId)")
    }
    
    //消息的发送处理
    func sendRawGenerlMessage(sequenceId:UInt32,toPeer:String,data:Data,
                              description:String,cb:@escaping(UInt32,Int,String)->Void){
        guard let kit = kit else{
            log.e("rtm engine is nil")
            cb(sequenceId,ErrCode.XERR_BAD_STATE,"rtm not initialized")
            return
        }
        if(data.count >= config.maxRtmPackage){
            log.e("rtm package size(\(data.count) exceeds limit(\(config.maxRtmPackage)")
            cb(sequenceId,ErrCode.XERR_BUFFER_OVERFLOW,"rtm msg length overfloat")
            return
        }
        
        //如果rtm当前为未连接状态，则消息缓存，且直接return,待连接成功再发送
        guard curUpdateState == .Connected  else {
            log.e("sendRawGenerlMessage: curUpdateState:\(String(describing: curUpdateState?.rawValue))")
            setNotSendGeneralMsg(sequenceId, toPeer, data, cb)
            return
        }
        
        let package = AgoraRtmRawMessage(rawData: data, description: description)
        let option = AgoraRtmSendMessageOptions()
        option.enableOfflineMessaging = false
        option.enableHistoricalMessaging = false
        let sendCb = {(ec:AgoraRtmSendPeerMessageErrorCode) in
            self.sendCallGeneralback(sequenceId,ec,cb)
        }
        log.i("sendRawGenerlMessage: peerNodeId:\(toPeer)")
        kit.send(package, toPeer: toPeer, sendMessageOptions: option, completion: sendCb)
       
    }
    
    //消息的接收处理
    func handelReceivedData(message: AgoraRtmMessage, fromPeer peerId: String) -> Void {
        
        if(message.type == .raw){
            if let msg = message as? AgoraRtmRawMessage{
                log.i("handelReceivedData: msg.rawData count:\(msg.rawData.count)")
                DispatchQueue.main.async { [weak self] in
                    let sessionId = self?.getSessionId(peerId: peerId) ?? ""
                    self?._onReceivedCommandCallback?(sessionId,msg.rawData)
                }
                return
            }
            else{
                log.e("rtm message type cast error")
            }
        }
        else if (message.type == .text){
            
            let dict = String.getDictionaryFromJSONString(jsonString: message.text)
            log.i("handelReceivedData type:text dict: \(dict)")
            
        }
        else{
            log.w("rtm unhandled messate type \(message.type)")
        }
        
    }
}

//由于连接状态导致的未发送消息处理
extension RtmEngine{
    
    //处理未发送数据
    func sendAlreadyMsg(){
        let allNotSendMsgMsgObjs = _notSendMsgMsgObjs.getAllKeysAndValues()
        for (key,obj) in allNotSendMsgMsgObjs{
            log.i("sendAlreadyMsg: sequenceId:\(obj.sequenceId)")
            sendRawGenerlMessage(sequenceId: obj.sequenceId, toPeer:obj.peerId, data: obj.msgObj!, description: "", cb: obj.reqCbObj)
            _ = _notSendMsgMsgObjs.removeValue(forKey: key)
        }
    }
    
}

//消息发送超时处理
extension RtmEngine{
    
    func  timeOutTimer(){
        timerTimeout = Timer()
        startTimeOut()
    }
    
    func startTimeOut() {
        timerTimeout = Timer.scheduledTimer(timeInterval: commandCheckTime, target: self, selector: #selector(handelTimeOut), userInfo: nil, repeats: true)
    }
    
    @objc func handelTimeOut() {
        handelRtmMsgTimeout()
    }
    
    func handelRtmMsgTimeout(){
        
        let allNotSendMsgMsgObjs = _notSendMsgMsgObjs.getAllKeysAndValues()
        for (key,obj) in allNotSendMsgMsgObjs{
            let lastTime = obj.timeStamp
            let timeSpace = String.dateTimeSpaceMillion(lastTime)
            if timeSpace > commandTimeOut{
                let callBack = obj.reqCbObj
                log.i("handelRtmMsgTimeout: sequenceId:\(obj.sequenceId)------_notSendMsgMsgObjs.count:\(_notSendMsgMsgObjs.getAllValues().count)")
                callBack(obj.sequenceId,ErrCode.XERR_TIMEOUT,"send time out")
                _ = _notSendMsgMsgObjs.removeValue(forKey: key)
            }
        }
    }
    
    func stopTimerOut() {
        log.i("RtmEngine timer is nil")
        timerTimeout?.invalidate()
        timerTimeout = nil
    }
    
}
