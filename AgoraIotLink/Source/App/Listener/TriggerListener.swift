//
//  TriggerListener.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/7.
//

import Foundation
class TriggerListener{
    private var _logout_watcher:()->Void = {}
    private var _remote_state_watcher:(ActionAck)->Void = {s in}
    private var _incoming_state_watcher:(ActionAck)->Void = {s in}
    private var _member_state_watcher:((MemberState,[UInt])->Void)? = {s,a in}
    var logout_watcher:()->Void{set{_logout_watcher = newValue}get{return _logout_watcher}}
    var remote_state_watcher:(ActionAck)->Void{set{_remote_state_watcher = newValue}get{return _remote_state_watcher}}
    var incoming_state_watcher:(ActionAck)->Void{set{_incoming_state_watcher = newValue}get{return _incoming_state_watcher}}
    var member_state_watcher:((MemberState,[UInt])->Void)?{
        set{
            log.i("listener set member_state_watcher")
            _member_state_watcher = newValue
            _member_state_watcher?(.Exist,uids)
            uids.removeAll()
        }
        get{return _member_state_watcher}}
    func reset(){
        log.i("listener reset")
        uids.removeAll()
        incoming_state_watcher = {a in}
        logout_watcher = {}
        remote_state_watcher = {a in}
        _member_state_watcher = defaultMemberState
    }
    private var uids:[UInt] = []
    private func defaultMemberState(s:MemberState,a:[UInt]){
        if(s == .Enter){
            for u in a{
                uids.append(u)
            }
        }
        if(s == .Leave){
            for u in a{
                if let idx = uids.firstIndex(of: u){
                    uids.remove(at: idx)
                }
                else{
                    log.e("listener unrecorded uid \(u) thang left rtc")
                }
            }
        }
    }
}
