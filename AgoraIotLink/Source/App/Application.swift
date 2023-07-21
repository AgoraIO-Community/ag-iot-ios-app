//
//  AppSdk.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation
//import AgoraRtmKit

/*
 * @brief SDK 状态机
 */
@objc public enum SdkState:Int {
    case invalid        // SDK未初始化
    case runing         // SDK就绪完成，可以正常使用
    case unpreparing    // SDK正在注销处理
}

open class Application{
    
    func initialize(initParam: InitParam,callbackFilter:@escaping(Int,String)->(Int,String)) -> Int {
        
        if(initParam.logFilePath != nil){
            log.ouput = .debugerConsoleAndFile
        }
        
        Logger.shared.removeAllAsync()
        let tempAppId = initParam.rtcAppId.substring(to: 1) + "*********************" + initParam.rtcAppId.substring(from: initParam.rtcAppId.count - 1)
        let projectId = initParam.projectId.substring(to: 1) + "*******" + initParam.projectId.substring(from: initParam.projectId.count - 1)
        log.i("=================  AgoraIotSdk  ======================")
        log.i("     version:   \(IAgoraIotSdkVersion)")
        log.i("       built:   \(Utils.dateTime())")
        log.i("       appId:   \(tempAppId)")
        log.i("   projectId:   \(projectId)")
        log.i("     logFile:   \(String(describing: initParam.logFilePath))")
        log.i("======================================================")

        
        _config = Config()
        _config!.appId = initParam.rtcAppId
        _config!.logFilePath = initParam.logFilePath
        _config!.projectId = initParam.projectId
        

        _context = Context()
        _context!.call.setting.logFilePath = initParam.logFilePath ?? ""
        _context!.rtm.setting.appId = initParam.rtcAppId
        _context!.callbackFilter = callbackFilter
        
        self._proxy = Proxy( cfg: self.config, ctx: self.context)

        
        if(initParam.rtcAppId == ""){
            log.e("sdk initParam.rtcAppId is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        
        if sdkStare == .runing {
            log.e("sdk initParam.rtcAppId is runing");
            return ErrCode.XERR_BAD_STATE
        }
        
//        _rule!.start(queue:DispatchQueue.main)
        sdkStare = .runing

        return ErrCode.XOK
    }
    
    func release() {
        _config = nil
        _context = nil
        _proxy = nil
        log.i("sdk release:");
        sdkStare = .invalid
    }
    
    public static let shared = Application()
    var sdkStare : SdkState = .invalid
    var sdk:IotAppSdk{get{return _sdk}}
//    var rule:RuleManager{get{return _rule!}}
    var config:Config{get{return _config!}}
//    var status:StateListener{get{return _status!}}
    var proxy:Proxy{get{return _proxy!}}
    var context:Context{get{return _context ?? Context()}}
    
    private var _config : Config?
    private var _context : Context?
//    private var _rule:RuleManager?
//    private var _status:StateListener?
    private var _sdk:IotAppSdk = IotAppSdk()
    
    private var _proxy:Proxy?
    
    init(){
        log.level = .verb
        self._sdk.application = self
//        self._status = StateListener(self)
//        _context = Context()
//        self._rule = RuleManager(self,postFun)
        
    }
    
//    let queue = DispatchQueue(label: "myQueue",qos: DispatchQoS.default,attributes: DispatchQueue.Attributes.concurrent,autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit,target: nil)
//    func postFun(act: @escaping ()->Void){
//        queue.sync{
//            act()
//        }
//    }
    
//    static func Instance()->Application{
//        return Application.shared;
//    }
    
    
}


