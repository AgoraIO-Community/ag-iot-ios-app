//
//  EventManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/26.
//

import Foundation
import AgoraRtmKit

class StateListener : NSObject{

    let app:Application
    var _statusHandler:(SdkState,StateChangeReason)->Void = {n,s in}
    var _signalingStatusHandler:(Bool)->Void = {s in}
    
    init(_ app:Application){
        self.app = app;
    }
    
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

    func do_Invalid() {
        app.sdkState = .invalid
        _statusHandler(.invalid,.none)
    }
    
    func do_Initialized(_ reason : StateChangeReason) {
        app.sdkState = .initialized
        _statusHandler(.initialized,reason)
    }
    
    func do_Preparing(_ reason : StateChangeReason) {
        app.sdkState = .loginOnGoing
        _statusHandler(.loginOnGoing,reason)
    }
    
    func do_Runing(_ reason : StateChangeReason) {
        app.sdkState = .running
        _statusHandler(.running,reason)
    }
    
    func do_Reconnecting(_ reason : StateChangeReason) {
        app.sdkState = .reconnecting
        _statusHandler(.reconnecting,reason)
    }
    
    func do_Unpreparing(_ reason : StateChangeReason) {
        app.sdkState = .logoutOnGoing
        _statusHandler(.logoutOnGoing,reason)
    }

}

extension StateListener{
    
    func setSignalingStatusHandler(handler:@escaping(Bool)->Void){
        _signalingStatusHandler = handler
        app.proxy.rtm.waitForStatusUpdated(statusUpdated: rtmStatusUpdated)
    }
    private func rtmStatusUpdated(state:MessageChannelStatus,msg:String,rtmMsg:AgoraRtmMessage?){

        log.i("onMqttListenerDesired state : \(state.rawValue)")
        
        switch state {
        case .Connecting:
            break
        case .Reconnecting:
            _signalingStatusHandler(false)
            break
        case .Connected:
            _signalingStatusHandler(true)
            break
        case .Disconnected:
            _signalingStatusHandler(false)
            break
        case .UnknownError:
            break
        default:
            break
        }

    }
    
}
