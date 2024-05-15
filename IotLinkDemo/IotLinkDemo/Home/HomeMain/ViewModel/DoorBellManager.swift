//
//  DoorBellManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/12.
//

import UIKit
import AgoraIotLink

class DoorBellManager: NSObject {

    public static let shared = DoorBellManager()
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}

    var volumeValue : Int = 10
    var members:Int = 0
    var isPlaying:Bool = false
    
    fileprivate override init() {
        super.init()
    }
    

    //设置音量
    func setDeviceVolume(_ connectObj:IConnectionObj?,subStreamId:StreamId,volumeLevel: Int,_ cb:@escaping(Bool,String)->Void){
        connectObj?.setAudioPlaybackVolume(subStreamId: subStreamId, volumeLevel: volumeLevel, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
        })
        
//        connectObj?.setAudioPlaybackVolume(subStreamId: subStreamId, volumeLevel: volumeLevel, result: { ec, msg in
//            log.i("errCode:\(errCode)")
//        })
    }
    
    //推本地视频到对端
    func publishVideoEnable(_ connectObj:IConnectionObj?,mute: Bool,cb:@escaping(Bool,String)->Void){
        let ret = connectObj?.publishVideoEnable(pubVideo: mute, result:{errCode ,msg in
            cb(errCode == ErrCode.XOK ? true : false , msg)
        })
        
//        connectObj?.publishVideoEnable(pubVideo: true, result:{errCode ,msg in
//            log.i("errCode:\(errCode)")
//        })
    }

    //推本地音频到对端
    func publishAudioEnable(_ connectObj:IConnectionObj?,mute: Bool,cb:@escaping(Bool,String)->Void){
        let ret = connectObj?.publishAudioEnable(pubAudio: mute, codecType: .G722, result:{errCode ,msg in
            cb(errCode == ErrCode.XOK ? true : false , msg)
        })
        
//        connectObj?.publishAudioEnable(pubAudio: true, codecType: .G722, result:{errCode ,msg in
//            log.i("errCode:\(errCode)")
//        })
    }
    
    //拉取对端音视频
    func streamSubscribeStart(_ connectObj:IConnectionObj?,subStreamId:StreamId,cb:@escaping(Bool,String)->Void){
        connectObj?.streamSubscribeStart(peerStreamId: subStreamId, attachMsg: "demo_test", result: {errCode ,msg in
            cb(errCode == ErrCode.XOK ? true : false , msg)
        })
        
//        connectObj?.streamSubscribeStart(peerStreamId: .BROADCAST_STREAM_1, attachMsg: "", result: {errCode ,msg in
//            log.i("errCode:\(errCode)")
//        })
    }
    
    //停止拉流
    func streamRecordStop(_ connectObj:IConnectionObj?,subStreamId:StreamId){
         connectObj?.streamSubscribeStop(peerStreamId: subStreamId)
    }
    
    //是否静音
    func mutePeerAudio(_ connectObj:IConnectionObj?,subStreamId:StreamId, mute: Bool,cb:@escaping(Bool,String)->Void){
        let ret = connectObj?.muteAudioPlayback(subStreamId: subStreamId, previewAudio: mute, result: {errCode ,msg in
            cb(errCode == ErrCode.XOK ? true : false , msg)
        })
        
//        connectObj?.muteAudioPlayback(subStreamId: subStreamId, previewAudio: true, result: {errCode ,msg in
//            log.i("errCode:\(errCode)")
//        })
    }
    
    //设置音效效果（通常是变声等音效）effectId: 音效Id
    func setAudioEffect(_ connectObj:IConnectionObj?,effectId: AudioEffectId,cb:@escaping(Int,String)->Void){
        sdk?.setPublishAudioEffect(effectId: effectId, result: cb)
    }
    
    //开始录制当前通话（包括音视频流），仅在通话状态下才能调用
    func talkingRecordStart(outFilePath:String = "", _ connectObj:IConnectionObj?,subStreamId:StreamId,cb:@escaping(Bool,String)->Void){
        let ret = connectObj?.streamRecordStart(subStreamId: subStreamId, outFilePath: outFilePath)
        cb(ret == ErrCode.XOK ? true : false , "")
    }
    
    //停止录制当前通话（包括音视频流），仅在通话状态下才能调用
    func talkingRecordStop(_ connectObj:IConnectionObj?,subStreamId:StreamId,cb:@escaping(Bool,String)->Void){
        connectObj?.streamRecordStop(subStreamId: subStreamId)
        cb(true , "")
    }
    
    //屏幕截屏 仅在通话状态下才能调用
    func capturePeerVideoFrame(saveFilePath:String = "",_ connectObj:IConnectionObj?,subStreamId:StreamId, cb:@escaping(Int,Int,Int)->Void){
        connectObj?.streamVideoFrameShot(subStreamId: subStreamId, saveFilePath: saveFilePath, cb: { errCode, w, h in
            debugPrint("\(errCode)")
            cb(errCode, w,h)
        })

    }

    //挂断来电
    func hungUpAnswer( _ connectObj:IConnectionObj,cb:@escaping(Bool,String)->Void){
        sdk?.connectionMgr.connectionDestroy(connectObj: connectObj)
        DoorBellManager.shared.members = 0
        cb(true , "")
    }
    
}
