//
//  Account.swift
//  demo
//
//  Created by ADMIN on 2022/2/7.
//

import Foundation

internal class Proxy{
    private var _al : AgoraLab!
    private var _rtc: RtcEngine?
    private var _rtm: RtmEngine?
    
    var al:AgoraLab{get{return _al}}
    var rtc:RtcEngine{get{return _rtc!}}
    var rtm:RtmEngine{get{return _rtm!}}
    
    init(cfg:Config,ctx:Context){
        self._rtc = RtcEngine()
        self._rtm = RtmEngine(cfg: cfg)
        self._al = AgoraLab(cRegion:cfg.cRegion)
    }
    
    func destory(){
        _rtc = nil
        _rtm = nil
        _al = nil
    }
}
 
