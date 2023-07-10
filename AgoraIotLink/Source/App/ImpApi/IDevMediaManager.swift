//
//  IDevMediaManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation


class IDevMediaManager : IDevMediaMgr{
    
    
    private var app:Application
    private var curSessionId:String //当前sessionId
    private var rtm:RtmEngine
    
    private var playStateListener:IPlayingCallbackListener? = nil
    
    init(app:Application,rtm:RtmEngine,sessionId:String){
        self.app = app
        self.rtm = rtm
        self.curSessionId = sessionId
    }
    
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
 
    func queryMediaCoverImage(imgUrl:String,cmdListener: @escaping (_ errCode:Int,_ result:Data) -> Void) {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2004
        let payloadParam = ["pic":imgUrl] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) { errCode, resultDic in
            if let fileContent = resultDic["fileContent"] as? String{
                if let decodedData = Data(base64Encoded: fileContent) {
                    cmdListener(errCode,decodedData)
//                    if let image = UIImage(data: decodedData) {
//                        log.i("转化成功")
//                        } else {
//                        log.i("转化失败")
//                    }
                } else {
                    log.e("解码失败")
                }
            }
            log.i("queryMediaCoverImage resutArray:\(resultDic)")
            cmdListener(errCode,Data())
        }
        
    }
    
    func play(globalStartTime: UInt64, playingCallListener: IPlayingCallbackListener)->Int {
        
        playStateListener = playingCallListener
//        playingCallListener.onDevMediaOpenDone(mediaUrl: "ceshi123456", errCode: ErrCode.XOK)
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2005
        let payloadParam = ["begin":globalStartTime,"rate":1] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) { errCode, resultDic in
            guard let cname = resultDic["cname"] as? String else{
                return
            }
            log.i("play globalStartTime: cname:\(cname) \(resultDic)")
            
        }
        return ErrCode.XOK
        
    }
    
    func play(fileId: String, startPos: UInt64, playSpeed: Int, playingCallListener: IPlayingCallbackListener)->Int {
        playStateListener = playingCallListener
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2006
        let payloadParam = ["id":fileId,"offset":startPos,"rate":playSpeed] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralDicData(paramDic, curTimestamp) { errCode, resutArray in
            log.i("play fileId:\(resutArray)")
            
        }
        return ErrCode.XOK
    }
    
    func stop() -> Int {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2007
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId] as [String : Any]
        sendGeneralStringData(paramDic, curTimestamp) { errCode, resutArray in
            log.i("stop:\(resutArray)")
            
        }
        return ErrCode.XOK
    }
    
    func setPlayingSpeed(speed: Int) -> Int {
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 2008
        let payloadParam = ["rate":speed] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralStringData(paramDic, curTimestamp) { errCode, resutArray in
            log.i("setPlayingSpeed:\(resutArray)")
            
        }
        return ErrCode.XOK
    }
    
    func setDisplayView(peerView: UIView?)->Int {
        return ErrCode.XOK
    }
    
    
    func pause() -> Int {
        return ErrCode.XOK
    }
    
    func resume() -> Int {
        return ErrCode.XOK
    }
    
    func seek(seekPos: UInt64) -> Int {
        return ErrCode.XOK
    }
    
    func getPlayingProgress() -> UInt64 {
        //todo
        return 000000
    }
    
    func getPlayingState() -> Int {
        return ErrCode.XOK
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
//        rtm.sendStringMessage(sequenceId: "\(sequenceId)", toPeer: peer, message: jsonString, cb: cmdListener)
        rtm.sendRawMessageDic(sequenceId: "\(sequenceId)", toPeer: peer, data: data, description: "\(sequenceId)",cb: cmdListener)
    }
    
    func sendGeneralStringData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, String) -> Void){
        
        guard let peer =  rtm.curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
        rtm.sendStringMessage(sequenceId: "\(sequenceId)", toPeer: peer, message: jsonString, cb: cmdListener)
        
    }
    
    func getSequenceId()->UInt32{
        
        let curSequenceId : UInt32 = app.config.counter.increment()
        return curSequenceId
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
    
}
