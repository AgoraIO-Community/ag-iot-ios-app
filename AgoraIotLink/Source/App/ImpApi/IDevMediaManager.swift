//
//  IDevMediaManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation

/*
 * @brief sd卡回放时产生的行为/事件
 */
@objc public enum MediaCallback:Int{
    case onjoinSuc               //加入通道成功
    case onPlayed                //设备连接连接完成
    case onFirstFrame            //获取到播放首帧
    case onStoped                //设备断开连接
    case onError                 //会话错误
    case UnknownAction           //未知错误
}


class IDevMediaManager : IDevMediaMgr{
    
    private var app:Application
    private var curSessionId:String //当前sessionId
    private var rtm:RtmEngine
    
    private var playStateListener:IPlayingCallbackListener? = nil
    
    var mediaItemArray = [DevMediaItem]()
    var curPlayItem  : DevMediaItem?
    var curStartTime : UInt64 = 0
    
    var peerDisplayView : UIView?
    
    init(app:Application,rtm:RtmEngine,sessionId:String){
        self.app = app
        self.rtm = rtm
        self.curSessionId = sessionId
    }
    
    lazy var playClock : MediaPlayingClock = {
        
        let playClock = MediaPlayingClock()
        return playClock
        
    }()
    
    deinit {
        log.i("IDevMediaManager 销毁了")
    }

    
    func queryMediaList(queryParam: QueryParam, queryListener: @escaping (Int, [DevMediaItem]) -> Void) {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2002
        let payloadParam = ["id":queryParam.mFileId, "begin": queryParam.mBeginTimestamp,"end": queryParam.mEndTimestamp, "index": queryParam.mPageIndex, "size": queryParam.mPageSize] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) { [weak self] errCode, resutArray in
            log.i("queryMediaList resutArray:\(resutArray)")
            queryListener(errCode,(self?.getDevMediaItemResult(resutArray))!)
        }
        
    }
    
    func deleteMediaList(deletingList: [String], deleteListener: @escaping (Int, [DevMediaDelResult]) -> Void) {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2003
        let payloadParam = ["fileIdList":deletingList] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) {[weak self] errCode, resutArray in
            log.i("deleteMediaList resutArray:\(resutArray)")
            deleteListener(errCode,(self?.getDeleteMediaResult(resutArray))!)
        }
        
    }
 
    func getMediaCoverData(imgUrl:String,cmdListener: @escaping (_ errCode:Int,_ imgUrl:String, _ result:Data) -> Void) {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2004
        let payloadParam = ["pic":imgUrl] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) { errCode, resultDic in
            if let fileContent = resultDic["fileContent"] as? String{
                if let decodedData = Data(base64Encoded: fileContent) {
                    cmdListener(errCode,"",decodedData)
//                    if let image = UIImage(data: decodedData) {
//                        log.i("转化成功")
//                        } else {
//                        log.i("转化失败")
//                    }
                } else {
                    log.e("解码失败")
                    cmdListener(errCode,"",Data())
                }
            }else{
                cmdListener(errCode,"",Data())
            }
            log.i("queryMediaCoverImage resutArray:\(resultDic)")
        }
        
    }
    
    func play(globalStartTime: UInt64, playSpeed: Int, playingCallListener: IPlayingCallbackListener)->Int {
        
        playStateListener = playingCallListener
        
        let curState = getPlayingState()
        playClock.setRunSpeed(playSpeed)
        playClock.stopWithProgress(TimeInterval(globalStartTime))
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2005
        let payloadParam = ["begin":globalStartTime,"rate":playSpeed] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) {[weak self] errCode, resultDic in
            if curState == .stopped{
                self?.startSDCardCall(errCode,resultDic)
            }
            log.i("play globalStartTime: \(resultDic)")
            
        }
        return ErrCode.XOK
        
    }

    func play(fileId: String, startPos: UInt64, playSpeed: Int, playingCallListener: IPlayingCallbackListener)->Int {
        
        log.i("play(fileId）send Msg:\(fileId) startPos:\(startPos)")
        
        playStateListener = playingCallListener
    
        let curState = getPlayingState()
        playClock.setRunSpeed(playSpeed)
        playClock.stopWithProgress(TimeInterval(startPos))

        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2006
        let payloadParam = ["id":fileId,"offset":startPos,"rate":playSpeed] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) {[weak self] errCode, resultDic in
            if curState == .stopped{
                log.i("play(fileId）receive Msg:\(resultDic)")
                self?.startSDCardCall(errCode,resultDic)
            }else{
                log.i("re play fileId:\(resultDic)")
                self?.playClock.setProgress(TimeInterval(startPos))
            }
        }
        return ErrCode.XOK
    }
    
    func stop() -> Int {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2007
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId] as [String : Any]
        sendGeneralStringData(paramDic, curTimestamp) { errCode, resutArray in
            if errCode == 0{
                CallListenerManager.sharedInstance.hunUpSDCard()
                
            }
            log.i("stop:\(resutArray)")
            
        }
        return ErrCode.XOK
    }
    
    func setPlayingSpeed(speed: Int) -> Int {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2008
        let payloadParam = ["rate":speed] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralStringData(paramDic, curTimestamp) {[weak self] errCode, resutArray in
            log.i("setPlayingSpeed:\(resutArray)")
            if errCode == ErrCode.XOK{
                self?.playClock.setRunSpeed(speed)
            }
            
        }
        return ErrCode.XOK
    }
    
    func pause() -> Int {
        
        if getPlayingState() != .playing{
            return ErrCode.XERR_BAD_STATE
        }
         
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2009
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId] as [String : Any]
        CallListenerManager.sharedInstance.pausingSDCardPlay()
        sendGeneralStringData(paramDic, curTimestamp) {[weak self] errCode, resutArray in
            log.i("pause:\(resutArray)")
            if errCode == ErrCode.XOK{
                self?.playClock.stop()
                CallListenerManager.sharedInstance.pausedSDCardPlay()
                self?.playStateListener?.onDevMediaPauseDone(fileId: "", errCode: ErrCode.XOK)
            }else{
                CallListenerManager.sharedInstance.resumedSDCardPlay()
                self?.playStateListener?.onDevMediaPauseDone(fileId: "", errCode: errCode)
            }
            
        }
        return ErrCode.XOK
    }
    
    func resume() -> Int {
        
        if getPlayingState() != .paused{
            return ErrCode.XERR_BAD_STATE
        }
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2010
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId] as [String : Any]
        CallListenerManager.sharedInstance.resumeingSDCardPlay()
        sendGeneralStringData(paramDic, curTimestamp) {[weak self] errCode, resutArray in
            log.i("resume:\(resutArray)")

            if errCode == ErrCode.XOK{
                self?.playClock.start()
                CallListenerManager.sharedInstance.resumedSDCardPlay()
                self?.playStateListener?.onDevMediaResumeDone(fileId: "", errCode: ErrCode.XOK)
            }else{
                CallListenerManager.sharedInstance.resumedSDCardPlay()
                self?.playStateListener?.onDevMediaResumeDone(fileId: "", errCode: errCode)
            }
            
        }
        return ErrCode.XOK
    }
    
    func DownloadFileList(filedIdList:[String], downloadFailList: @escaping (Int,[DevFileDownloadResult]) -> Void){
        
        let curTimestamp : UInt32 = getSequenceId()
        
        let commanId:Int = 2011
        let payloadParam = ["fileIdList":filedIdList] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
        sendGeneralDicData(paramDic, curTimestamp) {[weak self] errCode, resutArray in
            log.i("DownloadMediaList resutArray:\(resutArray)")
            downloadFailList(errCode,(self?.getDownloadMediaResult(resutArray))!)
        }
        
    }
    
    func setDisplayView(displayView: UIView?)->Int {

        self.peerDisplayView = displayView
        
        return ErrCode.XOK
    }
    
    func getPlayingProgress() -> UInt64 {
        let playTime = playClock.getProgress()
        log.i("getPlayingProgress:\(playTime)")
        return UInt64(playTime)
        
    }
    
    func getPlayingState() -> DevMediaStatus{
        
        guard let mediaMachine = getMediaStateMachine() else {
            log.e("getPlayingState: talkingKit is nil")
            return .stopped
        }
        return mediaMachine.currentState
    }
    
    func setAudioMute(mute:Bool,result:@escaping (Int,String)->Void){
        guard let talkingKit = getRtcTaklingKit() else {
            log.e("setAudioMute: talkingKit is nil")
            result(ErrCode.XERR_NOT_FOUND,"talkingKit is nil")
            return
        }
        DispatchQueue.main.async {
            talkingKit.mutePeerAudio(mute, cb: result)
        }
    }
 
}

extension IDevMediaManager{
    
    func sendGeneralDicData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, Dictionary<String, Any>) -> Void){
        
        guard let peer =  rtm.curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
        rtm.sendRawMessageDic(sequenceId: "\(sequenceId)", toPeer: peer, data: data, description: "\(sequenceId)",cb: cmdListener)
    }
    
    func sendGeneralStringData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, String) -> Void){
        
        guard let peer =  rtm.curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        rtm.sendStringMessage(sequenceId: "\(sequenceId)", toPeer: peer, message: jsonString, cb: cmdListener)
        
    }
    
    func getSequenceId()->UInt32{
        
        let curSequenceId : UInt32 = app.config.counter.increment()
        return curSequenceId
    }
    
    func getRtcTaklingKit()->AgoraTalkingEngine?{
        return CallListenerManager.sharedInstance.getCurrentSDcardTalkingEngine()
    }
    
    func getMediaStateMachine()->MediaStateMachine?{
        return CallListenerManager.sharedInstance.getCurrentSDCardCallMachine()
    }
}

extension IDevMediaManager{
    
    func startSDCardCall(_ errCode:Int, _ paramDic : Dictionary<String, Any>){
        
        guard errCode == ErrCode.XOK else{
            playStateListener?.onDevPlayingError(fileId: "", errCode: errCode)
            return
        }
        guard let cname = paramDic["cname"] as? String else{ return }
        guard let token = paramDic["token"] as? String else{ return }
        guard let uid = paramDic["uid"] as? UInt else{ return }
        guard let deviceUid = paramDic["device_uid"] as? UInt else{ return }
        
        let callSession = CallSession()
        callSession.cname = cname
        callSession.token = token
        callSession.uid = uid
        callSession.peerUid = deviceUid
        CallListenerManager.sharedInstance.startSDCardCall(dialParam: callSession,peerDisplayView:peerDisplayView) {[weak self] ackBack, sessionId, errCode in
            self?.handelCallAct(ackBack,errCode)
        } memberState: { MemberState, memList, sessionId in }

    }
    
    //处理连接设备返回
    func handelCallAct(_ act:MediaCallback, _ errorCode:Int ){
        
        if act == .onFirstFrame{
            playStateListener?.onDevMediaOpenDone(fileId: "", errCode: ErrCode.XOK)
            playClock.start()
        }else if act == .onStoped{//播放完成
            
            playClock.stopWithProgress(0)
            playStateListener?.onDevMediaPlayingDone(fileId: "")
        }else if act == .onError{
            
            playStateListener?.onDevPlayingError(fileId: "", errCode:errorCode)
        }else{
            
        }
    }
    
}

extension IDevMediaManager{
    
    func getDevMediaItemResult(_ dic:Dictionary<String, Any>)->[DevMediaItem]{
        guard let fileList = dic["fileList"] as? [Dictionary<String, Any>] else{
            return [DevMediaItem(mFileId: "", mStartTimestamp: 0, mStopTimestamp: 0, mType: 1, mEvent: 1, mImgUrl: "", mVideoUrl: "")]
        }
        var resultArray = [DevMediaItem]()
        for item in fileList{
            let medisItem = DevMediaItem(mFileId: item["id"] as? String ?? "", mStartTimestamp: item["start"] as? UInt64 ?? 0, mStopTimestamp: item["stop"] as? UInt64 ?? 0, mType: item["type"] as? Int ?? 0, mEvent: item["event"] as? Int ?? 0, mImgUrl: item["pic"] as? String ?? "", mVideoUrl: item["url"] as? String ?? "")
            resultArray.append(medisItem)
        }
        mediaItemArray.append(contentsOf: resultArray)
        return resultArray
    }
    
    func getDeleteMediaResult(_ dic:Dictionary<String, Any>)->[DevMediaDelResult]{
        guard let fileList = dic["deleteMediaList"] as? [Dictionary<String, Any>] else{
            return [DevMediaDelResult(mFileId: "", mErrCode: ErrCode.XERR_UNKNOWN)]
        }
        var resultArray = [DevMediaDelResult]()
        for item in fileList{
            let medisItem = DevMediaDelResult(mFileId: item["id"] as? String ?? "", mErrCode: item["error"] as? Int ?? 0)
            resultArray.append(medisItem)
        }
        return resultArray
    }
    
    func getDownloadMediaResult(_ dic:Dictionary<String, Any>)->[DevFileDownloadResult]{
        guard let fileList = dic["downloadFailList"] as? [Dictionary<String, Any>] else{
            return [DevFileDownloadResult(mFileId: "", mErrCode: ErrCode.XERR_UNKNOWN)]
        }
        var resultArray = [DevFileDownloadResult]()
        for item in fileList{
            let medisItem = DevFileDownloadResult(mFileId: item["id"] as? String ?? "", mErrCode: item["error"] as? Int ?? 0)
            resultArray.append(medisItem)
        }
        return resultArray
    }
    
    func getMeidaItemWithFileId(_ fileId : String)->DevMediaItem?{
        for item in mediaItemArray{
            if fileId == item.mFileId {
                return item
            }
        }
        return nil
    }
    
    func setStartPlayTime(){
        let fileSTime = curPlayItem?.mStartTimestamp ?? 0
        curStartTime =  String.dateTimeSpace(fileSTime)
    }
    
    
}
