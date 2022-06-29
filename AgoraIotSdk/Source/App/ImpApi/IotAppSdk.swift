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
    
    public func initialize(initParam: InitParam, sdkStatus:@escaping (SdkStatus, String)->Void,callbackFilter:@escaping(Int,String)->(Int,String)) -> Int {
        return app!.initialize(initParam: initParam,sdkStatus:sdkStatus,callBackFilter: callbackFilter)
    }
    
    private var app:Application?
    
    var application:Application{set{
        app = newValue
    }get{
        return app!
    }}
    
    public func release() {
        app!.release()
    }
    
    private var _accountManager : IAccountMgr? = nil
    private var _callkitManager: CallkitManager? = nil
    private var _deviceManager:IDeviceMgr? = nil
    private var _alarmManager:IAlarmMgr? = nil
    private var _notifyManager:INotificationMgr? = nil
    
    public var callkitMgr: ICallkitMgr{get{
        if(_callkitManager == nil){
            _callkitManager = CallkitManager(app: app!)
        }
        return _callkitManager!
        
    }}
    
    public var deviceMgr: IDeviceMgr{get{
        if(_deviceManager == nil){
            _deviceManager = DeviceManager(app: app!)
        }
        return _deviceManager!
        
    }}

    
    public var alarmMgr: IAlarmMgr{get{
        if(_alarmManager == nil){
            _alarmManager = AlarmManager(app:app!)
        }
        return _alarmManager!
    }}
    
    public var notificationMgr: INotificationMgr{get{
        if(_notifyManager == nil){
            _notifyManager = NotificationManager(app:app!)
        }
        return _notifyManager!
    }}
    
    public var accountMgr: IAccountMgr{get{
        if(_accountManager == nil){
            _accountManager = AccountManager(app: app!)
        }
        return _accountManager!
    }}
}
