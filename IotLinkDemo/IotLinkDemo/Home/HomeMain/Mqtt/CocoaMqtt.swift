//
//  CocoaMqtt.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/22.
//

import UIKit
import CocoaMQTT
import AgoraIotLink


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
    
    var pingFinished: ((Double) -> Void)?//获取ping数据
    var stateChanged: ((MqttState,String) -> Void)?//mqtt状态变化回调
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
            mqtt.maxAutoReconnectTimeInterval = 60
        }
    }
    
    func connect(){
 
        log.i("mqtt try connect ...")
        let ret = mqtt!.connect()
        if(ret != true){
            log.e("mqtt connect fail")
            stateChanged?(.ConnectFail,"mqtt connect fail")
        }
        
    }
    
    func disconnect(){
        log.i("mqtt disconnect ...")
        if self.mqtt != nil {
            mqtt?.disconnect()
            mqtt = nil
            stateChanged?(.ConnectionLost,"mqtt disconnect")
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
    
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        log.i("trust: \(trust)")
        completionHandler(true)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        log.i("didConnectAck ack: \(ack)")

        if ack == .accept {
            log.i("连接成功")
            subScribeTopics()
            stateChanged?(.ConnectDone,"success")
        }else{
            stateChanged?(.ConnectFail,"\(ack)")
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        log.i("new state: \(state)")
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
            stateChanged?(.ScribeDone,"success")
        }else{
            stateChanged?(.ScribeFail,"\(failed)")
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

}
