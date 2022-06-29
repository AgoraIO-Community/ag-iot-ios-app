//
//  TriggerListener.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/7.
//

import Foundation
class TriggerListener{
    private var _logout_watcher:()->Void = {}
    private var _local_join_watcher:(FsmCall.Event)->Void = {event in}
    private var _remote_state_watcher:(ActionAck)->Void = {s in}
    private var _incoming_state_watcher:(ActionAck)->Void = {s in}
    var logout_watcher:()->Void{set{_logout_watcher = newValue}get{return _logout_watcher}}
    var local_join_watcher:(FsmCall.Event)->Void{set{_local_join_watcher = newValue}get{return _local_join_watcher}}
    var remote_state_watcher:(ActionAck)->Void{set{_remote_state_watcher = newValue}get{return _remote_state_watcher}}
    var incoming_state_watcher:(ActionAck)->Void{set{_incoming_state_watcher = newValue}get{return _incoming_state_watcher}}
    
}
