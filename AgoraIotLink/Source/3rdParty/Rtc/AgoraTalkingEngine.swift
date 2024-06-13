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
    case Lost
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
    var isRecordingVideo  = false //是否正在录制视频
}

public class ChannelInfo : NSObject{
    
    var uid    : UInt = 0       //用户id
    var peerUid : UInt = 0      //对端id
    var cName  : String = ""    //频道名
    var token  : String = ""    //token
    var appId  : String = ""    //appId
    var encryptMode : Int = 0  //加密算法
    var secretKey : String = "" //密钥
    
    var mEncrypt : Bool = false //是否开启加密
}

public class ActionExtraInfo : NSObject{
    var width    : Int = 0      // 帧宽
    var height   : Int = 0      // 帧高
}

class AgoraTalkingEngine: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var app  = IotLibrary.shared
    var rtc  = IotLibrary.shared.proxy.rtc
    
    var rtcKit      : AgoraRtcEngineKit?
    var channelInfo : ChannelInfo?
    var connection  : AgoraRtcConnection = AgoraRtcConnection()
    var rtcSetting  : RtcSetting =  RtcSetting()
    var peerDisplayView : UIView?
    
    private var  _onPeerAction : (RtcPeerAction,UInt,ActionExtraInfo?)->Void = {b,u,e in}
    private var  _memberState : (MemberState,[UInt])->Void = {s,a in }
    private var  _rdtDataListen : (UInt,Data,Int)->Void = {u,d,e in }
    
    
    private var  _tokenWillExpire : ()->Void = {}
    private var _networkStatus : NetworkStatus = NetworkStatus()
    private var _onRtcImageCaptured:(Int,Int,Int)->Void = {ec,w,h in}
    
    private var peerEntered:Bool = false
    //原生rtc录制器
    private var mediaRecorder:AgoraMediaRecorder? = nil
    //stream对象列表
    var streamSessionObjs: [Int: StreamSessionObj] = [:]
    //rdt 管理对象
    var rdtTransferMgr : RdtTransferFileMgr? = nil
    
    init(setting: RtcSetting,channelInfo: ChannelInfo,cb:@escaping (TaskResult,String)->Void,peerAction:@escaping(RtcPeerAction,UInt,ActionExtraInfo?)->Void,memberState:@escaping(MemberState,[UInt])->Void){
        super.init()
        let rtcKit = AgoraRtcEngineMgr.sharedInstance.loadAgoraRtcEngineKit(appId: channelInfo.appId, setting: setting)
        self.rtcKit = rtcKit
        self.channelInfo = channelInfo
        self.rtcSetting = setting
        
        _onPeerAction = peerAction
        _memberState = memberState
        
        //注册首帧回调的监听
        registerMFirstRemoteVideoListern()
        //避免已加入的频道未退出又重新进入新的频道时无首帧回调
        rtc.setIsMFirstRemoteVideoCbValue(channelInfo.cName,channelInfo.peerUid)
    
        let tempCon = AgoraRtcConnection()
        tempCon.channelId = channelInfo.cName
        tempCon.localUid =  channelInfo.uid
        connection = tempCon
        
        peerDisplayView = setting.peerDisplayView
        //加入频道前进行内容加密
        encryptionChannel()
        log.i("rtc enterChannel when uid:\(channelInfo.uid) token:\(channelInfo.token) name:\(channelInfo.cName)")
        //加入频道
        joinChannel(cb: cb)
        creatStreamObjs()
        
        rdtTransferMgr = RdtTransferFileMgr(connection: tempCon)
    }
    
    
    func registerMFirstRemoteVideoListern(){
        rtc.waitForMFirstRemoteVideoCbListern {[weak self] act, uid, exData in
            self?.clearStreamObjtimeStamp(uid: uid)
            DispatchQueue.main.async{
                self?._onPeerAction(act,uid,exData)
            }
        }
    }
    
    func registeronRenderVideoFrameListern(renderDatalistern:@escaping(AgoraOutputVideoFrame, UInt)->Void){
        guard let channelName = channelInfo?.cName else {
            log.e("registeronRenderVideoFrameListern: channelName is nil")
            return
        }
        rtc.registerMRenderVideoFrameListern(channelName,renderDatalistern)
    }

    func registerRdtDataListern(rdtListen:@escaping(UInt,Data,Int)->Void){
        _rdtDataListen = rdtListen
    }
    
    func waitForTokenWillExpire(tokenWillExpireListern:@escaping()->Void){
        _tokenWillExpire = tokenWillExpireListern
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
    
    func getRtcObject() -> AgoraRtcEngineKit? {
        return AgoraRtcEngineMgr.sharedInstance.loadAgoraRtcEngineKit()
    }
    
    func encryptionChannel(){
        log.i("encryptionChannel mEncrypt:\(String(describing: channelInfo?.mEncrypt)) ret:\(String(describing: channelInfo?.secretKey))")
        guard let channelInfo = channelInfo else {
            log.i("channelInfo is nil ")
            return
        }
        
        let encryptConfig = AgoraEncryptionConfig()
        encryptConfig.encryptionMode =  AgoraEncryptionMode(rawValue:channelInfo.encryptMode)!
        encryptConfig.encryptionKdfSalt = getEncryptionSalt()
        encryptConfig.encryptionKey = channelInfo.secretKey
        let ret = rtcKit?.enableEncryptionEx(channelInfo.mEncrypt, encryptionConfig: encryptConfig, connection: connection)
        if ret != 0 {
            log.e("encryptionChannel: enableEncryptionEx fail ret:\(String(describing: ret))")
        }
        log.i("encryptionChannel mEncrypt:\(channelInfo.mEncrypt) ret:\(String(describing: ret))")
    }
    
    func joinChannel(cb:@escaping(TaskResult,String)->Void){
        
        let option:AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        option.channelProfile = .liveBroadcasting
        option.clientRoleType = .broadcaster
        option.autoSubscribeAudio = rtcSetting.subscribeAudio
        option.autoSubscribeVideo = rtcSetting.subscribeVideo
        option.publishCameraTrack = rtcSetting.publishVideo
        option.publishMicrophoneTrack = rtcSetting.publishAudio
        option.autoConnectRdt = true
        
        log.i("""
                 rtc try enterChannel: '\(String(describing: channelInfo?.cName))' 
                              for uid:(\(String(describing: channelInfo?.uid)))
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
            let ret = setupRemoteView(subStreamId: .BROADCAST_STREAM_1, peerView: peerView)
            log.i("init setupRemoteView ret:\(ret)")
        }
        
        if(ret != 0){
            log.e("rtc enterChannel:\(String(describing: ret))")
            cb(.Fail,"join channel fail")
        }else{
            cb(.Succ,"join channel sucess")
        }
        
        log.i("rtc local joinchannel peerid: \([NSNumber(value: channelInfo?.peerUid ?? 0)])")
        
        peerEntered = false

    }
    
    func leaveChannel(cb:@escaping (Bool)->Void){
        
        resetNetStatus()
        _onPeerAction = {b,u,e in}
        _memberState = {s,a in}
        peerEntered = false
        rdtTransferMgr = nil
        if peerDisplayView != nil{
            log.i("leaveChannel setupRemoteView nil")
            let ret = setupRemoteView(subStreamId: .BROADCAST_STREAM_1, peerView: nil)
            log.i("leaveChannel setupRemoteView nil ret:\(ret)")
        }
        log.i("rtc try leaveChannel ... curChannelName:\(self.connection.channelId)")
        let ret = rtcKit?.leaveChannelEx(connection,leaveChannelBlock: { stats in
            log.i("leaveChannelEx:\(stats)")
        })
        rtc.unRegisterMRenderVideoFrameListern(channelInfo?.cName ?? "")
        clearObject()
        clearStreamObjs()
        log.i("leaveChannelEx ret:\(String(describing: ret)) ")
        cb(true)
    }
    
    
    func clearObject(){
        rtcKit?.setDelegateEx(nil, connection: connection)
        rtcKit = nil
    }
    
    func destroy()->Void{
        log.i("rtc is destroying()")
        peerEntered = false
        AgoraRtcEngineMgr.sharedInstance.destroyRtcEngineKit()
    }
 
    lazy var videoRecordM : VideoRecordManager = {
        
        let videoRecord = VideoRecordManager.init()
        return videoRecord
    }()
    
    deinit {
        log.i("AgoraTalkingEngine 销毁了 cName:\(String(describing: channelInfo?.cName))")
    }

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
        return ret == 0 ? ErrCode.XOK  : ErrCode.XERR_SYSTEM
    }
    
    func setupRemoteView(subStreamId: StreamId, peerView:UIView?)->Int{
        
        let peerUid = StreamIdToUIdMap.getUId(baseUid:channelInfo?.uid ?? 0 , streamId: UInt(subStreamId.rawValue))
        log.i("rtc is setting up remote canvas peerUid:\(peerUid)  \(String(describing: peerView))")
        guard let rtcKit = rtcKit else{
            log.e("rtc engine is nil when setupRemoteView")
            return ErrCode.XERR_BAD_STATE
        }
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = peerUid
        canvas.renderMode = rtcSetting.renderMode
        canvas.view = peerView
        
        let ret = rtcKit.setupRemoteVideoEx(canvas, connection: connection)
        if(ret != 0){
            log.e("rtc setupRemoteView uid:\(peerUid) view:\(peerView != nil ? "not nil" : "nil") failed:\(String(describing: ret))")
        }
        return ret == 0 ? ErrCode.XOK  : ErrCode.XERR_UNSUPPORTED
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
        rtcSetting.publishVideo = (ret == 0 ? !mute : mute)
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNKNOWN,op + " fail:" + String(ret))
    }
    
    func muteLocalAudio(_ mute:Bool,codecType:AudioCodecType, cb:@escaping (Int,String)->Void){
        let op = mute ? "mute local audio" : "unmute local audio mute:\(mute)"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        
        if mute == false {
            // 配置私参：音频G711U(8k)--0; 音频G711A(8k)--8; 音频G722(16k)--9;  音频OPUS(16k)--120
            
            var type = "";
            if(rtcSetting.audioType == "G722"){
                type = "9"
                rtcSetting.audioSampleRate = "16000"
            }
            else if(rtcSetting.audioType == "G711U"){
                type = "0"
            }
            else if(rtcSetting.audioType == "G711A"){
                type = "8"
                rtcSetting.audioSampleRate = "8000"
            }
            else if(rtcSetting.audioType == "AAC"){
                type = "69"
            }else if(rtcSetting.audioType == "OPUS"){
                type = "120"
                rtcSetting.audioSampleRate = "16000"
            }

            if(type != ""){
                let cfg = "{\"che.audio.custom_payload_type\":" + type + "}"
                let ret = rtcKit.setParameters(cfg)
                log.i("custom_payload_type :\(cfg) ret : \(String(describing: ret))")
            }
            
            var sampleCfg = "{\"che.audio.input_sample_rate\":" + rtcSetting.audioSampleRate + "}"
            let ret = rtcKit.setParameters(sampleCfg)
            log.i("input_sample_rate :\(sampleCfg) ret : \(String(describing: ret))")
            
        }
        
        let option:AgoraRtcChannelMediaOptions = AgoraRtcChannelMediaOptions()
        option.channelProfile = .liveBroadcasting
        option.clientRoleType = .broadcaster
        option.publishMicrophoneTrack = !mute
        rtcKit.updateChannelEx(with: option, connection: connection)
        
        let ret = rtcKit.muteLocalAudioStreamEx(mute, connection: connection)
        if(ret != 0){
            log.w("rtc muteLocalAudio(\(mute)) faile:\(String(ret))")
        }else{
            log.i("muteLocalAudio ret:\(ret) mute:\(mute)")
        }
        rtcSetting.publishAudio = (ret == 0 ? !mute : mute)
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNSUPPORTED,op + " fail:" + String(ret))
    }
    
    func mutePeerVideo(_ subStreamId:StreamId, _ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute peer video" : "unmute peer video"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        let peerUid = StreamIdToUIdMap.getUId(baseUid:channelInfo?.uid ?? 0 , streamId: UInt(subStreamId.rawValue) )
        if mute == false{
            //注册首帧回调的监听，保证每次拉流都有最新首帧监听回调
            registerMFirstRemoteVideoListern()
            rtc.setIsMFirstRemoteVideoCbValue(channelInfo?.cName ?? "",peerUid)
        }
        let ret = rtcKit.muteRemoteVideoStreamEx(peerUid, mute: mute, connection: connection)
        if(ret != 0){
            log.w("rtc mutePeerVideo(\(mute)) peerUid:\(peerUid) faile:\(ret)")
        }
//        if mute == true {
//            setStreamObjVedio(streamId: subStreamId, isVideo: !mute)
//        }
        setStreamObjVedio(streamId: subStreamId, isVideo: !mute)
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNSUPPORTED,op + " fail:" + String(ret))
    }
    
    func mutePeerAudio(_ subStreamId:StreamId, _ mute:Bool,cb:@escaping (Int,String)->Void){
        let op = mute ? "mute peer audio" : "unmuete peer audio"
        guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,op + " fail")
            return
        }
        
        let peerUid = StreamIdToUIdMap.getUId(baseUid:channelInfo?.uid ?? 0 , streamId: UInt(subStreamId.rawValue) )
        let ret = rtcKit.muteRemoteAudioStreamEx(peerUid, mute: mute, connection: connection)
        if(ret != 0){
            log.w("rtc mutePeerAudio(\(mute))  peerUid:\(peerUid) faile:\(ret)")
        }
        setStreamObjAudio(streamId: subStreamId, isAudio: !mute)
        ret == 0 ? cb(ErrCode.XOK,op + " succ") : cb(ErrCode.XERR_UNSUPPORTED,op + " fail:" + String(ret))
    }
    
    func adjustRecordingSignalVolume(_ volume:Int,cb:@escaping (Int,String)->Void){
            
         guard let rtcKit = rtcKit else {
            log.e("rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"\(volume) fail")
            return
         }
            
         let ret = rtcKit.adjustRecordingSignalVolumeEx(volume, connection: connection)
            
         ret == 0 ? cb(ErrCode.XOK,"adjust \(volume) succ") : cb(ErrCode.XERR_UNKNOWN,"adjust \(volume) fail:" + String(ret))
            
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
            cb(ErrCode.XERR_INVALID_PARAM,"rtc peer not joined",nil)
            return
        }
        
        rtc.capturePeerVideoFrame(channel: channelInfo?.cName ?? "", cb: cb)
    }
    
    func capturePeerVideoFrame(_ subStreamId:StreamId, saveFilePath:String,cb:@escaping(Int,Int,Int)->Void)->Int{
        log.i("rtc try capturePeerVideoFrame ...")
        if(!peerEntered){
            log.w("rtc peer not entered for capture")
            return ErrCode.XERR_INVALID_PARAM
        }
        
        guard let engine = rtcKit else {
            log.e("rtc engine is nil")
            return ErrCode.XERR_BAD_STATE
        }
        
        let peerUid = StreamIdToUIdMap.getUId(baseUid:channelInfo?.uid ?? 0 , streamId: UInt(subStreamId.rawValue))
        self._onRtcImageCaptured = cb
        let ret = engine.takeSnapshotEx(connection, uid: Int(peerUid), filePath: saveFilePath)
        if(ret != 0){
            log.w("rtc takeSnapshot(\(saveFilePath)) faile:\(ret)")
        }
        return ret
    }
    
    func startRecord(documentPath:String,result: @escaping (Int, String) -> Void){
        
        log.i("rtc try capturePeerVideoFrame ...")
        if(!peerEntered){
            log.i("startRecord: rtc peer not entered for capture")
            result(ErrCode.XERR_INVALID_PARAM,"rtc peer not joined")
            return
        }
    
        rtc.startRecord(documentPath:documentPath, channel: channelInfo?.cName ?? "", result: result)
        
    }

    func stopRecord(result: @escaping (Int, String) -> Void){
        
        log.i("rtc try stopRecord ...")
        rtc.stopRecord(channel: channelInfo?.cName ?? "", result: result)
    }
    
    func getNetworkStatus()->NetworkStatus{
        return _networkStatus
    }
    
    /**
     * 设置指定频道的设备的视频质量
     */
    func setPeerVideoQuality(videoQuality: VideoQualityParam) -> Int {
        guard let engine = rtcKit else {
            log.e("rtc engine is nil")
            return ErrCode.XERR_BAD_STATE
        }

        var ret: Int32
        var enableSr: String
        var srType: String
        var veAlphaBlending: String

        switch videoQuality.mQualityType {
        case .sr: // 超分
            switch videoQuality.mSrDegree {
            case VideoSuperResolution.srDegree_100:
                srType = "{\"rtc.video.sr_type\" : 6}"
            case VideoSuperResolution.srDegree_133:
                srType = "{\"rtc.video.sr_type\" : 7}"
            case VideoSuperResolution.srDegree_150:
                srType = "{\"rtc.video.sr_type\" : 8}"
            default:
                srType = "{\"rtc.video.sr_type\" : 3}"
            }
            ret = engine.setParameters(srType)
            log.i("<setPeerVideoQuality> [SR] set sr_type=\(srType), ret=\(ret)")
            if ret != ErrCode.XOK {
                return Int(ret)
            }

            enableSr = "{\"rtc.video.enable_sr\": {\"enabled\": true, \"mode\": 0, \"uid\": \(channelInfo?.peerUid ?? 0)}}"
            ret = engine.setParameters(enableSr)
            log.i("<setPeerVideoQuality> [SR] set enable_sr=\(enableSr), ret=\(ret)")

        case .si: // 超级画质
            srType = "{\"rtc.video.sr_type\" : 20}"
            ret = engine.setParameters(srType)
            log.i("<setPeerVideoQuality> [SI] set sr_type=\(srType), ret=\(ret)")
            if ret != ErrCode.XOK {
                return Int(ret)
            }

            veAlphaBlending = "{\"rtc.video.ve_alpha_blending\": \(videoQuality.mSiDegree)}"
            ret = engine.setParameters(veAlphaBlending)
            log.i("<setPeerVideoQuality> [SI] set ve_alpha_blending=\(veAlphaBlending), ret=\(ret)")
            if ret != ErrCode.XOK {
                return Int(ret)
            }

            enableSr = "{\"rtc.video.enable_sr\": {\"enabled\": true, \"mode\": 0, \"uid\": \(channelInfo?.peerUid ?? 0)}}"
            ret = engine.setParameters(enableSr)
            log.i("<setPeerVideoQuality> [SI] set enable_sr=\(enableSr), ret=\(ret)")

        case .normal:
            enableSr = "{\"rtc.video.enable_sr\": {\"enabled\": false, \"mode\": 0, \"uid\": \(channelInfo?.peerUid ?? 0)}}"
            ret = engine.setParameters(enableSr)
            log.i("<setPeerVideoQuality> [NONE] set enable_sr=\(enableSr), ret=\(ret)")

        }

        return Int(ret)
    }
    
    func setRdtTransferState(_ state:TransferFileState){
        rdtTransferMgr?.setRdtTransferState(state)
    }
    
    func sendRdtMessageStart(startMessage: String)->Int {
        guard let peerUid =  channelInfo?.peerUid, let rdtTransferMgr = rdtTransferMgr else {
            log.e("sendRdtMessageStop:peerUid is nil")
            return ErrCode.XERR_INVALID_PARAM
        }
        return rdtTransferMgr.sendRdtStartMessage(Int(peerUid),startMessage)
    }
    
    func sendRdtMessageStop(stopMessage: String){
        guard let peerUid =  channelInfo?.peerUid, let rdtTransferMgr = rdtTransferMgr else {
            log.e("sendRdtMessageStop:peerUid is nil")
            return
        }
        rdtTransferMgr.sendRdtStopMessage(Int(peerUid),stopMessage)
    }
    
    func isFileTransfering()->Bool{
        if rdtTransferMgr?.getRdtTransferState() == .transfering{
            return true
        }
        return false
    }
    
}

extension AgoraTalkingEngine: AgoraRtcEngineDelegate{

    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveRdtMessageFromUid uid: UInt, type: AgoraRdtStreamType, data: Data) {
        log.i("receiveRdtMessageFromUid :uid：\(uid), type:\(type) data:\(data.count)")
        _rdtDataListen(uid,data,ErrCode.XOK)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurRdtMessageStateFromUid uid: UInt, state: AgoraRdtState) {
        log.i("didOccurRdtMessageStateFromUid：uid：\(uid),state:\(state)")
        rdtTransferMgr?.setRdtChannelState(state)
        if state == .blocked {
            _rdtDataListen(uid,Data(),ErrCode.XERR_NETWORK)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveMediaControlMessageFromUid uid: UInt, data: Data) {
        guard let myString = String(data: data, encoding: .utf8) else{
            // 转换失败
            print("data covert string fail")
            return
        }
        log.i("receiveMediaControlMessageFromUid :uid：\(uid), content:\(myString) data:\(data.count)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        log.i("rtc remote user didJoinedOfUid \(uid)")
        if uid == channelInfo?.peerUid{//只有设备端上线，状态才改变
            peerEntered = true
        }
        _onPeerAction(.Enter,uid, nil)
        _memberState(.Enter,[uid])
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        log.i("🐣🐣🐣rtc remote user didOfflineOfUid \(uid) reason:\(reason.rawValue)🐣🐣🐣")
        if uid == channelInfo?.peerUid{//只有设备端离线，状态才改变
            peerEntered = false
            rtc.stopRecord(channel: channelInfo?.cName ?? "") { code, msg in
                log.i("didOfflineOfUid:stopRecord")
            }
        }
        _onPeerAction(.Leave,uid,nil)
        _memberState(.Leave,[uid])
    }
    
    func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        log.i("💔💔💔 rtc rtcEngineConnectionDidInterrupted 💔💔💔")
    }
    
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        log.i("💔💔💔 rtc rtcEngineConnectionDidLost 💔💔💔")
        peerEntered = false
        _onPeerAction(.Lost,0,nil)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        log.i("rtc local user didJoinChannel \(uid)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith status:AgoraChannelStats){
        log.i("rtc local user didLeaveChannelWith")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        log.i("rtc firstRemoteVideoFrameOfUid first video frame rendered \(uid)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        log.i("rtc firstRemoteVideoDecodedOfUid first video frame decoded： \(uid)")
        //使用自管理首帧回调，此处注释
//        _onPeerAction(.VideoReady,uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameOfUid uid: UInt, elapsed: Int) {
        log.i("rtc firstRemoteAudioFrameDecodedOfUid first audio frame decoded \(uid)")
        _onPeerAction(.AudioReady,uid,nil)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, snapshotTaken uid: UInt, filePath: String, width: Int, height: Int, errCode: Int) {
        log.i("rtc snapshotTaken uid:\(uid) errCode:\(errCode) filePath:\(filePath)")
        self._onRtcImageCaptured(errCode,width,height)
        self._onRtcImageCaptured = {ec,w,h in}
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        //Token 将在30s内过期回调
        log.w("rtc tokenPrivilegeWillExpire token:\(token)")
        _tokenWillExpire()
    }

    func rtcEngineRequestToken(_ engine: AgoraRtcEngineKit) {
        //Token 已过期回调
        log.i("rtc rtcEngineRequestToken)")
        peerEntered = false
        _onPeerAction(.Leave,channelInfo?.peerUid ?? 0,nil)
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

extension AgoraTalkingEngine : AgoraMediaRecorderDelegate{
    
//    func mediaRecorder(_ recorder: AgoraMediaRecorder, stateDidChanged channelId: String, uid: UInt, state: AgoraMediaRecorderState, reason: AgoraMediaRecorderReasonCode) {
//        
//    }
    func mediaRecorder(_ recorder: AgoraMediaRecorder, stateDidChanged channelId: String, uid: UInt, state: AgoraMediaRecorderState, error: AgoraMediaRecorderErrorCode) {
        //todo:
        log.i("mediaRecorder:stateDidChanged: state:\(state) error:\(error)")
    }
    
    func mediaRecorder(_ recorder: AgoraMediaRecorder, informationDidUpdated channelId: String, uid: UInt, info: AgoraMediaRecorderInfo) {
        log.i("mediaRecorder:informationDidUpdated: uid:\(uid)")
    }
    
}

//--- 原生rtc录制功能---
extension AgoraTalkingEngine{

    func createMediaRecorder(_ subStreamId:StreamId,_ storagePath : String){
        guard let rtc = rtcKit else {
            log.e("rtc is nil");
            return
        }
        
        let peerUid = StreamIdToUIdMap.getUId(baseUid:channelInfo?.uid ?? 0 , streamId: UInt(subStreamId.rawValue))
        
        let recorderInfor = AgoraRecorderStreamInfo()
        recorderInfor.channelId = channelInfo?.cName ?? ""
        recorderInfor.uid = UInt(peerUid)
        
        mediaRecorder = rtc.createMediaRecorder(withInfo: recorderInfor)
        mediaRecorder?.setMediaRecorderDelegate(self)
        mediaRecorder?.enableMainQueueDispatch(true)
        
        startInterRecording(subStreamId,storagePath)
        setStreamObjRecoreding(streamId: subStreamId, isRecoreding: true)
    }
    
    func startInterRecording(_ subStreamId:StreamId, _ storagePath : String){
        let reConfig = AgoraMediaRecorderConfiguration()
        reConfig.storagePath = storagePath //录音文件在本地保存的绝对路径
        reConfig.containerFormat = .MP4
        reConfig.streamType = .both
        reConfig.maxDurationMs = 120000 //最大录制时长，单位为毫秒
        reConfig.recorderInfoUpdateInterval = 1000 //录制信息更新间隔，单位为毫秒
        if let streamObj = getStreamObj(subStreamId: subStreamId),streamObj.mVideoPreviewing == true,streamObj.mAudioPreviewing == false {
            log.i("startInterRecording: recording only video")
            reConfig.streamType = .video
        }
        
        let ret = mediaRecorder?.startRecording(reConfig)
        log.i("startInterRecording: ret:\(String(describing: ret))")
    }
    
    func stopInterRecording(_ subStreamId:StreamId){
        mediaRecorder?.stopRecording()
        mediaRecorder = nil
        setStreamObjRecoreding(streamId: subStreamId, isRecoreding: false)
    }
    
}


extension AgoraTalkingEngine{
    
    func creatStreamObjs(){
        
        for streamIndex in 1...18  {
            guard let streamId = StreamId(rawValue: streamIndex) else { continue }
            let sObj = StreamSessionObj(streamId:streamId, peerUid: 0, timeStamp: 0)
            streamSessionObjs[streamIndex] = sObj
        }
        log.i("creatStreamObjs:\(streamSessionObjs.count)")
    }
    
    func setStreamObjAudio(streamId:StreamId, isAudio:Bool){
        let streamObj = streamSessionObjs[streamId.rawValue]
        streamObj?.mAudioPreviewing = isAudio
    }
    
    func setStreamObjVedio(streamId:StreamId, isVideo:Bool){
        let streamObj = streamSessionObjs[streamId.rawValue]
        streamObj?.mVideoPreviewing = isVideo
    }
    
    func setStreamObjRecoreding(streamId:StreamId,isRecoreding:Bool){
        let streamObj = streamSessionObjs[streamId.rawValue]
        streamObj?.mRecording = isRecoreding
    }
    
    //设置订阅预览的streamId
    func setStreamObjTimeout(streamId : StreamId){
        let streamObj = streamSessionObjs[streamId.rawValue]
        if streamObj?.mVideoPreviewing == false {
            streamObj?.timeStamp = String.dateCurrentTime()
        }
    }
    
    //通过过uid获取订阅预览的StreamObj
    func getStreamObj(uid : UInt)-> StreamSessionObj?{
        let streamId = StreamIdToUIdMap.getStreamId(baseUid: channelInfo?.uid ?? 0, uId: uid)
        if streamSessionObjs.count > 0{
            return streamSessionObjs[streamId]
        }
        return nil
    }
    
    //通过过streamId获取订阅预览的StreamObj
    func getStreamObj(subStreamId : StreamId)-> StreamSessionObj?{
        if streamSessionObjs.count > 0{
            return streamSessionObjs[subStreamId.rawValue]
        }
        return nil
    }
    
    func clearStreamObjtimeStamp(uid : UInt){
        guard let streamObj = getStreamObj(uid:uid) else { return }
        streamObj.timeStamp = 0
        streamObj.mVideoPreviewing = true
        log.i("handelStreamObjTimeout:uid:\(uid)")
    }
    
    //清除未预览成功数据
    func clearStreamObjs(){
        streamSessionObjs.removeAll()
    }
    
}

extension AgoraTalkingEngine {
    
    func getEncryptionSalt() -> Data {
       // 将 Base64 编码的盐转换成 uint8_t
        let saltValue = (channelInfo?.cName ?? "") + "000000"
        log.i("getEncryptionSalt: saltValue:\(saltValue)")
        return  saltValue.data(using: .utf8)!
    }
    
}
