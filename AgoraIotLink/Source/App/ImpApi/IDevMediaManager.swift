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
    
    init(app:Application,sessionId:String){
        self.app = app
        self.curSessionId = sessionId
    }
    
    deinit {
        log.i("IDevMediaManager 销毁了")
    }
    
    func queryMediaList(queryParam: QueryParam, queryListener: @escaping (Int, [DevMediaItem]) -> Void) {
        
    }
    
    func deleteMediaList(deletingList: [UInt64], deleteListener: @escaping (Int, [DevMediaDelResult]) -> Void) {
        
    }
    
    func setDisplayView(peerView: UIView?) {
        
    }
    
    func stop() -> Int {
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
