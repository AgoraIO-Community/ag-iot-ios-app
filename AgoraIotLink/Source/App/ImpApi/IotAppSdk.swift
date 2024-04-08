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
    
    public func isSignalingReady() -> Bool {
        if app!.proxy.rtm.curUpdateState  == .Connected{
            return true
        }
        return false
    }
    
    public func getStateMachine() -> SdkState? {
        return app?.sdkState ?? nil
    }
    
    public func initialize(initParam: InitParam) -> Int {
        if app == nil { app = IotLibrary.shared }
        return app!.initialize(initParam: initParam)

    }
    
    private var app:IotLibrary?
    
    public func release() {
        
        leaveRtm()
        
        _iotAppSdkManager = nil
        _connectionManager = nil
        app!.release()
        app = nil
        
    }
    
    func leaveRtm(){
        log.i("leaveRtm:")
        app?.proxy.rtm.leave(cb: { succ in
            if(!succ){
                log.w("rtm leave fail")
            }else{
                log.i("rtm leave success")
            }
        })
    }
    
    public func setPublishAudioEffect(effectId: AudioEffectId, result: @escaping (Int, String) -> Void) -> Int {
        DispatchQueue.main.async {
            self.app?.proxy.rtc.setAudioEffect(effectId, cb: result)
        }
        return ErrCode.XOK
    }
    
    public func getPublishAudioEffect() -> AudioEffectId {
        //todo:
        return .NORMAL
    }
    
    private  var _iotAppSdkManager : IotAppSdkManager? = nil
    
    private var _connectionManager: IConnectionManager? = nil
    
    public var iotAppSdkMgr: IotAppSdkManager{get{
        if(_iotAppSdkManager == nil){
            _iotAppSdkManager = IotAppSdkManager(app: app!)
        }
        return _iotAppSdkManager!
        
    }}
    
    public var connectionMgr: IConnectionMgr{get{
        if(_connectionManager == nil){
            _connectionManager = IConnectionManager(app: app!)
        }
        return _connectionManager!
        
    }}
    
    
}
