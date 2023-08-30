//
//  MediaStateListener.swift
//  AgoraIotLink
//
//  Created by admin on 2023/7/10.
//

import UIKit


class MediaStateListener: NSObject {
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var app  = Application.shared
    var rtc  = Application.shared.proxy.rtc
    private var  callRcbTime : TimeCallback<(Int,String)>? = nil
    var callMachine : MediaStateMachine?
    var talkingEngine : AgoraTalkingEngine?
    
    var peerDisplayView : UIView?
    
    var callSession : CallSession?
    
    typealias callActionAck = (MediaCallback,_ sessionId:String,_ errCode:Int)->Void
    typealias callInterActionAck = (ActionAck,_ sessionId:String,_ peerNodeId:String)->Void
    typealias callMemberState = ((MemberState,[UInt],String)->Void)?
    typealias hangUpRetAck = (Bool,String)->Void
    typealias PreviewListener = (String, Int, Int)->Void
    
    private var callAct:callActionAck = {ack,sessionId,errCode in log.w("callAct callActionAck not inited")}
    private var hangUpRet :hangUpRetAck = {a,c in log.w("hangUpRetAck not inited")}
    
    var callMemState:callMemberState = {sessionId,m,c in log.w("callMemState callMemberState not inited")}
    var interCallAct:callInterActionAck = {ack,sessionId,peerNodeId in log.w("interCallAct callActionAck not inited")}
    var preViewlistener:PreviewListener = {sessionId,width,height in log.w("'_preViewlistener' callback not registered,please register it with 'PreviewListener'")}
    
    
    init(dialParam: CallSession,peerDisplayView:UIView?, actionAck:@escaping(MediaCallback,_ sessionId:String,_ errCode:Int)->Void,memberState:((MemberState,[UInt],String)->Void)?) {
        super.init()
        self.peerDisplayView = peerDisplayView
        callAct = actionAck
        callMemState = memberState
        startCall(dialParam)
        
    }
    
    func registerPreViewListener(previewListener: @escaping (String, Int, Int) -> Void){
        self.preViewlistener = previewListener
    }
    
    func startCall(_ dialParam: CallSession){
        
        callSession = dialParam
        callSession?.callType = .DIAL
        //RTC需要的参数
        callSession?.token = dialParam.token
        callSession?.cname = dialParam.cname
        callSession?.uid   = dialParam.uid
        callSession?.peerUid = dialParam.peerUid
        
        let callM = MediaStateMachine()
        callMachine = callM
        callMachine?.delegate = self
        callMachine?.handleEvent(.openCall)
 
    }
    
    func callRequest(){
        callMachine?.handleEvent(.startCall)
    }
    
    func hangUp(hangUpResult: @escaping (Bool,String) -> Void){
        hangUpRet = hangUpResult
        endTime()
        callMachine?.handleEvent(.endCall)
        self.callAct(.onStoped,self.callSession?.mSessionId ?? "",ErrCode.XOK)
        self.do_LEAVEANDDESTROY()
        destory()
    }
    
    func endTime(){
        self.callRcbTime?.invoke(args: (ErrCode.XOK,"stop call"))
    }
    
    deinit {
        log.i("MediaStateListener 销毁了")
    }

}

extension MediaStateListener : CallStateMachineListener{
    
    func do_CREATEANDENTER() {

        let uid = callSession?.uid ?? 0
        let name = callSession?.cname ?? ""
        let token = callSession?.token ?? ""
        let peerId = callSession?.peerUid ?? 0

        let setting = app.context.call.setting
        log.i("sdCard listener rtc.createAndEnter(uid:\(uid) channel:\(name))")
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
        rtcSetting.subscribeAudio = true   //sdk卡回看默认自动订阅音频
        rtcSetting.subscribeVideo = true   //sdk卡回看默认自动订阅视频
        
        rtcSetting.peerDisplayView = peerDisplayView //初始化时设置视图

        callRcbTime = TimeCallback<(Int,String)>(cb: { (state, msg) in
            log.i("callRcbTime :\(msg)")
        })
        
        let channelInfor = ChannelInfo()
        channelInfor.appId = app.config.appId
        channelInfor.uid = uid
        channelInfor.cName = name
        channelInfor.token = token
        channelInfor.peerUid = peerId
        
        talkingEngine = AgoraTalkingEngine.init(setting: rtcSetting, channelInfo: channelInfor, cb: {[weak self]ret,msg in
            
            if(ret == .Fail){
                log.e("listener rtc.createAndEnter failed:\(msg)")
                self?.callMachine?.handleEvent(.endCall)
                self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
            }
            else if(ret == .Succ){
                self?.callAct(.onjoinSuc,self?.callSession?.mSessionId ?? "",ErrCode.XOK)
                log.i("sdCard call reqCall CallForward")
                self?.callRcbTime?.schedule(time:self?.app.config.calloutTimeOut ?? 30,timeout: {
                    log.i("call reqCall ring remote timeout")
                    self?.callMachine?.handleEvent(.endCall)
                    self?.callAct(.onError,self?.callSession?.mSessionId ?? "",ErrCode.XERR_CALLKIT_DIAL)
                    self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
                })

            }
            else {//Abort
                log.i("listener rtc.createAndEnter aborted:\(msg)")
            }
        },
        peerAction: {act,uid in
            if(act == .Enter){
                log.i("listener Enter uid:\(uid)")
                if(self.callSession?.peerUid == uid){
                    self.callMachine?.handleEvent(.peerOnline)
                    self.callAct(.onPlayed,self.callSession?.mSessionId ?? "",ErrCode.XOK)
                }
            }
            else if(act == .Leave){
                log.i("listener Leave uid:\(uid)")
                if(self.callSession?.peerUid == uid){
                    self.callAct(.onStoped,self.callSession?.mSessionId ?? "",ErrCode.XOK)
                    self.interCallAct(.RemoteHangup,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
                }
            }
            else if(act == .VideoReady){
                log.i("listener VideoReady uid:\(uid)")
                if(self.callSession?.peerUid == uid){
                    self.endTime()
                    self.callAct(.onFirstFrame,self.callSession?.mSessionId ?? "",ErrCode.XOK)
                    self.preViewlistener(self.callSession?.mSessionId ?? "",0,0)

                }
            }
        },
        memberState:{s,a in
            if(s == .Enter){
                log.i("listener memberState Enter uid:\(a[0])")
                if(a[0] != self.callSession?.peerUid){
                    self.callMemState!(.Enter,[a[0]],self.callSession?.mSessionId ?? "")
                }
            }
            else if(s == .Leave){
                log.i("listener memberState Leave:\(a[0])")
                if(a[0] != self.callSession?.peerUid){
                    self.callMemState!(.Leave,[a[0]],self.callSession?.mSessionId ?? "")
                }
            }
            else{
                log.i("listener memberState aborted:\(s)")
            }
        })
    }
    
    func do_LEAVEANDDESTROY() {
        log.i("sdCard listener rtc.on_destroy")
        talkingEngine?.leaveChannel(cb: { [weak self] succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
            self?.hangUpRet(succ, "leaveAndDestroy ret")
        })
        talkingEngine = nil
    }
    
    func destory(){
        callMachine?.delegate = nil
        callMachine = nil
    }
  
}

extension MediaStateListener{
    
    func pausingSDCardPlay(){
        callMachine?.handleEvent(.toWillPaused)
    }
    
    func pausedSDCardPlay(){
        callMachine?.handleEvent(.toHavePaused)
    }
    
    func resumeingSDCardPlay(){
        callMachine?.handleEvent(.toResuming)
    }
    
    func resumedSDCardPlay(){
        callMachine?.handleEvent(.toReplay)
    }
    
    func reSetStateSDCardPlay(){
        guard let lastState = callMachine?.lastState else { return }
        callMachine?.currentState = lastState
    }
}
