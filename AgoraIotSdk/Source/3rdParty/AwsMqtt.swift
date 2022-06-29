//
//  AwsMqtt.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/25.
//

import Foundation
import AWSIoT
import AWSMobileClient
import AWSAuthCore
import AWSCognitoIdentityProvider
import AWSCore

fileprivate class AwsMqttTopicListener : NSObject{
    typealias CB = (String, Dictionary<String, Any>?)->Void
    var cb:CB?
    var timer:Timer?
    init(_ cb:@escaping CB){
        self.cb = cb
    }
    func setTimer(timer:Timer){
        self.timer = timer
    }
    func invoke(topic:String, dict:Dictionary<String, Any>?){
        if(cb != nil){
            cb!(topic,dict)
        }
        timer?.invalidate()
        timer = nil
    }
    func invalidate(){
        timer!.invalidate()
        timer = nil
    }
}

fileprivate class Listeners{
    var listeners:[AwsMqttTopicListener] = []
    func append(_ l:AwsMqttTopicListener){
        listeners.append(l)
    }
    
    func invoke(topic:String,dict:Dictionary<String,Any>)->Bool{
        if(!self.listeners.isEmpty){
            self.listeners[0].invoke(topic: topic, dict: dict)
            self.listeners.remove(at: 0)
            return true
        }
        return false
    }
    func remove(_ l:AwsMqttTopicListener){
        var idx = 0
        for cur in self.listeners{
            if(l == cur){
                self.listeners.remove(at: idx)
                break
            }
            idx = idx + 1
        }
    }
}

// this custom class is dedicated for getting getting aws dev auth identity credentials
class DeveloperAuthenticatedIdentityProvider: AWSCognitoCredentialsProviderHelper {
    var _token:String = ""
//    var _identityId:String? = ""
//    var _identityProviderName:String = "granwin"
    //var _identityPoolId:String
//    init(identityId:String, regionType: AWSRegionType, identityPoolId: String, useEnhancedFlow: Bool, identityProviderManager: AWSIdentityProviderManager?) {
//        self._identityId = identityId
//        self._identityPoolId = identityPoolId
//
//        super.init()
//    }
    override func token() -> AWSTask<NSString> {
        return AWSTask<NSString>(result: self._token as NSString )
    }
    
    override var identityProviderName:String{get{
        return "cognito-identity.cn-north-1.amazonaws.com.cn";
    }
    }
//    override func logins () -> AWSTask<NSDictionary> {
//        let tokens : NSDictionary = ["cognito-identity.amazonaws.com": self._token]
//        let t = tokens as NSDictionary
//        return AWSTask<NSDictionary>(result: t)
//    }
//    override var identityProviderName: String{
//        return self._identityProviderName
//    }
    override func getIdentityId() -> AWSTask<NSString> {
        return AWSTask<NSString>(result: self.identityId as NSString?)
    }
//    override var identityPoolId: String{
//        get{return self.identityPoolId}
//    }
//    override var identityId: String?{
//        get{
//        return _identityId
//    }
//        set{
//            _identityId = newValue}
//    }
    var stoken:String{
        set{_token = newValue}
        get{return _token}
    }
//    func refresh() -> AWSTask<NSString> {
//        return AWSTask<NSString>(result: self._identityId as NSString?)
//    }
}



class AWSMqtt{
    //var iotManager : AWSIoTManager?  = nil
    var iot : AWSIoT? = nil
    var iotDataManager: AWSIoTDataManager? = nil
    var thingName:String = ""
    //var clientId:String = ""
    var identityId:String = ""
    var appId:String = ""
    var deviceAlias:String = ""
    var subScribeWithClientCalled:Bool = false
    var credentialsProvider:AWSCognitoCredentialsProvider? = nil
    //let AWS_IOT_DATA_MANAGER_KEY = "iotsdk-data-manager-broker2"
    fileprivate var listeners:[String:Listeners] = [String:Listeners]()

    typealias MqttStatusDeleagte = (IotMqttSession.Status)->Void
    private var _onStatusChanged:MqttStatusDeleagte = {s in log.w("mqtt _onStatusChanged not inited")}
    public var onStatusChanged:MqttStatusDeleagte{set{_onStatusChanged = newValue} get{return _onStatusChanged}}
    
    //public var onCallIncoming:(CallSession)->Void{get{return _onCallIncoming}set{_onCallIncoming = newValue}}
    private var _onActionDesired:(ActionAck,CallSession?)->Void = {a,c in log.w("mqtt _onActionAck not inited")}
    
    public func waitForActionDesired(actionDesired:@escaping(ActionAck,CallSession?)->Void){
        _onActionDesired = actionDesired
    }
    
    private func dictToSession(reason:Int,desired:[String:Any]?,reported:[String:Any]?)->CallSession?{
        let info = "mqtt recv rtc state without: "
        var sess = CallSession()
        sess.reason = reason
        if let desired = desired{
            if let callerId = desired["callerId"] as? String {
                sess.callerId = callerId
            }else{
                sess.callerId = ""
                //log.w(info + "'callerId'")
                //return nil
            }
            
            if let calleeId = desired["calleeId"] as? String {
                sess.calleeId = calleeId
            }else{
                sess.calleeId = ""
                //log.e(info + "'calleeId'")
            }
            
            if let appId = desired["appId"] as? String{
                sess.appId = appId
            }else{
                sess.appId = ""
            }
            
            if let channelName = desired["channelName"] as? String{
                sess.channelName = channelName
            }
            else{
                sess.channelName = ""
                //log.e(info + "'channelName'")
            }
            
            if let rtcToken = desired["rtcToken"] as? String {
                sess.rtcToken = rtcToken
            }
            else{
                sess.rtcToken = ""
                //log.e(info + "'rtcToken'")
            }
            
            if let sessionId = desired["sessionId"] as? String{
                sess.sessionId = sessionId
            }
            else{
                sess.sessionId = ""
                //log.e(info + "'sessionId'")
            }
            
            if let uidStr = desired["uid"] as? String {
                if let uid = UInt(uidStr){
                    sess.uid = uid
                }
                else{
                    sess.uid = 0
                }
            }
            else{
                //log.e(info + "'uid'")
            }
            
            if let peerUidStr = desired["peerUid"] as? String {
                if let peerUid = UInt(peerUidStr){
                    sess.peerUid = peerUid
                }
                else{
                    sess.peerUid = 0
                    log.i(info + "'peerUid'")
                }
            }
            else{
                //log.e(info + "'peerUid'")
            }
            
            if let attachMsgStr = desired["attachMsg"] as? String {
                sess.attachedMsg = attachMsgStr
            }
            else{
                sess.attachedMsg = ""
                //log.w(info + "'attachMsg'")
            }
            
            if let cs = desired["cloudRecordStatus"] as? Int{
                sess.cloudRecordStatus = cs
            }
            else{
                sess.cloudRecordStatus = -1
                //log.w(info + "'cloudRecordStatus'")
            }
        }
        
        if let disabledPush = reported?["disabledPush"] as? UInt {
            sess.disabledPush = disabledPush == 1 ? true : false
        }
        else{
            if(sess.reason == 0){
                sess.disabledPush = false
            }
        }
        log.i("mqtt session is :\(sess)")
        return sess
    }
    private func getActionFromReason(reason:Int)->ActionAck{
        var action:ActionAck = .UnknownAction
        if(reason == 0){
            action = .StateInited
        }
        else if(reason == 1){
            action = .LocalHangup
        }
        else if(reason == 2){
            action = .LocalAnswer
        }
        else if(reason == 3){
            action = .RemoteHangup
        }
        else if(reason == 4){
            action = .RemoteAnswer
        }
        else if(reason == 5){
            action = .RemoteTimeout
        }
        else if(reason == 6){
            action = .RecordEnd
        }
        else if(reason == 7){
            action = .LocalTimeout
        }
        else{
            action = .UnknownAction
            log.e("unknown action reason:\(reason)")
        }
        return action
    }
    private func onUpdateCommStatus(dict:[String:Any]){
        
    }
    private func onUpdateRtcStatus(desired:[String:Any],reported:[String:Any]?){
        //log.i("mqtt onUpdateRtcStatus desired:\(desired)")
        //log.i("mqtt onUpdateRtcStatus reported:\(reported)")
        let r = desired["reason"] as? Int
        if(r == nil){
            log.e("mqtt reason is nil,set to default 0")
        }
        let reason = r ?? 0
        let sess = dictToSession(reason:reason, desired: desired,reported: reported)
        if let callStatus = desired["callStatus"] as? Int{
            switch callStatus{
            case 1: //local idle
                let action:ActionAck = getActionFromReason(reason: reason)
                log.i("mqtt local idle:reason(\(reason)) action(\(action.rawValue))")
                _onActionDesired(action,sess)
            case 2:
                log.i("mqtt local calling")
                _onActionDesired(.CallOutgoing,sess)
            case 3:
                log.i("mqtt remote calling")
                _onActionDesired(.CallIncoming,sess)
            case 4: //in talking
                let action = getActionFromReason(reason: reason)
                log.i("mqtt in talking reason:(\(String(describing: sess?.reason))) action(\(action.rawValue))")
                _onActionDesired(.RemoteAnswer,sess)
            default:
                log.e("mqtt unknown state for callStatus:\(callStatus)")
            }
        }
        else{
            log.i("mqtt call state dict no 'callStatus',may be just created")
        }
    }
    
    func toolsChangeToJson(info: Any) -> Dictionary<String, Any>?{
        guard let data = try? JSONSerialization.data(withJSONObject: info, options: []) else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        let dict = json as? Dictionary<String, Any>
        return dict
    }
    
    func initialize(thingName:String, endPoint: String, token: String, identityId: String, identityPoolId: String, region: String,appId:String,deviceAlias:String){
        //self.clientId = clientId
        self.thingName = thingName
        self.identityId = identityId
        self.appId = appId
        self.deviceAlias = deviceAlias
        let iotVer = AWSIoTSDKVersion
        let coreVer = AWSiOSSDKVersion
        let regionType:AWSRegionType = region.aws_regionTypeValue()
        
        log.i("mqtt aws iot AWSiOSSDKVersion:\(AWSiOSSDKVersion) AWSIoTSDKVersion: \(iotVer) AWSiOSSDKVersion: \(coreVer) AWSMobileClientVersionNumber: \(AWSMobileClientVersionNumber) AWSAuthCoreVersionNumber: \(AWSAuthCoreVersionNumber) AWSCognitoIdentityProviderSDKVersion:\(AWSCognitoIdentityProviderSDKVersion)")
        
        log.i("     thingName:\(thingName) region:\(region)")
        log.i("     endPoint:\(endPoint)")
        log.i("     identityId:\(identityId)")
        log.i("     identityPoolId:\(identityPoolId)")
        
        AWSDDLog.sharedInstance.logLevel = .all
        //AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        let provider = DeveloperAuthenticatedIdentityProvider(regionType: regionType, identityPoolId: identityPoolId, useEnhancedFlow: true, identityProviderManager: nil)
        provider.identityId = identityId
        provider.stoken = token
        let iotEndPoint = AWSEndpoint(urlString: "https://" + endPoint)
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType:regionType ,identityProvider:provider)
        
        
        let controlPlaneServiceConfiguration = AWSServiceConfiguration(region:regionType,credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = controlPlaneServiceConfiguration
        
        let iotDataConfiguration : AWSServiceConfiguration = AWSServiceConfiguration(region: regionType,
                                                                   endpoint: iotEndPoint,
                                                                   credentialsProvider: credentialsProvider)
        
        let mqttConfig = AWSIoTMQTTConfiguration(keepAliveTimeInterval: 20.0,
                                             baseReconnectTimeInterval: 1.0,
                                         minimumConnectionTimeInterval: 20.0,
                                          maximumReconnectTimeInterval: 128.0,
                                                               runLoop: RunLoop.current,
                                                 runLoopMode: RunLoop.Mode.default.rawValue,
                                                       autoResubscribe: true,
                                                  lastWillAndTestament: AWSIoTMQTTLastWillAndTestament() )

        AWSIoTDataManager.register(with: iotDataConfiguration,with:mqttConfig, forKey: thingName)
        iotDataManager = AWSIoTDataManager(forKey: thingName)
        
        log.i("mqtt initialized")
    }
    
    private var onConnect:((Bool,String)->Void?)? = nil
    func connect(completion:@escaping(Bool,String)->Void){
        log.i("mqtt try connect ...")
        self.onConnect = completion
        let ret = iotDataManager?.connectUsingWebSocket(withClientId: self.identityId, cleanSession: true, statusCallback: mqttConnEventCallback)
        if(ret != true){
            log.e("mqtt connect fail")
            completion(false,"连接服务失败")
        }
    }
    
    private var onDisconnect:((Bool,String)->Void?)? = nil
    func disconnect(completion:@escaping(Bool,String)->Void){
        log.i("mqtt disconnect ...")
        self.onDisconnect = completion
        guard let iotDataManager = self.iotDataManager else{
            return
        }
        iotDataManager.disconnect()
        AWSIoTDataManager.remove(forKey: thingName)
        credentialsProvider?.clearCredentials()
        
    }
    
    func mqttConnEventCallback( _ status: AWSIoTMQTTStatus ) {
        DispatchQueue.main.async {
            switch status {
            case .connecting:
                log.i("mqtt .connecting...")
                if(self.onConnect == nil){
                    self._onStatusChanged(.Connecting)
                }
            case .connected:
                log.i("mqtt .connected")
                
                if(self.onConnect != nil){
                    self.onConnect!(true,"mqtt 连接成功")
                    self.onConnect = nil
                }
                else{
                    if(!self.subScribeWithClientCalled){
                        self.subScribeWithClient(completion: {succ,msg in})
                    }
                    self._onStatusChanged(.Connected)
                }
            case .disconnected:
                log.i("mqtt .disconnected")
                if(self.onDisconnect != nil){
                    self.onDisconnect!(true,"mqtt 断开成功")
                    self.onDisconnect = nil
                }
                else {
                    self._onStatusChanged(.Disconnected)
                }
                
            case .connectionRefused:
                log.i("mqtt .connectionRefused")
                if(self.onConnect != nil){
                    self.onConnect!(false,"mqtt 连接被拒绝")
                    self.onConnect = nil
                }
                else{
                    self._onStatusChanged(.ConnectionRefused)
                }
                
            case .connectionError:
                log.i("mqtt .connectionError")
                if(self.onConnect != nil){
                    self.onConnect!(false,"mqtt 无法连接")
                    self.onConnect = {succ,msg in}
                }
                else {
                    self._onStatusChanged(.ConnectionError)
                }
                
            case .protocolError:
                log.i("mqtt .protocolError")
                if(self.onConnect != nil){
                    self.onConnect!(false,"mqtt 协议错误")
                    self.onConnect = nil
                }
                else{
                    self._onStatusChanged(.ProtocolError)
                }
            default:
                log.e("mqtt unknown state")
                if(self.onConnect != nil){
                    self.onConnect!(false,"mqtt 未知错误")
                    self.onConnect = nil
                }
                else if(self.onDisconnect != nil){
                    self.onDisconnect!(false,"mqtt 协议错误")
                    self.onDisconnect = nil
                }
                self._onStatusChanged(.Unknown)
            }
        }
    }
    
    //let topic1 = "+/+/device/connect"
    func onTopic1Callback(topicPub:String,topicRcv:String,jsonDict:[String:Any])->Bool{
        let bs1 = topicRcv.findFirst("/")
        let productKey = topicRcv.substring(to: bs1)
        let remain = topicRcv.substring(from: bs1 + 1)
        let bs2 = remain.findFirst("/")
        let mac = remain.substring(to: bs2)
        
        guard let data = jsonDict["data"] as? [String:Any] else{
            log.e("mqtt no 'data' found for \(topicRcv)")
            return false
        }
        
        guard let onoff = data["connect"] as? UInt else{
            log.e("mqtt no 'connect' found for \(topicRcv)")
            return false
        }

        if(onoff != 0 && onoff != 1){
            log.e("mqtt connect value:'\(onoff)' error")
            return false
        }
        devStateListener?.onDeviceOnOffline(online: onoff == 0 ? false : true, deviceId: mac, productId: productKey)
        return true
    }
    //topic2 = "$aws/things/+/shadow/get/+"
    func onTopic2Callback(topicPub:String,topicRcv:String, jsonDict:[String:Any])->Bool{
        guard let listener = self.listeners[topicRcv] else{
            log.w("mqtt \(topicRcv) no listener")
            return false
        }
        let handled = listener.invoke(topic: topicRcv,dict: jsonDict)
        if(!handled){
            log.w("mqtt \(topicRcv) not handled, handler maybe timeout")
            return true
        }
        return true
    }
    private var devStateListener:IDeviceStateListener? = nil
    func setListener(listener:IDeviceStateListener){
        devStateListener = listener
    }
    private func onDeviceOnOffline(_ topic:String,_ jsonData:[String:Any])->Bool{
        guard let mac = jsonData["mac"] as? String else{
            log.e("mqtt no 'mac' found for \(topic)")
            return false
        }
        guard let devId = jsonData["deviceId"] as? UInt64 else{
            log.e("mqtt no 'deviceId' found for \(topic)")
            return false
        }
        guard let isOnlineStr = jsonData["connect"] as? String else{
            log.e("mqtt no 'connect' found for \(topic)")
            return false
        }
        guard let onoff = UInt(isOnlineStr) else{
            log.e("mqtt connect:'\(isOnlineStr)' format error for \(topic)")
            return false
        }
        if(onoff != 0 && onoff != 1){
            log.e("mqtt connect value:'\(onoff)' error")
            return false
        }
        return true
    }
    private func onPropertyChanged(_ topic:String,_ jsonDict:[String:Any])->Bool{
        guard let mac = jsonDict["mac"] as? String else{
            log.e("mqtt no 'mac' found for \(topic)")
            return false
        }
        guard let devNumber = jsonDict["deviceId"] as? UInt64 else{
            log.e("mqtt no 'deviceId' found for \(topic)")
            return false
        }
        devStateListener?.onDevicePropertyUpdated(deviceId: mac,deviceNumber:String(devNumber), props: jsonDict["data"] as? [String:Any])
        return true
    }
    private func onBindListUpdated(_ topic:String,_ jsonDict:[String:Any])->Bool{
        var counter = 0
        if let data = jsonDict["data"] as? [String:Any]{
            for item in data{
                if let value = item.value as? [String:Any] {
                    log.i("mqtt parse key:\(item.key)")
                    if let actionType = value["actionType"] as? String {
                        if let mac = value["mac"] as? String{
                            devStateListener?.onDeviceActionUpdated(deviceId: mac, actionType: actionType)
                            counter += 1
                        }
                        else{
                            log.w("mqtt parse mac fail")
                        }
                    }
                    else{
                        log.w("mqtt parse action fail")
                    }
                }
            }
        }
        else{
            log.e("mqtt data is nil")
        }
        return counter == 0 ? false : true
    }
    //topic3 = "granwin/" + clientId + "/message"
    func onTopic3Callback(topicPub:String,topicRcv:String, jsonDict:[String:Any])->Bool{
        var messageType = -1
        if let type = jsonDict["messageType"] as? Int{
//            if let type = Int(typeStr){
//                messageType = type
//            }
//            else{
//                log.w("mqtt no 'messageType' found")
//                return false
//            }
            messageType = type
        }
        else{
            log.w("mqtt no 'messageType' found")
            return false
        }
//        guard let jsonData = jsonDict["data"] as? [String:Any] else{
//            log.e("mqtt no 'state' found for \(topicRcv)")
//            return false
//        }
        switch(messageType){
        case 1:
            return onDeviceOnOffline(topicRcv,jsonDict)
        case 2:
            return onPropertyChanged(topicRcv,jsonDict)
        case 3:
            return onBindListUpdated(topicRcv,jsonDict)
            
        default:
            log.e("mqtt unhandled messageType:\(messageType)")
            return false
        }
    }
    //topic4 = "$aws/things/" + clientId + "/shadow/name/rtc/update/accepted"
    func onTopic4Callback(topicPub:String,topicRcv:String, jsonDict:[String:Any])->Bool{
        guard let state = jsonDict["state"] as? [String:Any] else{
            log.e("mqtt no 'state' found for \(topicRcv)")
            return false
        }
        let reported = state["reported"] as? [String:Any]
        if let desired = state["desired"] as? [String:Any]{
            self.onUpdateRtcStatus(desired:desired,reported: reported)
            return true
        }
        else{
            log.i("mqtt json string: no 'desired' to handle\(topicRcv)")
            return true
        }
    }
    //topic5 = "$aws/things/" + clientId + "/shadow/name/rtc/get/accepted"
    func onTopic5Callback(topicPub:String,topicRcv:String, jsonDict:[String:Any])->Bool{
        guard let state = jsonDict["state"] as? [String:Any] else{
            log.e("mqtt no 'state' found for \(topicRcv)")
            return false
        }
        
        let reported = state["reported"] as? [String:Any]
        
        if let desired = state["desired"] as? [String:Any]{
            self.onUpdateRtcStatus(desired:desired,reported:reported)
            return true
        }
        else if let reported = reported{
            let sess = dictToSession(reason:0,desired: nil,reported: reported)
            _onActionDesired(.StateInited,sess)
            return true
        }
        else{
            log.w("mqtt json string: no 'desired' for \(topicRcv)")
            return true
        }
    }
    func syncRemoteRtcStatus(){
        guard let iotDataManager = iotDataManager else {
            log.e("mqtt iotDataManager is nil")
            return
        }
        
        let qos:AWSIoTMQTTQoS = .messageDeliveryAttemptedAtLeastOnce
        let topicUpdate = "$aws/things/" + thingName + "/shadow/name/rtc/update"
        let dict:[String:Any] = ["appId":self.appId,"deviceAlias":self.deviceAlias,"localRecord":0]
        let reported:[String:Any] = ["reported":dict]
        let stateJson:[String:Any] = ["state":reported]
        let str = JSON(stateJson)
        let jsonStr = str.rawString([.castNilToNSNull:true])
        if(jsonStr == nil){
            log.e("mqtt updateRtcStatus jsonStr is nil")
            return
        }
        else{
            log.i("mqtt topic pub: qos \(qos.rawValue): '\(topicUpdate)' '\(jsonStr!)'")
            iotDataManager.publishString(jsonStr!, onTopic: topicUpdate, qoS: qos) {
                log.i("mqtt topic ack: '\(topicUpdate)'")
                let qos:AWSIoTMQTTQoS = .messageDeliveryAttemptedAtLeastOnce
                let topicGet = "$aws/things/" + self.thingName + "/shadow/name/rtc/get"
                log.i("mqtt topic pub: qos \(qos.rawValue): '\(topicGet)'")
                iotDataManager.publishString("", onTopic: topicGet, qoS: qos) {
                    log.i("mqtt topic ack: '\(topicGet)'")
                    self.subScribeWithClientCalled = true
                }
            }
            return
        }
    }
    
    func updateRemoteRtcStatus(eid:String,enablePush:Bool)->Bool{
        guard let iotDataManager = iotDataManager else {
            log.e("mqtt iotDataManager is nil")
            return false
        }
        
        let eid = enablePush ? eid : ""

        let qos:AWSIoTMQTTQoS = .messageDeliveryAttemptedAtLeastOnce
        let topicUpdate = "$aws/things/" + thingName + "/shadow/name/rtc/update"
        let dict:[String:Any] = ["appId":self.appId,"deviceAlias":self.deviceAlias,"pusherId":eid,"localRecord":0,"disabledPush": enablePush ? false : true]
        let reported:[String:Any] = ["reported":dict]
        let stateJson:[String:Any] = ["state":reported]
        let str = JSON(stateJson)
        let jsonStr = str.rawString([.castNilToNSNull:true])
        if(jsonStr == nil){
            log.e("mqtt updateRtcStatus jsonStr is nil")
            return false
        }
        else{
            log.i("mqtt topic pub: qos \(qos.rawValue): '\(topicUpdate)' '\(jsonStr!)'")
            iotDataManager.publishString(jsonStr!, onTopic: topicUpdate, qoS: qos) {
                log.i("mqtt topic ack: '\(topicUpdate)'")
            }
            return true
        }
    }
    static let topic1 = "+/+/device/connect"
    static let topic2 = "$aws/things/+/shadow/get/+"
    func subScribeWithClient(completion:@escaping(Bool,String)->Void){
        let thingName = self.thingName
        let topic3 = "granwin/" + self.identityId + "/message"
        let topic4 = "$aws/things/" + thingName + "/shadow/name/rtc/update/accepted"
        let topic5 = "$aws/things/" + thingName + "/shadow/name/rtc/get/accepted"
        
        let topics:[String] = [AWSMqtt.topic1,AWSMqtt.topic2,topic3,topic4,topic5]
        let qos:[AWSIoTMQTTQoS] = [.messageDeliveryAttemptedAtLeastOnce,.messageDeliveryAttemptedAtLeastOnce,.messageDeliveryAttemptedAtLeastOnce,.messageDeliveryAttemptedAtLeastOnce,.messageDeliveryAttemptedAtLeastOnce]
        let callbacks:[(String,String,[String:Any])->Bool] = [onTopic1Callback,onTopic2Callback,onTopic3Callback,onTopic4Callback,onTopic5Callback]
        var loop:(Int)->Void = {i in}
        var e = 0
        loop = {i in
            self.subscribe(topic: topics[i], qos:qos[i],callback:callbacks[i]){
                succ in
                if(!succ){
                    log.e("mqtt subscribe \(topics[i]) failed")
                    e = e + 1
                }
                else{
                    self.listeners[topics[i]] = Listeners();
                }
                if(i < topics.count - 1){
                    loop(i+1)
                }
                else{
                    let succ = e == 0 ? true : false
                    completion(succ,succ ? "注册topic成功" : "注册topic部分失败:失败率\(e)/\(topics.count)" )
                    self.syncRemoteRtcStatus()
                    //self.updateRemoteRtcStatus()
                }
            }
        }
        loop(0)
        //let topicShadow = "$aws/things/" + thingName + "/shadow/get"
        //self.listeners[AWSMqtt.topic2] = Listeners();
    }
    
    public func publishPushId(id:String,enableNotify:Bool){
        updateRemoteRtcStatus(eid:id,enablePush:enableNotify)
    }
    
    public func publishEnableNotify(eid:String,enable:Bool,result:@escaping(Int,String)->Void){
        let ret = updateRemoteRtcStatus(eid:eid,enablePush:enable)
        result(ret ? ErrCode.XOK : ErrCode.XERR_BAD_STATE,ret ? "" : "设置参数失败")
    }
    
    public func publish(data:Data,topic:String,qos:AWSIoTMQTTQoS){
        self.iotDataManager?.publishData(data, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce)
    }
    
    func subscribe(topic:String,qos:AWSIoTMQTTQoS,callback:@escaping(String,String,[String:Any])->Bool,result:@escaping (Bool)->Void){
        let ret = iotDataManager?.subscribe(toTopic: topic, qoS: qos, fullCallback: {
            (curTopic,message) ->Void in
            //let json = try! JSONSerialization.jsonObject(with: payload, options: .mutableContainers)as! Dictionary<String,Any>
            
//            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
//            //log.i("mqtt received:\(stringValue)   \(json)")
//            var pay:Data = payload
            //log.i("topic arrive:'\(topic)'")
            //{"state":{"reported":{"100":1,"101":2,"102":0,"103":1,"104":30,"105":1,"106":50}},"metadata":{"reported":{"100":{"timestamp":1645794721},"101":{"timestamp":1645794721},"102":{"timestamp":1645794721},"103":{"timestamp":1645794721},"104":{"timestamp":1645794721},"105":{"timestamp":1645794721},"106":{"timestamp":1645794721}}},"version":1,"timestamp":1648462220}
//            log.i("mqtt recv topic:\(topic)")
//            log.i("          payload:\(payload)")
            let payload = message.messageData
            if let jsonDict = try? JSONSerialization.jsonObject(with: payload, options:.mutableContainers) as? [String: Any]{
                log.i("mqtt topic rec: '\(curTopic)'")
                log.i("           json: \(jsonDict)")
                DispatchQueue.main.async {
                    if(!callback(topic,curTopic,jsonDict)){
                        log.e("mqtt message callback ret error for \(jsonDict)")
                    }
                }
//                if let state = jsonDict["state"] as? [String:Any]{

//                    DispatchQueue.main.async {
//                        if(!callback(topic,state)){
//                            log.e("mqtt message callback ret error for \(jsonDict)")
//                        }
//                    }
                    
                    
//                    if(topic.contains("/device/connect")){
//                        for item in state {
//                            if item.key == "reported"{
//                                if let pairs = item.value as? [String:Any]{
//                                    log.i("\(pairs)")
//                                        DispatchQueue.main.async {
//                                            self.listeners.invoke(id: 0, msg: "", dict: pairs)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    else if(topic.contains("/shadow/get/accepted")){
//                        if let accepted = state["reported"] as? [String:Any]{
//                            let things_name = topic.replacingOccurrences(of: "\\$aws/things/", with: "")
//                            let name = things_name.replacingOccurrences(of: "/shadow/get/accepted", with: "")
//                            if(name == self.clientId){
//                                self.onCallStateUpdated(dict:accepted)
//                            }
//                            else{
//                                log.e("clientId not match:\(name) != \(self.clientId)")
//                            }
//                        }
//                        else{
//                            log.e("json string error: no 'reported' \(jsonDict)")
//                        }
//                    }
//                    else if(topic.contains("/shadow/name/rtc/update/accepted")){
//                        if let desired = state["desired"] as? [String:Any]{
//                            let things_name = topic.replacingOccurrences(of: "\\$aws/things/", with: "")
//                            let name = things_name.replacingOccurrences(of: "/shadow/name/rtc/update/accepted", with: "")
//                            if(name == self.clientId){
//                                self.onCallStateUpdated(dict:desired)
//                            }
//                            else{
//                                log.e("clientId not match:\(name) != \(self.clientId)")
//                            }
//                        }
//                        else{
//                            log.e("json string error: no 'desired' \(jsonDict)")
//                        }
//                    }
//                    else if(topic.contains("/shadow/name/rtc/get/accepted")){
//                        if let accepted = state["desired"] as? [String:Any]{
//                            let things_name = topic.replacingOccurrences(of: "\\$aws/things/", with: "")
//                            let name = things_name.replacingOccurrences(of: "/shadow/name/rtc/update/accepted", with: "")
//                            if(name == self.clientId){
//                                self.onCallStateUpdated(dict:accepted)
//                            }
//                            else{
//                                log.e("clientId not match:\(name) != \(self.clientId)")
//                            }
//                        }
//                        else{
//                            log.e("json string error: no 'desired' \(jsonDict)")
//                        }
//                    }
//                    else{
//                        log.w("unhandled topic \(topic)")
//                    }
//                }
//                else{
//                    log.e("json string error: no 'state' \(jsonDict)")
//                }
            }
            else{
                log.e("mqtt can't parse topic:\(topic)")
                log.e("           message \(payload)")
            }
        } ,
        ackCallback: {
            log.i("mqtt subscribe ack qos:\(qos.rawValue) topic: \(topic)")
            result(true)
        })
        if(true != ret){
            log.e("mqtt subscribe fail qos:\(qos.rawValue) topic: \(topic)")
            result(false)
        }
    }
    
    func unsubscribe(topic:String){
        iotDataManager?.unsubscribeTopic(topic)
    }
    
    struct UserControllerData{
        let product_key:String
        let action_type:String
        let action_type_name:String
        let account:String
    }
    
    func setDeviceStatus(account:String,productId:String,things_name:String,params:Dictionary<String,Any>,result: @escaping (Int, String)->Void){
        let topic = "$aws/things/" + things_name + "/shadow/update"
        let userControllerData = ["product_key":productId,"action_type":"1","action_type_name":"android","account":account]
        var dict = params
        dict["userControllerData"] = userControllerData
        let desiredValue = ["desired":dict]
        let stateValue = ["state":desiredValue]
        
        let str = JSON(stateValue)
        let jsonStr = str.rawString([.castNilToNSNull:true])
        if(jsonStr == nil){
            log.e("mqtt setDeviceStatus jsonStr is nil")
            result(ErrCode.XERR_INVALID_PARAM,"输入的参数错误")
            return
        }
        
//        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
//        if(data == nil){
//            log.e("mqtt setDeviceStatus param error:\(productKey) ,\(account)")
//            result(ErrCode.XERR_INVALID_PARAM,"输入的参数错误",nil)
//            return
//        }
        let topicGetAccepted = "$aws/things/" + things_name + "/shadow/get/accepted"
        //addDeviceStatusListener(topicKey: topicGetAccepted,result: result)
        log.i("mqtt topic pub: '\(topic)' \(jsonStr!)")
        iotDataManager?.publishString(jsonStr!, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce,ackCallback: {
            log.i("mqtt topic ack for \(topic)")
            DispatchQueue.main.async {
                result(ErrCode.XOK,"发送属性成功")
            }
//            let topicGet = "$aws/things/" + things_name + "/shadow/get"
////            log.i("mqtt publish topic : '\(topicGet)'")
//            self.iotDataManager?.publishString("", onTopic: topicGet, qoS: .messageDeliveryAttemptedAtLeastOnce,ackCallback: {
//                log.i("mqtt publish ack for \(topicGet)")
//            })
        })
    }
    
    private func addDeviceStatusListener(topicKey:String,result: @escaping (Int, String,Dictionary<String, Any>?)->Void){
        DispatchQueue.main.async {
            let listener = AwsMqttTopicListener({
                (topic,dict) in
                guard let state = dict?["state"] as? [String:Any] else{
                    log.e("mqtt no 'state' found for \(topic)")
                    result(ErrCode.XERR_INVALID_PARAM,"返回未知参数",nil)
                    return
                }
                guard let reported = state["reported"] as? [String:Any] else{
                    log.e("mqtt no 'desired' found for \(topic)")
                    result(ErrCode.XERR_INVALID_PARAM,"返回未知参数",nil)
                    return
                }
                result(ErrCode.XOK,"收到返回状态",reported)
                self.listeners[topicKey] = nil
            })
            
            let l = Listeners()
            l.append(listener)
            self.listeners[topicKey] = l
            
            let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){tm in
                result(ErrCode.XERR_TIMEOUT,"等待处理超时",nil)
                log.w("mqtt listen timeout for \(topicKey)")
                self.listeners[topicKey] = nil
            }
            listener.setTimer(timer: timer)
        }
    }
    
    func getDeviceStatus(things_name:String,result: @escaping (Int, String,Dictionary<String, Any>?)->Void){
        let topic = "$aws/things/" + things_name + "/shadow/get"
        
        addDeviceStatusListener(topicKey:topic + "/accepted", result: result)
        
        log.i("mqtt topic pub: '\(topic)'")
        self.iotDataManager?.publishString("", onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce,ackCallback: {
            log.i("mqtt topic ack: '\(topic)'")
        })
    }
    
    func getClientDesired(clientId:String, result: @escaping (Int, String,Dictionary<String, Any>?)->Void){
        let topic = "$aws/things/" + clientId + "/shadow/name/rtc/get"
        DispatchQueue.main.async {
            let listener = AwsMqttTopicListener({
                (topic,dict) in
                //todo
            })
            if let l = self.listeners[topic] {
                l.append(listener)
                let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){tm in
                    result(ErrCode.XERR_TIMEOUT,"等待处理超时",nil)
                    l.remove(listener)
                }
                listener.setTimer(timer: timer)
            }
            else{
                log.e("mqtt no listener for topic:'\(AWSMqtt.topic1)'")
            }
            
            self.iotDataManager?.publishString("", onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce,ackCallback: {
                log.i("mqtt publish ack for \(topic)")
            })
        }
    }
    
    struct StateValue{
        let reported:Any?
        let desired:Any?
    }
    
    func updateClientStatus(params:Dictionary<String,Any>,result: @escaping (Int, String,Dictionary<String, Any>?)->Void){
        let topic = "$aws/things/" + thingName + "/shadow/name/rtc/update"
        if(params.isEmpty){
            log.w("mqtt mqqtt update params is empty")
            return
        }
        let stateValue = StateValue(reported: params, desired: nil)
        let dict:Dictionary<String,Any> = ["state":stateValue]
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            iotDataManager?.publishData(jsonData, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce,ackCallback: {
                log.i("mqtt publish ack for \(topic)")
            })
        }catch let error {
            log.e("mqtt update client status error \(error)")
        }
    }
}
