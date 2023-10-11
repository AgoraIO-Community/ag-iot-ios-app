//
//  AgoraTalkingEngine.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/5.
//

import UIKit
import AgoraRtcKit
import CoreMedia

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
    var renderMode:AgoraVideoRenderMode = .fit
    var audioType = ""        //G722，G711A，G711U
    var audioSampleRate = ""; //16000,8000
    
    var logFilePath = ""
    var publishAudio = false    ///< 通话时是否推流本地音频
    var publishVideo = false    ///< 通话时是否推流本地视频
    var subscribeAudio = false ///< 通话时是否订阅对端音频
    var subscribeVideo = false  ///< 通话时是否订阅对端视频
    
    var peerDisplayView : UIView? //对端渲染视图
}

public class ChannelInfo : NSObject{
    
    var uid    : UInt = 0       //用户id
    var peerUid : UInt = 0      //对端id
    var cName  : String = ""    //频道名
    var token  : String = ""    //token
    var appId  : String = ""    //appId

}

class AgoraTalkingEngine: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var app  = Application.shared
    var rtc  = Application.shared.proxy.rtc
    
    var rtcKit      : AgoraRtcEngineKit?
    var channelInfo : ChannelInfo?
    var connection  : AgoraRtcConnection = AgoraRtcConnection()
    var rtcSetting  : RtcSetting =  RtcSetting()
    
    var peerDisplayView : UIView?
    
    
    private var  _onEnterChannel : TimeCallback<(TaskResult,String)>? = nil
    private var  _onPeerAction : (RtcPeerAction,UInt)->Void = {b,u in}
    private var  _memberState : (MemberState,[UInt])->Void = {s,a in }
    private var  _tokenWillExpire : ()->Void = {}
    

    private var _networkStatus : RtcNetworkStatus = RtcNetworkStatus()
    
    private var peerEntered:Bool = false
    private var state:Int = AgoraTalkingEngine.IDLED
    
    static private let IDLED = 0
    static private let CREATED = 1
    static private let ENTERED = 2
    
    
    init(setting: RtcSetting,channelInfo: ChannelInfo,cb:@escaping (TaskResult,String)->Void,peerAction:@escaping(RtcPeerAction,UInt)->Void,memberState:@escaping(MemberState,[UInt])->Void){
        super.init()
        
        let rtcKit = AgoraRtcEngineMgr.sharedInstance.loadAgoraRtcEngineKit(appId: channelInfo.appId, setting: setting)
        self.rtcKit = rtcKit
        self.channelInfo = channelInfo
        self.rtcSetting = setting
        _onPeerAction = peerAction
        _memberState = memberState
        
        let tempCon = AgoraRtcConnection()
        tempCon.channelId = channelInfo.cName
        tempCon.localUid =  channelInfo.uid
        connection = tempCon
        
        peerDisplayView = setting.peerDisplayView
//        setMetalData()
        
        _onEnterChannel?.invalidate()
        joinChannel(cb: cb)
        
    }
    
    //token 即将过期监听
    func waitForTokenWillExpire(tokenWillExpireListern:@escaping()->Void){
        _tokenWillExpire = tokenWillExpireListern
    }
    
    func getRtcObject() -> AgoraRtcEngineKit {
        return AgoraRtcEngineMgr.sharedInstance.loadAgoraRtcEngineKit()
    }
    
    func setMetalData(){
        rtcKit?.setMediaMetadataDelegate(self, with: .video)
        rtcKit?.setMediaMetadataDataSource(self, with: .video)
    }
    
    func clearMetalData(){
        rtcKit?.setMediaMetadataDelegate(nil, with: .video)
        rtcKit?.setMediaMetadataDataSource(nil, with: .video)
    }
    
    func renewToken(_ rtcToken : String){
        
        log.i("rtc renewToken:\(rtcToken)")
        guard let rtc = rtcKit else{
            log.e("rtc engine is nil")
            return
        }
        
        let option:AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        option.channelProfile = .liveBroadcasting
        option.clientRoleType = .broadcaster
        option.token = rtcToken
        let ret = rtc.updateChannelEx(with: option, connection: connection)
        log.i("rtc renewToken ret:\(ret)")
        
        channelInfo?.token = rtcToken
        
    }
    
    func joinChannel(cb:@escaping(TaskResult,String)->Void){
        
        let option:AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        option.channelProfile = .liveBroadcasting
        option.clientRoleType = .broadcaster
        option.autoSubscribeAudio =  rtcSetting.subscribeAudio
        option.autoSubscribeVideo =  rtcSetting.subscribeVideo
        option.publishCameraTrack = rtcSetting.publishVideo
        option.publishMicrophoneTrack = rtcSetting.publishAudio
        
        log.i("""
                 rtc try enterChannel: '\(String(describing: channelInfo?.cName))' for: uid(\(String(describing: channelInfo?.uid)))
                            audioType: \(rtcSetting.audioType)
                           sampleRate: \(rtcSetting.audioSampleRate)
                           autoSubscribeAudio: \(rtcSetting.subscribeAudio)
                           autoSubscribeVideo: \(rtcSetting.subscribeVideo)
                           publishCameraTrack: \(rtcSetting.publishVideo)
                           publishMicrophoneTrack: \(rtcSetting.publishAudio)
                 """)

        let ret = rtcKit?.joinChannelEx(byToken: channelInfo?.token, connection: connection, delegate: self, mediaOptions: option, joinSuccess:nil)
        
        rtc.setAudioAndVideoDelegate()
        
        if let peerView = peerDisplayView{
            log.i("init setupRemoteView")
            let ret = setupRemoteView(peerView: peerView, uid: self.channelInfo!.peerUid)
            log.i("init setupRemoteView ret:\(ret)")
        }
        
        if(ret != 0){
            log.e("rtc enterChannel:\(String(describing: ret))")
            cb(.Fail,"join channel fail")
        }
        _onEnterChannel = TimeCallback<(TaskResult,String)>(cb: cb)
        _onEnterChannel?.schedule(time: 20, timeout: {
            log.e("rtc join channel timeout")
            cb(.Fail,"join channel timeout")
        })
        
        var cfg = "{\"che.audio.input_sample_rate\":" + rtcSetting.audioSampleRate + "}"
        rtcKit?.setParameters(cfg)

        var type = "";
        if(rtcSetting.audioType == "G722"){
            type = "9"
        }
        else if(rtcSetting.audioType == "G711U"){
            type = "0"
        }
        else if(rtcSetting.audioType == "G711A"){
            type = "8"
        }else if(rtcSetting.audioType == "AAC"){
            type = "69"
        }

        if(type != ""){
            cfg = "{\"che.audio.custom_payload_type\":" + type + "}"
            let ret = rtcKit?.setParameters(cfg)
            log.i("custom_payload_type :\(cfg) ret : \(String(describing: ret))")
        }

    }
    
    func leaveChannel(cb:@escaping (Bool)->Void){
        
        resetNetStatus()
        _onPeerAction = {b,u in}
        _memberState = {s,a in}
        peerEntered = false
        if peerDisplayView != nil{
            log.i("leaveChannel setupRemoteView nil")
            let ret = setupRemoteView(peerView: nil, uid: self.channelInfo?.peerUid ?? 0)
            log.i("leaveChannel setupRemoteView nil ret:\(ret)")
        }
        log.i("rtc try leaveChannel ...")
        let ret = rtcKit?.leaveChannelEx(connection,leaveChannelBlock: { stats in
            log.i("leaveChannelEx:\(stats)")
        })
        clearObject()
        rtc.frameCount = 0
        _onEnterChannel?.invoke(args:(.Abort,"leaveChannel"))
        log.i("rtc try leaveChannel ..ret:\(String(describing: ret))")
        cb(true)
    }
    
    func clearObject(){
        rtcKit?.setDelegateEx(nil, connection: connection)
//        clearMetalData()
//        rtcKit?.setAudioFrameDelegate(nil)
//        rtcKit?.setVideoFrameDelegate(nil)
        rtcKit = nil
    }
    
    func destroy()->Void{
        log.i("rtc is destroying()")
        AgoraRtcEngineMgr.sharedInstance.destroyRtcEngineKit()
    }
    
    deinit {
        log.i("AgoraTalkingEngine 销毁了 cName:\(String(describing: channelInfo?.cName))")
    }
    
    
    lazy var videoRecordM : VideoRecordManager = {
        
        let videoRecord = VideoRecordManager.init()
        return videoRecord
    }()
    
}

extension AgoraTalkingEngine{
    
    func setupLocalView(localView:UIView?,uid:UInt)->Int{
        log.i("rtc is setting up local canvas")
        guard let rtcKit = rtcKit else{
            log.e("rtc engine is nil")
            return ErrCode.XERR_BAD_STATE
        }
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.renderMode =  rtcSetting.renderMode
        canvas.view = localView
        
        let ret = rtcKit.setupLocalVideo(canvas)
        if(ret != 0){
            log.e("rtc setupLocalView failed:\(String(describing: ret))")
        }
        return ret == 0 ? ErrCode.XOK  : ErrCode.XERR_API_RET_FAIL
    }
    
    func setupRemoteView(peerView:UIView?,uid:UInt)->Int{
        log.i("rtc is setting up remote canvas:\(uid) \(rtcSetting.renderMode.rawValue) \(String(describing: peerView))")
        guard let rtcKit = rtcKit else{
            log.e("rtc engine is nil when setupRemoteView")
            return ErrCode.XERR_BAD_STATE
        }
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.renderMode = rtcSetting.renderMode
        canvas.setupMode = .add
        canvas.view = peerView
        
        let ret = rtcKit.setupRemoteVideoEx(canvas, connection: connection)
        if(ret != 0){
            log.e("rtc setupRemoteView uid:\(uid) view:\(peerView != nil ? "not nil" : "nil") failed:\(String(describing: ret))")
        }
        return ret == 0 ? ErrCode.XOK  : ErrCode.XERR_API_RET_FAIL
    }
    
    func muteLocalVideo(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute local video" : "unmute local video mute:\(mute)"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XOK,op + " fail")
            return
        }
        
        let ret = rtcKit.muteLocalVideoStreamEx(mute, connection: connection)
        if(ret != 0){
            log.w("rtc muteLocalVideo(\(mute)) faile:\(String(ret))")
        }
        
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    func muteLocalAudio(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute local audio" : "unmute local audio mute:\(mute)"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        let option:AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        option.channelProfile = .liveBroadcasting
        option.clientRoleType = .broadcaster
//        option.autoSubscribeVideo = rtcSetting.subscribeVideo
//        option.autoSubscribeAudio = rtcSetting.subscribeAudio
//        option.publishCameraTrack = !mute
        option.publishMicrophoneTrack = !mute
        rtcKit.updateChannelEx(with: option, connection: connection)
        
        let ret = rtcKit.muteLocalAudioStreamEx(mute, connection: connection)
        if(ret != 0){
            log.w("rtc muteLocalAudio(\(mute)) faile:\(String(ret))")
        }else{
            log.i("muteLocalAudio ret:\(ret) mute:\(mute)")
        }
        
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    func mutePeerVideo(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute peer video" : "unmute peer video"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        let ret = rtcKit.muteRemoteVideoStreamEx(channelInfo?.peerUid ?? 0, mute: mute, connection: connection)
        if(ret != 0){
            log.w("rtc mutePeerVideo(\(mute)) peerUid:\(channelInfo?.peerUid ?? 0) faile:\(ret)")
        }
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    func mutePeerAudio(_ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute peer audio" : "unmuete peer audio"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        let ret = rtcKit.muteRemoteAudioStreamEx(channelInfo?.peerUid ?? 0, mute: mute, connection: connection)
        if(ret != 0){
            log.w("rtc mutePeerAudio(\(mute))  peerUid:\(channelInfo?.peerUid ?? 0) faile:\(ret)")
        }
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    
    
    private func resetNetStatus(){
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
    
}

extension AgoraTalkingEngine{
    
    
    func capturePeerVideoFrame(cb:@escaping(Int,String,UIImage?)->Void){
        log.i("rtc try capturePeerVideoFrame ...")
        if(!peerEntered){
            log.w("rtc peer not entered for capture")
            cb(ErrCode.XERR_BAD_STATE,"rtc peer not joined",nil)
            return
        }
        
        rtc.capturePeerVideoFrame(channel: channelInfo?.cName ?? "", cb: cb)
    }
    
    func startRecord(outFilePath:String,result: @escaping (Int, String) -> Void){
        
        log.i("rtc try capturePeerVideoFrame ...")
        if(!peerEntered){
            log.i("startRecord: rtc peer not entered for capture")
            result(ErrCode.XERR_BAD_STATE,"rtc peer not joined")
            return
        }
    
        rtc.startRecord(documentPath:outFilePath, channel: channelInfo?.cName ?? "", result: result)

    }

    func stopRecord(result: @escaping (Int, String) -> Void){
        
        rtc.stopRecord(channel: channelInfo?.cName ?? "", result: result)

    }
    
    func getNetworkStatus()->RtcNetworkStatus{
        return _networkStatus
    }
}

extension AgoraTalkingEngine: AgoraRtcEngineDelegate{

//    func rtcEngine(_ engine: AgoraRtcEngineKit, didClientRoleChanged oldRole: AgoraClientRole, newRole: AgoraClientRole, newRoleOptions: AgoraClientRoleOptions?) {
//        log.i("rtc didJoinedOfUid oldRole:\(oldRole.rawValue) newRole:\(newRole.rawValue)")
//    }
//
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didClientRoleChangeFailed reason: AgoraClientRoleChangeFailedReason, currentRole: AgoraClientRole) {
//        log.i("rtc didJoinedOfUid currentRole:\(currentRole.rawValue) reason:\(reason)")
//    }
    
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
        rtc.stopRecord(channel: channelInfo?.cName ?? "") { code, msg in
            log.i("didOfflineOfUid:stopRecord")
        }
//        if (isRecording.getValue()){
//            stopRecord { code, msg in
//                log.i("didOfflineOfUid:stopRecord")
//            }
//        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        log.i("rtc didJoinChannel \(uid)")
        _onEnterChannel?.invoke(args:(.Succ,"join channel succ"))
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith status:AgoraChannelStats){
        log.i("rtc didLeaveChannelWith")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        log.i("rtc firstRemoteVideoFrameOfUid first video frame rendered \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        log.i("rtc firstRemoteVideoDecodedOfUid first video frame decoded： \(uid)")
  
        _onPeerAction(.VideoReady,uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameOfUid uid: UInt, elapsed: Int) {
        log.i("rtc firstRemoteAudioFrameDecodedOfUid first audio frame decoded \(uid)")
        _onPeerAction(.AudioReady,uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        log.w("rtc tokenPrivilegeWillExpire token:\(token)")
        _tokenWillExpire()
    }

    func rtcEngineRequestToken(_ engine: AgoraRtcEngineKit) {
        log.i("rtc rtcEngineRequestToken)")
        peerEntered = false
        _onPeerAction(.Leave,channelInfo?.peerUid ?? 0)
        _memberState(.Leave,[channelInfo?.peerUid ?? 0])
        rtc.stopRecord(channel: channelInfo?.cName ?? "") { code, msg in
            log.i("rtcEngineRequestToken:stopRecord")
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        log.w("rtc didOccurWarning:\(warningCode.rawValue)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        log.e("rtc didOccurError:\(errorCode.rawValue)")
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

extension AgoraTalkingEngine: AgoraMediaMetadataDelegate,AgoraMediaMetadataDataSource {
    
    func metadataMaxSize() -> Int {
        return 1024
    }
    
    func readyToSendMetadata(atTimestamp timestamp: TimeInterval, sourceType: AgoraVideoSourceType) -> Data? {
        return nil
    }
    
    
    func receiveMetadata(_ data: Data, fromUser uid: Int, atTimestamp timestamp: TimeInterval) {
        let jsonDic = String.getDictionaryFromData(data: data)
        log.i("receiveMetadata: \(jsonDic)")
    }
    
}





