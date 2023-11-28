//
//  IotAppSdk.swift
//  demo
//
//  Created by ADMIN on 2022/2/10.
//

import Foundation

open class IotAppSdk : IAgoraIotAppSdk{

    public func getSdkVersion() -> String {
        return IAgoraIotSdkVersion
    }
    
    private var _callbackFilter:(Int,String)->(Int,String) = {ec,msg in return (ec,msg)}
    private func onCallbackFilter(ec:Int,msg:String)->(Int,String){
//        if(ec == ErrCode.XERR_TOKEN_INVALID){
//            log.i("sdk token invalid,try logout")
//            self.accountMgr.logoutAccount(false) { ec, msg in
//                log.i("sdk logout done")
//            }
//        }
        return _callbackFilter(ec,msg)
    }
    
    public func initialize(initParam: InitParam,callbackFilter:@escaping(Int,String)->(Int,String)) -> Int {
        _callbackFilter = callbackFilter
        return app!.initialize(initParam: initParam,callbackFilter: onCallbackFilter)
    }
    
    private var app:Application?
    
    var application:Application{set{
        app = newValue
    }get{
        return app!
    }}
    
    public func release() {
        
        leaveRtm()
        _iotAppSdkManager = nil
        app!.release()
        
//        _deviceSessionManager = nil
//        _vodPlayerManager = nil
//        app = nil
    }
    
    func leaveRtm(){
        log.i("leaveRtm:")
        application.proxy.rtm.leave(cb: { succ in
            if(!succ){
                log.w("rtm leave fail")
            }else{
                log.i("rtm leave success")
            }
        })
    }
    
    
    private  var _iotAppSdkManager : IotAppSdkManager? = nil
    
    private var _deviceSessionManager: IDeviceSessionMgr? = nil
//    private var _vodPlayerManager    : IVodPlayerMgr? = nil
    
//    private var _callkitManager: CallkitManager? = nil
//    private var _accountManager : IAccountMgr? = nil
//    private var _deviceManager:IDeviceMgr? = nil
//    private var _alarmManager:IAlarmMgr? = nil
//    private var _notifyManager:INotificationMgr? = nil

    public var iotAppSdkMgr: IotAppSdkManager{get{
        if(_iotAppSdkManager == nil){
            _iotAppSdkManager = IotAppSdkManager(app: app!)
        }
        return _iotAppSdkManager!
        
    }}

    public var deviceSessionMgr: IDeviceSessionMgr{get{
        if(_deviceSessionManager == nil ){
            _deviceSessionManager = IDeviceSessionManager(app: app!)
        }
        return _deviceSessionManager!
        
    }}
    
//    public var vodPlayerMgr: IVodPlayerMgr{get{
//        if(_vodPlayerManager == nil){
//            _vodPlayerManager = IVodPlayerManager()
//        }
//        return _vodPlayerManager!
//        
//    }}
    
    
    
//    public var callkitMgr: ICallkitMgr{get{
//        if(_callkitManager == nil){
//            _callkitManager = CallkitManager(app: app!)
//        }
//        return _callkitManager!
//
//    }}
//    public var deviceMgr: IDeviceMgr{get{
//        if(_deviceManager == nil){
//            _deviceManager = DeviceManager(app: app!)
//        }
//        return _deviceManager!
//
//    }}
//
//
//    public var alarmMgr: IAlarmMgr{get{
//        if(_alarmManager == nil){
//            _alarmManager = AlarmManager(app:app!)
//        }
//        return _alarmManager!
//    }}
//
//    public var notificationMgr: INotificationMgr{get{
//        if(_notifyManager == nil){
//            _notifyManager = NotificationManager(app:app!)
//        }
//        return _notifyManager!
//    }}
//
//    public var accountMgr: IAccountMgr{get{
//        if(_accountManager == nil){
//            _accountManager = AccountManager(app: app!)
//        }
//        return _accountManager!
//    }}

    
}


