//
//  RtcListener.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/2/15.
//

import Foundation
class RtcListener : FsmRtc.IListener{
    
    func do_LEAVEANDDESTROY(_ srcState: FsmRtc.State) {
        log.i("listener rtc.on_destroy")
        app.proxy.rtc.leaveAndDestroy(cb: {succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
            self.app.rule.trans(succ ? FsmRtc.Event.DESTROY_SUCC : FsmRtc.Event.DESTROY_FAIL)
        })
    }
    
    func do_CREATEANDENTER(_ srcState: FsmRtc.State) {
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
                self.app.rule.trans(FsmRtc.Event.ENTER_FAIL)
            }
            else if(ret == .Succ){
                self.app.rule.trans(FsmRtc.Event.ENTER_SUCC)
            }
            else {//Abort
                log.i("listener rtc.createAndEnter aborted:\(msg)")
            }
        },
        peerAction: {act,uid in
            if(act == .Enter){
                if(self.app.context.call.session.peerId == uid){
                    self.app.context.call.session.rtc.pairing.uid = uid
                    self.app.rule.trans(FsmRtc.Event.PEER_JOIN)
//                    self.app.rule.trans(FsmCall.Event.REMOTE_JOIN)
                }
            }
            else if(act == .Leave){
                if(self.app.context.call.session.peerId == uid){
                    self.app.context.call.session.rtc.pairing.uid = 0
                    self.app.rule.trans(FsmRtc.Event.PEER_LEFT)
                }
            }
            else if(act == .VideoReady){
                if(self.app.context.call.session.peerId == uid){
                    self.app.rule.trans(FsmRtc.Event.VIDEOREADY)
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
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}
