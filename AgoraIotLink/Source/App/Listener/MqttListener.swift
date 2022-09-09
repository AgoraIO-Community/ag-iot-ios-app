//
//  MqttListener.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/6.
//

import Foundation
class MqttListener : FsmMqtt.IListener{
    func on_disconnect(_ srcEvent: FsmMqtt.Event) {
        log.i("listener mqtt disconnect")
        self.app.proxy.mqtt.disconnect(completion: {succ,msg in
            if(!succ){
                log.e("listener mqtt disconnect fail:\(msg)")
            }
        })
    }
    
    func do_SUBMIT(_ srcState: FsmMqtt.State) {
        struct Reported : Codable{
            let appId:String
            let deviceAlias:String
            let pusherId:String
            let localRecord:Bool
        }
        struct State : Codable{
            let reported : Reported
        }
        let onMqttSubscribeResult = {(succ:Bool,msg:String) in
            self.app.rule.trans(succ ? FsmMqtt.Event.SUBMIT_SUCC : FsmMqtt.Event.SUBMIT_FAIL)
            
            //https://confluence.agoralab.co/pages/viewpage.action?pageId=944705001
//            let reported = Reported(appId: self.app.config.appId,
//                                    deviceAlias: self.app.context.call.session.deviceAlias,
//                                    pusherId: self.app.context.push.session.eid,
//                                    localRecord: false)
//            let state = State(reported: reported)
//
//
//            guard let data = try? JSONEncoder().encode(state) else{
//                log.e("listener encode state failed \(state)")
//                return
//            }
//            let topic = "$aws/things/" + self.app.context.gyiot.session.cert.thingName + "/shadow/name/rtc"
//            self.app.proxy.mqtt.publish(data:data,topic: topic,qos:.messageDeliveryAttemptedAtLeastOnce)
            
            
            
            if(succ){
                let dictRtm:[String:Any] = ["appId":self.app.config.appId]
                let reportedRtm:[String:Any] = ["reported":dictRtm]
                let stateJsonRtm:[String:Any] = ["state":reportedRtm]
                let strRtm = JSON(stateJsonRtm)
                let jsonStrRtm = strRtm.rawString([.castNilToNSNull:true])
                
                var topicRtmUpdate = "$aws/things/" + self.app.context.gyiot.session.cert.thingName + "/shadow/name/rtm/update"
                self.app.proxy.mqtt.publish(data: jsonStrRtm!, topic: topicRtmUpdate, qos: .messageDeliveryAttemptedAtLeastOnce)
            }
        }
        app.proxy.mqtt.subScribeWithClient(completion: onMqttSubscribeResult)
    }
    
    func do_INITMQTT(_ srcState: FsmMqtt.State) {
        let gwsess = app.context.gyiot.session
        app.proxy.mqtt.initialize(thingName:gwsess.cert.thingName, endPoint: gwsess.endPoint, token:  gwsess.pool_token,identityId: gwsess.pool_identityId,identityPoolId: gwsess.pool_identityPoolId,region: gwsess.region,appId: app.config.appId,deviceAlias: app.context.gyiot.session.account)
        
        app.rule.trans(FsmMqtt.Event.CONN)
    }
    
    func do_CONN(_ srcState: FsmMqtt.State) {
        let onMqttConnectResult = {(succ:Bool,msg:String) in
            self.app.rule.trans(succ ? .CONN_SUCC : .CONN_FAIL)
        }
        app.proxy.mqtt.connect(completion: onMqttConnectResult)
    }
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}
