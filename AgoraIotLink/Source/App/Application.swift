//
//  AppSdk.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

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
        
        Logger.shared.setLogFilePath(initParam.logFilePath ?? "")
        Logger.shared.removeAllAsync() //清除之前的日志文件
        
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
//        _config!.logFilePath = initParam.logFilePath
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
        
        if sdkState == .runing {
            log.e("sdk initParam.rtcAppId is runing");
            return ErrCode.XERR_BAD_STATE
        }

        sdkState = .runing

        return ErrCode.XOK
    }
    
    func release() {
        _proxy?.destory()
        _config = nil
        _context = nil
        _proxy = nil
        sdkState = .invalid
        log.i("sdk release:");
    }
    
    public static let shared = Application()
    var sdkState : SdkState = .invalid
    var sdk:IotAppSdk{get{return _sdk}}
    var config:Config{get{return _config!}}
    var proxy:Proxy{get{return _proxy!}}
    var context:Context{get{return _context ?? Context()}}
    
    private var _config : Config?
    private var _context : Context?
    private var _sdk:IotAppSdk = IotAppSdk()
    
    private var _proxy:Proxy?
    
    init(){
        log.level = .verb
        self._sdk.application = self
        
    }
    
    func registerLogListener(callback:@escaping(Int,String)->Void){
        Logger.shared.registerLogListener(callback: callback)
    }
    
}


