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
    var talkingEngine : AgoraTalkingEngine?
    
    var callSession : CallSession?
    
    typealias callActionAck = (SessionCallback,_ sessionId:String,_ errCode:Int)->Void
    typealias callInterActionAck = (ActionAck,_ sessionId:String,_ peerNodeId:String)->Void
    typealias callMemberState = ((MemberState,[UInt],String)->Void)?
    typealias InComing = (_ sessionId:String,_ peerNodeId:String,ActionAck)->Void
    typealias hangUpRetAck = (Bool,String)->Void
    typealias PreviewListener = (String, Int, Int)->Void
    
    private var callAct:callActionAck = {ack,sessionId,errCode in log.w("callAct callActionAck not inited")}
    private var income:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    private var hangUpRet :hangUpRetAck = {a,c in log.w("hangUpRetAck not inited")}
    
    var callMemState:callMemberState = {sessionId,m,c in log.w("callMemState callMemberState not inited")}
    var interCallAct:callInterActionAck = {ack,sessionId,peerNodeId in log.w("interCallAct callActionAck not inited")}
    var preViewlistener:PreviewListener = {sessionId,width,height in log.w("'_preViewlistener' callback not registered,please register it with 'PreviewListener'")}
    
    
    init(dialParam: ConnectParam,actionAck:@escaping(SessionCallback,_ sessionId:String,_ errCode:Int)->Void,memberState:((MemberState,[UInt],String)->Void)?) {
        super.init()
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
    
    func registerPreViewListener(previewListener: @escaping (String, Int, Int) -> Void){
        self.preViewlistener = previewListener
    }
    
    func startCall(_ dialParam: ConnectParam){
        let callM = CallStateMachine()
        callMachine = callM
        callMachine?.delegate = self
        callMachine?.handleEvent(.startCall)
        
        callSession = CallSession()
        callSession?.callType = .DIAL
        callSession?.peerNodeId = dialParam.mPeerDevId
        
        //RTC需要的参数
        callSession?.token = dialParam.mRtcToken
        callSession?.cname = dialParam.mChannelName
        callSession?.uid   = dialParam.mLocalRtcUid
        callSession?.peerUid = 10
        
        //RTM需要的参数
        callSession?.mRtmUid = dialParam.mRtmUid
        callSession?.mRtmToken = dialParam.mRtmToken
        
    }
    
    func startIncome(){
        isIcoming = true
        let callM = CallStateMachine()
        callM.delegate = self
        callMachine = callM
        callMachine?.handleEvent(.incomingCall)
    }
    
    func callRequest(){
        callMachine?.handleEvent(.localJoining)
    }
    
    func hangUp(hangUpResult: @escaping (Bool,String) -> Void){
        hangUpRet = hangUpResult
        if self.isIcoming == false{//主动呼叫
            endTime()
            callMachine?.handleEvent(.endCall)
            self.do_LEAVEANDDESTROY()
            DispatchQueue.main.async {
                self.callAct(.onDisconnected,self.callSession?.mSessionId ?? "",ErrCode.XOK)
            }
            
        }else{
            endTime()
            self.endIncomeTime()
            callMachine?.handleEvent(.endCall)
            self.income(self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "", .LocalHangup)
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
    }
    
    func renewToken(renewParam: TokenRenewParam) {
        talkingEngine?.renewToken(renewParam.mRtcToken)
    }
    
}

extension CallStateListener : CallStateMachineListener{
    
    func do_CREATEANDENTER() {
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
                let timeSpace = String.dateCurrentTime() - CallListenerManager.sharedInstance.startConnectTime
                log.i("-------------talkingEngine joinSuccess timeSpace:\(timeSpace)")
                
                CallListenerManager.sharedInstance.startTime = String.dateCurrentTime()
                if self?.isIcoming == false{//主动呼叫
                    log.i("call reqCall CallForward")
                    self?.callMachine?.handleEvent(.localJoinSuc)
                    self?.callRcbTime?.schedule(time:self?.app.config.calloutTimeOut ?? 30,timeout: {
                        log.i("call reqCall ring remote timeout")
                        self?.callMachine?.handleEvent(.endCall)
                        self?.callAct(.onError,self?.callSession?.mSessionId ?? "",ErrCode.XERR_CALLKIT_DIAL)
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
                
//                todo:
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 60){
//                    log.i("token过期模拟 1分钟")
//                    self.callAct(.onSessionTokenWillExpire,self.callSession?.mSessionId ?? "",ErrCode.XOK)
//                }
                
                log.i("listener Enter uid:\(uid)")
                if(self.callSession?.peerUid == uid){
                    let timeSpace = String.dateCurrentTime() - CallListenerManager.sharedInstance.startTime
//                    log.i("-------------listener Enter timeSpace:\(timeSpace)")
                    if self.isIcoming == false{//主动呼叫
                        self.endTime()
                        self.callMachine?.handleEvent(.peerOnline)
                        self.callAct(.onConnectDone,self.callSession?.mSessionId ?? "",ErrCode.XOK)
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
                    if self.isIcoming == false{//主动呼叫
                        self.callAct(.onDisconnected,self.callSession?.mSessionId ?? "",ErrCode.XOK)
                        self.interCallAct(.RemoteHangup,self.callSession?.mSessionId ?? "",self.callSession?.peerNodeId ?? "")
                    }else{
                        self.callMachine?.handleEvent(.endCall)
                        self.income(self.callSession?.mSessionId ?? "", self.callSession?.peerNodeId ?? "", .RemoteHangup)
                    }
                    
                }
            }
            else if(act == .VideoReady){
                log.i("listener VideoReady uid:\(uid)")
                let timeSpace = String.dateCurrentTime() - CallListenerManager.sharedInstance.startTime
                if(self.callSession?.peerUid == uid){
                    if self.isIcoming == false{//主动呼叫
                        self.preViewlistener(self.callSession?.mSessionId ?? "",0,0)
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
        
        talkingEngine?.waitForTokenWillExpire {
            self.callAct(.onSessionTokenWillExpire,self.callSession?.mSessionId ?? "",ErrCode.XOK)
        }
    }
    
    func do_LEAVEANDDESTROY() {
        log.i("listener rtc.on_destroy")
        talkingEngine?.leaveChannel(cb: { [weak self] succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
            self?.hangUpRet(succ, "leaveAndDestroy ret")
        })
        talkingEngine?.destroy()
        talkingEngine = nil
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
            
            let uid = callSession?.mRtmUid ?? ""
            rtm.enter(rtmSession, "\(uid)") { [weak self] ret, msg in
                if ret == .Fail{
                    self?.callAct(.onDisconnected,self?.callSession?.mSessionId ?? "",ErrCode.XOK)
                    self?.interCallAct(.RemoteHangup,self?.callSession?.mSessionId ?? "",self?.callSession?.peerNodeId ?? "")
                }
            }

        }
    }
    
    func renewRtmToken(){
        let token = callSession?.mRtmToken ?? ""
        let peerNodeId = callSession?.peerNodeId ?? ""
        log.i("renewRtmToken:token\(token) peerNodeId：\(peerNodeId)")
        //rtm 更新token
        let rtm = app.proxy.rtm
        //rtm 更新token，可能重新连接不同的设备，peerNodeId也需要传入进行更行
        rtm.renewToken(token,peerNodeId)
    }
    
    func registerRtmStatusLister(){
        let rtm = app.proxy.rtm
        rtm.waitForStatusUpdated(statusUpdated: {[weak self] MessageStatus, msg, rtmMsg in
            if MessageStatus == .TokenWillExpire {
                self?.callAct(.onSessionTokenWillExpire,self?.callSession?.mSessionId ?? "",ErrCode.XOK)
            }
        })
        
    }
}

