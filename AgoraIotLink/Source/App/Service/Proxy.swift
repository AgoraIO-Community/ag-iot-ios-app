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
    private var _cocoaMqtt:CocoaMqttMgr
    
    var al:AgoraLab{get{return _al}}
    var gw:IotLink{get{return _gw}}
    var rtc:RtcEngine{get{return _rtc!}}
    var cocoaMqtt:CocoaMqttMgr{get{return _cocoaMqtt}}
    
    init(rule:RuleManager,cfg:Config,ctx:Context){
        self._rtc = RtcEngine()
        self._al = AgoraLab(http: cfg.agoraServerUrl)
        self._gw = IotLink(http: cfg.iotlinkServerUrl)
        
        self._cocoaMqtt = CocoaMqttMgr(cfg:cfg)
    }
    
    func destory(){
        _rtc = nil
        _al = nil
        _gw = nil
    }
}
 
