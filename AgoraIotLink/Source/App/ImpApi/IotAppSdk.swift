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
    
    public func getMqttIsConnected() -> Bool {
        if app!.proxy.cocoaMqtt.curState == .ConnectDone{
            return true
        }
        return false
    }
    
    public func getStateMachine() -> SdkState? {
        return app?.sdkState ?? nil
    }
    
    public func initialize(initParam: InitParam,OnSdkStateListener:@escaping(SdkState,StateChangeReason)->Void) -> Int {
        if app == nil { app = Application.shared }
        return app!.initialize(initParam: initParam,OnSdkStateListener: OnSdkStateListener)
    }
    
    public func prepare(preParam: PrepareParam,prepareListener:@escaping(Int,String)->Void)-> Int{
        return iotAppSdkMgr.prepare(preParam: preParam, prepareListener: prepareListener)
    }
    
    public func unprepare() -> Int{
        return iotAppSdkMgr.unprepare()
    }
    
    public func getUserId()->String{
        return iotAppSdkMgr.getUserId()
    }
    
    public func getUserNodeId() -> String {
        return iotAppSdkMgr.getUserNodeId()
    }
    
    private var app:Application?
    
    public func release() {
        
        _iotAppSdkManager = nil
        _callkitManager = nil
        _accountManager = nil
        _deviceManager = nil
        _alarmManager = nil
        _notifyManager = nil
        
        app!.release()
        app = nil
        
    }
    
    
    private  var _iotAppSdkManager : IotAppSdkManager? = nil
    
    private var _callkitManager: CallkitManager? = nil
    private var _accountManager : IAccountMgr? = nil
    private var _deviceManager:IDeviceMgr? = nil
    private var _alarmManager:IAlarmMgr? = nil
    private var _notifyManager:INotificationMgr? = nil
    
    public var iotAppSdkMgr: IotAppSdkManager{get{
        if(_iotAppSdkManager == nil){
            _iotAppSdkManager = IotAppSdkManager(app: app!)
        }
        return _iotAppSdkManager!
        
    }}
    
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
