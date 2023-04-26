//
//  CallStateListener.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/24.
//

import UIKit

class CallStateListener: NSObject {
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var app  = Application.shared
    var rtc  = Application.shared.proxy.rtc
    private var  callRcbTime : TimeCallback<(Int,String)>? = nil
    var isIcoming : Bool = false //是否是来电
    
    var callMachine : CallStateMachine?
    
    typealias callResult = (Int,String)->Void
    typealias callActionAck = (ActionAck)->Void
    typealias callMemberState = ((MemberState,[UInt])->Void)?
    typealias InComing = (String,String,ActionAck)->Void
    private var callRet:callResult = {a,c in log.w("callRet callRes not inited")}
    private var callAct:callActionAck = {ack in log.w("callAct callActionAck not inited")}
    private var callMemState:callMemberState = {m,c in log.w("callMemState callMemberState not inited")}
    private var income:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    
    
    init(actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?) {
        super.init()
        callAct = actionAck
        callMemState = memberState
        startCall()
    }
    
    init(incoming: @escaping (String,String, ActionAck) -> Void) {
        super.init()
        income = incoming
        startIncome()
    }
    
    
    func startCall(){
        let callM = CallStateMachine()
        callM.delegate = self
        callMachine = callM
        callMachine?.handleEvent(.startCall)
    }
    
    func startIncome(){
        isIcoming = true
        let callM = CallStateMachine()
        callM.delegate = self
        callMachine = callM
        callMachine?.handleEvent(.startCall)
    }
    
    func callRequest(_ suc:Bool){
        if suc == true{
            callMachine?.handleEvent(.makeCalling)
        }else{
            callMachine?.handleEvent(.endCall)
        }
    }
    
    func hangUp(){
        endTime()
        callMachine?.handleEvent(.endCall)
        self.do_LEAVEANDDESTROY()
    }
    
    func endTime(){
        self.callRcbTime?.invoke(args: (ErrCode.XOK,"stop call"))
    }

}

extension CallStateListener : CallStateMachineListener{
    
    func do_CREATEANDENTER() {
        
        let appId = app.config.appId //app.context.call.session.appId
        let uid = app.context.call.session.uid
        let name = app.context.call.session.cname
        let token = app.context.call.session.token
        
        let setting = app.context.call.setting
        
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
                self.callMachine?.handleEvent(.endCall)
                self.callAct(.LocalHangup)
            }
            else if(ret == .Succ){
                if self.isIcoming == false{
                    self.callAct(.LocalAnswer)
                    log.i("call reqCall CallForward")
                    self.callRcbTime?.schedule(time:self.app.config.calloutTimeOut,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self.callMachine?.handleEvent(.endCall)
                        self.callAct(.RemoteTimeout)
                    })
                }else{
                    self.callMachine?.handleEvent(.IncomingCallSuc)
                    self.callAct(.CallIncoming)
                    self.income(String(self.app.context.call.session.uid), "", .CallIncoming)
                    self.callRcbTime?.schedule(time:self.app.config.calloutTimeOut,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self.on_callHangup()
                        self.callMachine?.handleEvent(.endCall)
                        self.callAct(.RemoteHangup)
                    })
                }

            }
            else {//Abort
                log.i("listener rtc.createAndEnter aborted:\(msg)")
            }
        },
        peerAction: {act,uid in
            if(act == .Enter){
                
                if(self.app.context.call.session.peerId == uid){
                    self.app.context.call.session.rtc.pairing.uid = uid
                    self.callAct(.RemoteAnswer)
                }
            }
            else if(act == .Leave){
                
                if(self.app.context.call.session.peerId == uid){
                    self.app.context.call.session.rtc.pairing.uid = 0
                    //todo:
                    self.callMachine?.handleEvent(.endCall)
                    self.callAct(.RemoteHangup)
                    self.do_LEAVEANDDESTROY()
                }
            }
            else if(act == .VideoReady){
                
                if(self.app.context.call.session.peerId == uid){
                    self.endTime()
                    self.callMachine?.handleEvent(.peerOnline)
                    self.callAct(.RemoteVideoReady)
                }
            }
        },
        memberState:{s,a in
            if(s == .Enter){
                if(a[0] == self.app.context.call.session.peerId){
                    self.callMemState!(.Enter,[a[0]])
                }
            }
            else if(s == .Leave){
                if(a[0] == self.app.context.call.session.peerId){
                    self.callMemState!(.Leave,[a[0]])
                }
            }
            else{
                log.i("listener memberState aborted:\(s)")
            }
        })
    }
    
    func on_callHangup() {
        do_LEAVEANDDESTROY()
    }
    
    func do_LEAVEANDDESTROY() {
        log.i("listener rtc.on_destroy")
        app.proxy.rtc.leaveAndDestroy(cb: {succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
        })
    }
  
}
