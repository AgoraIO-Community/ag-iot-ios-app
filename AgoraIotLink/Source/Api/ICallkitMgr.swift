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

@objc public enum ActionAck:Int{
    
    case StateInited   //初始化呼叫状态
    case LocalHangup   //本地挂断
    case LocalAnswer   //本地接听
    case RemoteHangup  //设备挂断
    case RemoteAnswer  //设备接听
    case RemoteTimeout  //对端超时
    case RecordEnd      //云录停止
    case LocalTimeout   //呼叫超时
    case AcceptFail     //本地接听失败
    
    case RemoteVideoReady //首次收到设备视频
    case RemoteAudioReady //首次收到设备音频
    
    case RemoteBusy    //设备忙
    case CallIncoming  //设备来电振铃
    case CallForward   //本地去电中继
    case CallOutgoing  //本地去电振铃
    case UnknownAction //未知错误
}

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
public protocol ICallkitMgr {
    /*
     * @brief 注册来电通知
     * @param incoming: 参数1:设备名称，参数2: attahcMsg,参数3:CallIncoming,RemoteHangup,RemoteVideoReady
     */
    func register(incoming:@escaping(String,String,ActionAck)->Void)
    /*
     * @brief 呼叫设备
     * @param device     : 被呼叫设备
     * @param attachMsg  : 呼叫时附带的信息
     * @param result     : 调用该接口是否成功
     * @param actionAck  : callDial 通话中产生的事件
     */
    func callDial(
        device: IotDevice,
        attachMsg: String,
        result:@escaping(Int,String)->Void,
        actionAck:@escaping(ActionAck)->Void
    )

    /*
     * @brief 挂断当前通话
     * @param result     : 调用该接口是否成功
     */
    func callHangup(result:@escaping(Int,String)->Void)

    /*
     * @brief 接听当前来电
     * @param result     : 调用该接口是否成功
     * @param actionAck  : callAnswer 通话中的事件
     */
    func callAnswer(result:@escaping(Int,String)->Void,
                    actionAck:@escaping(ActionAck)->Void)

    /*
     * @brief 设置本地视频显示控件，如果不设置则不显示本地视频
     * @param localView: 本地视频显示控件
     * @return 错误码，0:成功
     */
    func setLocalVideoView(localView: UIView?) -> Int

    /*
     * @brief 设置对端视频显示控件，如果不设置则不显示对端视频
     * @param peerView: 对端视频显示控件
     * @return 错误码，0:成功
     */
    func setPeerVideoView(peerView: UIView?) -> Int

    /*
     * @brief 禁止/启用 本地视频推流到对端
     * @param mute: 是否禁止
     * @param result     : 调用该接口是否成功
     */
    func muteLocalVideo(mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 本地音频推流到对端
     * @param mute: 是否禁止
     * @param result     : 调用该接口是否成功
     */
    func muteLocalAudio(mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 拉流对端视频
     * @param mute: 是否禁止
     * @param result     : 调用该接口是否成功
     */
    func mutePeerVideo(mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 禁止/启用 拉流对端音频
     * @param mute: 是否禁止
     * @param result     : 调用该接口是否成功
     */
    func mutePeerAudio(mute: Bool,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置音频播放的音量
     * @param volumeLevel: 音量级别
     * @param result     : 调用该接口是否成功
     */
    func setVolume(volumeLevel: Int,result:@escaping(Int,String)->Void)

    /*
     * @brief 设置音效效果（通常是变声等音效）
     * @param effectId: 音效Id
     * @param result     : 调用该接口是否成功
     */
    func setAudioEffect(effectId: AudioEffectId,result:@escaping(Int,String)->Void)

    /*
     * @brief 开始录制当前通话（包括音视频流），仅在通话状态下才能调用
     * @param result     : 调用该接口是否成功
     */
    func talkingRecordStart(result:@escaping(Int,String)->Void)

    /*
     * @brief 停止录制当前通话，仅在通话状态下才能调用
     * @param result     : 调用该接口是否成功
     */
    func talkingRecordStop(result:@escaping(Int,String)->Void)
    
    /*
     * @brief 屏幕截屏，仅在通话状态下才能调用
     * @param result     : 调用该接口是否成功，以及截屏的位图
     */
    func capturePeerVideoFrame(result:@escaping(Int,String,UIImage?)->Void)
}
