//
//  CallListenerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/25.
//

import UIKit

class CallListenerManager {

    static var sharedInstance = CallListenerManager()
    var app  = Application.shared
    var mediaLister : MediaStateListener?
    
    //todo:
    var startConnectTime : TimeInterval = 0
    var startTime : TimeInterval = 0
    var endTime   : TimeInterval = 0
    
//    struct Static
//    {
//        static var instance: CallListenerManager?
//    }
//
//    class var sharedInstance: CallListenerManager
//    {
//        if Static.instance == nil
//        {
//            Static.instance = CallListenerManager()
//        }
//
//        return Static.instance!
//    }
//
    static func destroy() {
//        CallListenerManager.Static.instance = nil
     }
    
    var callDict = [String:Any]()
    func startCall(sessionId:String,dialParam: ConnectParam,actionAck:@escaping(SessionCallback,_ sessionId:String,_ errCode:Int)->Void,memberState:((MemberState,[UInt],String)->Void)?){

        let callLister = CallStateListener(dialParam:dialParam, actionAck: actionAck, memberState: memberState)
        callDict[sessionId] = callLister
        callLister.callSession?.mSessionId = sessionId
        callLister.interCallAct = { [weak self] ack,sessionId,peerNodeId in
            if (ack == .RemoteHangup){
                self?.hungUp(sessionId, result: { errCode in
                    log.i("inter disconnect")
                })
            }
        }
        initOther(callLister,sessionId)
    }
    
    func initOther(_ callListen : CallStateListener,_ sessionId:String){
        let preMgr = IDevPreviewManager(app: self.app,sessionId:sessionId)
        callListen.callSession?.devPreviewMgr = preMgr
        
        initRtm(callListen, sessionId)
    }
    
    func initRtm(_ callListen : CallStateListener,_ sessionId:String){//初始化其他
        let rtm = RtmEngine(cfg: app.config)
        callListen.callSession?.rtm = rtm
        
        callListen.creatAndEnterRtm()
        
        let controlMgr = IDevControllerManager(app: self.app, rtm: rtm, sessionId: sessionId)
        callListen.callSession?.devControlMgr = controlMgr
        
        let mediaMgr = IDevMediaManager(app: self.app , rtm: rtm,sessionId: sessionId)
        callListen.callSession?.devMediaMgr = mediaMgr
   
    }
    
    func callRequest(_ sessionId:String = ""){
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.callRequest()
    }
    
    func disConnect(_ sessionId:String,disconnectListener:@escaping(OnSessionDisconnectListener,_ sessionId:String,_ errCode:Int)->Void){
        hungUp(sessionId) { errCode in
            disconnectListener(.onSessionDisconnectDone,sessionId,errCode)
        }
    }
    
    func hungUp(_ sessionId:String,result:@escaping(Int)->Void){//挂断
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.hangUp { isSuc, msg in
            self.clearCurrentCallObj(sessionId)
            log.i(" hangUp 走完了")
        }
        log.i("CallListenerManager hangUp 调用了")
        
        //断开其他
        hunUpSDCard()
        
        callListen?.callSession?.rtm?.leave(cb: { succ in
            if(!succ){
                log.w("rtm leave fail")
                result(ErrCode.XERR_UNKNOWN)
            }else{
                result(ErrCode.XOK)
            }
        })
        
    }
    
    func clearCurrentCallObj(_ sessionId:String){//清除当前call对象
        callDict.removeAll()
//        CallListenerManager.destroy()
        log.i("clearCurrentCallObj:\(callDict.count)")
//        callDict.removeValue(forKey: sessionId)
    }
    
    func registerPreViewListener(sessionId:String,previewListener: @escaping (String, Int, Int) -> Void){
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.registerPreViewListener(previewListener: previewListener)
    }

    func isTaking(_ peerNodeId : String)->Bool{
        
        if callDict.count == 1{
            let result = callDict.filter { ($0.value as! CallStateListener).callSession?.peerNodeId == "\(peerNodeId)" }
            log.i("isTaking___\(result) :result.count :\(result.count)")
            return true
        }
        return false
    }
    
    func isCallTaking(_ peerNodeId : String)->Bool{
        
        if callDict.count > 0{
            let result = callDict.filter { ($0.value as! CallStateListener).callSession?.peerNodeId == "\(peerNodeId)" }
            log.i("isCallTaking\(result) :result.count :\(result.count)")
            if result.count > 0{
                return true
            }
            return false
        }
        return false
    }

    func getCurrentCallSession(_ sessionId:String) -> CallSession?{
        let callListen = getCurrentCallObjet(sessionId)
        return callListen?.callSession
    }
    
    func getCurrentCallState(_ sessionId:String) -> CallState{
        guard let callListen = getCurrentCallObjet(sessionId),let callMachine = callListen.callMachine else {
            log.i("getCurrentCallState not found sessionId :\(sessionId), return idle ")
            return .idle
        }
        return callMachine.currentState
    }
    
    func getCurrentCallObjet(_ sessionId:String)->CallStateListener?{
        // 通过key找到对象
        if let callObjet = callDict[sessionId] as? CallStateListener {
            // 找到了对应的对象
            return callObjet
        } else {
            // 没有找到对应的对象
            log.i("getCurrentCallObjet not found sessionId :\(sessionId) ")
            return nil
        }
    }
    
    func getCurrentTalkingEngine(_ sessionId:String)->AgoraTalkingEngine?{
        
        guard let callObjet = getCurrentCallObjet(sessionId) else{
            log.i("getCurrentTalkingEngine not found sessionId :\(sessionId) ")
            return nil
        }
        return callObjet.talkingEngine
    }
    
    
    //-----------sdk回看----------
    func startSDCardCall(dialParam: CallSession,peerDisplayView:UIView?,actionAck:@escaping(MediaCallback,_ sessionId:String,_ errCode:Int)->Void,memberState:((MemberState,[UInt],String)->Void)?){

        let callLister = MediaStateListener(dialParam:dialParam,peerDisplayView:peerDisplayView, actionAck: actionAck, memberState: memberState)
        mediaLister = callLister
        callLister.callRequest()
        callLister.interCallAct = { [weak self] ack,sessionId,peerNodeId in
            if (ack == .RemoteHangup){
                self?.hunUpSDCard()
            }
        }
    }
    
    func pausingSDCardPlay(){
        mediaLister?.pausingSDCardPlay()
    }
    
    func pausedSDCardPlay(){
        mediaLister?.pausedSDCardPlay()
    }
    
    func resumeingSDCardPlay(){
        mediaLister?.resumeingSDCardPlay()
    }
    
    func resumedSDCardPlay(){
        mediaLister?.resumedSDCardPlay()
    }
    
    func hunUpSDCard(){
        guard let mediaLister = mediaLister else{ return }
        mediaLister.hangUp(hangUpResult: { [weak self] isSuc, msg in
            self?.mediaLister = nil
        })
    }
    
    func getCurrentSDcardTalkingEngine()->AgoraTalkingEngine?{
        
        guard let callObjet = mediaLister else{
            log.i("getCurrentSDcardTalkingEngine not found ")
            return nil
        }
        return callObjet.talkingEngine
    }
    
    func getCurrentSDCardCallSession() -> CallSession?{
        guard let callObjet = mediaLister else{
            log.i("getCurrentSDcardTalkingEngine not found ")
            return nil
        }
        return callObjet.callSession
    }
    
    func getCurrentSDCardCallMachine() -> MediaStateMachine?{
        guard let callObjet = mediaLister else{
            log.i("getCurrentSDcardTalkingEngine not found ")
            return nil
        }
        return callObjet.callMachine
    }
    
    
    //-------来电单独处理，暂时不用-------
    
    func updateCallSession(_ sessionId:String, _ sess : CallSession){
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.updateCallSession(sess)
    }
    
    func incomeCall(sessionId:String,sess:CallSession?,incoming: @escaping (_ sessionId:String,_ peerNodeId:String, ActionAck) -> Void,memberState:((MemberState,[UInt],String)->Void)?){
        let callLister = CallStateListener(sess:sess, incoming: incoming,memberState: memberState)
        callDict[sessionId] = callLister
        callLister.callSession?.mSessionId = sessionId
    }
    
    func acceptCall(_ sessionId:String){
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.inComeDealTime()
    }
    
}
