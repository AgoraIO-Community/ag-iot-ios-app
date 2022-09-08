//
//  EventManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/26.
//

import Foundation

class StateListener : FsmState.IListener{
    func do_INITRTM_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitRtmFail,"RTM初始化失败")
    }
    
    func do_INITPUSH_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitPushFail,"推送初始化失败")
    }
    
    func do_INITCALL_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitCallFail,"呼叫初始化失败")
    }
    
    func do_INITMQTT_FAIL(_ srcState: FsmState.State) {
        _statusHandler(.InitMqttFail,"Mqtt初始化失败")
    }
    
    func do_NOTREADY(_ srcState: FsmState.State) {
        _statusHandler(.NotReady,"未就绪")
    }
    
    func do_ALLREADY(_ srcState: FsmState.State) {
        _statusHandler(.AllReady,"准备就绪")
    }
    
    let app:Application
    var _statusHandler:(SdkStatus,String)->Void = {n,s in}
    func setStatusHandler(handler:@escaping(SdkStatus,String)->Void){
        _statusHandler = handler
    }
    func onMqttStatusChanged(status:IotMqttSession.Status){
        if(status == .Connecting){
            _statusHandler(.Disconnected,"Mqtt 正在连接")
        }
        else if(status == .ConnectionError){
            _statusHandler(.Disconnected,"Mqtt 连接错误")
        }
        else if(status == .Disconnected){
            _statusHandler(.Disconnected,"Mqtt 连接断开")
        }
        else if(status == .Connected){
            _statusHandler(.Reconnected, "Mqtt 自动连接成功")
        }
    }
    init(_ app:Application){
        self.app = app;
    }
}
