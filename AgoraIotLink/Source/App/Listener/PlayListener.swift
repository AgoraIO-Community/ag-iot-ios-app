//
//  PlayListener.swift
//  AgoraIotLink
//
//  Created by ADMIN on 2022/9/15.
//

import Foundation
class PlayListener : FsmPlay.IListener{
    func do_CREATEANDENTER(_ srcState: FsmPlay.State) {
        log.i("player do_CREATEANDENTER(\(srcState)")
        let token = sess.token
        let uid = sess.peerUid
        let name = sess.channel
        let setting = app.context.player.setting
        
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
        
        app.proxy.rtc.createAndEnter(appId: sess.appId, setting: rtcSetting, uid: uid,name: name, token:token, info: "",
                                     cb: {ret,msg in
            if(ret == .Fail){
                log.e("player rtc.createAndEnter failed:\(msg)")
                self.app.rule.trans(FsmPlay.Event.ENTER_FAIL)
            }
            else if(ret == .Succ){
                self.app.rule.trans(FsmPlay.Event.ENTER_SUCC)
            }
            else {//Abort
                log.i("player rtc.createAndEnter aborted:\(msg)")
            }
        },
        peerAction: {act,uid in
            if(act == .Enter){
                self.sess.peerUid = uid
                self.app.rule.trans(FsmPlay.Event.PEER_JOIN)
            }
            else if(act == .Leave){
                self.sess.peerUid = 0
                self.app.rule.trans(FsmPlay.Event.PEER_LEFT)
            }
            else if(act == .VideoReady){
                self.app.rule.trans(FsmPlay.Event.VIDEOREADY)
            }
        },
        memberState:{s,a in
            log.w("player other member can't join this channel")
        })
    }
    
    func do_LEAVEANDDESTROY(_ srcState: FsmPlay.State) {
        log.i("player do_LEAVEANDDESTROY(\(srcState)")
        app.proxy.rtc.leaveAndDestroy(cb: {succ in
            if(!succ){
                log.e("player rtc leaveAndDestroy fail")
            }
        })
        app.rule.trans(FsmPlay.Event.DESTROY_SUCC)
    }
    
    func on_startSession(_ srcEvent: FsmPlay.Event) {
        log.i("player on_startSession(\(srcEvent)")
    }
    
    func on_stopSession(_ srcEvent: FsmPlay.Event) {
        log.i("player on_stopSession(\(srcEvent)")
    }
    
    func on_watcher(_ srcEvent: FsmPlay.Event) {
        log.i("player on_watcher(\(srcEvent)")
        if(srcEvent == .REMOTE_JOIN){
            sess.stateChanged(.RemoteJoin, "设备接入")
        }
        else if(srcEvent == .REMOTE_LEFT){
            sess.stateChanged(.RemoteLeft, "设备退出");
        }
        else if(srcEvent == .LOCAL_JOIN_SUCC){
            sess.stateChanged(.LocalReady,"正在接入设备")
        }
        else if(srcEvent == .LOCAL_JOIN_FAIL){
            sess.stateChanged(.LocalError,"接入设备失败")
        }
        else if(srcEvent == .REMOTE_VIDEOREADY){
            sess.stateChanged(.VideoReady,"收到设备视频")
        }
        else{
            log.e("player unknown event to watch:\(srcEvent.rawValue)")
        }
    }
    
    func setPlaybackView(peerView: UIView?) -> Int {
        app.proxy.rtc.setupRemoteView(peerView: peerView, uid: sess.peerUid)
    }
    
    func start(channelName: String, uid: UInt, result: @escaping (Int, String) -> Void,stateChanged:@escaping(PlaybackStatus,String)->Void){
        sess.appId = "aab8b8f5a8cd4469a63042fcfafe7063"
        sess.token = ""
        sess.peerUid = uid
        sess.channel = channelName
        sess.stateChanged = stateChanged
        app.proxy.rtc.muteLocalAudio(true, cb: {ec,msg in})
        app.proxy.rtc.muteLocalVideo(true, cb: {ec,msg in})
        result(ErrCode.XOK,"")
    }
    
    func stop(){
        sess.appId = ""
        sess.token = ""
        sess.peerUid = 0
        sess.channel = ""
        sess.stateChanged = {ec,msg in}
    }
    
    struct Session{
        var appId:String = ""
        var token:String = ""
        var peerUid:UInt = 0
        var channel:String = ""
        var stateChanged : (PlaybackStatus,String)->Void = {ec,msg in}
    }
    
    var sess : Session = Session()
    
    let app:Application
    init(app:Application){
        self.app = app;
    }
}
