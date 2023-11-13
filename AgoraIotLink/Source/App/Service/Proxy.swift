//
//  Account.swift
//  demo
//
//  Created by ADMIN on 2022/2/7.
//

import Foundation

internal class Proxy{

    private var _rtc: RtcEngine?
    private var _rtm: RtmEngine?
    
    var rtc:RtcEngine{get{return _rtc!}}
    var rtm:RtmEngine{get{return _rtm!}}
    
    
    init(cfg:Config,ctx:Context){
        self._rtc = RtcEngine()
        self._rtm = RtmEngine(cfg: cfg)
    }
    
    func destory(){
        _rtc = nil
        _rtm = nil
    }
}
 
