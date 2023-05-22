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
    private var  incomeRcbTime : TimeCallback<(Int,String)>? = nil
    var isIcoming : Bool = false //是否是来电
    var callMachine : CallStateMachine?
    
    typealias callActionAck = (ActionAck)->Void
    typealias callMemberState = ((MemberState,[UInt])->Void)?
    typealias InComing = (String,String,ActionAck)->Void
    typealias hangUpRetAck = (Bool,String)->Void
    private var callAct:callActionAck = {ack in log.w("callAct callActionAck not inited")}
    private var income:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    private var hangUpRet :hangUpRetAck = {a,c in log.w("hangUpRetAck not inited")}
    
    var callMemState:callMemberState = {m,c in log.w("callMemState callMemberState not inited")}
    var interCallAct:callActionAck = {ack in log.w("interCallAct callActionAck not inited")}
    
    
    init(actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?) {
        super.init()
        callAct = actionAck
        callMemState = memberState
        startCall()
    }
    
    init(incoming: @escaping (String,String, ActionAck) -> Void,memberState:((MemberState,[UInt])->Void)?) {
        super.init()
        income = incoming
        callMemState = memberState
        startIncome()
    }
    
    
    func startCall(){
        let callM = CallStateMachine()
        callMachine = callM
        callMachine?.delegate = self
        callMachine?.handleEvent(.startCall)
    }
    
    func startIncome(){
        isIcoming = true
        let callM = CallStateMachine()
        callM.delegate = self
        callMachine = callM
        callMachine?.handleEvent(.incomingCall)
    }
    
    func callRequest(_ suc:Bool){
        if suc == true{
            callMachine?.handleEvent(.makeCalling)
        }else{
            callMachine?.handleEvent(.endCall)
        }
    }
    
    func hangUp(hangUpResult: @escaping (Bool,String) -> Void){
        hangUpRet = hangUpResult
        if self.isIcoming == false{
            endTime()
            callMachine?.handleEvent(.endCall)
            self.callAct(.RemoteHangup)
            self.do_LEAVEANDDESTROY()
        }else{
            endTime()
            callMachine?.handleEvent(.endCall)
            self.income(String(self.app.context.call.session.cname), "", .LocalHangup)
            self.do_LEAVEANDDESTROY()
        }
        destory()
    }
    
    func endTime(){
        self.callRcbTime?.invoke(args: (ErrCode.XOK,"stop call"))
    }
    
    func endIncomeTime(){
        self.incomeRcbTime?.invoke(args: (ErrCode.XOK,"stop incoming"))
    }
    
    func inComeDealTime(){
        self.endTime()
        if callMachine?.currentState == .incoming{// 点击接听时，对端未上线
            incomeRcbTime = TimeCallback<(Int,String)>(cb: { (state, msg) in
                log.i("incomeRcbTime :\(msg)")
            })
            incomeRcbTime?.schedule(time:15,timeout: {
                log.i("call reqCall ring remote timeout")
                self.callMachine?.handleEvent(.endCall)
                self.income(String(self.app.context.call.session.cname ), "", .RemoteHangup)
            })
            log.i("incoming peer not online")
        }
    }
    
    deinit {
        log.i("CallStateListener 销毁了")
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

        callRcbTime = TimeCallback<(Int,String)>(cb: { (state, msg) in
            log.i("callRcbTime :\(msg)")
        })
        
        app.proxy.rtc.createAndEnter(appId: appId, setting: rtcSetting, uid: uid,name: name, token:token, info: "",
                                     cb: {[weak self]ret,msg in
            if(ret == .Fail){
                log.e("listener rtc.createAndEnter failed:\(msg)")
                self?.callMachine?.handleEvent(.endCall)
                self?.callAct(.LocalHangup)
            }
            else if(ret == .Succ){
                if self?.isIcoming == false{
                    self?.callAct(.LocalAnswer)
                    log.i("call reqCall CallForward")
                    self?.callRcbTime?.schedule(time:self?.app.config.calloutTimeOut ?? 30,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self?.callMachine?.handleEvent(.endCall)
                        self?.callAct(.RemoteTimeout)
                    })
                }else{
                    self?.income(String(self?.app.context.call.session.cname ?? ""), "", .CallIncoming)
                    self?.callRcbTime?.schedule(time:self?.app.config.inComingTimeOut ?? 30,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self?.callMachine?.handleEvent(.endCall)
                        self?.income(String(self?.app.context.call.session.cname ?? ""), "", .RemoteHangup)
                    })
                }

            }
            else {//Abort
                log.i("listener rtc.createAndEnter aborted:\(msg)")
            }
        },
        peerAction: {act,uid in
            if(act == .Enter){
                log.i("listener Enter uid:\(uid)")
                if(self.app.context.call.session.peerId == uid){
                    if self.isIcoming == false{
                        self.callMachine?.handleEvent(.peerOnline)
                        self.callAct(.RemoteAnswer)
                    }else{
                        self.callMachine?.handleEvent(.peerOnline)
                        if self.incomeRcbTime != nil{
                            self.endIncomeTime()
                        }
                    }
                    
                }
            }
            else if(act == .Leave){
                log.i("listener Leave uid:\(uid)")
                if(self.app.context.call.session.peerId == uid){
                    if self.isIcoming == false{
                        self.interCallAct(.RemoteHangup)
                    }else{
                        self.callMachine?.handleEvent(.endCall)
                        self.income(String(self.app.context.call.session.cname), "", .RemoteHangup)
                    }
                    
                }
            }
            else if(act == .VideoReady){
                log.i("listener VideoReady uid:\(uid)")
                if(self.app.context.call.session.peerId == uid){
                    if self.isIcoming == false{
                        self.endTime()
                        self.callAct(.RemoteVideoReady)
                    }else{
                        self.income(String(self.app.context.call.session.cname), "", .RemoteVideoReady)
                    }

                }
            }
        },
        memberState:{s,a in
            if(s == .Enter){
                log.i("listener memberState Enter uid:\(a[0])")
                if(a[0] != self.app.context.call.session.peerId){
                    self.callMemState!(.Enter,[a[0]])
                }
            }
            else if(s == .Leave){
                log.i("listener memberState Leave:\(a[0])")
                if(a[0] != self.app.context.call.session.peerId){
                    self.callMemState!(.Leave,[a[0]])
                }
            }
            else{
                log.i("listener memberState aborted:\(s)")
            }
        })
    }
    
    func do_LEAVEANDDESTROY() {
        log.i("listener rtc.on_destroy")
        app.proxy.rtc.leaveAndDestroy(cb: {succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
            self.hangUpRet(succ, "leaveAndDestroy ret")
        })
    }
    
    func destory(){
        callMachine?.delegate = nil
        callMachine = nil
    }
  
}
