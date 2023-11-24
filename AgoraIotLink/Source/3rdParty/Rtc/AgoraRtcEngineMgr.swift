//
//  AgoraRtcEngineMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/5.
//

import UIKit
import AgoraRtcKit

class AgoraRtcEngineMgr: NSObject {

    static let sharedInstance = AgoraRtcEngineMgr()
    
    var rtcKit : AgoraRtcEngineKit?
    
    func loadAgoraRtcEngineKit(appId:String,setting:RtcSetting)->AgoraRtcEngineKit?{
        
        if rtcKit != nil{
            return rtcKit!
        }
        
        log.i("""
                rtc is creating,   version:  \(AgoraRtcEngineKit.getSdkVersion())
                                 dimension:  \(setting.dimension)
                                 frameRate:  \(setting.frameRate)
                                   bitRate:  \(setting.bitRate)
                           orientationMode:  \(setting.orientationMode)
               """)
        rtcKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: nil)
        guard let rtc = rtcKit else {
            log.e("rtc create engine failed");
            return nil
        }
        if(setting.logFilePath != ""){
            rtc.setLogFilter(AgoraLogFilter.error.rawValue)
            rtc.setLogFile(setting.logFilePath)
        }

        rtc.setClientRole(.broadcaster)
        rtc.setChannelProfile(.liveBroadcasting)
        rtc.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(
            size:setting.dimension,
            frameRate: setting.frameRate,
            bitrate: setting.bitRate,
            orientationMode: setting.orientationMode, mirrorMode: .auto
        ))
        
        rtc.enableAudio()
        rtc.enableVideo()
        rtc.setEnableSpeakerphone(true)
        rtc.setClientRole(.broadcaster)
        rtc.setChannelProfile(.liveBroadcasting)
        
        return rtcKit
    }
    
    func loadAgoraRtcEngineKit()->AgoraRtcEngineKit{
        guard let kit = rtcKit else {
            log.i("loadAgoraRtcEngineKit : rtc create")
            return loadAgoraRtcEngineKit()
        }
        return kit
    }
    
    func destroyRtcEngineKit(){
        AgoraRtcEngineKit.destroy()
        rtcKit = nil
    }
    
}
