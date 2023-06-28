//
//  Account.swift
//  demo
//
//  Created by ADMIN on 2022/2/7.
//

import Foundation

internal class Proxy{
    private var _gw : IotLink!
    private var _al : AgoraLab!
    private var _rtc: RtcEngine?
//    private var _rtm: RtmEngine?
    private var _ntf: PushNotifier!
//    private var _mqtt:AWSMqtt!
    
    var al:AgoraLab{get{return _al}}
    var gw:IotLink{get{return _gw}}
    var ntf:PushNotifier{get{return _ntf!}}
    var rtc:RtcEngine{get{return _rtc!}}
//    var mqtt:AWSMqtt{get{return _mqtt}}
//    var rtm:RtmEngine{get{return _rtm!}}
    
    init(event:StateListener, rule:RuleManager,cfg:Config,ctx:Context){
        self._rtc = RtcEngine()
//        self._rtm = RtmEngine(cfg:cfg)
        self._ntf = PushNotifier(cfg: cfg)
//        self._mqtt = AWSMqtt(cfg: cfg)
//        self._mqtt.onStatusChanged = event.onMqttStatusChanged
        self._al = AgoraLab(http: cfg.agoraServerUrl)
        self._gw = IotLink(http: cfg.iotlinkServerUrl)
    }
}
 
