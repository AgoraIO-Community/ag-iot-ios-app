//
//  EventManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/26.
//

import Foundation

class StateListener : NSObject{


    func do_Invalid() {
        app.sdkState = .invalid
        _statusHandler(.invalid,.none)
    }
    
    func do_Initialized(_ reason : StateChangeReason) {
        app.sdkState = .initialized
        _statusHandler(.initialized,reason)
    }
    
    func do_Preparing(_ reason : StateChangeReason) {
        app.sdkState = .preparing
        _statusHandler(.preparing,reason)
    }
    
    func do_Runing(_ reason : StateChangeReason) {
        app.sdkState = .runing
        _statusHandler(.runing,reason)
    }
    
    func do_Reconnecting(_ reason : StateChangeReason) {
        app.sdkState = .reconnecting
        _statusHandler(.reconnecting,reason)
    }
    
    func do_Unpreparing(_ reason : StateChangeReason) {
        app.sdkState = .unpreparing
        _statusHandler(.unpreparing,reason)
    }
    
    

    let app:Application
    var _statusHandler:(SdkState,StateChangeReason)->Void = {n,s in}
    func setStatusHandler(handler:@escaping(SdkState,StateChangeReason)->Void){
        _statusHandler = handler
        app.proxy.cocoaMqtt.waitForListenerDesired(listenterDesired: onMqttListenerDesired)
    }
    
    private func onMqttListenerDesired(state:MqttState,msg:String){

        log.i("onMqttListenerDesired state : \(state.rawValue)")
        
        switch state {
        case .ConnectDone:
            break
        case .ConnectFail:
            do_Initialized(.abort)
            break
        case .ScribeDone:
            do_Runing(.none)
            break
        case .ScribeFail:
            break
        case .ConnectionLost:
            do_Reconnecting(.network)
            break
        default:
            break
        }

    }
    
    init(_ app:Application){
        self.app = app;
    }
}
