
//
//  IConnectionObjManager.swift
//  AgoraIotLink
//
//  Created by admin on 2024/2/20.
//


class IConnectionObjManager: IConnectionObj {

    private var app:IotLibrary
    private let rtc:RtcEngine
    private let rtm:RtmEngine
    private var curConnectId:String
    init(app:IotLibrary,connectId:String){
        
        self.app = app
        self.curConnectId = connectId
        self.rtc = app.proxy.rtc
        self.rtm = app.proxy.rtm
        
    }
    
    private func asyncResult(_ ec:Int,_ msg:String,_ result:@escaping(Int,String)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1)
        }
    }
    
    deinit {
        log.i("IConnectionObjManager 销毁了")
    }

    func getRtcTaklingKit()->AgoraTalkingEngine?{
        return ConnectListenerManager.sharedInstance.getCurrentTalkingEngine(curConnectId)
    }
    
    func getConnectObj()->ConnectStateListener?{
        return ConnectListenerManager.sharedInstance.getCurrentConnecObjet(curConnectId)
    }
    
    func getConnectSession()->CallSession?{
        return ConnectListenerManager.sharedInstance.getCurrentCallSession(curConnectId)
    }

}

extension IConnectionObjManager{
    
    func registerListener(callBackListener: ICallbackListener) -> Int {
        ConnectListenerManager.sharedInstance.registerCallBackListener(self.curConnectId,callBackListener:callBackListener )
        return ErrCode.XOK
    }
    
    func unregisterListener() -> Int {
        ConnectListenerManager.sharedInstance.unregisterCallListener(self.curConnectId)
        return ErrCode.XOK
    }
    
    func getInfo() -> ConnectionInfo {
        
        let conInfor = ConnectionInfo()
        guard let callObj = getConnectObj(), let callSession = callObj.callSession else {
            log.e("getInfo:  getConnectSession fail curConnectId:\(curConnectId)")
            return conInfor
        }
        conInfor.mPeerNodeId = callSession.peerNodeId
        conInfor.mLocalNodeId = app.config.mLocalNodeId
        conInfor.mType = callSession.callType
        conInfor.mState = (callObj.callMachine?.currentState) ?? .disconnected
        conInfor.mAudioPublishing = callObj.talkingEngine?.rtcSetting.publishAudio ?? false
        conInfor.mVideoPublishing = callObj.talkingEngine?.rtcSetting.publishVideo ?? false
        return conInfor
    }
    
    func getNetworkStatus() -> NetworkStatus {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("getNetworkStatus: talkingKit is nil")
            return NetworkStatus()
        }
        return talkingKit.getNetworkStatus()
    }
    
    func publishVideoEnable(pubVideo: Bool, result:@escaping(Int,String)->Void) -> Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("muteLocalVideo: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        
        DispatchQueue.main.async {
            talkingKit.muteLocalVideo(!pubVideo, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
        return ErrCode.XOK
    }
    
    func publishAudioEnable(pubAudio: Bool, codecType:AudioCodecType, result:@escaping(Int,String)->Void) -> Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("muteLocalAudio: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        DispatchQueue.main.async {
            talkingKit.muteLocalAudio(!pubAudio,codecType: codecType, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
        return ErrCode.XOK
    }
    
    func setPublishAudioEffect(effectId: AudioEffectId, result: @escaping (Int, String) -> Void) -> Int {
        
        DispatchQueue.main.async {
            self.rtc.setAudioEffect(effectId, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
        return ErrCode.XOK
    }
    
    func getStreamStatus(peerStreamId: StreamId) -> StreamStatus{
        
        let streamStatusObj = StreamStatus()
        guard let talkingKit = getRtcTaklingKit(),let streamObj = talkingKit.getStreamObj(subStreamId: peerStreamId) else {
            log.e("getPeerStreamStatus: talkingKit is nil")
            return streamStatusObj
        }
        streamStatusObj.mStreamId = streamObj.streamId
        streamStatusObj.mRecording = streamObj.mRecording
        streamStatusObj.mSubscribed = streamObj.mVideoPreviewing
        streamStatusObj.mAudioMute = streamObj.mAudioPreviewing
        return streamStatusObj
    }
 
    func streamSubscribeStart(peerStreamId: StreamId, attachMsg: String, result: @escaping (Int, String) -> Void) {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("mutePeerAudio: talkingKit is nil")
            result(ErrCode.XERR_BAD_STATE,"fail")
            return
        }
        sendEnableAVCmd(subStreamId: peerStreamId, subscribe: true, attachMsg: attachMsg)
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        var retAudioCode = 0
        var retVideoCode = 0
        group.enter()
        queue.async(group: group) {
            talkingKit.mutePeerAudio(peerStreamId,true, cb: {ec,msg in
                retAudioCode = ec
                group.leave()
            })
        }
        
        group.enter()
        queue.async(group: group) {
            talkingKit.mutePeerVideo(peerStreamId,false, cb: {ec,msg in
                retVideoCode = ec
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            log.i(" mutePeerAV 完全走完了")
            if retAudioCode != ErrCode.XOK{
                result(retAudioCode,"fail")
            }else if retVideoCode != ErrCode.XOK{
                result(retVideoCode,"fail")
            }else{
                result(ErrCode.XOK,"suc")
            }
        }
    }
    
    func streamSubscribeStop(peerStreamId: StreamId) {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("streamSubscribeStop: talkingKit is nil")
            return
        }
        
        sendEnableAVCmd(subStreamId: peerStreamId, subscribe: false, attachMsg: "")
        
        DispatchQueue.main.async {
            talkingKit.mutePeerVideo(peerStreamId,true, cb: {ec,msg in})
            talkingKit.mutePeerAudio(peerStreamId,true, cb: {ec,msg in})
            //todo: 清除其他比如音量
        }
    }
    
    func setVideoDisplayView(subStreamId: StreamId, displayView: UIView?) -> Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("setPeerVideoView: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        return talkingKit.setupRemoteView(subStreamId: subStreamId,peerView: displayView)
    }
    
    func muteAudioPlayback(subStreamId: StreamId, previewAudio: Bool, result: @escaping (Int, String) -> Void) {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("mutePeerAudio: talkingKit is nil")
            result(ErrCode.XERR_BAD_STATE,"fail")
            return
        }
        DispatchQueue.main.async {
            talkingKit.mutePeerAudio(subStreamId,!previewAudio, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func setAudioPlaybackVolume(subStreamId: StreamId, volumeLevel: Int, result: @escaping (Int, String) -> Void) {
        
        DispatchQueue.main.async {
            self.rtc.setPlaybackVolume(volumeLevel, cb: {ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func streamVideoFrameShot(subStreamId: StreamId, saveFilePath: String, cb: @escaping (Int, Int, Int) -> Void) -> Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("capturePeerVideoFrame: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        return talkingKit.capturePeerVideoFrame(subStreamId,saveFilePath: saveFilePath, cb: cb)
    }
    
    func streamRecordStart(subStreamId: StreamId, outFilePath: String) -> Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("captureVideoFrame: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        talkingKit.createMediaRecorder(subStreamId, outFilePath)
        return ErrCode.XOK
    }
    
    func streamRecordStop(subStreamId: StreamId) -> Int {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("captureVideoFrame: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        talkingKit.stopInterRecording(subStreamId)
        return ErrCode.XOK
    }
    
    func isStreamRecording(subStreamId: StreamId) -> Bool {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("captureVideoFrame: talkingKit is nil")
            return false
        }
        guard let streamObj = talkingKit.getStreamObj(subStreamId: subStreamId) else {
            log.e("getStreamObj: StreamObj is nil subStreamId:\(subStreamId)")
            return false
        }
        return streamObj.mRecording
    }
}

extension IConnectionObjManager{
    
    func fileTransferStart(startMessage: String)->Int {
        
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("fileTransferStart: talkingKit is nil")
            return ErrCode.XERR_BAD_STATE
        }
        
        let paramString = getRdtParamString(transfering: 1, attachMsg: startMessage)
        return talkingKit.sendRdtMessageStart(startMessage: paramString)
    }
    
    func fileTransferStop() {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("fileTransferStop: talkingKit is nil")
            return
        }
        let paramString = getRdtParamString(transfering: 0, attachMsg: "")
        talkingKit.sendRdtMessageStop(stopMessage: paramString)
    }
    
    func isFileTransfering() -> Bool {
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("isFileTransfering: talkingKit is nil")
            return false
        }
        return talkingKit.isFileTransfering()
    }
    
    func getRdtParamString(transfering: Int,attachMsg: String)->String {
        
        guard let callSession =  getConnectSession() else{
            log.i("callSession is nil")
            return ""
        }
        
        var base64AttachMsg = ""
        if let attachMsgData = attachMsg.data(using: .utf8) {
            base64AttachMsg = attachMsgData.base64EncodedString()
        }
        
        var curTransferId : UInt64 = UInt64(String.dateCurrentTime())
        if transfering == 0 {
            curTransferId = callSession.transferId
        }else{
            callSession.transferId = curTransferId
        }
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:Int = CommandList.command_EnableTranferFile
        let payloadParam = ["callerNodeId": app.config.mLocalNodeId, "calleeNodeId": callSession.peerNodeId, "transferId": curTransferId, "transfering": transfering,"attachMsg": base64AttachMsg ] as [String : Any]
        let paramDic = ["traceId": callSession.traceId,"sequenceId": curSequenceId, "commandId": commanId, "param": payloadParam] as [String : Any]
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        
        return jsonString
    
    }
    
}

extension IConnectionObjManager{
    
    func sendMessageData(messageData:Data) -> UInt32{
        let curSequenceId : UInt32 = getSequenceId()
        sendGeneralData(messageData,curSequenceId)
        return curSequenceId
        
    }
    
    func sendGeneralData(_ signalData:Data, _ sequenceId:UInt32){
        
        guard let callObj = getConnectObj()  else{ return }
        guard let callSession = callObj.callSession,let cbListen = callObj.callBackListener else{ return }
        
        guard let data = configOutData(signalData) else {
            log.e("sendGeneralData: configOutData fail")
            return
        }
        
        rtm.sendRawGenerlMessage(sequenceId:sequenceId, toPeer: callSession.peerNodeId, data: data, description: "") { sequenceId, errCode, msg in
            cbListen.onMessageSendDone(connectObj: callSession.connectionObj, errCode: errCode, signalId: sequenceId)
        }
    }
    
    func getSequenceId()->UInt32{
        let curSequenceId : UInt32 = app.config.counter.increment()
        return curSequenceId
    }
    
    func configOutData(_ parmData: Data)->Data?{
        
        // 第5位的索引
        let insertionIndex = 4
        
        // 创建目标字节数组
        var targetArray = [UInt8](repeating: 0, count: insertionIndex + parmData.count)

        // 将目标数组的第1和第2两个字节都设置为 0x01123
        targetArray[0] = UInt8(0x01)
        targetArray[1] = UInt8(0x02)
        
        // 获取 data 的字节长度
        let dataLength = parmData.count
        let byteDataLength = UInt16(dataLength)
        // 将 data 的字节长度按大端写入 targetArray 的第3和第4位
        targetArray[2] = UInt8(((byteDataLength >> 8) & 0xFF))
        targetArray[3] = UInt8((byteDataLength & 0xFF))

        // 将字符串的字节内容复制到目标字节数组中的指定位置
        for (index, byte) in parmData.enumerated() {
            if insertionIndex + index < targetArray.count {
                targetArray[insertionIndex + index] = byte
            } else {
                break // 如果超出目标数组长度则跳出循环
            }
        }
        
        let retData = Data(targetArray)
        
        return retData
        
    }

}

extension IConnectionObjManager{
    
    func sendEnableAVCmd(subStreamId: StreamId, subscribe: Bool?, attachMsg:String){
        
        guard let callObj = getConnectObj()  else{ return }
        guard let callSession = callObj.callSession else{ return }
        
        log.i("----------sendEnableAVCmd------------ peerNodeId:\(String(describing: callObj.callSession?.peerNodeId))")
        
        let peerUid = StreamIdToUIdMap.getUId(baseUid:callSession.uid , streamId: UInt(subStreamId.rawValue) )
        var enableVideo = 0
        if let subscribe = subscribe{
            enableVideo = subscribe ? 1 : 0
        }
        var base64AttachMsg = ""
        if let attachMsgData = attachMsg.data(using: .utf8) {
            base64AttachMsg = attachMsgData.base64EncodedString()
        }
        
        callSession.connectionCmd?.sendCmdPreviewAV(peerUid: peerUid, subscribe: enableVideo,attachMsg:base64AttachMsg, cmdListener: {  errCode, msg in
            if errCode != 0{
                log.e("Error occurred. Retrying... errCode：\(errCode)")
                guard let cbListen = callObj.callBackListener else{ return }
                cbListen.onStreamError(connectObj: callObj.callSession?.connectionObj, subStreamId: subStreamId, errCode: errCode)
            }else{
                if subscribe == true {//如果是开启视频，则设置超时处理
                    callObj.talkingEngine?.setStreamObjTimeout(streamId: subStreamId)
                }
            }
        })
        
    }
 
    
}
