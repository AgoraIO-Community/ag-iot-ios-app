//
//  IConnectionObj.swift
//  AgoraIotLink
//
//  Created by admin on 2024/2/19.
//

import Foundation



/*
 * @brief 链接的类型
 */
@objc public enum ConnectType:Int {
    case unknown           // 未知
    case active            // 主动的
    case passive           // 被动的
}

/*
 * @brief 链接的状态机
 */
@objc public enum ConnectState:Int {
    case disconnected           // 未连接状态
    case connectReqing          // 正在发送连接请求,等待服务器响应
    case connecting             // 连接请求成功,等待对端响应
    case connected              // 连接成功,可以进行链接的各种操作
}

/**
 * @brief StreamId 定义
 */
@objc public enum StreamId:Int {
    case PUBLIC_STREAM_1 = 1      ///< 公有StreamId 1
    case PUBLIC_STREAM_2 = 2     ///< 公有StreamId 2
    case PUBLIC_STREAM_3 = 3     ///< 公有StreamId 3
    case PUBLIC_STREAM_4 = 4     ///< 公有StreamId 4
    case PUBLIC_STREAM_5 = 5     ///< 公有StreamId 5
    case PUBLIC_STREAM_6 = 6     ///< 公有StreamId 6
    case PUBLIC_STREAM_7 = 7     ///< 公有StreamId 7
    case PUBLIC_STREAM_8 = 8     ///< 公有StreamId 8
    case PUBLIC_STREAM_9 = 9     ///< 公有StreamId 9

    case PRIVATE_STREAM_1 = 10    ///< 私有StreamId 1，这个保留，应用层不要使用
    case PRIVATE_STREAM_2 = 11    ///< 私有StreamId 2
    case PRIVATE_STREAM_3 = 12    ///< 私有StreamId 3
    case PRIVATE_STREAM_4 = 13    ///< 私有StreamId 4
    case PRIVATE_STREAM_5 = 14    ///< 私有StreamId 5
    case PRIVATE_STREAM_6 = 15    ///< 私有StreamId 6
    case PRIVATE_STREAM_7 = 16    ///< 私有StreamId 7
    case PRIVATE_STREAM_8 = 17    ///< 私有StreamId 8
    case PRIVATE_STREAM_9 = 18    ///< 私有StreamId 9
}

/*
 * @brief 音频格式
 */
@objc public enum AudioCodecType:Int{
    case G711U
    case G711A
    case G722
    case OPUS
}

/*
 * @brief 链接信息
 */
@objc public class ConnectionInfo : NSObject{
    
    public var mLocalNodeId:String = ""             //本地端的 NodeId
    public var mPeerNodeId:String = ""              //对端的 NodeId
    public var mState:ConnectState = .disconnected  //当前会话状态
    public var mType:ConnectType = .unknown         //当前链接类型
    public var mVideoPublishing:Bool = false        //是否正在推送本地视频
    public var mAudioPublishing:Bool = false        //是否正在推送本地音频
    
}

/*
 * @brief 流的状态信息
 */
@objc public class StreamStatus : NSObject{
    
    public var mStreamId:StreamId  = .PUBLIC_STREAM_1  //设备流的唯一标识
    public var mSubscribed:Bool = false                //当前是否已经订阅
    public var mVideoView:UIView? = nil                //当前视频帧显示控件
    public var mAudioMute:Bool = false                 //音频播放是否静音
    public var mAudioVolume:Int = 0                    //当前音频播放音量
    public var mRecording:Bool = false                 //当前是否正在录制
    
}

/**
 * @brief RTC状态信息
 */
public class NetworkStatus : NSObject{
    public var totalDuration : UInt      = 0
    public var txBytes : UInt            = 0
    public var rxBytes : UInt            = 0
    public var txKBitRate : UInt         = 0
    public var txAudioBytes : UInt       = 0
    public var rxAudioBytes : UInt       = 0
    public var txVideoBytes : UInt       = 0
    public var rxVideoBytes : UInt       = 0
    public var rxKBitRate : UInt         = 0
    public var txAudioKBitRate : UInt    = 0
    public var rxAudioKBitRate : UInt    = 0
    public var txVideoKBitRate : UInt    = 0
    public var rxVideoKBitRate : UInt    = 0
    public var lastmileDelay : UInt      = 0
    public var cpuTotalUsage : Double    = 0
    public var cpuAppUsage : Double      = 0
    public var users : UInt              = 0
    public var connectTimeMs : Int       = 0
    public var txPacketLossRate : Int    = 0
    public var rxPacketLossRate : Int    = 0
    public var memoryAppUsageRatio : Double = 0
    public var memoryTotalUsageRatio : Double = 0
    public var memoryAppUsageInKbytes : Int = 0
}

/*
 *@brief 链接操作的回调接口
 */
@objc public protocol ICallbackListener{
    
    /**
     * @brief 对端首帧出图
     * @param connectObj : 当前连接对象
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param videoWidth : 首帧视频宽度
     * @param videoHeight : 首帧视频高度
     */
    func onStreamFirstFrame(connectObj:IConnectionObj?, subStreamId:StreamId, videoWidth:Int, videoHeight:Int)
    
    /**
     * @brief 错误事件，在订阅预览视频时错误发生
     * @param connectObj : 当前连接对象
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param errCode : 错误码. XERR_CONNOBJ_SUBSCRIBE_CMD----订阅命令发送失败
     *                         XERR_CONNOBJ_NO_FRAME----订阅后没有视频帧过来
     */
    func onStreamError(connectObj:IConnectionObj?,subStreamId:StreamId,errCode:Int)
    
    /**
     * @brief 消息发送完成事件
     * @param connectObj : 当前连接对象
     * @param errCode : 发送结果错误码
     *                  XOK----表示发送成功；
     *                  XERR_TIMEOUT----表示SDK内部消息系统网络问题，导致发送超时失败
     *                  XERR_RTMMGR_MSG_xxxx----表示SDK消息系统相应问题
     * @param messageId : message的唯一标识
     * @param messageData : 发送的消息内容
     */
    func onMessageSendDone(connectObj:IConnectionObj?, errCode:Int, signalId:UInt32)
    
    /**
     * @brief 接收到对端的消息事件
     * @param connectObj : 当前连接对象
     * @param recvedSignalData : 接收到的信令数据
     */
    func onMessageRecved(connectObj:IConnectionObj?, recvedSignalData:Data)
    
    /**
     * @brief 传输接收单个文件开始回调
     * @param connectObj : 当前连接对象
     * @param startDescrption : 启动描述
     */
    func onFileTransRecvStart(connectObj:IConnectionObj?,startDescrption:Data)
    
    /**
     * @brief 传输接收单个文件数据回调
     * @param connectObj : 当前连接对象
     * @param recvedData : 接收到的数据内容
     */
    func onFileTransRecvData(connectObj:IConnectionObj?,recvedData:Data)
    
    /**
     * @brief 传输接收单个文件完成回调
     * @param connectObj : 当前连接对象
     * @param transferEnd : 是否整个传输都结束
     * @param doneDescrption: 结束描述
     */
    func onFileTransRecvDone(connectObj:IConnectionObj?,transferEnd:Bool,doneDescrption:Data)
    
}

/*
 * @brief 链接操作对象接口
 */
@objc public protocol IConnectionObj {
    
    
    ////////////////////////////////////////////////////////////////////////
    //////////////////////////// Public Methods ///////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
     * @brief 注册回调接口
     * @param callBackListener : 回调接口
     * @return 错误码
     */
    func registerListener(callBackListener:ICallbackListener)->Int
    
    /**
     * @brief 注销回调接口
     * @return 错误码
     */
    func unregisterListener()->Int
    
    /**
     * @brief 根据获取链接信息
     * @return 返回当前链接信息
     */
    func getInfo()->ConnectionInfo
    
    /*
     * @brief 获取当前网络状态
     * @return 返回RTC网络状态信息，如果当前没有任何一个链接，则返回null
     */
    func getNetworkStatus()->NetworkStatus
    
    
    //////////////////////////////////////////////////////////////////////
    /////////////////////////// 推流处理方法 ///////////////////////////////
    //////////////////////////////////////////////////////////////////////
    
    /**
     * @brief 控制推送本地视频流
     * @param pubVideo: 是否推送视频流
     * @return 错误码，XOK--推送成功；
     *               XERR_BAD_STATE--当前未连接导致推送失败
     *               XERR_UNSUPPORTED--视频数据推送失败
     */
    func publishVideoEnable(pubVideo:Bool, result:@escaping(Int,String)->Void)->Int
    
    /**
     * @brief 控制推送本地音频
     * @param pubAudio: 是否推送音频流
     * @return 错误码，XOK--推送成功；
     *               XERR_BAD_STATE--当前未连接导致推送失败
     *               XERR_UNSUPPORTED--音频数据推送失败
     */
    func publishAudioEnable(pubAudio:Bool, codecType:AudioCodecType, result:@escaping(Int,String)->Void)->Int
    
    
    
    //////////////////////////////////////////////////////////////////////
    /////////////////////////// 预览处理方法 ///////////////////////////////
    //////////////////////////////////////////////////////////////////////
    
    /**
     * @brief 获取对端流的信息
     * @param peerStreamId : 指定的 对端StreamId
     * @return 返回流的状态信息
     */
    func getStreamStatus(peerStreamId:StreamId)->StreamStatus
    
    /**
     * @brief 开始订阅对端流
     * @param peerStreamId : 指定的 对端StreamId
     * @param attachMsg : 订阅附加信息
     * @return 错误码，XOK--订阅成功；
     *               XERR_BAD_STATE--当前未连接导致订阅失败
     *               XERR_UNSUPPORTED--订阅失败
     */
    func streamSubscribeStart(peerStreamId:StreamId, attachMsg:String, result:@escaping(Int,String)->Void)
    
    /**
     * @brief 停止订阅对端流，停止订阅后，不能再收看相应流的音视频数据
     * @param peerStreamId : 指定的 对端StreamId
     * @return 错误码，XOK--取消订阅成功；
     *               XERR_BAD_STATE--当前未连接导致取消失败
     *               XERR_UNSUPPORTED--取消订阅失败
     */
    func streamSubscribeStop(peerStreamId:StreamId)
    
    /**
     * @brief 设置对端视频帧预览控件
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param displayView: 视频帧显示控件
     * @return 错误码，XOK--设置成功；
     *               XERR_BAD_STATE--当前未连接导致设置失败
     *               XERR_UNSUPPORTED--设置失败
     */
    func setVideoDisplayView(subStreamId:StreamId, displayView: UIView?) -> Int
    
    /**
     * @brief 设置对端流音频流是否静音
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param mute: 控制是否静音
     * @return 错误码，XOK--设置成功；
     *                XERR_BAD_STATE--当前未连接导致设置失败
     *                XERR_UNSUPPORTED--设置失败
     */
    func muteAudioPlayback(subStreamId:StreamId, previewAudio:Bool, result:@escaping(Int,String)->Void)
    
    /**
     * @brief 设置本地播放所有混音后音频的音量
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param volumeLevel: 音量级别
     * @return 错误码，XOK--设置成功；
     *                XERR_BAD_STATE--当前未连接导致设置失败
     *                XERR_UNSUPPORTED--设置失败
     */
    func setAudioPlaybackVolume(subStreamId:StreamId, volumeLevel:Int, result:@escaping(Int,String)->Void)
    
    /*
     * @brief 对端视频帧截图，仅在通话状态下才能调用
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param saveFilePath : 输出保存的图片文件路径（应用层确保文件有可写权限,以.jpg为后缀，比如：../App Sandbox/Library/Caches/example.jpg）
     * @param result: (参数1:错误码，参数2:图片宽度（px),参数3:图片高度（px))，0--截图请求成功,< 0: 截图失败。
     * @return 错误码，XOK--截图请求成功；
     *                XERR_BAD_STATE--当前未连接导致截图失败
     *               XERR_UNSUPPORTED--设置失败
     */
    func streamVideoFrameShot(subStreamId:StreamId,saveFilePath:String,cb:@escaping(Int,Int,Int)->Void)->Int
    
    /**
     * @brief 开始录制当前链接（包括音视频流），仅在预览状态下才能调用
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @param outFilePath : 输出保存的视频文件路径（应用层确保文件有可写权限）
     * @return 错误码，XOK--开始录制成功；
     *                XERR_BAD_STATE--当前未连接导致开始录制失败
     *                XERR_UNSUPPORTED--录制失败
     */
    func streamRecordStart(subStreamId:StreamId, outFilePath : String)->Int
    
    /**
     * @brief 停止录制当前通话，仅在通话状态下才能调用
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @return 错误码，XOK--开始录制成功；
     *                XERR_BAD_STATE--当前未连接导致停止录制失败
     *                XERR_UNSUPPORTED--停止失败
     */
    func streamRecordStop(subStreamId:StreamId)->Int
    
    /**
     * @brief 判断当前是否正在本地录制
     * @param subStreamId : 指定订阅预览的 对端StreamId
     * @return true 表示正在本地录制频道； false: 不在录制
     */
    func isStreamRecording(subStreamId:StreamId)
    
    
    //////////////////////////////////////////////////////////////////////
    /////////////////////////// 消息处理方法 ///////////////////////////////
    //////////////////////////////////////////////////////////////////////
    
    /**
     * @brief 发送信令到链接的对端，发送结果通过 onSignalSendDone() 回调异步通知
     * @param messageData : 发送的信令内容
     * @return 消息的唯一标识 messageId, null表示错误，在回调中依赖messageId进行区分
     */
    func sendMessageData(messageData:Data) -> UInt32
    

    
}
