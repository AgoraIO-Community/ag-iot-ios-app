//
//  EventManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/26.
//

import Foundation

class StateListener : FsmState.IListener{
    func do_INITRTM_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitRtmFail,"rtm init faill")
    }
    
    func do_INITPUSH_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitPushFail,"push init fail")
    }
    
    func do_INITCALL_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitCallFail,"callkit init fail")
    }
    
    func do_INITMQTT_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitMqttFail,"Mqtt init fail")
    }
    
    func do_NOTREADY(_ srcState: FsmState.State) {
        _statusHandler(.NotReady,"not ready")
    }
    
    func do_ALLREADY(_ srcState: FsmState.State) {
        _statusHandler(.AllReady,"all ready")
    }
    
    let app:Application
    var _statusHandler:(SdkStatus,String)->Void = {n,s in}
    func setStatusHandler(handler:@escaping(SdkStatus,String)->Void){
        _statusHandler = handler
    }
    func onMqttStatusChanged(status:IotMqttSession.Status){
        if(status == .Connecting){
            _statusHandler(.Disconnected,"Mqtt connecting")
        }
        else if(status == .ConnectionError){
            _statusHandler(.Disconnected,"Mqtt connect fail")
        }
        else if(status == .Disconnected){
            _statusHandler(.Disconnected,"Mqtt disconnected")
        }
        else if(status == .Connected){
            _statusHandler(.Reconnected, "Mqtt auto connected")
        }
    }
    init(_ app:Application){
        self.app = app;
    }
}
