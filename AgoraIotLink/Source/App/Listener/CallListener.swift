//
//  CallListener.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/25.
//

import Foundation
import AgoraRtcKit
class CallListener : FsmCall.IListener{
    
    func on_incoming_state_watcher(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_incoming_state_watcher \(srcEvent)")
        app.rule.trigger.incoming_state_watcher(srcEvent == FsmCall.Event.VIDEOREADY ? .RemoteVideoReady : .RemoteHangup)
    }
    
    func on_remote_state_watcher(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_remote_state_watcher \(srcEvent)")
        app.rule.trigger.remote_state_watcher(srcEvent == FsmCall.Event.VIDEOREADY ? .RemoteVideoReady : .RemoteHangup)
    }
    
    func on_local_join_watcher(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_local_join_watcher \(srcEvent)")
        app.rule.trigger.local_join_watcher(srcEvent)
    }
    
    func on_callkit_ready(_ srcEvent: FsmCall.Event) {
        app.context.call.session.rtc.paired.removeAll(keepingCapacity: true)
        app.context.call.session.rtc.pairing.uid = 0
        app.context.call.session.rtc.pairing.view = nil
    }
    
    func do_REMOTE_JOIN(_ srcState: FsmCall.State) {
        var paired = app.context.call.session.rtc.paired
        
        if(paired.count != 0){
            log.e("call setPeerVideoView with error session count:\(paired.count)")
        }
        let pairing = app.context.call.session.rtc.pairing

        if(pairing.view != nil && pairing.uid != 0){
            let canvas = AgoraRtcVideoCanvas()
            canvas.uid = pairing.uid
            canvas.renderMode = app.context.call.setting.rtc.renderMode
            canvas.view = pairing.view
            paired[pairing.uid] = RtcSession.VideoView()
            pairing.view = nil
            pairing.uid = 0
            app.proxy.rtc.setupRemoteView(remote: canvas)
        }
    }
    
    func on_callHangup(_ srcEvent: FsmCall.Event) {
        log.i("listener call.on_callHangup")
        app.rule.trans(FsmCall.Event.LOCAL_HANGUP,
                       {self.app.callkitMgr.doCallHangup(result: {ec,msg in
            log.i("reqCall auto hangup locally by CallListener:\(msg)(\(ec))")
        })})
    }
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}
