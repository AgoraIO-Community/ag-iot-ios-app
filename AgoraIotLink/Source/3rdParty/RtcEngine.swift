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
    
    private var  _onMFirstRemoteVideoDecodedAction : (RtcPeerAction,UInt)->Void = {b,u in log.i("onMFirstRemoteVideoDecodedAction init")} //自管理首帧返回回调
    private var  isMFirstRemoteVideoCb : Bool = false  //是否自管理首帧已返回
    
    var curChannel : String = ""
    
//    var frameCount : Int = 0
    
    //注册首帧返回自管理回调监听
    func waitForMFirstRemoteVideoCbListern(_ mFirstRemoteVideoAction:@escaping(RtcPeerAction,UInt)->Void){
        _onMFirstRemoteVideoDecodedAction = mFirstRemoteVideoAction
    }
    
    //设置是否已回调首帧返回
    func setIsMFirstRemoteVideoCbValue(_ channel:String,_ isCb : Bool){
        self.curChannel = channel
        isMFirstRemoteVideoCb = isCb
    }
 
    func setAudioEffect(_ effectId:AudioEffectId,cb:@escaping (Int,String)->Void){

        let rtcKit = getRtcObject()
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
        let ret = rtcKit.setAudioEffectPreset(preset)
        ret == 0 ? cb(ErrCode.XOK,"switch audio effect succ") : cb(ErrCode.XERR_UNKNOWN,"switch audio effect fail:" + String(ret))
    }
    
    func setVolume(_ vol: Int,cb:@escaping (Int,String)->Void){
        let rtcKit = getRtcObject()
        let ret = rtcKit.setEffectsVolume(vol)
        return ret == 0 ? cb(ErrCode.XOK,"unimplemented") : cb(ErrCode.XERR_UNSUPPORTED,"unimplemented")
    }
    
    func setParameters(paramString : String,cb:@escaping (Int)->Void){
        
        let rtcKit = getRtcObject()
        let ret = rtcKit.setParameters(paramString)
        cb(Int(ret))
        
    }
 
    func getRtcObject() -> AgoraRtcEngineKit {
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
          
        videoRecordM.outFilePath = documentPath
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
        rtcKit.setVideoFrameDelegate(self)
        rtcKit.setAudioFrameDelegate(self)
    }
}

extension RtcEngine{
    
    func videoRecoredHanle(_ isStart : Bool){
        
        if isStart == true{
            log.i("videoRecoredHanle：startRecored")
            videoRecordM.startWriter()
        }else{
            log.i("videoRecoredHanle：stopRecored")
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
        
//        if uid != 10 {
////            frameCount += 1
////            log.i("onRenderVideoFrame:count:\(frameCount) uid:\(uid)")
//        }
        
        if isMFirstRemoteVideoCb == false && channelId == curChannel {
            log.i("onRenderVideoFrame: mFirstRemoteVideoDecodedAction uid:\(uid)")
            _onMFirstRemoteVideoDecodedAction(.VideoReady,uid)
            isMFirstRemoteVideoCb = true
        }
        
        if channelId != curChannel{//如果不是当前频道的视频帧，则返回
            return true
        }
        
        if  videoRecordM.videoW == 0{
            videoRecordM.videoW = videoFrame.width
            videoRecordM.videoH = videoFrame.height
            debugPrint("onRenderVideoFrame:width:\(videoFrame.width)height:\(videoFrame.height)")
        }
        
        if (isRecording.getValue()){

            if(videoFrame.type == 12){//CVPixelBufferRef

//                log.i("rtc capture frame is CVPixelBufferRef")

                if let buffer = videoFrame.pixelBuffer{
                    videoRecordM.videoWithSampleBuffer(buffer)
                }
                else{
                    log.e("rtc capture pixelBuffer is nil")
                }

            }else if(videoFrame.type == 1){

//                log.i("rtc capture frame is I420")

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
//            log.e("onPlaybackAudioFrame channelId:\(channelId)")
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
        debugPrint("\(frame)")
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

