//
//  CocoaMqttMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/22.
//

import UIKit
import CocoaMQTT
import AgoraIotLink

public class CallSession : NSObject{
    var token = ""
    var cname = ""    //对端nodeId
    var uid:UInt = 0
//    var peerId = ""
    var version:UInt = 0
    
    var peerUid:UInt = 0                //对端id
    var mPubLocalAudio : Bool = false   //设备端接听后是否立即推送本地音频流
    
    var callType:CallType = .UNKNOWN    //通话类型
    var mSessionId = ""                 //通话Id
    var traceId:UInt = 0                //追踪ID
    var peerNodeId = ""                 //对端nodeId
    
}

class CocoaMqttMgr: NSObject {
    
    
    var customParam:String
    
    private var cocoaMqttTool: CocoaMqtt?
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    private var _onActionDesired:(CallSession?)->Void = {c in log.w("mqtt _onActionAck not inited")}
    private var _onIncomingDesired:(CallSession?)->Void = {c in log.w("mqtt _onActionAck not inited")}
    private var _onListenterDesired:(MqttState,String)->Void = {s,msg in log.w("mqtt _onActionAck not inited")}
    
    var curRtcUpdateVersion : UInt = 0
    
    
    public func waitForIncomingDesired(actionDesired:@escaping(CallSession?)->Void){
        _onIncomingDesired = actionDesired
    }
    
    public func waitForActionDesired(actionDesired:@escaping(CallSession?)->Void){
        _onActionDesired = actionDesired
    }
    
    public func waitForPrepareListenerDesired(listenterDesired:@escaping(MqttState,String)->Void){
        _onListenterDesired = listenterDesired
    }
    
    public func disconnect(){
        self.cocoaMqttTool?.disconnect()
    }
    
    init(customParam:String){
        self.customParam = customParam
    }
    
    func initialize(defaultHost:String, clientID: String, userNameStr: String, passWordStr: String,port:UInt){
        
        self.cocoaMqttTool = CocoaMqtt()
        self.cocoaMqttTool?.initialize(defaultHost: defaultHost, clientID: clientID, userNameStr: userNameStr, passWordStr: passWordStr, port: port)
        self.cocoaMqttTool?.connect()
        
        self.cocoaMqttTool?.receiveMsg = {[weak self] receiveData in
            log.i("cocoaMqttTool?.receiveMsg:\(String(describing: receiveData))")
            self?.handelMqttRevieveData(receiveData)
        }
        self.cocoaMqttTool?.stateChanged = {[weak self] state,msg in
            log.i("cocoaMqttTool?.stateChanged: \(state.rawValue) msg: \(msg)")
            self?._onListenterDesired(state,msg)
        }
        

    }
    
    //处理订阅的数据
    func handelMqttRevieveData(_ data : CocoaMQTTMessage){
        
         if data.topic == self.cocoaMqttTool?.topic{
            let dicResult = String.getDictionaryFromJSONString(data: data.payload)
            let sess = dictToSession(dicResult)
            if sess?.callType == .DIAL {
                _onActionDesired(sess)
            }else{
                
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
    func publishCallData(data:String){
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
        if let cname = payloadDic["cname"] as? String {
            cnameStr = cname
        }
        if let token = payloadDic["token"] as? String {
            tokenStr = token
        }
        if let uid = payloadDic["uid"] as? UInt {
            uId = uid
        }
        sess.cname = cnameStr
        sess.peerNodeId = cnameStr
        sess.token = tokenStr
        sess.uid   = uId
        
        var peerIdStr = ""
        var versionStr : UInt  = 0
        if let peerId = payloadDic["peerId"] as? String {
            peerIdStr = peerId
        }
        if let version = payloadDic["version"] as? UInt {
            versionStr = version
        }
        sess.version = versionStr
        

        log.i("dictToSession: method:\(method) payloadDic:\(payloadDic)")
        
        return sess
    }
    
}




