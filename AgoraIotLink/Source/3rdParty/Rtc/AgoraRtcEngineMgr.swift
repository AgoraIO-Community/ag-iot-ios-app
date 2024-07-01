//
//  AgoraRtcEngineMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/5.
//

import UIKit
import AgoraRtcKit


/**
 * 视频质量类型
 */
@objc public enum  VideoQualityType:Int {
    case normal = 0   // 默认质量
    case sr = 1        // 超分
    case si = 2        // 超级画质
}

/**
 * 视频超分程度
 */
@objc public enum VideoSuperResolution:Int {
    case srDegree_100 = 100  // 1倍超分
    case srDegree_133 = 133  // 1.33倍超分
    case srDegree_150 = 150  // 1.5倍超分
    case srDegree_200 = 200  // 2倍超分
}

/**
 * @brief 设置的视频质量参数
 */
@objc public class VideoQualityParam : NSObject{
    @objc public var mQualityType : VideoQualityType = .normal            ///< 视频质量类型，参考 @VideoQuality
    @objc public var mSrDegree : VideoSuperResolution = .srDegree_100     ///< 超分程度，参考 @VideoSuperResolution，仅对 typeSR有效
    @objc public var mSiDegree : Int = 0                                ///< 超级画质程度, 0~256 (256最大程度),仅对 typeSI有效
}



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
        
        let logConFig = AgoraLogConfig()
        logConFig.level = .info
        
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        config.logConfig = logConFig
        rtcKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: nil)
        guard let rtc = rtcKit else {
            log.e("rtc create engine failed");
            return nil
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

        //设置音频场景为gameStreaming，解决开麦和禁麦时声音忽大忽小的问题
        rtc.setAudioScenario(.meeting)
        
        return rtcKit
    }
    
    func loadAgoraRtcEngineKit()->AgoraRtcEngineKit?{
        guard let kit = rtcKit else {
            log.i("loadAgoraRtcEngineKit : rtc create")
            return nil
        }
        return kit
    }
    
    func destroyRtcEngineKit(){
        AgoraRtcEngineKit.destroy()
        rtcKit = nil
    }
    
}
