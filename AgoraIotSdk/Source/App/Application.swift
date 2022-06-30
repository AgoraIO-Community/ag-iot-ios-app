//
//  AppSdk.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation
//import UIKit

open class Application{
    func initialize(initParam: InitParam, sdkStatus: @escaping(SdkStatus, String)->Void,callBackFilter:@escaping(Int,String)->(Int,String)) -> Int {
        
        if(initParam.logFilePath != ""){
            log.ouput = .debugerConsoleAndFile
        }
        
        Logger.shared.removeAllAsync()
        
        log.i("=================  AgoraIotSdk  ======================")
        log.i("     version:   \(IAgoraIotSdkVersion)")
        log.i("       built:   \(Utils.dateTime())")
        log.i("======================================================")
        
        _config.appId = initParam.rtcAppId
        _config.logFilePath = initParam.logFilePath
        _config.ntfAppKey = initParam.ntfAppKey
        _config.ntfApnsCertName = initParam.ntfApnsCertName
        _config.agoraServerUrl = initParam.slaveServerUrl
        _config.granWinServerUrl = initParam.masterServerUrl
        _config.projectId = initParam.projectId
        
        _status?.setStatusHandler(handler: sdkStatus)
        _context.callBackFilter = callBackFilter
        
        _context.call.setting.rtc.logFilePath = initParam.logFilePath
        _context.call.setting.rtc.publishAudio = initParam.publishAudio
        _context.call.setting.rtc.publishVideo = false
        _context.call.setting.rtc.subscribeAudio = initParam.subscribeAudio
        _context.call.setting.rtc.subscribeVideo = initParam.subscribeVideo
        
        self._proxy = Proxy(event:self.status, rule:self.rule, cfg: self.config, ctx: self.context)
        
        if(initParam.rtcAppId == ""){
            log.e("sdk initParam.rtcAppId is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        if(initParam.masterServerUrl == ""){
            log.e("sdk initParam.agoraLabUrl is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        if(initParam.slaveServerUrl == ""){
            log.e("sdk initParam.granwinUrl is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        if(initParam.ntfAppKey == ""){
            log.e("sdk initParam.ntfAppKey is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        if(initParam.ntfApnsCertName == ""){
            log.e("sdk initParam.ntfApnsCertName is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        
        _rule!.start(queue:DispatchQueue.main)

        return ErrCode.XOK
    }
    
    func release() {
        
    }
    
    public static let shared = Application()
    
    var sdk:IotAppSdk{get{return _sdk}}
    var rule:RuleManager{get{return _rule!}}
    var config:Config{get{return _config}}
    var status:StateListener{get{return _status!}}
    var proxy:Proxy{get{return _proxy!}}
    var context:Context{get{return _context}}
    
    var callkitMgr:CallkitManager{get{return _sdk.callkitMgr as! CallkitManager}}
    
    private var _config = Config()
    private var _context = Context()
    private var _rule:RuleManager?
    private var _status:StateListener?
    private var _sdk:IotAppSdk = IotAppSdk()
    
    private var _proxy:Proxy?
    
    init(){
        log.level = .info
        self._sdk.application = self
        self._status = StateListener(self)
        self._rule = RuleManager(self,invoke)
        
    }
    
    let queue = DispatchQueue(label: "myQueue",qos: DispatchQoS.default,attributes: DispatchQueue.Attributes.concurrent,autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit,target: nil)
    //let queue = DispatchQueue.main
    func invoke(act: @escaping ()->Void){
        queue.sync{
            act()
        }
    }
    
    static func Instance()->Application{
        return Application.shared;
    }
}


