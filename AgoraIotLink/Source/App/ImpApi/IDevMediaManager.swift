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
        
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2002
        let payloadParam = ["fileId":queryParam.mFileId, "beginTime": queryParam.mBeginTimestamp,"endTime": queryParam.mEndTimestamp, "pageIndex": queryParam.mPageIndex, "pageSize": queryParam.mPageSize] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
    }
    
    func deleteMediaList(deletingList: [String], deleteListener: @escaping (Int, [DevMediaDelResult]) -> Void) {
        
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2003
        let payloadParam = ["fileIdList":deletingList] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
    }
    
    func setDisplayView(peerView: UIView?) {
        
    }
    
    func queryMediaCoverImage(imgUrl:String,cmdListener: @escaping (_ errCode:Int,_ result:Data) -> Void) {
        
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2004
        let payloadParam = ["imgUrl":imgUrl] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
    }
    
    func play(globalStartTime: UInt64, playingCallListener: IPlayingCallbackListener) {
        
        playStateListener = playingCallListener
        playingCallListener.onDevMediaOpenDone(mediaUrl: "ceshi123456", errCode: ErrCode.XOK)
        
        //todo:
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2005
        let payloadParam = ["globalStartTime":globalStartTime,"rate":1,"cname":""] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
        
    }
    
    func play(fileId: UInt64, startPos: UInt64, playSpeed: Int, playingCallListener: IPlayingCallbackListener) {
        playStateListener = playingCallListener
        
        //todo:
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2006
        let payloadParam = ["fileId":fileId,"startTime":startPos,"rate":playSpeed,"cname":""] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
    }
    
    func stop() -> Int {
        
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2007
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId] as [String : Any]
        
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
    
    func setPlayingSpeed(speed: Int) -> Int {
        
        let curTimestamp:Int = String.dateTimeRounded()
        let commanId:Int = 2008
        let payloadParam = ["rate":speed] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
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
