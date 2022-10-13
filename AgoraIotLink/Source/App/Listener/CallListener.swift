//
//  CallListener.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/25.
//

import Foundation
//import AgoraRtcKit
class CallListener : FsmCall.IListener{
    func on_reset_call(_ srcEvent: FsmCall.Event) {
        app.context.call.session.reset()
        app.rule.trigger.reset()
    }
    
    func on_incoming_state_watcher(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_incoming_state_watcher \(srcEvent)")
        var act:ActionAck = .UnknownAction
        if(srcEvent == .VIDEOREADY){
            act = .RemoteVideoReady
        }
        else if(srcEvent == .INCOMING_HANGUP){
            act = .RemoteHangup
        }
        else if(srcEvent == .LOCAL_ACCEPT_ERROR){
            act = .AcceptFail
        }
        else{
            log.e("listener unknown act:\(srcEvent.rawValue)")
        }
        app.rule.trigger.incoming_state_watcher(act)
    }
    
    func on_remote_state_watcher(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_remote_state_watcher \(srcEvent)")
        var act:ActionAck = .UnknownAction
        if(srcEvent == .VIDEOREADY){
            act = .RemoteVideoReady
        }
        else if(srcEvent == .NTF_REMOTE_HANGUP){
            act = .RemoteHangup
        }
        else{
            log.e("listener unknown act:\(srcEvent.rawValue)")
        }
        app.rule.trigger.remote_state_watcher(act)
    }
    
    func on_local_join_watcher(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_local_join_watcher \(srcEvent)")
        app.rule.trigger.local_join_watcher(srcEvent)
    }
    
    func do_REMOTE_JOIN(_ srcState: FsmCall.State) {
//        var paired = app.context.call.session.rtc.paired
//        
//        if(paired.count != 0){
//            log.e("call setPeerVideoView with error session count:\(paired.count)")
//        }
        let pairing = app.context.call.session.rtc.pairing

        if(pairing.view != nil && pairing.uid != 0){
            let uid = pairing.uid
            let view = pairing.view
            //paired[pairing.uid] = RtcSession.VideoView(uid: uid, view: view)
            pairing.view = nil
            pairing.uid = 0
            app.proxy.rtc.setupRemoteView(peerView: view, uid: uid)
        }
    }
    
    func on_callHangup(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_callHangup")
//        app.rule.trans(FsmCall.Event.LOCAL_HANGUP,
//                       {self.app.callkitMgr.doCallHangup(result: {ec,msg in
//            log.i("reqCall auto hangup locally by CallListener:\(msg)(\(ec))")
//        })})
        self.app.callkitMgr.callHangup(result: {ec,msg in
            log.i("reqCall auto hangup locally by CallListener:\(msg)(\(ec))")
        })
    }
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}
