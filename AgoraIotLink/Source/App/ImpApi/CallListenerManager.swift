//
//  CallListenerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/25.
//

import UIKit

class CallListenerManager: NSObject {

    static let sharedInstance = CallListenerManager()
    var app  = Application.shared

    var callDict = [String:Any]()
    func startCall(sessionId:String,dialParam: ConnectParam,actionAck:@escaping(SessionCallback,_ sessionId:String,_ errCode:Int)->Void,memberState:((MemberState,[UInt],String)->Void)?){

        let callLister = CallStateListener(dialParam:dialParam, actionAck: actionAck, memberState: memberState)
        callDict[sessionId] = callLister
        callLister.callSession?.mSessionId = sessionId
        callLister.interCallAct = { [weak self] ack,sessionId,peerNodeId in
            if (ack == .RemoteHangup){
                self?.hangUp(sessionId)
            }
        }
        initOther(callLister,sessionId)
    }
    
    func initOther(_ callListen : CallStateListener,_ sessionId:String){
        let preMgr = IDevPreviewManager(app: self.app,sessionId:sessionId)
        callListen.callSession?.devPreviewMgr = preMgr
        
        //初始化其他
        let setting = app.context.rtm.setting
        let succ = app.proxy.rtm.create(setting)
    }
    
    func callRequest(_ sessionId:String = ""){
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.callRequest()
    }
    
    func hangUp(_ sessionId:String){//挂断
        let callListen = getCurrentCallObjet(sessionId)
        callListen?.hangUp { isSuc, msg in
            self.clearCurrentCallObj(sessionId)
            log.i(" hangUp 走完了")
        }
        log.i("CallListenerManager hangUp 调用了")
        
        //断开其他
        app.proxy.rtm.destroy();
        
    }
    
    func clearCurrentCallObj(_ sessionId:String){//清除当前call对象
        callDict.removeAll()
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
