//
//  IVodPlayerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation
//import IJKMediaFramework
//import SJBaseVideoPlayer
//import SJVideoPlayer

class IVodPlayerManager : IVodPlayerMgr{
    
    
    typealias callActionAck = (_ errCode:Int,_ disPlayView:UIView)->Void
    
    private var callAct:callActionAck = {errCode,disPlayView in log.w("IVodPlayerManager callAct callActionAck not inited")}
    
    
//    lazy var player:SJVideoPlayer = {
//        let player = SJVideoPlayer()
//        player.defaultEdgeControlLayer.bottomAdapter .removeItem(forTag:SJEdgeControlLayerBottomItem_Full)
//        player.defaultEdgeControlLayer.bottomAdapter.removeAllItems()
//        player.defaultEdgeControlLayer.topAdapter.removeAllItems()
//
//        return player
//    }()
    
    private lazy var playerContainerView:UIView = {
        return UIView()
    }()
    
    func open(mediaUrl: String, callback: @escaping (Int, UIView) -> Void) {
        callAct = callback
        
//        let ijkVC : SJIJKMediaPlaybackController = SJIJKMediaPlaybackController()
//        let options = IJKFFOptions.byDefault()
//        ijkVC.options = options
//        player.playbackController = ijkVC
//
//        guard let url = URL(string: mediaUrl) else {
//            callAct(ErrCode.XERR_INVALID_PARAM, player.view)
//            return
//        }
//        player.urlAsset = SJVideoPlayerURLAsset(url: url)
//        callAct(ErrCode.XOK, player.view)
        
    }
    
    func close() {
        
    }
    
    func setDisplayView(_ displayView:UIView, _ frame:CGRect)->Int{
//        displayView.addSubview(player.view)
//        player.view.frame = frame
        return ErrCode.XOK
    }
    
    func getPlayingProgress() -> UInt64 {
        return 0
    }
    
    func play() {
//        player.play()
    }
    
    func pause() {
//        player.pauseForUser()
    }
    
    func stop() {
//        player.stop()
    }
    
    func seek(seekPos: UInt64) -> UInt64 {
        return 0
    }
    
    
    
}
