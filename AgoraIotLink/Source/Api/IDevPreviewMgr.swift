//
//  IDevPreviewMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//


@objc public class RtcNetworkStatus : NSObject{
    @objc public var isBusy : Bool             = false //是否在工作中（从开始呼叫到结束呼叫）
    @objc public var totalDuration : UInt      = 0
    @objc public var txBytes : UInt            = 0
    @objc public var rxBytes : UInt            = 0
    @objc public var txKBitRate : UInt         = 0
    @objc public var txAudioBytes : UInt       = 0
    @objc public var rxAudioBytes : UInt       = 0
    @objc public var txVideoBytes : UInt       = 0
    @objc public var rxVideoBytes : UInt       = 0
    @objc public var rxKBitRate : UInt         = 0
    @objc public var txAudioKBitRate : UInt    = 0
    @objc public var rxAudioKBitRate : UInt    = 0
    @objc public var txVideoKBitRate : UInt    = 0
    @objc public var rxVideoKBitRate : UInt    = 0
    @objc public var lastmileDelay : UInt      = 0
    @objc public var cpuTotalUsage : Double    = 0
    @objc public var cpuAppUsage : Double      = 0
    @objc public var users : UInt              = 0
    @objc public var connectTimeMs : Int       = 0
    @objc public var txPacketLossRate : Int    = 0
    @objc public var rxPacketLossRate : Int    = 0
    @objc public var memoryAppUsageRatio : Double = 0
    @objc public var memoryTotalUsageRatio : Double = 0
    @objc public var memoryAppUsageInKbytes : Int = 0
}

/*
 * @brief 会话的状态机
 */
@objc public enum CallState:Int {
    case idle           // 空闲状态
    case callRequest    // 呼叫请求状态
    case dialing        // 本地已经进入频道，等待对方响应
    case onCall         // 通话状态
    case incoming       // 来电状态
}

/*
 * @brief 与对端通话时的产生的行为/事件
 */
@objc public enum ActionAck:Int{
    case RemoteAnswer                   //对端接听
    case RemoteHangup                   //对端挂断
    case RemoteTimeout                  //对端超时
    case RemoteVideoReady               //对端首帧出图
    case LocalHangup                    //本地挂断
    case CallIncoming                   //设备来电振铃
    case UnknownAction                  //未知错误
}

/*
 * @brief 声音特效类型
 */
@objc public enum AudioEffectId:Int{
    case NORMAL
    case OLDMAN
    case BABYBOY
    case BABYGIRL
    case ZHUBAJIE
    case ETHEREAL
    case HULK
}

/*
 * @brief 呼叫系统接口
 */
@objc public protocol IDevPreviewMgr {
    
    /**
     * @brief 设备端首帧出图
     * @param sessionId : 会话唯一标识
     * @param bSubAudio : 是否禁止拉取音频（true:禁止，false：拉取）
     * @param videoWidth : 首帧视频宽度
     * @param videoHeight : 首帧视频高度
     */
    func previewStart(bSubAudio:Bool, previewListener: @escaping (_ sessionId:String,_ videoWidth:Int,_ videoHeight:Int) -> Void)

    /**
     * @brief 停止设备音视频流预览
     * @return 返回错误码
     */
    func previewStop(result:@escaping(Int,String)->Void)
    
    /*
     * @brief 设置对端视频显示控件，如果不设置则不显示对端视频
     * @param peerView: 对端视频显示控件
     * @return 错误码，0:成功
     */
    func setPeerVideoView(peerView: UIView?) -> Int

    /*
     * @brief 禁止/启用 本地音频推流到对端
     * @param mute: 是否禁止
     * @param result: 调用该接口是否成功
     */
    func muteLocalAudio( mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 拉流对端视频
     * @param mute: 是否禁止
     * @param result: 调用该接口是否成功
     */
    func mutePeerVideo(mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 拉流对端音频
     * @param mute: 是否禁止
     * @param result: 调用该接口是否成功
     */
    func mutePeerAudio(mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置音频播放的音量
     * @param volumeLevel: 音量级别
     * @param result: 调用该接口是否成功
     */
    func setPlaybackVolume(volumeLevel: Int,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置音效效果（通常是变声等音效）
     * @param effectId: 音效Id
     * @param result: 调用该接口是否成功
     */
    func setAudioEffect(effectId: AudioEffectId,result:@escaping(Int,String)->Void)

    /*
     * @brief 开始录制当前预览（包括音视频流），仅在预览状态下才能调用，同一时刻只能启动一路录像功能
     * @param outFilePath : 输出保存的视频文件路径（应用层确保文件有可写权限,以.mp4为后缀，比如：../Documents/VideoFile/out_test810C3162.mp4）
     * @param result: 调用该接口是否成功
     */
    func recordingStart(outFilePath:String, result:@escaping(Int,String)->Void)

    /*
     * @brief 停止录制当前预览，仅在预览状态下才能调用
     * @param result: 调用该接口是否成功
     */
    func recordingStop(result:@escaping(Int,String)->Void)
    
    /*
     * @brief 屏幕截屏，仅在通话状态下才能调用
     * @param result: 调用该接口是否成功，以及截屏的位图
     */
    func captureVideoFrame( result:@escaping(Int,String,UIImage?)->Void)
    
    /*
     * @brief 获取当前网络状态
     * @return 返回RTC网络状态信息
     */
    func getNetworkStatus()->RtcNetworkStatus
    
    /*
     * @brief 设置RTC私有参数
     * @param privateParam : 要设置的私参
     * @return 错误码
     */
    func setRtcPrivateParam(privateParam : String)->Int
}
