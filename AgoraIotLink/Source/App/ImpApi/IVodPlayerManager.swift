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


//class IVodPlayerManager : IVodPlayerMgr{
//    
//    var player:IJKFFMoviePlayerController?
//    
//    typealias callActionAck = (_ errCode:Int,_ disPlayView:UIView)->Void
//    private var callAct:callActionAck = {errCode,disPlayView in log.w("IVodPlayerManager callAct callActionAck not inited")}
//    
//    
//    private lazy var playerContainerView:UIView = {
//        return UIView()
//    }()
//    
//    func open(mediaUrl: String, callback: @escaping (Int, UIView) -> Void) {
//        
//        callAct = callback
//        installObserver()
//        
//        var url:URL?
//        if mediaUrl.hasPrefix("http") || mediaUrl.hasPrefix("rtmp") {
//            url = URL(string: mediaUrl)
//        }
//        else {
//            url = URL(fileURLWithPath: mediaUrl)
//        }
//        
//        guard let url = url else {
//            callAct(ErrCode.XERR_INVALID_PARAM, self.player?.view ?? UIView())
//            return
//        }
//        
//        guard let options = IJKFFOptions.byDefault() else {
//            return
//        }
//        
//        self.player = IJKFFMoviePlayerController.init(contentURL: url, with: options)
//        self.player?.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
//        self.player?.scalingMode = .aspectFit
//        self.player?.shouldAutoplay = false;
//        
//        prepareToPlay()
//         
//    }
//
//    func close() {
//        destory()
//        self.player?.shutdown()
//    }
//    
//    func setDisplayView(_ displayView:UIView)->Int{
//        displayView.addSubview(self.player?.view ?? UIView())
//        self.player?.view.frame = displayView.bounds
//        return ErrCode.XOK
//    }
//    
//    func getPlayingProgress() -> Double {
//        let currentTime = self.player?.currentPlaybackTime ?? 0
//        let duration = self.player?.duration ?? 0
//        let progress = Double(currentTime/duration)
//        return progress
//    }
//    
//    func getPlayDuration() -> Double {
//        return self.player?.duration ?? 0
//    }
//    
//    func getCurrentPlaybackTime() -> Double {
//        return self.player?.currentPlaybackTime ?? 0
//    }
//    
//    func getPlayer()-> IJKFFMoviePlayerController?{
//        return self.player
//    }
//    
//    func prepareToPlay() {
//        self.player?.prepareToPlay()
//    }
//    
//    func play() {
//        self.player?.play()
//    }
//    
//    func pause() {
//        self.player?.pause()
//    }
//    
//    func stop() {
//        self.player?.stop()
//    }
//    
//    func seek(seekPos: Double){
//        self.player?.currentPlaybackTime = seekPos
//    }
//    
//    func installObserver(){
//        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
//    }
//    
//    @objc func mediaIsPreparedToPlayDidChange(notification:NSNotification){
//        log.i("ijk mediaIsPreparedToPlayDidChange")
//        callAct(ErrCode.XOK, self.player?.view ?? UIView())
//    }
//    
//    @objc func moviePlayBackDidFinish(notification:NSNotification){
//        log.i("ijk moviePlayBackDidFinish \(String(describing: notification.userInfo))")
//        let reason = (notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] ?? "0") as? IJKMPMovieFinishReason
//        guard let reason = reason else{
//            log.w("ijk unknown reason")
//            return
//        }
//        switch(reason){
//        case .playbackEnded:
//            log.i("ijk finished by playbackEnded")
//        case .playbackError:
//            log.i("ijk finished by playbackError")
//        case .userExited:
//            log.i("ijk finished by userExited")
//        @unknown default:
//            log.i("ijk finished by unknown")
//        }
//    }
//    
//    func destory(){
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
//    }
//  
//}



//class IVodPlayerManager : IVodPlayerMgr{
//
//
//    typealias callActionAck = (_ errCode:Int,_ disPlayView:UIView)->Void
//
//    private var callAct:callActionAck = {errCode,disPlayView in log.w("IVodPlayerManager callAct callActionAck not inited")}
//
//
//    lazy var player:SJVideoPlayer = {
//        let player = SJVideoPlayer()
//        player.defaultEdgeControlLayer.bottomAdapter .removeItem(forTag:SJEdgeControlLayerBottomItem_Full)
//        player.defaultEdgeControlLayer.bottomAdapter.removeAllItems()
//        player.defaultEdgeControlLayer.topAdapter.removeAllItems()
//        player.defaultEdgeControlLayer.centerAdapter.removeAllItems()
//        player.defaultEdgeControlLayer.leftAdapter.removeAllItems()
//        player.defaultEdgeControlLayer.rightAdapter.removeAllItems()
//        // 禁用手势
//        player.gestureRecognizerShouldTrigger = { player,type,location in
//            return false
//        }
//
//        return player
//    }()
//
//    private lazy var playerContainerView:UIView = {
//        return UIView()
//    }()
//
//    func open(mediaUrl: String, callback: @escaping (Int, UIView) -> Void) {
//        callAct = callback
//
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
//
//        player.autoplayWhenSetNewAsset = true
//        player.pause()
//
//        callAct(ErrCode.XOK, player.view)
//
//    }
//
//    func close() {
//        player.stop()
//    }
//
//    func setDisplayView(_ displayView:UIView, _ frame:CGRect)->Int{
//        displayView.addSubview(player.view)
//        player.view.frame = frame
//        return ErrCode.XOK
//    }
//
//    func getPlayingProgress() -> Double {
//        let currentTime = player.currentTime
//        let duration = player.duration
//        let progress = currentTime/duration
//        print("currentTime:\(currentTime),duration:\(duration)")
//        return progress
//    }
//
//    func getPlayDuration() -> Double{
//        return player.duration
//    }
//
//    func play() {
//        player.play()
//    }
//
//    func pause() {
//        player.pauseForUser()
//    }
//
//    func stop() {
//        player.stop()
//    }
//
//    func seek(seekPos:Double)->Double {
//        player.seek(toTime: TimeInterval(seekPos))
//        return 0
//    }
//
//    func setRate(rate:Float){
//        player.rate = rate
//    }
//
//
//
//}
