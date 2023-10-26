//
//  AppSdk.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

open class Application{
    
     func initialize(initParam: InitParam,OnSdkStateListener:@escaping(SdkState,StateChangeReason)->Void,onSignalingStateChanged:@escaping(Bool)->Void) -> Int {
        
        if(initParam.logFilePath != nil){
            log.ouput = .debugerConsoleAndFile
        }
        
//        Logger.shared.removeAllAsync()
        let tempAppId = initParam.mAppId.substring(to: 1) + "*********************" + initParam.mAppId.substring(from: initParam.mAppId.count - 1)
        log.i("=================  AgoraIotSdk  ======================")
        log.i("     version:   \(IAgoraIotSdkVersion)")
        log.i("       built:   \(Utils.dateTime())")
        log.i("       appId:   \(tempAppId)")
        log.i("    SlaveUrl:   \(initParam.mServerUrl)")
        log.i("     logFile:   \(String(describing: initParam.logFilePath))")
        log.i("======================================================")

        
        _config.masterAppId = initParam.mAppId
        _config.logFilePath = initParam.logFilePath
        _config.agoraServerUrl = initParam.mServerUrl
        
        _context.call.setting.logFilePath = initParam.logFilePath ?? ""
        _context.rtm.setting.appId = initParam.mAppId
        
        self._proxy = Proxy( rule:self.rule, cfg: self.config, ctx: self.context)
        _status?.setStatusHandler(handler: OnSdkStateListener)
        _status?.setSignalingStatusHandler(handler: onSignalingStateChanged)

        
        if(initParam.mAppId == ""){
            log.e("sdk initParam.rtcAppId is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        if(initParam.mServerUrl == ""){
            log.e("sdk initParam.iotLinkUrl is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        
        if sdkState != .invalid {
            log.e("sdk initParam.rtcAppId is runing");
            return ErrCode.XERR_BAD_STATE
        }
        
        status.do_Initialized(.none)
        
        _rule!.start(queue:DispatchQueue.main)

        return ErrCode.XOK
    }
    
    func release() {
        _proxy?.destory()
        _proxy = nil
        log.i("sdk release:");
        sdkState = .invalid
    }
    
    public static let shared = Application()
    var sdkState : SdkState = .invalid
    var sdk:IotAppSdk{get{return _sdk}}
    var rule:RuleManager{get{return _rule!}}
    var config:Config{get{return _config}}
    var status:StateListener{get{return _status!}}
    var proxy:Proxy{get{return _proxy!}}
    var context:Context{get{return _context}}
    
    private var _config = Config()
    private var _context = Context()
    private var _rule:RuleManager?
    private var _status:StateListener?
    private var _sdk:IotAppSdk = IotAppSdk()
    
    private var _proxy:Proxy?
    
    init(){
        log.level = .verb
//        self._sdk.application = self
        self._status = StateListener(self)
        self._rule = RuleManager(self,postFun)
        
    }
    
    let queue = DispatchQueue(label: "myQueue",qos: DispatchQoS.default,attributes: DispatchQueue.Attributes.concurrent,autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit,target: nil)
    func postFun(act: @escaping ()->Void){
        queue.sync{
            act()
        }
    }
    
}


