//
//  IVodPlayerMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation


/*
 * @brief 设备端媒体文件管理器
 */
public protocol IVodPlayerMgr {
    
    /**
     * @brief 打开媒体文件准备播放，打开成功后播放进度位于开始0处，状态切换到 VODPLAYER_STATE_PAUSED
     * @param mediaUrl: 要播放的媒体文件URL，包含密码信息
     * @param callback : 播放回调接口
     * @return 返回错误码
     */
    func open(mediaUrl:String,callback: @escaping (_ errCode:Int,_ displayView:UIView) -> Void)
    
    /**
     * @brief 关闭当前播放器，释放所有的播放资源，状态切换到 VODPLAYER_STATE_CLOSED
     * @return 错误码
     */
    func close()
    
    /**
     * @brief 获取当前播放的时间戳，单位ms
     * @return 播放进度时间戳
     */
    func getPlayingProgress()->UInt64
    
    /**
     * @brief 设置播放器视频帧显示控件
     * @param displayView: 视频帧显示控件
     * @param frame: 视频帧显示控件的frame
     * @return 返回错误码
     */
    func setDisplayView(_ displayView:UIView, _ frame:CGRect)->Int
    
    /**
     * @brief 从当前进度开始播放，状态切换到 VODPLAYER_STATE_PLAYING
     * @return 错误码
     */
    func play()
    
    /**
     * @brief 暂停播放，状态切换到 VODPLAYER_STATE_PAUSED
     * @return 错误码
     */
    func pause()
    
    /**
     * @brief 暂停当前播放，并且将播放进度回归到开始0处，状态切换到 VODPLAYER_STATE_PAUSED
     * @return 错误码
     */
    func stop()
    
    /**
     * @brief 直接跳转播放进度
     * @param seekPos: 需要跳转到的目标时间戳，单位ms
     * @return 如果seek成功，返回实际跳转的时间戳； <0 表示seek失败，返回错误码
     */
    func seek(seekPos:UInt64)->UInt64;
    
    
}
