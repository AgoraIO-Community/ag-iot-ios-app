//
//  RtcEngine2.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/5/30.
//
//
import Foundation
import UIKit
import AgoraRtcKit


enum RtcPeerAction{
    case Enter
    case Leave
    case AudioReady
    case VideoReady
}

struct RtcSetting{
    var dimension = AgoraVideoDimension640x360
    var frameRate = AgoraVideoFrameRate.fps15
    var bitRate = AgoraVideoBitrateStandard
    var orientationMode:AgoraVideoOutputOrientationMode = .adaptative
    var renderMode:AgoraVideoRenderMode = .adaptive
    var audioType = "" //G722，G711A，G711U
    var audioSampleRate = ""; //16000,8000
    
    var logFilePath = ""
    var publishAudio = true ///< 通话时是否推流本地音频
    var publishVideo = true ///< 通话时是否推流本地视频
    var subscribeAudio = true ///< 通话时是否订阅对端音频
    var subscribeVideo = true ///< 通话时是否订阅对端视频
}

class RtcEngine : NSObject{
    private var _setting:RtcSetting = RtcSetting()
    private var state:Int = RtcEngine.IDLED
    private var engine:AgoraRtcEngineKit? = nil
    private var peerEntered:Bool = false
    private var isSnapShoting : HOPAtomicBoolean = HOPAtomicBoolean(value: false)
    private var _onImageCaptured:(Int,String,UIImage?)->Void = {ec,msg,img in}
    private var _networkStatus : RtcNetworkStatus = RtcNetworkStatus()
    
    static private let IDLED = 0
    static private let CREATED = 1
    static private let ENTERED = 2
    
    func create(appId:String,setting:RtcSetting)->Bool{
        _setting = setting
        if(state != RtcEngine.IDLED){
            log.e("rtc state : \(state) error for create()")
            return true
        }
        log.i("""
                rtc is creating,   version:  \(AgoraRtcEngineKit.getSdkVersion())
                                 dimension:  \(_setting.dimension)
                                 frameRate:  \(_setting.frameRate)
                                   bitRate:  \(_setting.bitRate)
                           orientationMode:  \(_setting.orientationMode)
               """)
        engine = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        guard let rtc = engine else {
            log.e("rtc create engine failed");
            return false
        }
        
//        rtc.setParameters("{\"che.hardware_encoding\": 0}");
//        rtc.setParameters("{\"che.hardware_decoding\": 0}");
        
        if(setting.logFilePath != ""){
            //todo:日志等级暂设debug，原为info
//            rtc.setLogFilter(AgoraLogFilter.debug.rawValue)
            rtc.setParameters("{\"rtc.enable_debug_log\":true}");
//            rtc.setLogFilter(AgoraLogFilter.info.rawValue)
            rtc.setLogFile(setting.logFilePath)
        }
        else{
            //rtc.setLogFilter(AgoraLogFilter.error.rawValue)
        }

        rtc.setClientRole(.broadcaster)
        rtc.setChannelProfile(.liveBroadcasting)
        rtc.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(
            size:setting.dimension,
            frameRate: setting.frameRate,
            bitrate: setting.bitRate,
            orientationMode: setting.orientationMode, mirrorMode: .auto
        ))
        //rtc.setVideoDataFrame(self)
        rtc.setVideoFrameDelegate(self)
        state = RtcEngine.CREATED
        peerEntered = false
        log.i("rtc created engine")
        return true
    }
    private var  _onEnterChannel : TimeCallback<(TaskResult,String)>? = nil
    private var  _onPeerAction : (RtcPeerAction,UInt)->Void = {b,u in}
    private var  _memberState : (MemberState,[UInt])->Void = {s,a in }
    func enterChannel(uid:UInt,token:String, name:String,info:String?,cb:@escaping(TaskResult,String)->Void){
        if(state != RtcEngine.CREATED){
            log.e("rtc state : \(state) error for enterChannel()")
            cb(.Fail,"rtc state: \(state) error for enter")
            return
        }
        guard let rtc = engine else{
            log.e("rtc engine is nil")
            cb(.Fail,"rtc engine if nil")
            return
        }
        let option:AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        //todo:4.0.0版本调用
        option.autoSubscribeAudio = AgoraRtcBoolOptional.of(_setting.subscribeAudio)
        option.autoSubscribeVideo = AgoraRtcBoolOptional.of(_setting.subscribeVideo)
//        option.autoSubscribeAudio = _setting.subscribeAudio
//        option.autoSubscribeVideo = _setting.subscribeVideo
        //option.audiotr = AgoraRtcBoolOptional.of(true)
        //option.publishCameraTrack = AgoraRtcBoolOptional.of(false)
        
        rtc.enableAudio()
        rtc.enableVideo()
        rtc.setEnableSpeakerphone(true)
//        rtc.setAudioSessionOperationRestriction(.setCategory)//SDK 对AudioSession的操作权限，解决门铃控制中心播放告警消息没有声音的问题
        rtc.setClientRole(.broadcaster)
        rtc.setChannelProfile(.liveBroadcasting)
        
        muteLocalVideo(_localVideoMute != nil ? _localVideoMute! : !_setting.publishVideo, cb: {ec,msg in})
        muteLocalAudio(_localAudioMute != nil ? _localAudioMute! : !_setting.publishAudio, cb: {ec,msg in})
        
        if(_peerVideoMute != nil){
            mutePeerVideo(_peerVideoMute!, cb: {ec,msg in})
        }
        
        if(_peerAudioMute != nil){
            mutePeerAudio(_peerAudioMute!, cb: {ec,msg in})
        }
        
        if(_audioEffect != nil){
            setAudioEffect(_audioEffect!, cb: {ec,msg in})
        }

        var cfg = "{\"che.audio.input_sample_rate\":" + _setting.audioSampleRate + "}"
        rtc.setParameters(cfg)

        var type = "";
        if(_setting.audioType == "G722"){
            type = "9"
        }
        else if(_setting.audioType == "G711U"){
            type = "0"
        }
        else if(_setting.audioType == "G711A"){
            type = "8"
        }

        if(type != ""){
            cfg = "{\"che.audio.custom_payload_type\":" + type + "}"
            rtc.setParameters(cfg)
        }

        //rtc.record
        //rtc.setAudioProfile(AgoraAudioProfile.default, scenario: .iot)
        log.i("""
                 rtc try enterChannel: '\(name)' for: uid(\(uid))
                            audioType: \(_setting.audioType)
                           sampleRate: \(_setting.audioSampleRate)
                           localAudio: \(String(describing: _localAudioMute == nil ? _setting.publishAudio : _localAudioMute))
                           localVideo: \(String(describing: _localVideoMute == nil ? _setting.publishVideo : _localVideoMute))
                          remoteAudio: \(String(describing: _peerAudioMute))
                          remoteVideo: \(String(describing: _peerVideoMute))
                 """)
        
        let ret = rtc.joinChannel(byToken: token, channelId: name, uid: uid, mediaOptions: option)
        if(ret != 0){
            log.e("rtc enterChannel:\(String(describing: ret))")
            cb(.Fail,"join channel fail")
        }
        _onEnterChannel = TimeCallback<(TaskResult,String)>(cb: cb)
        _onEnterChannel?.schedule(time: 10, timeout: {
            log.e("rtc join channel timeout")
            cb(.Fail,"join channel timeout")
        })
        peerEntered = false
    }
    
    func setupLocalView(localView:UIView?,uid:UInt)->Int{
        log.i("rtc is setting up local canvas")
        guard let rtc = engine else{
            log.e("rtc engine is nil")
            return ErrCode.XERR_BAD_STATE
        }
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.renderMode = _setting.renderMode
        canvas.view = localView
        
        let ret = rtc.setupLocalVideo(canvas)
        if(ret != 0){
            log.e("rtc setupLocalView failed:\(String(describing: ret))")
        }
        return ret == 0 ? ErrCode.XOK  : ErrCode.XERR_API_RET_FAIL
    }
    
    func setupRemoteView(peerView:UIView?,uid:UInt)->Int{
        log.i("rtc is setting up remote canvas:\(uid) \(_setting.renderMode.rawValue) \(String(describing: peerView))")
        guard let rtc = engine else{
            log.e("rtc engine is nil when setupRemoteView")
            return ErrCode.XERR_BAD_STATE
        }
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.renderMode = _setting.renderMode
        canvas.view = peerView
        
        let ret = rtc.setupRemoteVideo(canvas)
        if(ret != 0){
            log.e("rtc setupRemoteView uid:\(uid) view:\(peerView != nil ? "not nil" : "nil") failed:\(String(describing: ret))")
        }
        return ret == 0 ? ErrCode.XOK  : ErrCode.XERR_API_RET_FAIL
    }
    
    private var _localVideoMute:Bool? = nil
    func muteLocalVideo(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute local video" : "unmute local video"
        if(state == RtcEngine.IDLED){
            _localVideoMute = mute
            log.i("rtc state : \(state),lazy set:\(mute) for muteLocalVideo()")
            cb(ErrCode.XOK,op + " succ")
            return
        }
        guard let engine = engine else {
            log.e("rtc engine is nil")
            cb(ErrCode.XOK,op + " fail")
            return
        }
        var ret = engine.enableLocalVideo(!mute)
        if(ret != 0){
            log.w("rtc enableLocalVideo(\(!mute)) failed:\(String(ret))")
        }
        
        ret = engine.muteLocalVideoStream(mute)
        if(ret != 0){
            log.w("rtc muteLocalVideo(\(mute)) faile:\(String(ret))")
        }
        _localVideoMute = nil
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    private var _localAudioMute:Bool? = nil
    func muteLocalAudio(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute local audio" : "unmute local audio"
        if(state == RtcEngine.IDLED){
            _localAudioMute = mute
            log.i("rtc state : \(state),lazy set:\(mute) for muteLocalAudio()")
            cb(ErrCode.XOK,op + " succ")
            return
        }
        guard let engine = engine else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
//        below api will trigger codec error,so comment out this code
//        var ret = 0;//engine.enableLocalAudio(!mute)
//        if(ret != 0){
//            log.w("rtc enableLocalAudio(\(!mute)) failed:\(String(ret))")
//        }
        engine.enableLocalAudio(!mute) //关闭本地音频采集，解决rtc通话中，其他播放器播放视频没有声音问题
        let ret = engine.muteLocalAudioStream(mute)
        if(ret != 0){
            log.w("rtc muteLocalAudio(\(mute)) faile:\(String(ret))")
        }
        
        _localAudioMute = nil
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    private var _peerVideoMute:Bool? = nil
    func mutePeerVideo(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute peer video" : "unmute peer video"
        if(state == RtcEngine.IDLED){
            _peerVideoMute = mute
            log.i("rtc state : \(state),lazy set:\(mute) for mutePeerVideo()")
            cb(ErrCode.XOK,op + " succ")
            return
        }
        guard let engine = engine else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        let ret = engine.muteAllRemoteVideoStreams(mute)
        if(ret != 0){
            log.w("rtc mutePeerVideo(\(mute)) faile:\(ret)")
        }
        _peerVideoMute = nil
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    private var _peerAudioMute:Bool? = nil
    func mutePeerAudio(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute peer audio" : "unmuete peer audio"
        if(state == RtcEngine.IDLED){
            _peerAudioMute = mute
            log.i("rtc state : \(state),lazy set:\(mute) for mutePeerAudio()")
            cb(ErrCode.XOK,op + " succ")
            return
        }
        guard let engine = engine else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }

        let ret = engine.muteAllRemoteAudioStreams(mute)
        if(ret != 0){
            log.w("rtc mutePeerAudio(\(mute)) faile:\(ret)")
        }
        _peerAudioMute = nil
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    private var _audioEffect:AudioEffectId? = nil
    func setAudioEffect(_ effectId:AudioEffectId,cb:@escaping (Int,String)->Void){
        if(state == RtcEngine.IDLED){
            _audioEffect = effectId
            log.i("rtc state : \(state),lazy set:\(effectId) for setAudioEffect()")
            cb(ErrCode.XOK,"switch audio effect succ")
            return
        }
        guard let engine = engine else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"switch audio effect fali")
            return
        }
        
        var preset: AgoraAudioEffectPreset
        switch effectId {
        case .NORMAL:
            preset = .off
        case .OLDMAN:
            preset = .voiceChangerEffectOldMan
        case .BABYBOY:
            preset = .voiceChangerEffectBoy
        case .BABYGIRL:
            preset = .voiceChangerEffectGirl
        case .ZHUBAJIE:
            preset = .voiceChangerEffectPigKin
        case .ETHEREAL:
            preset = .roomAcousEthereal
        case .HULK:
            preset = .voiceChangerEffectHulk
        }
        let ret = engine.setAudioEffectPreset(preset)
        _audioEffect = nil
        ret == 0 ? cb(ErrCode.XOK,"switch audio effect succ") : cb(ErrCode.XERR_UNKNOWN,"switch audio effect fail:" + String(ret))
    }
    
    func startRecord(result: @escaping (Int, String) -> Void){
//        _onAudioFrame = onAudioFame
//        _onVideoFrame = onVideoFrame
        result(ErrCode.XOK,"")
    }

    func stopRecord(result: @escaping (Int, String) -> Void){
//        _onAudioFrame = nil
//        _onVideoFrame = nil
        result(ErrCode.XOK,"")
    }
    
    func setVolume(_ vol: Int,cb:@escaping (Int,String)->Void){
        let ret = -1 //engine?.(vol)
        return ret == 0 ? cb(ErrCode.XOK,"unimplemented") : cb(ErrCode.XERR_UNSUPPORTED,"unimplemented")
    }
    
    private func resetNetStatus(){
        _networkStatus.isBusy              = false //是否在工作中（从开始呼叫到结束呼叫）
        _networkStatus.totalDuration       = 0
        _networkStatus.txBytes             = 0
        _networkStatus.rxBytes             = 0
        _networkStatus.txKBitRate          = 0
        _networkStatus.txAudioBytes        = 0
        _networkStatus.rxAudioBytes        = 0
        _networkStatus.txVideoBytes        = 0
        _networkStatus.rxVideoBytes        = 0
        _networkStatus.rxKBitRate          = 0
        _networkStatus.txAudioKBitRate     = 0
        _networkStatus.rxAudioKBitRate     = 0
        _networkStatus.txVideoKBitRate     = 0
        _networkStatus.rxVideoKBitRate     = 0
        _networkStatus.lastmileDelay       = 0
        _networkStatus.cpuTotalUsage       = 0
        _networkStatus.cpuAppUsage         = 0
        _networkStatus.users               = 0
        _networkStatus.connectTimeMs       = 0
        _networkStatus.txPacketLossRate    = 0
        _networkStatus.rxPacketLossRate    = 0
        _networkStatus.memoryAppUsageRatio = 0
        _networkStatus.memoryTotalUsageRatio = 0
        _networkStatus.memoryAppUsageInKbytes = 0
    }
    
    func createAndEnter(appId:String,setting:RtcSetting,uid:UInt,name:String,token:String, info:String?,cb:@escaping (TaskResult,String)->Void,peerAction:@escaping(RtcPeerAction,UInt)->Void,memberState:@escaping(MemberState,[UInt])->Void){
        _onEnterChannel?.invalidate()
        _networkStatus.isBusy = true
        if(!create(appId: appId, setting: setting)){
            log.w("rtc create engine error when createAndEnter")
            cb(.Fail,"create rtc fail")
            return
        }
        _onPeerAction = peerAction
        _memberState = memberState
        enterChannel(uid:uid,token:token, name: name,info: info,cb:cb)
    }
    
    func leaveAndDestroy(cb:@escaping (Bool)->Void){
        self.resetNetStatus()
        _onPeerAction = {b,u in}
        _memberState = {s,a in}
        log.i("rtc leaveAndDestroy when state:\(state)")
        if(state == RtcEngine.ENTERED){
            let cbLeave = {(b:Bool) in
                if(!b){
                    log.w("rtc leave channel error when leaveAndDestroy")
                }
                self.destroy()
                cb(b)
            }
            leaveChannel(cb:cbLeave)
        }
        else if(state == RtcEngine.CREATED){
            _onEnterChannel?.invoke(args:(.Abort,"abort joining channel"))
            destroy()
            cb(true)
        }
        else{
            cb(true)
        }
    }
    
    func setDefaultAudioRouteToSpeakerphone(defaultToSpeaker:Bool,cb:@escaping (Int,String)->Void){
//        let ret = engine?.setDefaultAudioRouteToSpeakerphone(defaultToSpeaker)
//        ret == 0 ? cb(ErrCode.XOK,"操作成功") : cb(ErrCode.XERR_UNKNOWN,engine == nil ? ("Rtc未初始化:" + String(state)) : ("操作失败:" + String(ret!)))
    }
    
    var  _onLeaveChannel : (Bool)->Void = {b in}
    func leaveChannel(cb:@escaping (Bool)->Void){
        log.i("rtc try leaveChannel ...")
        if(state != RtcEngine.ENTERED){
            log.e("rtc state : \(state) error for enterChannel()")
            cb(false)
            return
        }
        guard let rtc = engine else{
            log.e("rtc engine is nil")
            cb(false)
            return
        }
        let ret = rtc.leaveChannel(nil)
        if(ret != 0){
            log.e("leaveChannel:\(String(describing: ret))")
            cb(false)
        }
        else{
            _onLeaveChannel = cb
        }
        peerEntered = false
    }
    
    func destroy()->Void{
        log.i("rtc is destroying()")
        if(engine == nil){
            log.e("rtc engine is nil")
            return
        }
        if(state != RtcEngine.CREATED){
            log.e("rtc state:\(state) not correct")
            return
        }
        AgoraRtcEngineKit.destroy()
        state = RtcEngine.IDLED
        peerEntered = false
    }
    
    func capturePeerVideoFrame(cb:@escaping(Int,String,UIImage?)->Void){
        log.i("rtc try capturePeerVideoFrame ...")
        if(state != RtcEngine.ENTERED){
            log.e("rtc state : \(state) error for capturePeerVideoFrame()")
            cb(ErrCode.XERR_BAD_STATE,"rtc state error",nil)
            return
        }
        if(!peerEntered){
            log.w("rtc peer not entered for capture")
            cb(ErrCode.XERR_BAD_STATE,"rtc peer not joined",nil)
            return
        }
        self._onImageCaptured = cb
        isSnapShoting.setValue(true)
    }
    
    func getNetworkStatus()->RtcNetworkStatus{
        return _networkStatus
    }
}

extension RtcEngine: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        log.w("rtc didOccurWarning:\(warningCode.rawValue)")
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        log.e("rtc didOccurError:\(errorCode.rawValue)")
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        log.i("rtc didJoinChannel \(uid)")
        state = RtcEngine.ENTERED
        _onEnterChannel?.invoke(args:(.Succ,"join channel succ"))
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith status:AgoraChannelStats){
        log.i("rtc didLeaveChannelWith")
        state = RtcEngine.CREATED
        _onLeaveChannel(true)
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        log.i("rtc didJoinedOfUid \(uid)")
        peerEntered = true
        _onPeerAction(.Enter,uid)
        _memberState(.Enter,[uid])
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        log.i("rtc didOfflineOfUid \(uid)")
        peerEntered = false
        _onPeerAction(.Leave,uid)
        _memberState(.Leave,[uid])
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        log.i("rtc firstRemoteVideoFrameOfUid first video frame rendered \(uid)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        log.i("rtc firstRemoteVideoDecodedOfUid first video frame decoded \(uid)")
        _onPeerAction(.VideoReady,uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameOfUid uid: UInt, elapsed: Int) {
        log.i("rtc firstRemoteAudioFrameDecodedOfUid first audio frame decoded \(uid)")
        _onPeerAction(.AudioReady,uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        _networkStatus.totalDuration = stats.duration;
        _networkStatus.txBytes = stats.txBytes
        _networkStatus.rxBytes = stats.rxBytes
        _networkStatus.txKBitRate = stats.txKBitrate;
        _networkStatus.rxKBitRate = stats.rxKBitrate;
        _networkStatus.txAudioBytes = stats.txAudioBytes;
        _networkStatus.rxAudioBytes = stats.rxAudioBytes;
        _networkStatus.txVideoBytes = stats.txVideoBytes;
        _networkStatus.rxVideoBytes = stats.rxVideoBytes;
        _networkStatus.txAudioKBitRate = stats.txAudioKBitrate;
        _networkStatus.rxAudioKBitRate = stats.rxAudioKBitrate;
        _networkStatus.txVideoKBitRate = stats.txVideoKBitrate;
        _networkStatus.rxVideoKBitRate = stats.rxVideoKBitrate;
        _networkStatus.txPacketLossRate = stats.txPacketLossRate;
        _networkStatus.rxPacketLossRate = stats.rxPacketLossRate;
        _networkStatus.lastmileDelay = stats.lastmileDelay;
        _networkStatus.connectTimeMs = stats.connectTimeMs;
        _networkStatus.cpuAppUsage = stats.cpuAppUsage;
        _networkStatus.cpuTotalUsage = stats.cpuTotalUsage;
        _networkStatus.users = stats.userCount;
        _networkStatus.memoryAppUsageRatio = stats.memoryAppUsageRatio;
        _networkStatus.memoryTotalUsageRatio = stats.memoryTotalUsageRatio;
        _networkStatus.memoryAppUsageInKbytes = stats.memoryAppUsageInKbytes;
    }
}

extension RtcEngine : AgoraVideoFrameDelegate{

    func onCapture(_ videoFrame: AgoraOutputVideoFrame) -> Bool {
        return false
    }

    func onRenderVideoFrame(_ videoFrame: AgoraOutputVideoFrame, uid: UInt, channelId: String) -> Bool {
        if (isSnapShoting.getValue()) {
            isSnapShoting.setValue(false)
            if(videoFrame.type == 1){//1 for zhuban  12 for dcg
                log.i("rtc capture frame:\(videoFrame.type) width:\(videoFrame.width),height:\(videoFrame.height)")
                let image = Utils.i420(toImage: videoFrame.yBuffer, srcU: videoFrame.uBuffer, srcV: videoFrame.vBuffer,yStride: Int32(videoFrame.yStride), uStride:Int32(videoFrame.uStride), vStride:Int32(videoFrame.vStride), width: Int32(videoFrame.width), height: Int32(videoFrame.height))
                DispatchQueue.main.async {
                    self._onImageCaptured(image != nil ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,"capture screen",image)
                    self._onImageCaptured = {ec,msg,img in}
                }
            }
            else if(videoFrame.type == 12){//CVPixelBufferRef
                log.i("rtc capture frame is CVPixelBufferRef")
                var img:UIImage? = nil
                if let ref = videoFrame.pixelBuffer{
                    img = Utils.convert(ref)
                }
                else{
                    log.e("rtc capture pixelBuffer is nil")
                }
                DispatchQueue.main.async {
                    self._onImageCaptured(img != nil ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,"capture screen",img)
                    self._onImageCaptured = {ec,msg,img in}
                }
            }
            else{
                log.e("rtc capture frame: unknown type:\(videoFrame.type)")
            }
        }
        return true
    }}