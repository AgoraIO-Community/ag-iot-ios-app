//
//  MediaPlayer.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/22.
//

import Foundation
import UIKit
import IJKMediaFramework
import AgoraIotLink
public class MediaPlayer: UIView {
    public var url:URL?
    var player:IJKFFMoviePlayerController?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initCommon()
    }
    
    @objc func loadStateDidChange(notification:NSNotification){
        log.i("ijk loadStateDidChange")
        guard let player = self.player else{
            return
        }
        let loadState = player.loadState
        if((loadState.rawValue & IJKMPMovieLoadState.playthroughOK.rawValue) != 0){
            log.i("ijk load state playthroughOK")
        }
        else if((loadState.rawValue & IJKMPMovieLoadState.stalled.rawValue) != 0){
            log.i("ijk load state stalled")
        }
        else{
            log.i("ijk load state \(loadState.rawValue)")
        }
    }
    @objc func moviePlayBackDidFinish(notification:NSNotification){
        log.i("ijk moviePlayBackDidFinish \(notification.userInfo)")
        let reason = (notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] ?? "0") as? IJKMPMovieFinishReason
        guard let reason = reason else{
            log.w("ijk unknown reason")
            return
        }
        switch(reason){
        case .playbackEnded:
            log.i("ijk finished by playbackEnded")
        case .playbackError:
            log.i("ijk finished by playbackError")
        case .userExited:
            log.i("ijk finished by userExited")
        @unknown default:
            log.i("ijk finished by unknown")
        }
    }
    @objc func mediaIsPreparedToPlayDidChange(notification:NSNotification){
        log.i("ijk mediaIsPreparedToPlayDidChange")
    }
    @objc func moviePlayBackStateDidChange(notification:NSNotification){
        guard let player = player else {
            return
        }
        log.i("ijk moviePlayBackStateDidChange:\(player.playbackState.rawValue)")
        switch(player.playbackState){
        case .stopped:
            log.i("ijk state stopped")
        case .playing:
            log.i("ijk state playing")
        case .paused:
            log.i("ijk state paused")
        case .interrupted:
            log.i("ijk state interrupted")
        case .seekingForward:
            log.i("ijk state seekingForward")
        case .seekingBackward:
            log.i("ijk state seekingBackward")
        @unknown default:
            log.i("ijk state unknown")
        }
    }
    
    func initCommon() {
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        IJKFFMoviePlayerController.setLogReport(false)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_WARN)
    }
    
    func installObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.moviePlayBackDidFinish), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.mediaIsPreparedToPlayDidChange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.moviePlayBackStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func play(url:String) {
        if url.hasPrefix("http") || url.hasPrefix("rtmp") {
            self.url = URL.init(string: url)
        }
        else {
            self.url = URL.init(fileURLWithPath: url)
        }
        self.toPlay()
    }
    
    public func play(alarm:IotAlarm) {
        Utils.loadAlertVideoUrl(alarm.deviceId, alarm.beginTime) { ec, msg, url in
            if(url != nil){
                self.url = URL.init(string: url!)
                self.toPlay()
            }
            else{
                log.w("demo load video url failed,use test m3u8")
                self.url = URL.init(string: "https://aios-personalized-wuw.oss-cn-beijing.aliyuncs.com/ts_muxer.m3u8")
                self.toPlay()
            }
        }
    }
    
    func toPlay() {
        
//
//        // 开启硬解码
//        options.setPlayerOptionValue("1", forKey: "videotoolbox")
//
//        // 帧速率(fps) （可以改，确认非标准桢率会导致音画不同步，所以只能设定为15或者29.97）
//        options.setPlayerOptionIntValue(Int64(29.94), forKey: "r")
//
//        // -vol——设置音量大小，256为标准音量。（要设置成两倍音量时则输入512，依此类推
//        options.setPlayerOptionIntValue(Int64(256), forKey: "vol")
//
//        // 最大fps
//        options.setPlayerOptionIntValue(Int64(60), forKey: "max-fps")
//
//        // 跳帧开关
//        options.setPlayerOptionIntValue(Int64(0), forKey: "framedrop")
//
//        // 指定最大宽度
//        options.setPlayerOptionIntValue(Int64(UIScreen.main.bounds.width), forKey: "videotoolbox-max-frame-width")
//
//        // 自动转屏开关
//        options.setPlayerOptionIntValue(Int64(0), forKey: "auto_convert")
//
//        // 重连次数
//        options.setFormatOptionIntValue(Int64(1), forKey: "reconnect")
//
//        // 超时时间，timeout参数只对http设置有效，若果你用rtmp设置timeout，ijkplayer内部会忽略timeout参数。rtmp的timeout参数含义和http的不一样。
//        options.setFormatOptionIntValue(Int64(30 * 1000 * 1000), forKey: "timeout")
        
//        options?.setValue("ijklas", forKey: "iformat")
//        options?.setValue("ijklas", forKey: "iformat")
//        options?.setValue("ijklas", forKey: "iformat")
        guard let url = self.url else {
//            let imageView = UIImageView(image:UIImage(named:"msg_preview_placeholder"))
//            imageView.contentMode = .scaleAspectFill
//            self.addSubview(imageView)
//            imageView.snp.makeConstraints { make in
//                make.center.equalTo(self)
//            }
            return
        }
        
        guard let options = IJKFFOptions.byDefault() else {
            return
        }
        
        stop();

        log.i("demo to play \(url)")
        self.player = IJKFFMoviePlayerController.init(contentURL: url, with: options)
        
        self.player?.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        let bounds = self.bounds
        self.player?.view.frame = self.bounds
        self.player?.scalingMode = .aspectFit
        self.player?.shouldAutoplay = true;
        self.autoresizesSubviews = true
        if let view = self.player?.view {
            self.backgroundColor = .clear
            self.addSubview(view)
            self.installObserver()
            self.player?.prepareToPlay()
        }
    }
    
    public func setPicture(uiImage:UIImage){
        
    }
    
    public func prepareToPlay() {
        self.player?.prepareToPlay()
    }
    
    public func pause() {
        self.player?.pause()
    }
    
    public func resume(){
        self.player?.play()
    }
    
    public var duration:TimeInterval{
        get{return self.player?.duration ?? 0}
    }
    
    public var currentTime:TimeInterval{
        get{return self.player?.currentPlaybackTime ?? 0}
        set{self.player?.currentPlaybackTime = newValue}
    }
    
    public var isPlaying:Bool{
        return self.player?.isPlaying() ?? false
    }
    
    public func stop(){
        self.player?.stop()
        self.player?.shutdown()
        self.player?.view.removeFromSuperview()
    }
    
    public func download(){
        self.player
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
