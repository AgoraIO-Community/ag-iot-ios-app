//
//  ConnectListenerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2024/3/14.
//


import UIKit

class ConnectListenerManager: NSObject {
    
    var app  = IotLibrary.shared
    static var sharedInstance = ConnectListenerManager()
    
    var connectBackListener:IConnectionMgrListener? = nil
    var connectDict = ThreadSafeDictionary<String,ConnectStateListener?>()
    
    func connect(connectionId:String,connectParam: ConnectCreateParam)->IConnectionObj?{

        let callLister = ConnectStateListener(connectionParam: connectParam, connectionCallback: {[weak self] ack, connectObj, errCode in
            if ack == .onConnectDone {
                self?.connectBackListener?.onConnectionCreateDone(connectObj: connectObj, errCode: errCode)
            }else if ack == .onDisconnected{
                self?.connectBackListener?.onPeerDisconnected(connectObj: connectObj, errCode: errCode)
            }
        })
        connectDict.setValue(callLister, forKey: connectionId)
        callLister.callSession?.mConnectId = connectionId
        callLister.innerCallAct = { [weak self] ack,connectId,peerNodeId in
            if (ack == .RemoteHangup){
                self?.hangUp(connectId) { errCode in log.i("inner disconnect") }
            }else if(ack == .connectFail){
                self?.callRequestFail(connectId)
            }
        }
        let connectionObj = IConnectionObjManager(app: app, connectId: connectionId)
        callLister.callSession?.connectionObj = connectionObj
        
        initOther(callLister,connectionId)
        
        return connectionObj
    }
    
    func initOther(_ callListen : ConnectStateListener,_ connectId:String){
        
        let rtm = app.proxy.rtm
        let connectionCmd = InnerCmdManager(app: app, rtm: rtm, connectId: connectId)
        callListen.callSession?.connectionCmd = connectionCmd
        
        registerRtmLister()
    }
    
    func callRequestFail(_ connectId:String = ""){//呼叫失败时清除呼叫对象
        clearCurrentCallObj(connectId)
    }
    
    func disConnect(_ connectObj:IConnectionObj)->Int{
        
        let curPeerId = connectObj.getInfo().mPeerNodeId
        let callListen =  getCurrentCallObjetWithPeerId(curPeerId)
        
        guard callListen?.callMachine?.currentState != .disconnected else {
            log.e("disconnect fail:\(connectObj)")
            return ErrCode.XERR_BAD_STATE
        }
        
        if callListen?.callSession?.traceId != ""{
            callListen?.callSession?.connectionCmd?.sendCmdDisConnect(cmdListener: { code, msg in })
        }
        
        log.i("disConnect:------connectID:\(String(describing: callListen?.callSession?.mConnectId) )")
        hangUp(callListen?.callSession?.mConnectId ?? "") { errCode in log.i("disConnect: errCode:\(errCode)") }
        log.i("disConnect:  调用了 left current connectDict.keys:\(connectDict.getAllKeys())")
        
        return ErrCode.XOK
    }
    
    func hangUp(_ connectId:String, result:@escaping(Int)->Void){//挂断
        let callListen = getCurrentConnecObjet(connectId)
        callListen?.hangUp { isSuc, msg in  }
        clearCurrentCallObj(connectId)
        log.i("ConnectListenerManager hangUp 调用了")
    }
    
    func clearCurrentCallObj(_ connectId:String){//清除当前call对象
        log.i("🐶🐶🐶clearCurrentCallObj: connectId:\(connectId)🐶🐶🐶🐶🐶🐶")
        let ret = connectDict.removeValue(forKey: connectId)
        log.i("clearCurrentCallObj: ret:\(String(describing: ret)) left connectDict.keys:\(connectDict.getAllKeys())")
    }
 
    func registerConnectBackListener(connectBackListener: IConnectionMgrListener){
        self.connectBackListener = connectBackListener
    }
    
    func unregisterConnectListener(){
        connectBackListener = nil
    }

    func registerCallBackListener(_ connectId:String = "",callBackListener: ICallbackListener){
        let callListen = getCurrentConnecObjet(connectId)
        callListen?.registerCallBackListener(callBackListener: callBackListener)
    }
    
    func unregisterCallListener(_ connectId:String = ""){
        let callListen = getCurrentConnecObjet(connectId)
        callListen?.unregisterCallBackListener()
    }
    
    func updateCallSessionVideoQuality(_ connectId:String, _ videoQuality : VideoQualityParam){
        let callListen = getCurrentConnecObjet(connectId)
        callListen?.updateCallSessionVideoQuality(videoQuality)
    }
    
    func isCallTaking(_ peerNodeId : String)->Bool{
        
        let connectObjs = connectDict.getAllValues()
        guard connectObjs.count > 0 else { return false }
        
        for conObj in connectObjs {
            if conObj?.callSession?.peerNodeId == peerNodeId {
                log.i("isCallTaking: already peerNodeId :\(peerNodeId) ")
                return true
            }
        }
        log.i("isCallTaking: peerNodeId :\(peerNodeId) ")
        return false
        
    }
}

extension ConnectListenerManager{
    
    func registerRtmLister(){
        let rtm = app.proxy.rtm
        rtm.waitReceivedCommandCallback {[weak self] connectId, receiveData in
            if self?.IsInterCmd(receiveData) == true{
                self?.handelInterReceiceData(receiveData)
                return
            }
            guard let callObj = self?.getCurrentConnecObjet(connectId), let cbListenr = callObj.callBackListener else{
                log.e("registerRtmLister: waitReceivedCommandCallback: connectId:\(connectId)")
                return
            }
            cbListenr.onMessageRecved(connectObj: callObj.callSession?.connectionObj, recvedSignalData: receiveData)
        }
        rtm.waitForStatusUpdated(statusUpdated: {[weak self] status, msg, rtmMsg in
            log.i("waitForStatusUpdated: status:\(status) msg:\(msg)")
            self?.handelRtmStatus(status)
        })
    }
    
    func handelRtmStatus(_ status:MessageChannelStatus){
//        if status == .Connected {
//            let connectObjs = connectDict.getAllValues()
//            //监听到Rtm连接成功
//            for obj in connectObjs{
//                obj?.handelRtmAlready()
//            }
//        }
        if status == .TokenWillExpire {
            let connectObjs = connectDict.getAllValues()
            if connectObjs.count > 0 {
                log.i("handelRtmStatus:rtm TokenWillExpire will renewTotalToken")
                let obj_First = connectObjs[0]
                obj_First?.renewTotalToken()
            }else{
                app.proxy.rtm.leave { suc in
                    log.i("handelRtmStatus: TokenWillExpire rtm leave because no connect")
                    if suc {
                        log.i("handelRtmStatus: rtm leave:\(suc)")
                    }
                }
            }
            
        }else if status == .Aborted {
            app.proxy.rtm.leave { suc in
                log.i("handelRtmStatus: Aborted rtm leave")
                if suc {
                    log.i("handelRtmStatus: rtm leave:\(suc)")
                }
            }
            
        }
    }
    
    func IsInterCmd(_ receiceData : Data)->Bool{
        guard receiceData.count > 2 else { return false }
        let cmdType :Int = Int(receiceData[1])
        if cmdType == 1 {
            return true
        }
        return false
    }
    
    func handelInterReceiceData(_ receiceData : Data){
        
        let subData = receiceData.subdata(in: 4..<receiceData.count)
        let dict = String.getDictionaryFromData(data: subData)
        log.i("handelInterReceiceData:  releive peer message:\(dict)")
        guard let commandId = dict["commandId"] as? Int else{
            log.e("handelInterReceiceData: commandId is nil; dict:\(dict)")
            return
        }
        guard let traceId = dict["traceId"] as? String else{
            log.e("handelInterReceiceData: traceId is nil; dict:\(dict)")
            return
        }
        guard let paramDic = dict["param"] as? [String:Any], let peerId = paramDic["calleeNodeId"] as? String else {
            log.e("handelInterReceiceData: param is nil; dict:\(dict)")
            return
        }
        if commandId == CommandList.command_ConnectCompelete{
            
            log.i("handelInterReceiceData: commandId is commandId:\(commandId) dict:\(dict)")
            let callObj = getCurrentCallObjetWithPeerId(peerId)
            guard callObj?.callSession?.traceId == traceId else {
                log.e("handelInterReceiceData: traceId not equal curTraceId:\(String(describing: callObj?.callSession?.traceId))")
                return
            }
            callObj?.handelPeerOnlineAction()
            
        }else if commandId == CommandList.command_Disconnect{
            let callObj = getCurrentCallObjetWithPeerId(peerId)
            guard callObj?.callSession?.traceId == traceId else {
                log.e("handelInterReceiceData: traceId not equal curTraceId:\(String(describing: callObj?.callSession?.traceId))")
                return
            }
            hangUp(callObj?.callSession?.mConnectId ?? "" ) { errCode in log.i("handelInterReceiceData: command_Disconnect errCode:\(errCode)") }
            
        }else if commandId == CommandList.command_PeerAct{
            guard let connectRespCode = paramDic["connectRespCode"] as? Bool else {
                log.e("handelInterReceiceData: connectRespCode is nil; dict:\(dict)")
                return
            }
            let callObj = getCurrentCallObjetWithPeerId(peerId)
            guard callObj?.callSession?.traceId == traceId else {
                log.e("handelInterReceiceData: traceId not equal curTraceId:\(String(describing: callObj?.callSession?.traceId))")
                return
            }
            connectBackListener?.onPeerAnswerOrReject(connectObj: callObj?.callSession?.connectionObj, answer: connectRespCode)
            
        }
    }
    
}

extension ConnectListenerManager{
    
    func getCurrentCallSession(_ connectId:String) -> CallSession?{
        let callListen = getCurrentConnecObjet(connectId)
        return callListen?.callSession
    }
    
    func getConnectionList()->[IConnectionObj]?{
        
        if connectDict.getAllKeys().count > 0 {
            let connectObjs = connectDict.getAllValues()
            var connectArray = [IConnectionObj]()
            for callObj in connectObjs{
                if let callSession = callObj?.callSession,let connectObj = callSession.connectionObj {
                    connectArray.append(connectObj)
                }
            }
            return connectArray
        }
        return nil
    }
    
    func getCurrentCallState(_ connectId:String) -> ConnectState{
        
        guard let callListen = getCurrentConnecObjet(connectId),let callMachine = callListen.callMachine else {
            log.i("getCurrentCallState not found connectId :\(connectId), return idle ")
            return .disconnected
        }
        return callMachine.currentState
    }
    
    func getCurrentConnecObjet(_ connectId:String)->ConnectStateListener?{
        
        if let callObjet = connectDict.getValue(forKey: connectId, defaultValue: nil) {
            return callObjet
        } else {
            log.i("getCurrentCallObjet not found connectId :\(connectId) ")
            return nil
        }
    }
    
    func getConnectObj(_ connectObj:IConnectionObj)->ConnectStateListener?{
        let connectObjs = connectDict.getAllValues()
        let curPeerId = connectObj.getInfo().mPeerNodeId
        for conObj in connectObjs {
            if conObj?.callSession?.peerNodeId == curPeerId {
                log.i("getConnectObj: curPeerId :\(curPeerId) ")
                return conObj
            }
        }
        return nil
    }
    
    func getCurrentTalkingEngine(_ connectId:String)->AgoraTalkingEngine?{
         
        guard let callObjet = getCurrentConnecObjet(connectId) else{
            log.i("getCurrentTalkingEngine not found connectId :\(connectId) ")
            return nil
        }
        return callObjet.talkingEngine
    }
    
    func getCurrentCallbackListener(_ connectId:String)->ICallbackListener?{
         
        guard let callObjet = getCurrentConnecObjet(connectId) else{
            log.i("getCurrentCallbackListener not found connectId :\(connectId) ")
            return nil
        }
        return callObjet.callBackListener
    }
    
    func getCurrentCallObjetWithPeerId(_ peerId:String)->ConnectStateListener?{
        
        let connectObjs = connectDict.getAllValues()
        for conObj in connectObjs {
            if conObj?.callSession?.peerNodeId == peerId {
                log.i("getCurrentCallObjetWithPeerId: peerId :\(peerId) ")
                return conObj
            }
        }
        
        return nil
    }

}
