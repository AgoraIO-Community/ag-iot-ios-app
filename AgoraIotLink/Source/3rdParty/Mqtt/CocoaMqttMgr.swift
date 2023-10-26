//
//  CocoaMqttMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/22.
//

import UIKit
import CocoaMQTT

/*
 * @brief 会话类型
 */
@objc public enum MsgType : Int{
    case UNKNOWN                         //未知
    case Call                            //主叫
    case UPDATETOKEN                     //刷新token
}

class CocoaMqttMgr: NSObject {
    
    
    var cfg:Config
    
    private var cocoaMqttTool: CocoaMqtt?
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    var curState:MqttState?
    
    var notSendMsg = [String]()
    
    private var _onActionDesired:(CallSession?)->Void = {c in log.w("mqtt _onActionAck not inited")}
    private var _onIncomingDesired:(CallSession?)->Void = {c in log.w("mqtt _onActionAck not inited")}
    private var _onUpdateTokenDesired:(CallSession?)->Void = {c in log.w("mqtt _updateToken not inited")}
    private var _onListenterDesired:(MqttState,String)->Void = {s,msg in log.w("mqtt _onActionAck not inited")}
    private var _onListenterPreparDesired:(MqttState,Int,String)->Void = {s,c,msg in log.w("mqtt _onActionAck not inited")}
    
    var curRtcUpdateVersion : UInt = 0
    
    
    public func waitForIncomingDesired(actionDesired:@escaping(CallSession?)->Void){
        _onIncomingDesired = actionDesired
    }
    
    public func waitForActionDesired(actionDesired:@escaping(CallSession?)->Void){
        _onActionDesired = actionDesired
    }
    
    public func waitForListenerDesired(listenterDesired:@escaping(MqttState,String)->Void){
        _onListenterDesired = listenterDesired
    }
    
    public func waitForPrepareListenerDesired(listenterDesired:@escaping(MqttState,Int,String)->Void){
        _onListenterPreparDesired = listenterDesired
    }
    
    public func disconnect(){
        self.cocoaMqttTool?.disconnect()
    }
    
    init(cfg:Config){
        self.cfg = cfg
    }
    
    func initialize(defaultHost:String, clientID: String, userNameStr: String, passWordStr: String,port:UInt){
        
        self.cocoaMqttTool = CocoaMqtt()
        self.cocoaMqttTool?.initialize(defaultHost: defaultHost, clientID: clientID, userNameStr: userNameStr, passWordStr: passWordStr, port: port)
        self.cocoaMqttTool?.connect()
        
        self.cocoaMqttTool?.receiveMsg = {[weak self] receiveData in
            log.i("cocoaMqttTool?.receiveMsg:\(String(describing: receiveData))")
            self?.handelMqttRevieveData(receiveData)
        }
        self.cocoaMqttTool?.stateChanged = {[weak self] state,errCode,msg in
            log.i("cocoaMqttTool?.stateChanged: \(state.rawValue) msg: \(msg)")
            self?.curState = state
            self?._onListenterDesired(state,msg)
            self?._onListenterPreparDesired(state,errCode,msg)
            if state == .ConnectDone {
                self?.sendAlreadyMsg()
            }
        }
    }
    
    //处理未发送数据
    func sendAlreadyMsg(){
        if notSendMsg.count > 0 {
            for msg in notSendMsg{
                log.i("sendAlreadyMsg:\(msg)")
                publishCallData(sessionId:"", data: msg)
            }
            notSendMsg.removeAll()
        }
    }
    
    //清除未发送数据
    func clearAlreadyMsg(){
        notSendMsg.removeAll()
    }
    
    //处理订阅的数据
    func handelMqttRevieveData(_ data : CocoaMQTTMessage){
        
         if data.topic == self.cocoaMqttTool?.topic{
            let dicResult = String.getDictionaryFromJSONString(data: data.payload)
            let sess = dictToSession(dicResult)
            if sess?.callType == .DIAL {
                _onActionDesired(sess)
            }else if sess?.msgType == .UPDATETOKEN{
                _onUpdateTokenDesired(sess)
            }
             else{
                
                guard let version = sess?.version, version > curRtcUpdateVersion else{
                    log.i(" version error:\(String(describing: sess?.version)) curRtcUpdateVersion:\(curRtcUpdateVersion)")
                    return
                }
                curRtcUpdateVersion = version
                
                _onIncomingDesired(sess)
            }
        }
    }
    
    //发送数据
    func publish(data:String,topic:String){
        self.cocoaMqttTool?.sendData(data,topic)
    }
    
    //发送呼叫数据
    func publishCallData(sessionId:String,data:String){
        if self.cocoaMqttTool?.curConnState != .connected{
            log.i("cocoaMqtt已断连 正在重连中...")
            notSendMsg.append(data)
            return
        }
        let topicCallPub = "$falcon/callkit/" + (self.cocoaMqttTool?.mInitParam?.mClientId ?? "") + "/pub"
        publish(data: data, topic: topicCallPub)
    }
    
    //发送呼叫数据
    func publishUpdateTokenData(sessionId:String,data:String,actionDesired:@escaping(CallSession?)->Void){
        if self.cocoaMqttTool?.curConnState != .connected{
            log.i("cocoaMqtt已断连 正在重连中...")
            notSendMsg.append(data)
            return
        }
        _onUpdateTokenDesired = actionDesired
        let topicCallPub = "$falcon/callkit/" + (self.cocoaMqttTool?.mInitParam?.mClientId ?? "") + "/pub"
        publish(data: data, topic: topicCallPub)
    }
}

extension CocoaMqttMgr{
    
    private func dictToSession(_ dict : Dictionary<String, Any>)->CallSession?{
        
        log.i("dictToSession:\(dict))")
        
        let sess = CallSession()
        
        guard let headerDic = dict["header"] as? [String:Any] ,let traceId = headerDic["traceId"] as? UInt, let method = headerDic["method"] as? String else {
            log.e("dictToSession:\(dict))")
            return sess
        }
        
        sess.traceId = traceId
        
        if method == "user-start-call" {
            sess.callType = .DIAL
        }else if method == "device-start-call"{
            sess.callType = .INCOMING
        }else if method == "refresh-token"{
            sess.msgType = .UPDATETOKEN
        }else{
            sess.callType = .UNKNOWN
        }
        
        guard let code = dict["code"] as? Int, code == 0 else {
            log.e("dictToSession:\(dict))")
            return sess
        }
        
        
        guard let payloadDic = dict["payload"] as? [String:Any] else {
            log.e("dictToSession:\(dict))")
            return sess
        }

        var cnameStr = ""
        var tokenStr = ""
        var uId : UInt  = 0
        var rtmUidStr = ""
        var rtmTokenStr = ""
        if let cname = payloadDic["cname"] as? String {
            cnameStr = cname
        }
        if let token = payloadDic["token"] as? String {
            tokenStr = token
        }
        if let uid = payloadDic["uid"] as? UInt {
            uId = uid
        }
        if let rtmUid = payloadDic["rtmUid"] as? String {
            rtmUidStr = rtmUid
        }
        if let rtmToken = payloadDic["rtmToken"] as? String {
            rtmTokenStr = rtmToken
        }
        sess.cname = cnameStr
        sess.peerNodeId = cnameStr
        sess.token = tokenStr
        sess.uid   = uId
        sess.mRtmUid = rtmUidStr
        sess.mRtmToken = rtmTokenStr
        
        var versionStr : UInt  = 0
        if let version = payloadDic["version"] as? UInt {
            versionStr = version
        }
        sess.version = versionStr
        
//        var peerIdStr = ""
//        if let peerId = payloadDic["peerId"] as? String {
//            peerIdStr = peerId
//        }

        log.i("dictToSession: method:\(method) payloadDic:\(payloadDic)")
        
        return sess
    }
    
}




