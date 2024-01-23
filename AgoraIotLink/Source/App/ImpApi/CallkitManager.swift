//
//  CallKitManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/2/15.
//

import Foundation
//import AgoraRtcKit

public class CallSession : NSObject{
    var token = ""
    var cname = ""    //对端nodeId
    var uid:UInt = 0
    var version:UInt = 0
    
    var peerUid:UInt = 0                //对端id
    var mPubLocalAudio : Bool = false   //设备端接听后是否立即推送本地音频流
    
    var callType:CallType = .UNKNOWN    //通话类型
    var msgType:MsgType = .UNKNOWN      //消息类型
    var mSessionId = ""                 //通话Id
    var traceId:UInt = 0                //追踪ID
    var peerNodeId = ""                 //对端nodeId
    
    var mVideoQuality:VideoQualityParam = VideoQualityParam()   //当前通话视频质量参数
    
    //------rtm信息------
    var mRtmUid: String = ""             //本地用户的 UserId
    var mRtmToken: String = ""           //要会话的 RTM Token
    
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
    
    typealias InComing = (_ sessionId:String,_ peerNodeId:String,ActionAck)->Void
    typealias InComMemberState = ((MemberState,[UInt],String)->Void)?
    typealias resultCallback = (Int,String)->Void
    var _incoming:InComing = {callerId,msg,calling in log.w("'incoming' callback not registered,please register it with 'CallkitManager'")}
    var _incomMemState:InComMemberState = {m,c,sessionId in log.w("incomMemState not inited")}
    private var _onCallIncoming:(CallSession)->Void = {s in log.w("mqtt _onCallIncoming not inited")}
    private var _onPeerRinging:(Int,String,CallSession?)->Void = {ec,msg,sess in log.w("mqtt _onPeerRinging not inited for \(msg)(\(ec))")}
    
    
    func register(incoming: @escaping (_ sessionId:String,_ peerNodeId:String, ActionAck) -> Void,memberState:((MemberState,[UInt],String)->Void)?) {
        self._incoming = incoming
        self._incomMemState = memberState
        self.app.proxy.cocoaMqtt.waitForIncomingDesired(actionDesired: onIcomingDesired)
    }

    private var app:Application
    private let rtc:RtcEngine
    private let rtm:RtmEngine
    
    init(app:Application){
        self.app = app
        self.rtc = app.proxy.rtc
        self.rtm = app.proxy.rtm
//        self.app.proxy.cocoaMqtt.waitForIncomingDesired(actionDesired: onIcomingDesired)
    }
    
    func callAnswer(sessionId: String, pubLocalAudio: Bool,result:@escaping(Int,String)->Void) {
        log.i("call callAnswer")
        let ret = CallListenerManager.sharedInstance.acceptCall(sessionId)
        result(ret,"suc")
    }
    
    private func onIcomingDesired(sess:CallSession?){//来电mqtt回调
        if(sess == nil){
            log.e("call reqCall action ack:sess is nil when call CallIncoming")
        }
        else{
            
            if CallListenerManager.sharedInstance.isTaking(sess?.peerNodeId ?? "") == true{//通话中来了呼叫直接返回
                log.i("talking incoming------:\(String(describing: sess?.peerNodeId))")
                return
            }
            let mSessionId = (sess?.peerNodeId ?? "") + "&" + "\(String.dateTimeRounded())"
            CallListenerManager.sharedInstance.incomeCall(sessionId:mSessionId,sess:sess, incoming: _incoming, memberState: _incomMemState)
        }
    }
    
    private func onMqttDesired(sess:CallSession?){//呼叫mqtt回调

        if(sess == nil){
            log.e("call reqCall action ack:sess is nil when call CallIncoming")
        }
        else{
            let  mSessionId = (sess?.peerNodeId ?? "") + "&" + "\(sess?.traceId ?? 0)"
            CallListenerManager.sharedInstance.updateCallSession(mSessionId,sess!)
            CallListenerManager.sharedInstance.callRequest(mSessionId,true)
        }
    }
    
    func callDial(dialParam: DialParam, result: @escaping (_ errCode:Int,_ sessionId:String,_ peerNodeId:String) -> Void,actionAck:@escaping(ActionAck,_ sessionId:String,_ peerNodeId:String)->Void,memberState:((MemberState,[UInt],String)->Void)?) {
        
        if CallListenerManager.sharedInstance.isCallTaking(dialParam.mPeerNodeId) == true{
            log.i("---callDial--device is already---:\(dialParam.mPeerNodeId)")
            result(ErrCode.XERR_CALLKIT_LOCAL_BUSY,"", "")
            return
        }
        
        if self.app.proxy.cocoaMqtt.curState != .ScribeDone{
            log.i("---callDial--cocoaMqtt--curState is not ConnectDone---:\(dialParam.mPeerNodeId)")
            result(ErrCode.XERR_NETWORK,"", "")
            return
        }
        
        
        let curTimestamp:Int = String.dateTimeRounded()
        
        let mSessionId = dialParam.mPeerNodeId + "&" + "\(curTimestamp)"
        CallListenerManager.sharedInstance.startCall(sessionId:mSessionId, dialParam:dialParam, result:result,actionAck: actionAck, memberState: memberState)
        
        let nodeToken = app.sdk.iotAppSdkMgr.mLocalNode?.mToken ?? ""
        
        let appId = app.config.masterAppId
        let headerParam = ["traceId": curTimestamp, "timestamp": curTimestamp, "nodeToken": nodeToken, "method": "user-start-call"] as [String : Any]
        let payloadParam = ["appId": appId, "deviceId": dialParam.mPeerNodeId, "extraMsg": dialParam.mAttachMsg] as [String : Any]
        let paramDic = ["header":headerParam,"payload":payloadParam]
        let jsonString = paramDic.convertDictionaryToJSONString()
        self.app.proxy.cocoaMqtt.waitForActionDesired(actionDesired: onMqttDesired)
        self.app.proxy.cocoaMqtt.publishCallData(sessionId: mSessionId,data: jsonString)
        log.i("---callDial--发起呼叫---")
        
    }
 
    
    func callHangup(sessionId: String, result:@escaping(Int,String)->Void){
        log.i("call callHangup")
        CallListenerManager.sharedInstance.hangUp(sessionId)
        result(ErrCode.XOK,"success")
    }
}

extension CallkitManager{
    
    func setPeerVideoView(sessionId: String, peerView: UIView?) -> Int {
        let session = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        if(session?.peerUid != 0){
            log.i("call setPeerVideoView uid:\(session?.peerUid ?? 0) \(String(describing: peerView))")
            return app.proxy.rtc.setupRemoteView(peerView: peerView, uid: session?.peerUid ?? 0)
        }
        else{
            log.d("call setPeerVideoView with no remote user joined")
        }
        return ErrCode.XERR_UNSUPPORTED
    }
    
    func muteLocalVideo(sessionId: String, mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.muteLocalVideo(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func muteLocalAudio(sessionId: String, mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.muteLocalAudio(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func mutePeerVideo(sessionId: String, mute: Bool,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.mutePeerVideo(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func mutePeerAudio(sessionId: String, mute: Bool,result:@escaping (Int,String)->Void){
//        reNewToken(sessionId)
        DispatchQueue.main.async {
            self.rtc.mutePeerAudio(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setVolume(volumeLevel: Int,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.setVolume(volumeLevel, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setAudioEffect(effectId: AudioEffectId,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.setAudioEffect(effectId, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func talkingRecordStart(sessionId: String, outFilePath:String, result:@escaping(Int,String)->Void) {
        DispatchQueue.main.async {
            self.rtc.startRecord(outFilePath:outFilePath, result: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func talkingRecordStop(sessionId: String, result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.stopRecord (result:{ec,msg in self.asyncResult(ec, msg,result)})
        }
    }

    func capturePeerVideoFrame(sessionId: String, result: @escaping (Int, String, UIImage?) -> Void) {
        DispatchQueue.main.async {
            self.app.proxy.rtc.capturePeerVideoFrame(cb: {ec,msg,img in self.asyncResultData(ec,msg,img,result)})
        }
    }
    
    func capturePeerVideoFrame(sessionId:String,saveFilePath:String,cb:@escaping(Int,Int,Int)->Void)->Int{
        return self.app.proxy.rtc.capturePeerVideoFrame(saveFilePath: saveFilePath, cb: cb)
    }
    
    func getNetworkStatus() -> RtcNetworkStatus {
        return self.app.proxy.rtc.getNetworkStatus()
    }
    
    func setPeerVideoQuality(sessionId: String, videoQuality: VideoQualityParam) -> Int {
        CallListenerManager.sharedInstance.updateCallSessionVideoQuality(sessionId, videoQuality)
        return self.app.proxy.rtc.setPeerVideoQuality(videoQuality: videoQuality)
    }

    func setRtcPrivateParam(privateParam: String) -> Int {
        //todo:
        return 0
    }
    
    func getSessionInfo(sessionId: String) -> SessionInfo? {
        
        guard let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId) else{
            return nil
        }
        let sessionInfor = SessionInfo()
        sessionInfor.mSessionId = callSession.mSessionId
        sessionInfor.mPeerNodeId = callSession.cname
        sessionInfor.uid = callSession.uid
        sessionInfor.mVideoQuality = callSession.mVideoQuality
        sessionInfor.mLocalNodeId = app.config.userId
        sessionInfor.mState = CallListenerManager.sharedInstance.getCurrentCallState(sessionId)
        
        return sessionInfor
        
    }
    
    func reNewToken(_ sessionId: String) {
        
        let sessionObj = getSessionInfo(sessionId: sessionId)
        
        let curTimestamp:Int = String.dateTimeRounded()
        
        
        let nodeToken = app.sdk.iotAppSdkMgr.mLocalNode?.mToken ?? ""
        
        let appId = app.config.masterAppId
        let headerParam = ["traceId": curTimestamp, "timestamp": curTimestamp, "nodeToken": nodeToken, "method": "refresh-token"] as [String : Any]
        let payloadParam = ["appId": appId, "deviceId": sessionObj?.mPeerNodeId ?? "","uid":sessionObj?.uid ?? "" ,"cname": sessionObj?.mPeerNodeId ?? ""] as [String : Any]
        let paramDic = ["header":headerParam,"payload":payloadParam]
        let jsonString = paramDic.convertDictionaryToJSONString()
        self.app.proxy.cocoaMqtt.publishCallData(sessionId: sessionId,data: jsonString)
        log.i("---callDial--更新token---")
        
    }
    
}

extension CallkitManager{
    
    //发送信息
     func sendCommand(sessionId:String,cmd:String,onCmdSendDone: @escaping (_ errCode:Int) -> Void) -> Int{//发送rtm消息
        return sendGeneralData(sessionId,cmd,onCmdSendDone)
    }
    
    //收到对端Rtm信息
    func onReceivedCommand(receivedListener: @escaping (_ sessionId:String,_ cmd:String) -> Void){
        rtm.waitReceivedCommandCallback(receivedListener)
    }
    
    func sendGeneralData(_ sessionId:String, _ param:String,_ cmdListener: @escaping (Int) -> Void)->Int{
        
        guard let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId) else{
            return ErrCode.XERR_BAD_STATE
        }
        
        guard let data = param.data(using: .utf8) else{ return ErrCode.XERR_INVALID_PARAM}
        rtm.sendRawGenerlMessage(toPeer: callSession.peerNodeId, data: data, description: "") { errCode, msg in
            cmdListener(errCode)
        }
        return ErrCode.XOK
    }
    
    func getSequenceId()->UInt32{
        let curSequenceId : UInt32 = app.config.counter.increment()
        return curSequenceId
    }
        
}

