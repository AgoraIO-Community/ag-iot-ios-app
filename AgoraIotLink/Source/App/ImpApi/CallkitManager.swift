//
//  CallKitManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/2/15.
//

import Foundation
//import AgoraRtcKit

class CallSession{
    var callerId:String = ""
    var calleeId:String = ""
    var callStatus:Int = 0
    var appId:String = ""
    var channelName:String = ""
    var attachedMsg = ""
    var rtcToken:String = ""
    var sessionId:String = ""
    var uid:UInt = 0
    var peerUid:UInt = 0
    var cloudRecordStatus:Int = 0
    var reason:Int = 0
    var disabledPush:Bool = false
    
    var token = ""
    var cname = ""
}

class CallkitManager : ICallkitMgr{
    
    private func asyncResult(_ ec:Int,_ msg:String,_ result:@escaping(Int,String)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1)
        }
    }
    
    private func asyncResultData<T>(_ ec:Int,_ msg:String,_ data:T?,_ result:@escaping(Int,String,T?)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data)
        }
    }
    
    typealias InComing = (String,String,ActionAck)->Void
    typealias InComMemberState = ((MemberState,[UInt])->Void)?
    typealias resultCallback = (Int,String)->Void
    var _incoming:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    var _incomMemState:InComMemberState = {m,c in log.w("incomMemState not inited")}
    private var _onCallIncoming:(CallSession)->Void = {s in log.w("mqtt _onCallIncoming not inited")}
    private var _onPeerRinging:(Int,String,CallSession?)->Void = {ec,msg,sess in log.w("mqtt _onPeerRinging not inited for \(msg)(\(ec))")}
    
    
    func register(incoming: @escaping (String,String, ActionAck) -> Void,memberState:((MemberState,[UInt])->Void)?) {
        self._incoming = incoming
        self._incomMemState = memberState
        self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
    }

    private func onCallSessionUpdated(sess:CallSession){
        
        self.app.context.call.session.uid = sess.uid
        self.app.context.call.session.token = sess.token
        self.app.context.call.session.cname = sess.cname
        self.app.context.call.session.peerId = 10
    }
    
    private func onLastCallSessionUpdated(uId:UInt){
        self.app.context.call.lastSession.uid = uId
    }

    private var app:Application
    private let rtc:RtcEngine
    var isCallRet = true
    
    init(app:Application){
        self.app = app
        self.rtc = app.proxy.rtc
        self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
    }
    
    func callAnswer(result:@escaping(Int,String)->Void,
                    actionAck:@escaping(ActionAck)->Void,
                    memberState:((MemberState,[UInt])->Void)?){
        log.i("call callAnswer")
        CallListenerManager.sharedInstance.acceptCall()
        result(ErrCode.XOK,"suc")
    }
    
    private func onActionDesired(action:ActionAck,sess:CallSession?){
        log.i("call action desired:\(action.rawValue)")

        if(action == .CallIncoming){
            if CallListenerManager.sharedInstance.isTaking() == true{//通话中来了呼叫直接返回
                log.i("talking incoming------:\(String(describing: sess))")
                return
            }
            if(sess == nil){
                log.e("call reqCall action ack:sess is nil when call CallIncoming")
            }
            else{
                self.onCallSessionUpdated(sess: sess!)
                CallListenerManager.sharedInstance.incomeCall(incoming: _incoming, memberState: _incomMemState)
                let local = self.app.context.gyiot.session.cert.thingName
                log.i("call sess caller:\(sess!.peerUid) callee:\(sess!.uid) local:\(local)")
            }
        }
        else{
            log.i("call action \(action.rawValue) not handled")
        }
        
        if(self.app.context.push.session.pushEnabled == nil){
            let enabled = sess?.disabledPush == true ? false : true
            log.i("call action \(action.rawValue) StateInited pushEnabled:\(enabled)")

            self.app.context.push.session.pushEnabled = enabled
            let eid = app.context.push.session.eid

            app.proxy.mqtt.publishPushId(id: eid,enableNotify:enabled)
        }
    }
    
    
//    private func onActionDesired(action:ActionAck,sess:CallSession?){
//        log.i("call action desired:\(action.rawValue)")
//        if(action == .RemoteHangup){
//            if self.app.context.call.lastSession.talkingId == 0 { return }
//            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
//            self.app.rule.trans(FsmCall.Event.REMOTE_HANGUP)
//        }
//        else if(action == .RemoteAnswer){
//
//            if self.app.context.call.lastSession.talkingId == 0 { return }
//
//            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
//            log.i("call remote answered,waiting for remote join channel")
//            if(sess == nil){
//                log.w("call action ack:sess is nil when .RemoteAnswer")
//            }
//            else{//don't update sess because mqtt return status only during normal condition
//                if(sess?.sessionId != ""){
//                    //abnormal call ack after an unfinished call session
//                    self.onCallSessionUpdated(sess: sess!)
//                }
//            }
//            self.app.rule.trans(FsmCall.Event.REMOTE_ANSWER,{},{
//                self.doCallHangupInter(result: {ec,msg in})})
//        }
//        else if(action == .RemoteTimeout){
//            if self.app.context.call.lastSession.talkingId == 0 { return  }
//            log.i("call RemoteTimeout 对端超时")
//            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
//            self.app.rule.trans(FsmCall.Event.REMOTE_TIMEOUT)
//        }
//        else if(action == .LocalTimeout){
//            if self.app.context.call.lastSession.talkingId == 0 { return  }
//            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
//            self.app.rule.trans(FsmCall.Event.REMOTE_TIMEOUT)
//        }
//
//        else if(action == .CallIncoming){
//            if(sess == nil){
//                log.e("call reqCall action ack:sess is nil when call CallIncoming")
//            }
//            else{
//                self.onCallSessionUpdated(sess: sess!)
//                let local = self.app.context.gyiot.session.cert.thingName
//
//                log.i("call sess caller:\(sess!.callerId) callee:\(sess!.calleeId) local:\(local)")
//                self.app.rule.trans(FsmCall.Event.INCOME)
//
//                if(local != sess!.callerId){
//                    _incoming(sess!.callerId,sess!.attachedMsg,action)
//                    self.app.rule.trigger.incoming_state_watcher = {a in
//                        self._incoming(sess!.callerId,sess!.attachedMsg,a)
//                    }
//                }
//            }
//        }
//        else{
//            log.i("call action \(action.rawValue) not handled")
//        }
//
//        if(self.app.context.push.session.pushEnabled == nil){
//            let enabled = sess?.disabledPush == true ? false : true
//            log.i("call action \(action.rawValue) StateInited pushEnabled:\(enabled)")
//
//            self.app.context.push.session.pushEnabled = enabled
//            let eid = app.context.push.session.eid
//
//            app.proxy.mqtt.publishPushId(id: eid,enableNotify:enabled)
//        }
//    }

    
    private func doCallSimpleDial(deviceId:String,attachMsg:String,result:@escaping(Int,String)->Void){
        let appId = app.config.appId
        app.context.call.session.caller = app.context.gyiot.session.cert.thingName
        app.context.call.session.callee = deviceId
        
        let userId = app.context.gyiot.session.cert.thingName
        let req = AgoraLab.CallSimple.Payload(appId: appId, deviceId: deviceId, userId: userId, extraMsg: attachMsg)
        
        log.i("talkingId:\(app.context.call.lastSession.talkingId)")
        let traceId:Int = String.dateTimeRounded()
        
        //留存当前呼叫的信息------
        app.context.call.lastSession.talkingId = traceId
        app.context.call.lastSession.caller = app.context.gyiot.session.cert.thingName
        app.context.call.lastSession.callee = deviceId
        self.app.proxy.mqtt.curTimeStamp = traceId
        self.isCallRet = false
        
        //1.query_agoraLab result
        let cbDial = { (ec:Int,msg:String,rsp:AgoraLab.CallSimple.Rsp?) in
   
            if(ec == ErrCode.XOK){
                self.isCallRet = true
                
                guard let rsp = rsp else{
                    log.e("call callDial ret XOK, but rsp is nil")
                    CallListenerManager.sharedInstance.callRequest(false)
                    result(ErrCode.XERR_CALLKIT_DIAL,"param error")
                    return
                }
                
                log.i("rsp.traceId:\(rsp.traceId) lastSession.talkingId:\(self.app.context.call.lastSession.talkingId)")
                guard Int(rsp.traceId) == self.app.context.call.lastSession.talkingId else {//如果不是本次呼叫，直接返回，不做处理
                    log.i("not current call response rsp.traceId:\(rsp.traceId) lastSession.talkingId:\(self.app.context.call.lastSession.talkingId)")
                    return
                }
                
                guard let data = rsp.data else{
                    log.e("call reqCall ret data is nil for \(rsp.msg) (\(rsp.code))")
                    CallListenerManager.sharedInstance.callRequest(false)
                    result(ErrCode.XERR_INVALID_PARAM,"param error")
                    return
                }
 
                self.app.context.call.session.token = data.token
                self.app.context.call.session.uid = UInt(data.uid)
                self.app.context.call.session.cname = data.cname
                self.app.context.call.session.peerId = 10

                self.onLastCallSessionUpdated(uId: UInt(data.uid) )
                
                CallListenerManager.sharedInstance.callRequest(true)
                
                log.i("call reqCall token:\(data.token) uid:\(data.uid) data:\(data)")
                
                result(ec,msg)
            }
            else{
                self.isCallRet = true
                log.e("call reqCall fail:\(msg) ec: (\(ec))")
                guard let rsp = rsp else{
                    log.e("call callDial ret fail, but rsp is nil")
                    CallListenerManager.sharedInstance.callRequest(false)
                    result(ec,msg)
                    return
                }
                log.i("rsp.traceId:\(rsp.traceId) lastSession.talkingId:\(self.app.context.call.lastSession.talkingId)")
//                guard Int(rsp.traceId) == self.app.context.call.lastSession.talkingId else { //如果不是本次呼叫，直接返回，不做处理
//                    log.i("not current call response rsp.traceId:\(rsp.traceId) lastSession.talkingId:\(self.app.context.call.lastSession.talkingId)")
//                    return
//                }
                CallListenerManager.sharedInstance.callRequest(false)
                result(ec,msg)
            }
        }
        self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
        let agToken = app.context.aglab.session.accessToken
        app.proxy.al.reqCallSimple(agToken,req,"\(traceId)", cbDial)
        
    }
    
    func callDial(device: IotDevice, attachMsg: String, result: @escaping (Int, String) -> Void,actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?) {
        log.i("---callDial--发起呼叫---")
        CallListenerManager.sharedInstance.startCall(actionAck: actionAck, memberState: memberState)
        doCallSimpleDial(deviceId: device.deviceId, attachMsg: attachMsg, result: result)
        
    }
    
    func callHangup(result:@escaping(Int,String)->Void){
        log.i("call callHangup")
        CallListenerManager.sharedInstance.hangUp()
        result(ErrCode.XOK,"success")
    }
    
    func setLocalVideoView(localView: UIView?) -> Int {
        let uid = app.context.call.session.uid
        let ret = app.proxy.rtc.setupLocalView(localView: localView, uid: uid)
        return ret
    }
    
    func setPeerVideoView(peerView: UIView?) -> Int {
        let pairing = app.context.call.session.rtc.pairing
        pairing.view = peerView
        pairing.uid = app.context.call.session.peerId
        if(pairing.uid != 0){
            log.i("call setPeerVideoView uid:\(pairing.uid) \(String(describing: peerView))")
            
            let view = pairing.view
            let uid = pairing.uid
            
            pairing.view = nil
            pairing.uid = 0
            
            return app.proxy.rtc.setupRemoteView(peerView: view, uid: uid)
        }
        else{
            log.d("call setPeerVideoView with no remote user joined")
        }
        return ErrCode.XERR_BAD_STATE
    }
    
    func muteLocalVideo(mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.muteLocalVideo(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func muteLocalAudio(mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.muteLocalAudio(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func mutePeerVideo(mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.mutePeerVideo(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func mutePeerAudio(mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.mutePeerAudio(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setVolume(volumeLevel: Int,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.setVolume(volumeLevel, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setDefaultAudioRouteToSpeakerphone(defaultToSpeaker: Bool, result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            self.rtc.setDefaultAudioRouteToSpeakerphone(defaultToSpeaker: defaultToSpeaker, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setAudioEffect(effectId: AudioEffectId,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.setAudioEffect(effectId, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func talkingRecordStart(result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            self.rtc.startRecord(result: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func talkingRecordStop(result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.stopRecord (result:{ec,msg in self.asyncResult(ec, msg,result)})
        }
    }

    func capturePeerVideoFrame(result: @escaping (Int, String, UIImage?) -> Void) {
        DispatchQueue.main.async {
            self.app.proxy.rtc.capturePeerVideoFrame(cb: {ec,msg,img in self.asyncResultData(ec,msg,img,result)})
        }
    }
    
    func getNetworkStatus() -> RtcNetworkStatus {
        return self.app.proxy.rtc.getNetworkStatus()
    }
}

extension CallkitManager {
    
    //重置设备状态
    private func resetDevice(_ rsp:@escaping(Int,String)->Void){
        let deviceId = self.app.context.gyiot.session.cert.thingName
        let appid = self.app.config.appId
        let agToken = app.context.aglab.session.accessToken
        self.app.proxy.al.resetDevice(deviceId, appid, agToken, rsp)
    }
    
    //每次登陆需重置的信息
    func reset(){
        self.isCallRet = true
    }
    
}
