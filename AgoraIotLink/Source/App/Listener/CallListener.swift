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
           log.i("listener auto call.on_callHangup")
           app.rule.trans(FsmCall.Event.LOCAL_HANGUP,
                          {self.autoCallHangup()})
                          
       }
       
    func autoCallHangup(){
           log.i("listener autoCallHangup")
           self.app.callkitMgr.doCallHangupInter(result: {ec,msg in
               log.i("auto hangup locally by CallListener:\(msg)(\(ec))")
           })
       }
    
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}

extension CallListener{
    
    func do_LEAVEANDDESTROY() {
        log.i("listener rtc.on_destroy")
        app.proxy.rtc.leaveAndDestroy(cb: {succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
            //todo:
//            self.app.rule.trans(succ ? FsmRtc.Event.DESTROY_SUCC : FsmRtc.Event.DESTROY_FAIL)
        })
    }
    
    func do_CREATEANDENTER() {
        let appId = app.context.call.session.appId
        let setting = app.context.call.setting
        let uid = app.context.call.session.uid
        let name = app.context.call.session.channelName
        let token = app.context.call.session.rtcToken
        log.i("listener rtc.createAndEnter(uid:\(uid) channel:\(name))")
        var rtcSetting = RtcSetting()
        rtcSetting.dimension = setting.dimension
        rtcSetting.frameRate = setting.frameRate
        rtcSetting.bitRate = setting.bitRate
        rtcSetting.orientationMode = setting.orientationMode
        rtcSetting.renderMode = setting.renderMode
        rtcSetting.audioType = setting.audioType
        rtcSetting.audioSampleRate = setting.audioSampleRate
        
        rtcSetting.logFilePath = setting.logFilePath
        rtcSetting.publishAudio = setting.publishAudio
        rtcSetting.publishVideo = setting.publishVideo
        rtcSetting.subscribeAudio = setting.subscribeAudio
        rtcSetting.subscribeVideo = setting.subscribeVideo
        
        app.proxy.rtc.createAndEnter(appId: appId, setting: rtcSetting, uid: uid,name: name, token:token, info: "",
                                     cb: {ret,msg in
            if(ret == .Fail){
                log.e("listener rtc.createAndEnter failed:\(msg)")
                //todo:
//                self.app.rule.trans(FsmRtc.Event.ENTER_FAIL)
            }
            else if(ret == .Succ){
                //todo:
//                self.app.rule.trans(FsmRtc.Event.ENTER_SUCC)
            }
            else {//Abort
                log.i("listener rtc.createAndEnter aborted:\(msg)")
            }
        },
        peerAction: {act,uid in
            if(act == .Enter){
                if(self.app.context.call.session.peerId == uid){
                    self.app.context.call.session.rtc.pairing.uid = uid
                    //todo:
//                    self.app.rule.trans(FsmRtc.Event.PEER_JOIN)
                    self.app.rule.trans(FsmCall.Event.REMOTE_JOIN)
                }
            }
            else if(act == .Leave){
                if(self.app.context.call.session.peerId == uid){
                    self.app.context.call.session.rtc.pairing.uid = 0
                    //todo:
//                    self.app.rule.trans(FsmRtc.Event.PEER_LEFT)
                    self.app.rule.trans(FsmCall.Event.REMOTE_LEFT)
                }
            }
            else if(act == .VideoReady){
                if(self.app.context.call.session.peerId == uid){
                    //todo:
                    self.app.rule.trans(FsmCall.Event.REMOTE_JOIN)
                    self.app.rule.trans(FsmCall.Event.REMOTE_VIDEOREADY)
                }
            }
        },
        memberState:{s,a in
            if(s == .Enter){
                if(a[0] == self.app.context.call.session.peerId){
                    self.app.rule.trigger.member_state_watcher?(s,a)
                }
            }
            else if(s == .Leave){
                if(a[0] != self.app.context.call.session.peerId){
                    self.app.rule.trigger.member_state_watcher?(s,a)
                }
            }
            else{
                self.app.rule.trigger.member_state_watcher?(s,a)
            }
        })
    }

//    func do_DESTROY(_ srcState: FsmRtc.State) {
//        log.i("listener rtc.do_DESTROY")
//        app.proxy.rtc.destroy()
//        app.rule.trans(FsmRtc.Event.DESTROY_SUCC)
//    }

    
    func do_FsmCall_LOCAL_JOIN_SUCC() {
        
    }
    
    func do_FsmCall_LOCAL_JOIN_FAIL() {
        
    }
    
    func do_FsmCall_REMOTE_JOIN() {
        
    }
    
    func do_FsmCall_REMOTE_LEFT() {
        
    }
    
    func do_FsmCall_REMOTE_VIDEOREADY() {
        
    }
}
