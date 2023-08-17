//
//  CocoaMqtt.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/22.
//

import UIKit
import CocoaMQTT
import Security


/*
 * @brief 会话类型
 */
@objc public enum CallType : Int{
    case UNKNOWN                         //未知
    case DIAL                            //主叫
    case INCOMING                        //被叫
}


/*
 * @brief MqttState状态变化种类
 */
@objc public enum MqttState : Int{
    case ConnectDone                         //连接服务器成功
    case ConnectFail                         //连接服务器失败
    case ScribeDone                          //订阅成功
    case ScribeFail                          //订阅失败
    case ConnectionLost                      //断开连接
}

public class MqttParam : NSObject {
    @objc public var defaultHost   : String        //服务器地址
    @objc public var mClientId     : String
    @objc public var mUserName     : String
    @objc public var mPassword     : String
    @objc public var mPort         : UInt
    
    
    public init(defaultHost:String ,
                mClientId:String,
                mUserName:String,
                mPassword:String,
                mPort:UInt
    ){
        self.defaultHost = defaultHost
        self.mClientId = mClientId
        self.mUserName = mUserName
        self.mPassword = mPassword
        self.mPort = mPort
    }
}

class CocoaMqtt: NSObject,CocoaMQTTDelegate  {
    
    
    let defaultHost1 = "120.92.238.227"//"broker-cn.emqx.io"
    let clientID1 = "Agora_01"
    let userNameStr = "01GSPRKFNCYZPKDJC7R42CJQ7H"
    let passWordStr = "01GSPRKFNCYZPKDJC7R42CJQ7H/315488"
    
    var mInitParam : MqttParam?
    
    var mqtt: CocoaMQTT?
    var curConnState:CocoaMQTTConnState?
    
    var pingFinished: ((Double) -> Void)?//获取ping数据
    var stateChanged: ((MqttState,Int,String) -> Void)?//mqtt状态变化回调
    var receiveMsg: ((CocoaMQTTMessage) -> Void)?//收到消息回调
    
    var topic = ""
    
    
    override init() {
        super.init()
    }
    
//    func initCustom(){
//        initialize(defaultHost: defaultHost1, clientID: clientID1, userNameStr: userNameStr, passWordStr:passWordStr,port: 11883  )
//    }
    
    func initialize(defaultHost:String, clientID: String, userNameStr: String, passWordStr: String,port:UInt){
        
        if self.mqtt != nil {
            return
        }
        
        self.mInitParam = MqttParam(defaultHost: defaultHost, mClientId: clientID, mUserName: userNameStr, mPassword: passWordStr, mPort: port)
        
        let clientID = clientID
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: UInt16(port))//11883
        if let mqtt = mqtt{
            mqtt.logLevel = .debug
            mqtt.username = userNameStr
            mqtt.password = passWordStr
            mqtt.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
            mqtt.keepAlive = 60
            mqtt.delegate = self
            mqtt.autoReconnect = true
            mqtt.autoReconnectTimeInterval = 2
            mqtt.maxAutoReconnectTimeInterval = 16
            
            mqtt.enableSSL = true
            mqtt.allowUntrustCACertificate = true
            
        }
    }
    
    func connect(){
 
        log.i("mqtt try connect ...")
        let ret = mqtt!.connect()
        if(ret != true){
            log.e("mqtt connect fail")
            stateChanged?(.ConnectFail,ErrCode.XERR_NETWORK,"mqtt connect fail")
        }
        
    }
    
    func disconnect(){
        log.i("mqtt disconnect ...")
        if self.mqtt != nil {
            mqtt?.disconnect()
            mqtt = nil
            curConnState = .disconnected
        }
    }
    
    func subScribeTopics(){//(completion:@escaping(Bool,String)->Void)
        
        let topic1 = "$falcon/callkit/" + (mInitParam?.mClientId ?? "") + "/sub"
        
        topic = topic1
        
        let topics:[(String, CocoaMQTTQoS)] = [(topic1,CocoaMQTTQoS.qos1)]
        mqtt?.subscribe(topics)
 
    }
    
    func sendData(_ msg : String,_ topic:String){
        
        let publishProperties = MqttPublishProperties()
        publishProperties.contentType = "JSON"
        let ret =  mqtt!.publish(topic, withString: msg, qos: .qos1 ,retained:true)
        log.i("----sendData--- = \(ret)")
  
    }
    
//    func testPublis(){
//
//        let topicCallPub = "$falcon/callkit/" + (mInitParam?.mClientId ?? "") + "/pub"
//
//        let curTimestamp:Int = String.dateTimeRounded()
//
//        let headerParam = ["traceId": curTimestamp, "timestamp": curTimestamp, "method": "user-start-call"] as [String : Any]
//        let payloadParam = ["appId": "d0177a34373b482a9c4eb4dedcfa586a", "deviceId": "test_peerid", "extraMsg": "extraMsg"] as [String : Any]
//        let paramDic = ["header":headerParam,"payload":payloadParam]
//        let jsonString = paramDic.convertDictionaryToJSONString()
//        self.sendData(jsonString,jsonString)
//
//    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        log.i("didConnectAck ack: \(ack)")

        if ack == .accept {
            log.i("连接成功")
            subScribeTopics()
            curConnState = mqtt.connState
            stateChanged?(.ConnectDone,ErrCode.XOK,"success")

        }else if ack == .badUsernameOrPassword || ack == .notAuthorized{
            stateChanged?(.ConnectFail,ErrCode.XERR_NOT_AUTHORIZED, "\(ack)")
        }else{
            stateChanged?(.ConnectFail,ErrCode.XERR_NETWORK,"\(ack)")
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        log.i("new state: \(state)")
        if curConnState == .connected && state == .disconnected{
            curConnState = mqtt.connState
            stateChanged?(.ConnectionLost,ErrCode.XERR_NETWORK,"mqtt disconnect")
        }
    }


    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        log.i("didPublishMessage: \(String(describing: message.string?.description)), id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        log.i("发送成功id: \(id)")
        pingFinished?(0)
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        log.i("didReceiveMessage: \(String(describing: message.string?.description)), id: \(id)")
        receiveMsg?(message)

    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        log.i("subscribed: \(success), failed: \(failed)")
        if failed.count == 0{
            stateChanged?(.ScribeDone,ErrCode.XOK,"success")
        }else{
            stateChanged?(.ScribeFail,ErrCode.XERR_NETWORK,"\(failed)")
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        log.i("topic: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        log.i("mqttDidPing")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        log.i("mqttDidReceivePong")
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        log.i("\(err.debugDescription)")
    }
 
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
 
        
        if let path = AgoraIotLinkTools.loadBundle()?.path(forResource: "certificate", ofType: "cer")  {
            
            guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                  log.i("Unable to read certificate file.")
                  return
            }

            let cfData = fileData as CFData
            let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, cfData)
            if verifyCA(trust: trust, certData: certificate!) {
                    log.i("证书有效，由受信任的根证书签发")
                    completionHandler(true)
                    return
            } else {
                    log.i("证书无效")
                    completionHandler(false)
                    return
            }
            
        } else {
            log.i("找不到证书文件")
        }
        
        
//        //单独校验服务端(不需要本地证书)
//        let cer = convertSecTrustToSecCertificate(trust)!
//        verifyServiceCA(cer)
//
//        let policy1 = SecPolicyCreateBasicX509()
//        SecTrustSetPolicies(trust, policy1)
//
//        var trustResult1: SecTrustResultType = .invalid
//        SecTrustEvaluate(trust, &trustResult1)
//
//        if trustResult1 == .proceed || trustResult1 == .unspecified {
//            // 证书验证成功
//            log.i("trust: 证书验证成功")
//        } else {
//            // 证书验证失败
//            log.i("trust: 证书验证失败")
//        }
        
        
        log.i("trust: \(trust)")
        completionHandler(false)
    }
    
    // self signed delegate
//    func mqttUrlSession(_ mqtt: CocoaMQTT, didReceiveTrust trust: SecTrust, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
//        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
//            let myCert = "myCert"
//            let certData = Data(base64Encoded: myCert as String)!
//
//            if let trust = challenge.protectionSpace.serverTrust,
//               let cert = SecCertificateCreateWithData(nil,  certData as CFData) {
//                let certs = [cert]
//                SecTrustSetAnchorCertificates(trust, certs as CFArray)
//
//                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: trust))
//                return
//            }
//        }
//
//        log.i("mqttUrlSession trust: \(trust)")
//        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
//
//    }


}

extension CocoaMqtt{
    
//        func verifyServiceCA(_ certData: SecCertificate) -> Bool {
//
//            // 创建一个证书验证策略
//            let policy = SecPolicyCreateBasicX509()
//
//            // 创建一个待验证的证书集合
//            let certArray = [certData] as CFArray
//
//            // 创建SecTrustRef对象
//            var trustNew: SecTrust?
//            let trustCreationStatus = SecTrustCreateWithCertificates(certArray, policy, &trustNew)
//
//            if trustCreationStatus == errSecSuccess {
//                // 成功创建SecTrustRef对象，可以继续进行证书验证
//                log.i("success creating new trust")
//
//                // 设置受信任的根证书集合
//                SecTrustSetAnchorCertificates(trustNew!, certArray)
//
//                // 执行证书验证
//                var resultType = SecTrustResultType.invalid
//                SecTrustEvaluate(trustNew!, &resultType)
//
//                // 检查证书是否通过验证
//                if resultType == .unspecified || resultType == .proceed {
//                    // 证书有效，由受信任的根证书签发
//                    return true
//                }
//
//
//            } else {
//                // 创建SecTrustRef对象失败，处理错误
//                let error = NSError(domain: NSOSStatusErrorDomain, code: Int(trustCreationStatus), userInfo: nil)
//                log.i("Error creating trust: \(error)")
//            }
//
//            return false
//        }
        
//        func convertSecTrustToSecCertificate(_ trust: SecTrust) -> SecCertificate? {
//
//
//            guard let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) else {
//                return nil
//            }
//
//            return serverCertificate
//        }

        
        func verifyCA(trust: SecTrust, certData: SecCertificate) -> Bool {
     
            // 创建一个证书验证策略
            let policy = SecPolicyCreateBasicX509()
            SecTrustSetPolicies(trust, policy)
            
            // 创建一个待验证的证书集合
            let certArray = [certData] as CFArray
            
            // 创建SecTrustRef对象
            var trustNew: SecTrust?
            let trustCreationStatus = SecTrustCreateWithCertificates(certArray, policy, &trustNew)
            
            if trustCreationStatus == errSecSuccess {
                // 成功创建SecTrustRef对象，可以继续进行证书验证
                log.i("success creating new trust")

                // 设置受信任的根证书集合
                SecTrustSetAnchorCertificates(trust, certArray)
                
                // 执行证书验证
                var resultType = SecTrustResultType.invalid
                SecTrustEvaluate(trust, &resultType)
                
                // 检查证书是否通过验证
                if resultType == .unspecified || resultType == .proceed {
                    // 证书有效，由受信任的根证书签发
                    return true
                }
                
            } else {
                // 创建SecTrustRef对象失败，处理错误
                let error = NSError(domain: NSOSStatusErrorDomain, code: Int(trustCreationStatus), userInfo: nil)
                log.i("Error creating trust: \(error)")
            }
     
            return false
        }
    
}
