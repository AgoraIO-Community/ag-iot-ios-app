//
//  IDevPreviewManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

//import UIKit
//
//class IDevPreviewManager: NSObject {
//
//}

/*
 * @brief 会话类型
 */
@objc public enum CallType : Int{
    case UNKNOWN                         //未知
    case DIAL                            //主叫
    case INCOMING                        //被叫
}


public class CallSession : NSObject{
    var token:String = ""
    var cname:String = ""               //对端nodeId
    var uid:UInt = 0

    var version:UInt = 0
    
    var peerUid:UInt = 0                //对端id
    
    var callType:CallType = .UNKNOWN    //通话类型
    var mSessionId:String = ""          //通话Id
    var traceId:UInt = 0                //追踪ID
    var peerNodeId:String = ""          //对端nodeId
    
    var devPreviewMgr : IDevPreviewMgr?       //设备预览接口对象
    var devControlMgr : IDevControllerMgr?    //设备控制接口对象
    var devMediaMgr : IDevMediaMgr?           //设备媒体文件管理器接口对象
    
    
    var mUserId: String = ""             //本地用户的 UserId
    var rtm : RtmEngine?                 //当前连接对应的Rtm对象
    var mRtmToken: String = ""           //要会话的 RTM Token
    
}

class IDevPreviewManager : IDevPreviewMgr{
    
    private var app:Application
    private let rtc:RtcEngine
    
    private var curSessionId:String //当前sessionId
    
    init(app:Application,sessionId:String){
        self.app = app
        self.rtc = app.proxy.rtc
        self.curSessionId = sessionId

    }
    
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
    
    func previewStart(bSubAudio:Bool,previewListener: @escaping (String, Int, Int) -> Void) {
        CallListenerManager.sharedInstance.registerPreViewListener(sessionId: curSessionId, previewListener:previewListener)
        mutePeerAudio(mute: bSubAudio) { ec, msg in }
    }
    
    func previewStop(result:@escaping(Int,String)->Void) {
        log.i("previewStop:")
        mutePeerAudio(mute: true) { ec, msg in }
        mutePeerVideo(mute: true) { ec, msg in }
        result(ErrCode.XOK,"success")
        
    }
    
    deinit {
        log.i("IDevPreviewManager 销毁了")
    }

    func getRtcTaklingKit()->AgoraTalkingEngine?{
        return CallListenerManager.sharedInstance.getCurrentTalkingEngine(curSessionId)
    }
    
}

extension IDevPreviewManager{
    
    func setPeerVideoView(peerView: UIView?) -> Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("setPeerVideoView: talkingKit is nil")
            return ErrCode.XERR_NOT_FOUND
        }
        
        let session = CallListenerManager.sharedInstance.getCurrentCallSession(curSessionId)
        if(session?.peerUid != 0){
            log.i("call setPeerVideoView uid:\(session?.peerUid ?? 0) \(String(describing: peerView))")
            return talkingKit.setupRemoteView(peerView: peerView, uid: session?.peerUid ?? 0)
        }
        else{
            log.d("call setPeerVideoView with no remote user joined")
        }
        return ErrCode.XERR_BAD_STATE
    }
    
    func muteLocalVideo(mute: Bool,result:@escaping (Int,String)->Void){
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("muteLocalVideo: talkingKit is nil")
            return
        }
        
        DispatchQueue.main.async {
            talkingKit.muteLocalVideo(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func muteLocalAudio(mute: Bool,result:@escaping (Int,String)->Void){
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("muteLocalAudio: talkingKit is nil")
            return
        }
        DispatchQueue.main.async {
            talkingKit.muteLocalAudio(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func mutePeerVideo(mute: Bool,result:@escaping (Int,String)->Void){
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("mutePeerVideo: talkingKit is nil")
            return
        }
        DispatchQueue.main.async {
            talkingKit.mutePeerVideo(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func mutePeerAudio(mute: Bool,result:@escaping (Int,String)->Void){
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("mutePeerAudio: talkingKit is nil")
            return
        }
        DispatchQueue.main.async {
            talkingKit.mutePeerAudio(mute, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setPlaybackVolume(volumeLevel: Int,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.setVolume(volumeLevel, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setAudioEffect(effectId: AudioEffectId,result:@escaping (Int,String)->Void){
        DispatchQueue.main.async {
            self.rtc.setAudioEffect(effectId, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func recordingStart(outFilePath:String, result: @escaping (Int, String) -> Void) {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("recordingStart: talkingKit is nil")
            return
        }
        DispatchQueue.main.async {
            talkingKit.startRecord(outFilePath:outFilePath, result: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func recordingStop(result:@escaping (Int,String)->Void){
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("recordingStop: talkingKit is nil")
            return
        }
        DispatchQueue.main.async {
            talkingKit.stopRecord (result:{ec,msg in self.asyncResult(ec, msg,result)})
        }
    }

    func captureVideoFrame(result: @escaping (Int, String, UIImage?) -> Void) {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("captureVideoFrame: talkingKit is nil")
            return
        }
        
        DispatchQueue.main.async {
            talkingKit.capturePeerVideoFrame(cb: {ec,msg,img in self.asyncResultData(ec,msg,img,result)})
        }
    }
    
    func getNetworkStatus() -> RtcNetworkStatus {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("getNetworkStatus: talkingKit is nil")
            return RtcNetworkStatus()
        }
        return talkingKit.getNetworkStatus()
    }

    func setRtcPrivateParam(privateParam: String) -> Int {
        //todo:
        return 0
    }
    
    func getSessionInfo(sessionId: String) -> SessionInfo {
        
        let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        let sessionInfor = SessionInfo()
        sessionInfor.mSessionId = callSession?.mSessionId ?? ""
        sessionInfor.mPeerDevId = callSession?.cname ?? ""
        sessionInfor.mUserId = app.config.userId
        sessionInfor.mState = CallListenerManager.sharedInstance.getCurrentCallState(sessionId)
        
        return sessionInfor
        
    }
    
}