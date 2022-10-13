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
    var _incoming:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    private var _onCallIncoming:(CallSession)->Void = {s in log.w("mqtt _onCallIncoming not inited")}
    
    private var _onPeerRinging:(Int,String,CallSession?)->Void = {ec,msg,sess in log.w("mqtt _onPeerRinging not inited for \(msg)(\(ec))")}
    
    func register(incoming: @escaping (String,String, ActionAck) -> Void) {
        self._incoming = incoming
        self._onPeerRinging = onCallOngoing
        self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
    }

    private func onCallSessionUpdated(sess:CallSession){
        self.app.context.call.session.appId = sess.appId
        self.app.context.call.session.caller = sess.callerId
        self.app.context.call.session.callee = sess.calleeId
        self.app.context.call.session.sessionId = sess.sessionId
        self.app.context.call.session.rtcToken = sess.rtcToken
        self.app.context.call.session.channelName = sess.channelName
        self.app.context.call.session.uid = sess.uid
        self.app.context.call.session.peerId = sess.peerUid
        self.app.context.call.session.cloudRecordStatus = sess.cloudRecordStatus
    }
    
    private func onCallOngoing(ec:Int,msg:String,sess:CallSession?){
        if(ec != ErrCode.XOK){
            log.w("call onCallOngoing \(msg)(\(ec))")
            self.app.context.call.session.callee = ""
            self.app.context.call.session.caller = ""
            self.app.rule.trans(ec == ErrCode.XERR_TIMEOUT ? FsmCall.Event.REMOTE_TIMEOUT :  FsmCall.Event.MQTT_ACK_ERROR)
        }
        else{
            guard let sess = sess else{
                log.e("call unknown error: nil session with \(ec),\(msg)")
                self.app.rule.trans(FsmCall.Event.MQTT_ACK_ERROR)
                return
            }

            onCallSessionUpdated(sess: sess)

            self.app.rule.trans(
                FsmCall.Event.REMOTE_RINGING,
                {},
                {
                log.e("call state error from trans REMOTE_RINGING")
                self.app.rule.trans(FsmCall.Event.STATUS_ERROR)
            })
        }
    }

    private var app:Application
    private let rtc:RtcEngine
    
    init(app:Application){
        self.app = app
        self.rtc = app.proxy.rtc
        self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
    }
    
    private func doCallHangup(result:@escaping(Int,String)->Void){
        let sessionId = app.context.call.session.sessionId
        let caller = app.context.call.session.caller
        let callee = app.context.call.session.callee
        let localId = app.context.gyiot.session.cert.thingName
        let req = AgoraLab.Answer.Payload(sessionId: sessionId, calleeId: callee, callerId: caller,localId: localId, answer: 1)
        let traceId:String = app.context.call.session.traceId
        let cb = { (ec:Int,msg:String,data:AgoraLab.Answer.Data?) in
            if(ec != ErrCode.XOK){
                log.e("call Hangup fail:\(msg)(\(ec)) caller:\(caller)  callee:\(callee)  local:\(localId)")
            }
            result(ec,msg)
            self.app.rule.trans(ec == ErrCode.XOK ? FsmCall.Event.LOCAL_HANGUP_SUCC : FsmCall.Event.LOCAL_HANGUP_FAIL)
        }
        app.rule.trigger.local_join_watcher = {b in}
        let agToken = app.context.aglab.session.accessToken
        app.proxy.al.reqAnswer(agToken,req,traceId, cb)
    }
    
    func callHangup(result:@escaping(Int,String)->Void){
        log.i("call callHangup")
        app.rule.trans(FsmCall.Event.LOCAL_HANGUP,
                       {self.doCallHangup(result: {ec,msg in self.asyncResult(ec, msg, result)})},
                       {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
    }
    
    private func finiCall(result:@escaping(Int,String)->Void){
        app.rule.trans(FsmCall.Event.FINICALL)
        let filter = self.app.context.callbackFilter
        let ret = filter(ErrCode.XOK,"")
        result(ret.0,ret.1)
    }
    
    private func doCallAnswer(result:@escaping(Int,String)->Void,
                              actionAck:@escaping(ActionAck)->Void,
                              memberState:((MemberState,[UInt])->Void)?){
        let sessionId = app.context.call.session.sessionId
        if(sessionId == ""){
            log.e("call callAnswer session is empty")
            result(ErrCode.XERR_BAD_STATE,"state error")
            return
        }
        
        let caller = app.context.call.session.caller
        let callee = app.context.call.session.callee
        let localId = app.context.gyiot.session.cert.thingName
        app.rule.trigger.member_state_watcher = memberState
        app.rule.trigger.remote_state_watcher = { s in
            actionAck(s)
        }
        
        let req = AgoraLab.Answer.Payload(sessionId: sessionId, calleeId: callee, callerId: caller,localId: localId, answer: 0)
        let traceId:String = app.context.call.session.traceId
        let cb = { (ec:Int,msg:String,data:AgoraLab.Answer.Data?) in
            if(ec == ErrCode.XOK){
//                self.muteLocalAudio(mute: false, result: {ec,msg in
//                    if(ec != ErrCode.XOK){
//                        log.w("call muteLocalAudio fail:\(msg)(\(ec))")
//                    }
//                })
//                self.muteLocalVideo(mute: false, result: {ec,msg in
//                    if(ec != ErrCode.XOK){
//                        log.w("call muteLocalVideo fail:\(msg)(\(ec))")
//                    }
//                })
                self.app.context.call.setting.publishVideo = false
                self.app.context.call.setting.publishAudio = true
                result(ec,msg)
            }
            else{
                result(ec,msg)
            }
        }
        let agToken = app.context.aglab.session.accessToken
        app.proxy.al.reqAnswer(agToken,req,traceId, cb)
    }
    
    func callAnswer(result:@escaping(Int,String)->Void,
                    actionAck:@escaping(ActionAck)->Void,
                    memberState:((MemberState,[UInt])->Void)?){
        log.i("call callAnswer")
        app.rule.trans(FsmCall.Event.LOCAL_ACCEPT,
                       {self.doCallAnswer(result: {ec,msg in self.asyncResult(ec, msg, result)},actionAck: actionAck,memberState: memberState)},
                                          {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
    }
    
    class AsyncCallback{
        public var invoked:Bool = false
        var callback:(Int,String)->Void
        public var timer:Timer
        public func call(_ ec:Int,_ msg:String){
            if(!invoked){
                callback(ec,msg)
                timer.invalidate()
                invoked = true
            }
        }
        public init(_ cb:@escaping (Int,String)->Void,_ timer:Timer){
            self.callback = cb
            self.timer = timer
        }
    }
    
    private func onActionDesired(action:ActionAck,sess:CallSession?){
        log.i("call action desired:\(action.rawValue)")
        if(action == .RemoteHangup){
            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
            self.app.rule.trans(FsmCall.Event.REMOTE_HANGUP)
        }
        else if(action == .RemoteAnswer){
            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
            log.i("call remote answered,waiting for remote join channel")
            if(sess == nil){
                log.w("call action ack:sess is nil when .RemoteAnswer")
            }
            else{//don't update sess because mqtt return status only during normal condition
                if(sess?.sessionId != ""){
                    //abnormal call ack after an unfinished call session
                    self.onCallSessionUpdated(sess: sess!)
                }
                else{
                    //during a normal call session,this will be empty
                }
            }
            self.app.rule.trans(FsmCall.Event.REMOTE_ANSWER,{},{
                self.doCallHangup(result: {ec,msg in})})
        }
        else if(action == .RemoteTimeout){
            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
            self.app.rule.trans(FsmCall.Event.REMOTE_TIMEOUT)
        }
        else if(action == .LocalTimeout){
            self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
            self.app.rule.trans(FsmCall.Event.REMOTE_TIMEOUT)
        }
        else if(action == .CallOutgoing){
            self._onPeerRinging(ErrCode.XOK,"calling ...", sess)
            self.onCallSessionUpdated(sess: sess!)
            self._onPeerRinging = {e,m,s in }
        }
        else if(action == .LocalHangup){
            //no need to handle because LocalHangup by local
        }
        else if(action == .CallIncoming){
            if(sess == nil){
                log.e("call reqCall action ack:sess is nil when call CallIncoming")
            }
            else{
                self.onCallSessionUpdated(sess: sess!)
                let local = self.app.context.gyiot.session.cert.thingName
                
                log.i("call sess caller:\(sess!.callerId) callee:\(sess!.calleeId) local:\(local)")
                self.app.rule.trans(FsmCall.Event.INCOME)
                
                if(local != sess!.callerId){
                    _incoming(sess!.callerId,sess!.attachedMsg,action)
                    self.app.rule.trigger.incoming_state_watcher = {a in
                        self._incoming(sess!.callerId,sess!.attachedMsg,a)
                    }
                }
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

    private func doCallDial(deviceId:String,attachMsg:String,result:@escaping(Int,String)->Void,actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?){
        let appId = app.config.appId
        app.context.call.session.caller = app.context.gyiot.session.cert.thingName//app.context.gran.session.pool_identityId
        app.context.call.session.callee = deviceId

        let caller = app.context.gyiot.session.cert.thingName
        let callee = app.context.call.session.callee
        let req = AgoraLab.Call.Payload(callerId:caller,calleeIds: [callee],attachMsg: attachMsg,appId: appId)
        let traceId:String = app.context.call.session.traceId
        
        app.rule.trigger.member_state_watcher = memberState
        app.rule.trigger.remote_state_watcher = { s in
            actionAck(s)
        }
        
        let rcb = TimeCallback<(Int,String)>(cb:result)
        
        let local_join_watcher : (FsmCall.Event)->Void = {event in
            log.i("call local_join_watcher triggered")
            if(event == FsmCall.Event.LOCAL_JOIN_FAIL){
                rcb.invoke(args:(ErrCode.XERR_CALLKIT_DIAL,"join channel fail"))
            }
            else if(event == FsmCall.Event.REMOTE_ANSWER){
                rcb.invoke(args: (ErrCode.XOK,"device answer"))
                actionAck(.RemoteAnswer)
            }
            else if(event == FsmCall.Event.LOCAL_JOIN_SUCC){
                rcb.invoke(args: (ErrCode.XOK,"device is ringing"))
                let pacb = TimeCallback<ActionAck>(cb:actionAck)
                pacb.schedule(time:self.app.config.calloutTimeOut,timeout: {
                    log.i("call reqCall peerAction waitForAction timeout")
                    self.app.rule.trans(FsmCall.Event.REMOTE_TIMEOUT)
                    actionAck(.RemoteTimeout)
                })
                self.app.proxy.mqtt.waitForActionDesired(actionDesired: {action,sess in
                    log.i("call reqCall action ack:\(action.rawValue)")
                    self.onActionDesired(action:action,sess: sess)
                    pacb.invoke(args: action)
                })
            }
        }

        //1.wait_mqtt_ntf result
        let pr = {(ec:Int,msg:String,sess:CallSession?) in
            if(ec != ErrCode.XOK){
                log.w("call waitForDidCalling \(msg)(\(ec))")
                self.app.context.call.session.reset()
                self.app.rule.trans(ec == ErrCode.XERR_TIMEOUT ? FsmCall.Event.REMOTE_TIMEOUT :  FsmCall.Event.MQTT_ACK_ERROR)
                rcb.invoke(args: (ec,msg))
            }
            else{
                guard let sess = sess else{
                    log.e("call unknown error: nil session with \(ec),\(msg)")
                    self.app.rule.trans(FsmCall.Event.MQTT_ACK_ERROR)
                    rcb.invoke(args: (ErrCode.XERR_UNKNOWN,"unknown error"))
                    return
                }
                
                log.i("call reqCall remote shadow ringing session:\(sess.sessionId)")
                self.onCallSessionUpdated(sess: sess)

                self.app.rule.trans(FsmCall.Event.REMOTE_RINGING,{
                    log.i("all reqCall set local_join_watcher after mqtt ack")
                    self.app.rule.trigger.local_join_watcher = local_join_watcher
                    actionAck(.CallOutgoing)
                },{
                    log.e("call state error from trans REMOTE_RINGING")
                    self.app.rule.trans(FsmCall.Event.STATUS_ERROR)
                })
            }
        }
        
        //1.query_agoraLab result
        let cbDial = { (ec:Int,msg:String,rsp:AgoraLab.Call.Rsp?) in
            if(ec == ErrCode.XOK){
                guard let rsp = rsp else{
                    log.e("call callDial ret XOK, but rsp is nil")
                    result(ErrCode.XERR_CALLKIT_DIAL,"param error")
                    return
                }
                
                var ec = ErrCode.XERR_UNKNOWN
                var msg = "unknown rsp:\(rsp.code)"
                switch(rsp.code){
                case AgoraLab.RspCode.IN_TALKING:
                    msg = "peer is in talking"
                    ec = ErrCode.XERR_CALLKIT_PEER_BUSY
                case AgoraLab.RspCode.ANSWER:
                    msg = "answer fail"
                    ec = ErrCode.XERR_CALLKIT_ANSWER
                case AgoraLab.RspCode.HANGUP:
                    ec = ErrCode.XERR_CALLKIT_HANGUP
                    msg = "hangup fail"
                case AgoraLab.RspCode.ANSWER_TIMEOUT:
                    ec = ErrCode.XERR_CALLKIT_TIMEOUT
                    msg = "timeout for answering"
                case AgoraLab.RspCode.CALL:
                    ec = ErrCode.XERR_CALLKIT_LOCAL_BUSY
                    msg = "can't call again during calling"
                case AgoraLab.RspCode.INVALID_ANSWER:
                    ec = ErrCode.XERR_CALLKIT_ERR_OPT
                    msg = "invalid answer"
                case AgoraLab.RspCode.SYS_ERROR:
                    ec = ErrCode.XERR_UNKNOWN
                    msg = "system error"
                case AgoraLab.RspCode.APPID_NOT_SAME:
                    ec = ErrCode.XERR_CALLKIT_APPID_DIFF
                    msg = "appid not same"
                case AgoraLab.RspCode.SAME_ID:
                    ec = ErrCode.XERR_CALLKIT_SAME_ID
                    msg = "caller and callee id are same"
                case AgoraLab.RspCode.APPID_NOT_REPORT:
                    ec = ErrCode.XERR_CALLKIT_NO_APPID
                    msg = "appid not report"
                case AgoraLab.RspCode.OK:
                    ec = ErrCode.XOK
                    msg = "succ"
                
                default:
                    ec = ErrCode.XERR_INVALID_PARAM
                    msg = "unknown rsp:\(rsp.code)"
                }
                if(ec != ErrCode.XOK){
                    log.e("call callDial ret \(msg)(\(ec))")
                    self.app.rule.trans(FsmCall.Event.ACK_INVALID,{
                        result(ec,msg)
                    })
                    return
                }
                
                guard let data = rsp.data else{
                    log.e("call reqCall ret data is nil for \(rsp.msg) (\(rsp.code))")
                    self.app.rule.trans(FsmCall.Event.ACK_INVALID)
                    result(ErrCode.XERR_INVALID_PARAM,"param error")
                    return
                }
                
                log.i("call reqCall recv session data from agoraLab, waiting for shadow ring ack")
                log.i("    sessionId:\(data.sessionId) uid:\(data.uid)")
                self.app.context.call.session.appId = data.appId
                self.app.context.call.session.sessionId = data.sessionId
                self.app.context.call.session.channelName = data.channelName
                self.app.context.call.session.rtcToken = data.rtcToken
                self.app.context.call.session.uid = UInt(data.uid) ?? 0
                self.app.context.call.session.cloudRecordStatus = data.cloudRecordStatus
                        
                self.app.rule.trans(FsmCall.Event.ACK_SUCC,{
                    actionAck(.CallForward)
                    rcb.schedule(time:self.app.config.calloutTimeOut,timeout: {
                        self._onPeerRinging = {e,m,s in }
                        log.i("call reqCall ring remote timeout")
                        self.app.rule.trans(FsmCall.Event.REMOTE_TIMEOUT,{
                            result(ErrCode.XERR_TIMEOUT,"dial number timeout")
                        })
                    })
                })
            }
            else{
                log.e("call reqCall fail:\(msg)(\(ec))")
                self.app.rule.trans(FsmCall.Event.ACK_INVALID)
                result(ec,msg)
            }
        }
        self.app.proxy.mqtt.waitForActionDesired(actionDesired: onActionDesired)
        self._onPeerRinging = pr
        let agToken = app.context.aglab.session.accessToken
        app.proxy.al.reqCall(agToken,req,traceId, cbDial)
    }
    
    func callDial(device: IotDevice, attachMsg: String, result: @escaping (Int, String) -> Void,actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?) {
        let filter = self.app.context.callbackFilter
        app.rule.trans(FsmCall.Event.CALL,
                       {self.doCallDial(deviceId: device.deviceId, attachMsg: attachMsg, result: {ec,msg in self.asyncResult(ec, msg, result)}, actionAck: actionAck,memberState:memberState)},
                       {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
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
