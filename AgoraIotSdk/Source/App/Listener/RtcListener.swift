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
        let setting = app.context.call.setting.rtc
        let uid = app.context.call.session.uid
        let name = app.context.call.session.channelName
        let token = app.context.call.session.rtcToken
        log.i("listener rtc.createAndEnter(uid:\(uid) channel:\(name))")
        app.proxy.rtc.createAndEnter(appId: appId, setting: setting, uid: uid,name: name, token:token, info: "",
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
                self.app.context.call.session.rtc.pairing.uid = uid
                self.app.rule.trans(FsmRtc.Event.PEER_JOIN)
            }
            else if(act == .Leave){
                self.app.context.call.session.rtc.pairing.uid = 0
                self.app.rule.trans(FsmRtc.Event.PEER_LEFT)
            }
            else if(act == .VideoReady){
                self.app.rule.trans(FsmRtc.Event.VIDEOREADY)
            }
        })
    }

    func do_DESTROY(_ srcState: FsmRtc.State) {
        log.i("listener rtc.do_DESTROY")
        app.proxy.rtc.destroy()
        app.rule.trans(FsmRtc.Event.DESTROY_SUCC)
    }
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}
