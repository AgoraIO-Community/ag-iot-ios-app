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
import CoreMedia

class RtcEngine : NSObject{
    
    private var isSnapShoting : HOPAtomicBoolean = HOPAtomicBoolean(value: false)
    private var isRecording : HOPAtomicBoolean = HOPAtomicBoolean(value: false)
    private var _onImageCaptured:(Int,String,UIImage?)->Void = {ec,msg,img in}
    
    private var  _onMFirstRemoteVideoDecodedAction : (RtcPeerAction,UInt,ActionExtraInfo?)->Void = {b,u,e in log.i("onMFirstRemoteVideoDecodedAction init")} //自管理首帧返回回调
    private var  waitFirstRemoteUidArray: [UInt] = []  //等待首帧回调的List
    
    typealias RenderDataListern = (AgoraOutputVideoFrame, UInt)->Void
    private var _renderDataListernObjs = ThreadSafeDictionary<String,RenderDataListern>()

    var curChannel : String = ""
    var curAudioEffectId: AudioEffectId = .NORMAL
    
    //注册首帧返回自管理回调监听
    func waitForMFirstRemoteVideoCbListern(_ mFirstRemoteVideoAction:@escaping(RtcPeerAction,UInt,ActionExtraInfo?)->Void){
        _onMFirstRemoteVideoDecodedAction = mFirstRemoteVideoAction
    }
    
    //注册视频帧回调监听
    func registerMRenderVideoFrameListern(_ channel:String, _ mRenderVideoFrameAction:@escaping(AgoraOutputVideoFrame, UInt)->Void){
        _renderDataListernObjs.setValue(mRenderVideoFrameAction, forKey: channel)
    }
    
    //移除视频帧回调监听
    func unRegisterMRenderVideoFrameListern(_ channel:String){
        _ = _renderDataListernObjs.removeValue(forKey: channel)
    }
     
    //设置是否已回调首帧返回
    func setIsMFirstRemoteVideoCbValue(_ channel:String,_ curUid:UInt){
        self.curChannel = channel
        if !waitFirstRemoteUidArray.contains(curUid) {
            waitFirstRemoteUidArray.append(curUid)
        }
    }
    
    func setAudioEffect(_ effectId:AudioEffectId,cb:@escaping (Int,String)->Void){
        
        guard let rtcKit = getRtcObject() else {
            log.e("setAudioEffect: rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtc is nil")
            return
        }
        
        var preset: AgoraAudioEffectPreset
        switch effectId {
        case .NORMAL:
            preset = .off
        case .KTV:
            preset = .roomAcousticsKTV
        case .CONCERT:
            preset = .roomAcousVocalConcer
        case .STUDIO:
            preset = .roomAcousStudio
        case .PHONOGRAPH:
            preset = .roomAcousPhonograph
        case .VIRTUALSTEREO:
            preset = .roomAcousVirtualStereo
        case .SPACIAL:
            preset = .roomAcousSpatial
        case .ETHEREAL:
            preset = .roomAcousEthereal
        case .VOICE3D:
            preset = .roomAcous3DVoice
        case .UNCLE:
            preset = .voiceChangerEffectUncle
        case .OLDMAN:
            preset = .voiceChangerEffectOldMan
        case .BOY:
            preset = .voiceChangerEffectBoy
        case .SISTER:
            preset = .voiceChangerEffectSister
        case .GIRL:
            preset = .voiceChangerEffectGirl
        case .PIGKING:
            preset = .voiceChangerEffectPigKin
        case .HULK:
            preset = .voiceChangerEffectHulk
        case .RNB:
            preset = .styleTransformationRnb
        case .POPULAR:
            preset = .styleTransformationPopular
        case .PITCHCORRECTION:
            preset = .pitchCorrection
        }
        curAudioEffectId = effectId
        let ret = rtcKit.setAudioEffectPreset(preset)
        ret == 0 ? cb(ErrCode.XOK,"switch audio effect succ") : cb(ErrCode.XERR_UNSUPPORTED,"switch audio effect fail:" + String(ret))
    }
    
    func setPlaybackVolume(_ volume: Int,cb:@escaping (Int,String)->Void){
        
        guard let rtcKit = getRtcObject() else {
            log.e("setPlaybackVolume: rtc engine is nil")
            cb(ErrCode.XERR_BAD_STATE,"rtc is nil")
            return
        }
        
        let ret = rtcKit.adjustPlaybackSignalVolume(volume)
        return ret == 0 ? cb(ErrCode.XOK,"unimplemented") : cb(ErrCode.XERR_UNSUPPORTED,"unimplemented")
    }
    
    func setParameters(paramString : String)->Int{
        
        guard let rtcKit = getRtcObject() else {
            log.e("setParameters: rtc engine is nil")
            return ErrCode.XERR_BAD_STATE
        }
        
        let ret = rtcKit.setParameters(paramString)
        return Int(ret)
    }
 
    func getRtcObject() -> AgoraRtcEngineKit? {
        
        return AgoraRtcEngineMgr.sharedInstance.loadAgoraRtcEngineKit()
    }
 
    lazy var videoRecordM : VideoRecordManager = {
        
        let videoRecord = VideoRecordManager.init()
        return videoRecord
    }()
    
   
    
}

extension RtcEngine{
    
    func capturePeerVideoFrame(channel:String, cb:@escaping(Int,String,UIImage?)->Void){
        
        self.curChannel = channel
        self._onImageCaptured = cb
        isSnapShoting.setValue(true)
        log.i("\(isSnapShoting)___\(isSnapShoting.getValue())")
    }
    
    func startRecord(documentPath:String,channel:String, result: @escaping (Int, String) -> Void){
          
        videoRecordM.documentPath = documentPath
        self.curChannel = channel
        videoRecoredHanle(true)
        isRecording.setValue(true)
        result(ErrCode.XOK,"已开始")
    }

    func stopRecord(channel:String, result: @escaping (Int, String) -> Void){
        
        if isRecording.getValue() == true {
            self.curChannel = channel
            videoRecoredHanle(false)
            isRecording.setValue(false)
            result(ErrCode.XOK,"已停止")
        }
        
    }
    
    func setAudioAndVideoDelegate(){
        let rtcKit = getRtcObject()
        rtcKit?.setVideoFrameDelegate(self)
//        rtcKit.setAudioFrameDelegate(self)
    }
}

extension RtcEngine{
    
    func videoRecoredHanle(_ isStart : Bool){
        
        if isStart == true{
            debugPrint("videoRecoredHanle：开始录屏")
            videoRecordM.startWriter()
        }else{
            debugPrint("videoRecoredHanle：停止录屏")
            videoRecordM.stopWriter()
        }
        
    }
    
}

extension RtcEngine : AgoraVideoFrameDelegate{

    func onCapture(_ videoFrame: AgoraOutputVideoFrame, sourceType: AgoraVideoSourceType) -> Bool {
        return false
    }

    func getVideoFormatPreference() -> AgoraVideoFormat {

        return .cvPixelNV12 //.cvPixelNV12  .I420
    }

    func onRenderVideoFrame(_ videoFrame: AgoraOutputVideoFrame, uid: UInt, channelId: String) -> Bool {
        
        if channelId == curChannel, let index = waitFirstRemoteUidArray.firstIndex(of: uid) {
            log.i("onRenderVideoFrame: mFirstRemoteVideoDecodedAction uid:\(uid)")
            let exdata = ActionExtraInfo()
            exdata.width = Int(videoFrame.width)
            exdata.height = Int(videoFrame.height)
            waitFirstRemoteUidArray.remove(at: index)
            _onMFirstRemoteVideoDecodedAction(.VideoReady,uid,exdata)
        }
        
        let allListernObjs = _renderDataListernObjs.getAllKeysAndValues()
        for (key,obj) in allListernObjs{
            if key == channelId {
                obj(videoFrame,uid)
            }else{
                log.i("onRenderVideoFrame: allListernObjs not contain channel: \(key)")
            }
        }

        if channelId != curChannel{//如果不是当前频道的视频帧，则返回
            return true
        }
        
        if  videoRecordM.videoW == 0{
            videoRecordM.videoW = videoFrame.width
            videoRecordM.videoH = videoFrame.height
        }
        
        if (isRecording.getValue()){

            if(videoFrame.type == 12){//CVPixelBufferRef
                log.i("rtc capture frame is CVPixelBufferRef")
                if let buffer = videoFrame.pixelBuffer{
                    videoRecordM.videoWithSampleBuffer(buffer)
                }else{
                    log.e("rtc capture pixelBuffer is nil")
                }

            }else if(videoFrame.type == 1){

                log.i("rtc capture frame is I420")
                let  buffer : Unmanaged<CVPixelBuffer> = Utils.i420(toPixelBuffer:videoFrame.yBuffer!, srcU: videoFrame.uBuffer!, srcV: videoFrame.vBuffer!,yStride: Int32(videoFrame.yStride), uStride:Int32(videoFrame.uStride), vStride:Int32(videoFrame.vStride), width: Int32(videoFrame.width), height: Int32(videoFrame.height))
                _ = buffer.takeUnretainedValue()
                let anOpaque = buffer.toOpaque()
                let pixelBuffer : CVPixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(anOpaque).takeUnretainedValue()
                videoRecordM.videoWithSampleBuffer(pixelBuffer)
                Utils.realseCvbuffer(pixelBuffer)

            }
        }

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
 }

}

extension RtcEngine : AgoraAudioFrameDelegate{

    func onRecordAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        debugPrint("\(frame)")
        return true
    }

    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {

        if channelId != curChannel{
            return true
        }
        
        if (isRecording.getValue()){
            videoRecordM.audioWithBuffer(frame)
        }
        return true
    }

    //获取采集和播放音频混音后的数据
    func onMixedAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        debugPrint("\(frame)")
        return true
    }

    //获得播放的原始音频数据
    func onPlaybackAudioFrame(beforeMixing frame: AgoraAudioFrame, channelId: String, uid: UInt) -> Bool {
//        debugPrint("\(frame)")
        return true
    }

    func getObservedAudioFramePosition() -> AgoraAudioFramePosition {

        return  AgoraAudioFramePosition.playback

    }

    func getMixedAudioParams() -> AgoraAudioParams {

        return getAudioParams()

    }

    func getRecordAudioParams() -> AgoraAudioParams {

        return getAudioParams()

    }

    func getPlaybackAudioParams() -> AgoraAudioParams {

        return getAudioParams()

    }

    func getAudioParams()->AgoraAudioParams{

        let params = AgoraAudioParams.init()
        params.sampleRate = 44100 //44100
        params.channel = 2
        params.samplesPerCall = 1024 //1024

        return params
    }

}

