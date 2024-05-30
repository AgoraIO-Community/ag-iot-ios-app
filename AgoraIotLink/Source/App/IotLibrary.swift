//
//  AppSdk.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

public let IAgoraIotSdkVersion = "2.1.0.1"

/*
 * @brief SDK 状态机
 */
@objc public enum SdkState:Int {
    case invalid         // SDK未初始化
    case running         // SDK就绪完成，可以正常使用
}

open class IotLibrary : NSObject{
    
    func initialize(initParam: InitParam) -> Int {
        
        if(initParam.mLogFileName != nil){
            log.ouput = .debugerConsoleAndFile
        }
        
        Logger.shared.removeAllAsync()
        let tempAppId = initParam.mAppId.substring(to: 1) + "*********************" + initParam.mAppId.substring(from: initParam.mAppId.count - 1)
        log.i("=================  AgoraIotSdk  ======================")
        log.i("     version:   \(IAgoraIotSdkVersion)")
        log.i("       built:   \(Utils.dateTime())")
        log.i("       appId:   \(tempAppId)")
        log.i("    mRegion:   \(initParam.mRegion)")
        log.i("     logFile:   \(String(describing: initParam.mLogFileName))")
        log.i("======================================================")

        
        _config.masterAppId = initParam.mAppId
        _config.logFilePath = initParam.mLogFileName
        _config.cRegion = initParam.mRegion
        _config.mLocalNodeId = initParam.mLocalNodeId
        _config.mAuthToken = initParam.mLocalNodeToken
        _config.customerKey = initParam.mCustomerKey
        _config.customerSecret = initParam.mCustomerSecret
        
        _context.call.setting.logFilePath = initParam.mLogFileName ?? ""
        _context.rtm.setting.appId = initParam.mAppId
        
        self._proxy = Proxy( cfg: self.config, ctx: self.context)

        
        if(initParam.mAppId == ""){
            log.e("sdk initParam.rtcAppId is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        if(initParam.mRegion == 0){
            log.e("sdk initParam.iotLinkUrl is empty");
            return ErrCode.XERR_INVALID_PARAM
        }
        
        if sdkState != .invalid {
            log.e("sdk initParam.rtcAppId is runing");
            return ErrCode.XERR_BAD_STATE
        }
        
        status.do_Initialized()
        

        return ErrCode.XOK
    }
    
    func release() {
        _proxy?.destory()
        _proxy = nil
        log.i("sdk release:");
        sdkState = .invalid
    }
    
    public static let shared = IotLibrary()
    var sdkState : SdkState = .invalid
    var sdk:IotAppSdk{get{return _sdk}}
    var config:Config{get{return _config}}
    var status:StateListener{get{return _status!}}
    var proxy:Proxy{get{return _proxy!}}
    var context:Context{get{return _context}}
    
    private var _config = Config()
    private var _context = Context()
    private var _status:StateListener?
    private var _sdk:IotAppSdk = IotAppSdk()
    
    private var _proxy:Proxy?
    
    override init(){
        super.init()
        log.level = .verb
        self._status = StateListener(self)
        
    }
    
    
}


