/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 Agora Lab, Inc (http://www.agora.io/)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

/**
 * @brief RTC状态信息
 */
public class RtcNetworkStatus : NSObject{
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
 * @brief 会话的状态机
 */
@objc public enum CallState:Int {
    case idle           // 空闲状态
    case callRequest    // 正在发送拨号请求
    case dialing        // 本地已经进入频道，等待对方响应
    case onCall         // 正在通话中
    case incoming       // 设备端来电中
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
 * @brief 会话信息
 */
public class SessionInfo : NSObject{
    
    public var mSessionId:String = ""   //会话的唯一标识
    public var mLocalNodeId:String = "" //当前用户的 NodeId
    public var mPeerNodeId:String = ""  //对端设备的 NodeId
    public var mState:CallState = .idle //当前会话状态
    
    
    public var uid:UInt = 0
    
}

/*
 * @brief 多人呼叫时成员状态变化种类
 */
@objc public enum MemberState : Int{
    case Exist                          //当前已有用户(除开自己)
    case Enter                          //其他新用户接入会话
    case Leave                          //其他用户退出会话
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
 * @brief 设备信息，(productKey+mDeviceId) 构成设备唯一标识
 */
public class DialParam : NSObject {
    @objc public var mPeerNodeId    : String                //要呼叫的对端设备 NodeId
    @objc public var mAttachMsg     : String                //主叫呼叫附带信息
    @objc public var mPubLocalAudio : Bool                  //设备端接听后是否立即推送本地音频流
    
    public init(mPeerNodeId:String ,
                mAttachMsg:String,
                mPubLocalAudio:Bool){
        self.mPeerNodeId = mPeerNodeId
        self.mAttachMsg = mAttachMsg
        self.mPubLocalAudio = mPubLocalAudio
    }
}

/*
 * @brief 呼叫系统接口
 */
public protocol ICallkitMgr {
    
    /*
     * @brief 注册来电通知
     * @param incoming: 参数1:会话id，参数2:对端设备的 NodeId ,参数3:CallIncoming,RemoteHangup,RemoteVideoReady
     * @param memberState:多人通话时他人的状态，state:成员状态，uid:成员uid
     */
    func register(incoming: @escaping (_ sessionId:String,_ peerNodeId:String, ActionAck) -> Void,memberState:((MemberState,[UInt],String)->Void)?)
    
    /**
     * @brief 根据 sessionId 获取会话状态信息
     * @param sessionId : 会话唯一标识
     * @return 返回会话信息，如果没有查询到会话，则返回nil
     */
    func getSessionInfo(sessionId:String)->SessionInfo?
    
    /*
     * @brief 呼叫设备
     * @param dialParam  : 呼叫信息
     * @param result     : 调用该接口是否成功 errCode : 错误代码，0表示呼叫请求成功
     * @param actionAck  : callDial 通话中产生的事件
     * @param memberState: 多人通话时他人的状态，state:成员状态，uid:成员uid
     */
    func callDial(
        dialParam: DialParam,
        result:@escaping(_ errCode:Int,_ sessionId:String,_ peerNodeId:String)->Void,
        actionAck:@escaping(ActionAck,_ sessionId:String,_ peerNodeId:String)->Void,
        memberState:((_ state:MemberState,_ uid:[UInt],String)->Void)?)

    /*
     * @brief 挂断当前通话
     * @param sessionId : 会话唯一标识
     * @param result: 错误码，目前总是返回 XOK，如果找不到该会话，清除相关信息，也返回 XOK
     */
    func callHangup(sessionId:String, result:@escaping(Int,String)->Void)
    
    /*
     * @brief 接听当前来电
     * @param sessionId : 会话唯一标识
     * @param pubLocalAudio : 接听后是否立即推送本地音频
     * @param result: 错误码，XOK--接听成功；XERR_INVALID_PARAM--没有找到该会话；XERR_BAD_STATE--该会话类型不是来电会话；
     */
    func callAnswer(sessionId: String, pubLocalAudio: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置对端视频显示控件，如果不设置则不显示对端视频
     * @param sessionId : 会话唯一标识
     * @param peerView: 对端视频显示控件
     * @return 错误码，XOK--设置成功； XERR_INVALID_PARAM--没有找到该会话； XERR_UNSUPPORTED--设置失败
     */
    func setPeerVideoView(sessionId:String, peerView: UIView?) -> Int
    
    /*
     * @brief 禁止/启用 本地音频推流到对端
     * @param sessionId : 会话唯一标识
     * @param mute: 是否禁止
     * @param result:(参数1:错误码，参数2:提示信息) 错误码，XOK--设置成功； XERR_INVALID_PARAM--没有找到该会话； XERR_UNSUPPORTED--设置失败
     */
    func muteLocalAudio(sessionId:String, mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 拉流对端视频
     * @param sessionId : 会话唯一标识
     * @param mute: 是否禁止
     * @param result: (参数1:错误码，参数2:提示信息) 错误码，XOK--设置成功； XERR_INVALID_PARAM--没有找到该会话； XERR_UNSUPPORTED--设置失败
     */
    func mutePeerVideo(sessionId:String, mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 拉流对端音频
     * @param sessionId : 会话唯一标识
     * @param mute: 是否禁止
     * @param result: (参数1:错误码，参数2:提示信息) 错误码，XOK--设置成功； XERR_INVALID_PARAM--没有找到该会话； XERR_UNSUPPORTED--设置失败
     */
    func mutePeerAudio(sessionId:String, mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置音频播放的音量
     * @param volumeLevel: 音量级别
     * @param result: (参数1:错误码，参数2:提示信息) 错误码，XOK--设置成功； XERR_UNSUPPORTED--设置失败
     */
    func setVolume(volumeLevel: Int,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置音效效果（通常是变声等音效）
     * @param sessionId : 会话唯一标识
     * @param effectId: 音效Id
     * @param result: (参数1:错误码，参数2:提示信息) 错误码，XOK--设置成功；XERR_UNSUPPORTED--设置失败
     */
    func setAudioEffect(effectId: AudioEffectId,result:@escaping(Int,String)->Void)
    
    /*
     * @brief 开始录制当前通话（包括音视频流），仅在通话状态下才能调用
     * @param outFilePath : 输出保存的视频文件路径（应用层确保文件有可写权限,以.mp4为后缀，比如：../Documents/VideoFile/out_test810C3162.mp4）
     * @param result: result:(参数1:错误码，参数2:提示信息) 错误码，XOK--开始录制成功； XERR_INVALID_PARAM--没有找到该会话
     */
    func talkingRecordStart(sessionId: String, outFilePath:String, result:@escaping(Int,String)->Void)

    /*
     * @brief 停止录制当前通话，仅在通话状态下才能调用
     * @param sessionId : 会话唯一标识
     * @param result: (参数1:错误码，参数2:提示信息) 错误码，XOK--开始录制成功； XERR_INVALID_PARAM--没有找到该会话；
     */
    func talkingRecordStop(sessionId:String, result:@escaping(Int,String)->Void)
    
    /*
     * @brief 屏幕截屏，仅在通话状态下才能调用
     * @param sessionId : 会话唯一标识
     * @param result: (参数1:错误码，参数2:提示信息，参数3:位图信息)错误码，XOK--截图请求成功； XERR_INVALID_PARAM--没有找到该会话； XERR_UNSUPPORTED--截图失败
     */
    func capturePeerVideoFrame(sessionId:String, result:@escaping(Int,String,UIImage?)->Void)
    
    /*
     * @brief 获取当前网络状态
     * @return 返回RTC网络状态信息，如果当前没有任何一个会话，则返回null
     */
    func getNetworkStatus()->RtcNetworkStatus
    
    /*
     * @brief 设置RTC私有参数
     * @param privateParam : 要设置的私参
     * @return 错误码，XOK--设置成功； XERR_UNSUPPORTED--设置失败
     */
    func setRtcPrivateParam(privateParam : String)->Int
    
    
    /*
     * @brief  注册收到对端rtm消息监听
     * @return 错误码，XOK--设置成功； XERR_UNSUPPORTED--设置失败  
     * @param receivedListener: sessionId: 会话唯一标识 cmd: 收到的命令数据
     */
    func onReceivedCommand(receivedListener: @escaping (_ sessionId:String,_ cmd:String) -> Void)
    
    /*
     * @brief 发送rtm消息
     * @param  cmd: 发送的命令数据
     * @return 错误码，XOK--设置成功； XERR_UNSUPPORTED--设置失败  cmd: 发送的命令数据
     * @param cmdListener: 命令完成回调 错误码，XOK--设置成功； XERR_UNSUPPORTED--设置失败 sessionId: 会话唯一标识 cmd: 发送的命令数据
     */
    func sendCommand(sessionId:String,cmd:String,onCmdSendDone: @escaping (_ errCode:Int) -> Void) -> Int
    
}
