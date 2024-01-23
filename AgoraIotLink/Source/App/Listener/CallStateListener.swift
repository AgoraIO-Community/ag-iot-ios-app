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
    private var  callReqTime : TimeCallback<(Int,String)>? = nil
    private var  incomeRcbTime : TimeCallback<(Int,String)>? = nil
    var isIcoming : Bool = false //是否是来电
    var callMachine : CallStateMachine?
    
    var callSession : CallSession?
    var timer: Timer? //保活心跳
    
    typealias callResult = (_ errCode:Int,_ sessionId:String,_ peerNodeId:String) -> Void
    typealias callActionAck = (ActionAck,_ sessionId:String,_ peerNodeId:String)->Void
    typealias callMemberState = ((MemberState,[UInt],String)->Void)?
    typealias InComing = (_ sessionId:String,_ peerNodeId:String,ActionAck)->Void
    typealias hangUpRetAck = (Bool,String)->Void
    
    private var callRet:callResult = {code,sessionId,peerNodeId in log.w("callRet not inited")}
    private var callAct:callActionAck = {ack,sessionId,peerNodeId in log.w("callAct callActionAck not inited")}
    private var income:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    private var hangUpRet :hangUpRetAck = {a,c in log.w("hangUpRetAck not inited")}
    
    var callMemState:callMemberState = {sessionId,m,c in log.w("callMemState callMemberState not inited")}
    var interCallAct:callActionAck = {ack,sessionId,peerNodeId in log.w("interCallAct callActionAck not inited")}
    
    
    init(dialParam: DialParam,result: @escaping (_ errCode:Int,_ sessionId:String,_ peerNodeId:String) -> Void,actionAck:@escaping(ActionAck,_ sessionId:String,_ peerNodeId:String)->Void,memberState:((MemberState,[UInt],String)->Void)?) {
        super.init()
        callRet = result
        callAct = actionAck
        callMemState = memberState
        startCall(dialParam)
        
    }
    
    init(sess:CallSession?,incoming: @escaping (_ sessionId:String,_ peerNodeId:String, ActionAck) -> Void,memberState:((MemberState,[UInt],String)->Void)?) {
        super.init()
        
        income = incoming
        callMemState = memberState
        
        callSession = CallSession()
        updateCallSession(sess!)
        callSession?.peerNodeId = sess?.peerNodeId ?? ""
        
        startIncome()
    }
    
    
    func startCall(_ dialParam: DialParam){
        let callM = CallStateMachine()
        callMachine = callM
        callMachine?.delegate = self
        callMachine?.handleEvent(.startCall)
        
        callSession = CallSession()
        callSession?.callType = .DIAL
        callSession?.mPubLocalAudio = dialParam.mPubLocalAudio
        callSession?.peerNodeId = dialParam.mPeerNodeId
        
        callReqTime = TimeCallback<(Int,String)>(cb: { (state, msg) in
            log.i("callReqTime :\(msg)")
        })
        callReqTime?.schedule(time:30 ,timeout: {[weak self] in
            log.i("callReqTime timeout")
            self?.callRet(ErrCode.XERR_CALLKIT_DIAL,self?.callSession?.mSessionId ?? "", self?.callSession?.peerNodeId ?? "")
            self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
        })
        
    }
    
    func startIncome(){
        
        isIcoming = true
        let callM = CallStateMachine()
        callM.delegate = self
        callMachine = callM
        callMachine?.handleEvent(.incomingCall)
        
    }
    
    func callRequest(_ suc:Bool){
        self.endReqTime()
        if suc == true{
            callRet(ErrCode.XOK,self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "")
            callMachine?.handleEvent(.localJoining)
        }else{
            callRet(ErrCode.XERR_CALLKIT_DIAL,self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "")
            interCallAct(.RemoteHangup,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
            callMachine?.handleEvent(.endCall)
        }
    }
    
    func hangUp(hangUpResult: @escaping (Bool,String) -> Void){
        hangUpRet = hangUpResult
        stopTimer()
        if self.isIcoming == false{
            endTime()
            self.endReqTime()
            callMachine?.handleEvent(.endCall)
            self.callAct(.LocalHangup,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
            self.do_LEAVEANDDESTROY()
            self.app.proxy.cocoaMqtt.clearAlreadyMsg()
        }else{
            endTime()
            self.endIncomeTime()
            callMachine?.handleEvent(.endCall)
            self.income(self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "", .LocalHangup)
            self.do_LEAVEANDDESTROY()
        }
        destory()
        //todo:
        //去登出rtm
        leaveAndDestoryRtm()
    }
    
    func endTime(){
        self.callRcbTime?.invoke(args: (ErrCode.XOK,"stop call"))
    }
    func endReqTime(){
        self.callReqTime?.invoke(args: (ErrCode.XOK,"stop request"))
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
            incomeRcbTime?.schedule(time:30,timeout: {
                log.i("call reqCall ring remote timeout")
                self.callMachine?.handleEvent(.endCall)
                self.income(self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "", .RemoteHangup)
            })
            log.i("incoming peer not online")
        }
    }
    
    deinit {
        log.i("CallStateListener 销毁了")
    }

}

extension CallStateListener {
    
    func updateCallSession(_ sess : CallSession){
        callSession?.token = sess.token
        callSession?.cname = sess.cname
        callSession?.uid   = sess.uid
        callSession?.peerUid = 10
        callSession?.callType = sess.callType
        callSession?.mRtmUid = sess.mRtmUid
        callSession?.mRtmToken = sess.mRtmToken
    }
    
    func updateCallSessionVideoQuality(_ videoQuality : VideoQualityParam){
        callSession?.mVideoQuality = videoQuality
    }
    
}

extension CallStateListener : CallStateMachineListener{
    
    func do_CREATEANDENTER() {
        
        //todo:
        //去登陆rtm
        creatAndEnterRtm()

        let appId = app.config.masterAppId
        let uid = callSession?.uid ?? 0
        let name = callSession?.cname ?? ""
        let token = callSession?.token ?? ""
        
        let peerId = callSession?.peerUid ?? 0

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
        
        app.proxy.rtc.createAndEnter(appId: appId, setting: rtcSetting, uid: uid, peerId: peerId,name: name, token:token, info: "",
                                     cb: {[weak self]ret,msg in
            if(ret == .Fail){
                log.e("listener rtc.createAndEnter failed:\(msg)")
                self?.callMachine?.handleEvent(.endCall)
                self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
            }
            else if(ret == .Succ){
                self?.heartbeatTimer()
                if self?.isIcoming == false{
                    log.i("call reqCall CallForward")
                    self?.callMachine?.handleEvent(.localJoinSuc)
                    self?.callRcbTime?.schedule(time:self?.app.config.calloutTimeOut ?? 30,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self?.callMachine?.handleEvent(.endCall)
                        self?.callAct(.RemoteTimeout,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
                        self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
                    })
                }else{
                    self?.income(self?.callSession?.mSessionId ?? "", self?.callSession?.peerNodeId ?? "", .CallIncoming)
                    self?.callRcbTime?.schedule(time:self?.app.config.inComingTimeOut ?? 30,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self?.callMachine?.handleEvent(.endCall)
                        self?.income(self?.callSession?.mSessionId ?? "", self?.callSession?.peerNodeId ?? "", .RemoteHangup)
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
                if(self.callSession?.peerUid == uid){
                    if self.isIcoming == false{
                        self.callMachine?.handleEvent(.peerOnline)
                        self.callAct(.RemoteAnswer,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
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
                if(self.callSession?.peerUid == uid){
                    if self.isIcoming == false{
                        self.callAct(.RemoteHangup,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
                        self.interCallAct(.RemoteHangup,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
                    }else{
                        self.callMachine?.handleEvent(.endCall)
                        self.income(self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "", .RemoteHangup)
                    }
                    
                }
            }
            else if(act == .VideoReady){
                log.i("listener VideoReady uid:\(uid)")
                if(self.callSession?.peerUid == uid){
                    if self.isIcoming == false{
                        self.endTime()
                        self.callAct(.RemoteVideoReady,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
                    }else{
                        self.income(self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "", .RemoteVideoReady)
                    }

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

extension CallStateListener{//rtm
    
    func creatAndEnterRtm(){
        
        let rtm = app.proxy.rtm
        //初始化其他
        let setting = app.context.rtm.setting
        let succ = rtm.create(setting)
        
        if succ == true{
            let rtmSession = RtmSession()
            rtmSession.token = callSession?.mRtmToken ?? ""
            rtmSession.peerVirtualNumber = callSession?.peerNodeId ?? ""
            
            let uid = callSession?.mRtmUid ?? "" //01GW488RS7MXFXX883VTV0EZV7
            rtm.enter(rtmSession, "\(uid)") { [weak self] ret, msg in
//                if ret == .Fail{
//                    self?.callAct(.onDisconnected,self?.callSession?.mSessionId ?? "",ErrCode.XOK)
//                    self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
//                }
            }

        }

    }
    
    func leaveAndDestoryRtm(){
        
        //断开其他
        app.proxy.rtm.leave(cb: { succ in
            if(!succ){
                log.w("rtm leave fail")
            }
        })
        app.proxy.rtm.destroy();
    }
}

extension CallStateListener{
    
    func  heartbeatTimer(){
        timer = Timer()
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 8*60*60, target: self, selector: #selector(reNewToken), userInfo: nil, repeats: true)
    }
    
    @objc func reNewToken() {
        
        let curTimestamp:Int = String.dateTimeRounded()
        
        
        let nodeToken = app.sdk.iotAppSdkMgr.mLocalNode?.mToken ?? ""
        
        let appId = app.config.masterAppId
        let headerParam = ["traceId": curTimestamp, "timestamp": curTimestamp, "nodeToken": nodeToken, "method": "refresh-token"] as [String : Any]
        let payloadParam = ["appId": appId, "deviceId": callSession?.peerNodeId ?? "","uid":callSession?.uid ?? 0 ,"cname": callSession?.peerNodeId ?? ""] as [String : Any]
        let paramDic = ["header":headerParam,"payload":payloadParam]
        let jsonString = paramDic.convertDictionaryToJSONString()
        self.app.proxy.cocoaMqtt.publishUpdateTokenData(sessionId:callSession?.mSessionId ?? "", data: jsonString) {[weak self] sess in
            if let sess = sess{
                self?.updateToken(sess)
            }else{
                log.i("---sess is nil---")
            }
        }
        log.i("---callDial--更新token---")
        
    }
    
    func updateToken(_ sess : CallSession) {
        // 在这里实现发送消息的逻辑
        log.i("send renew msg")
        let rtm = app.proxy.rtm
        rtm.renewToken(sess.mRtmToken)
        app.proxy.rtc.renewToken(sess.token)
    }
    
    func stopTimer() {
        log.i("RtmEngine timer is nil")
        timer?.invalidate()
        timer = nil
    }
    
    
}
