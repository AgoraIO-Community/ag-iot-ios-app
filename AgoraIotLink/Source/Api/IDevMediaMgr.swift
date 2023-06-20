//
//  IDevMediaMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation


/*
 * @brief 分页查询文件参数，可以进行查询组合
 */
public class QueryParam : NSObject {
    @objc public var mFileId: UInt64 = 0             //文件Id, 0表示则返回根目录文件夹目录
    @objc public var mBeginTimestamp: UInt64 = 0     //查询时间段的开始时间戳，单位秒
    @objc public var mEndTimestamp: UInt64 = 0       //查询时间段的结束时间戳，单位秒
    @objc public var mPageIndex: Int = 0             //查询开始的页索引，从1开始
    @objc public var mPageSize: Int = 0              //一页文件数量
    
    public init(mFileId:UInt64 ,
                mBeginTimestamp:UInt64,
                mEndTimestamp:UInt64,
                mPageIndex:Int,
                mPageSize:Int){
        self.mFileId = mFileId
        self.mBeginTimestamp = mBeginTimestamp
        self.mEndTimestamp = mEndTimestamp
        self.mPageIndex = mPageIndex
        self.mPageSize = mPageSize
    }
}

/*
 * @brief 查询到的 设备媒体项
 */
public class DevMediaItem : NSObject {
    @objc public var mFileId: UInt64 = 0              //媒体文件Id，是文件唯一标识
    @objc public var mStartTimestamp: UInt64 = 0      //录制开始时间，单位秒
    @objc public var mStopTimestamp: UInt64 = 0       //录制结束时间，单位秒
    @objc public var mType: Int = 0                   //文件类型：0--媒体文件；1--目录
    @objc public var mEvent: Int = 0                  //事件类型：0-全部事件、1-页面变动、2-有人移动
    @objc public var mImgUrl : String = ""            //录像封面图片URL地址
    @objc public var mVideoUrl : String = ""          //录像下载的URL地址
    
    public init(mFileId:UInt64 ,
                mStartTimestamp:UInt64,
                mStopTimestamp:UInt64,
                mType:Int,
                mEvent:Int,
                mImgUrl:String,
                mVideoUrl:String){
        self.mFileId = mFileId
        self.mStartTimestamp = mStartTimestamp
        self.mStopTimestamp = mStopTimestamp
        self.mType = mType
        self.mEvent = mEvent
        self.mImgUrl = mImgUrl
        self.mVideoUrl = mVideoUrl
    }
}

/*
 * @brief 设备端单个文件媒体信息
 */
public class DevMediaInfo : NSObject {
    @objc public var mMediaUrl: String = ""              //媒体文件Url
    @objc public var mDuration: UInt64 = 0               //播放时长，单位ms
    @objc public var mVideoWidth: Int = 0                //视频帧宽度
    @objc public var mVideoHeight: Int = 0               //视频帧高度
    
    public init(mMediaUrl:String ,
                mDuration:UInt64,
                mVideoWidth:Int,
                mVideoHeight:Int){
        self.mMediaUrl = mMediaUrl
        self.mDuration = mDuration
        self.mVideoWidth = mVideoWidth
        self.mVideoHeight = mVideoHeight
    }
}


/*
 * @brief 设备信息，(productKey+mDeviceId) 构成设备唯一标识
 */
public class DevMediaDelResult : NSObject {
    @objc public var mFileId: UInt64 = 0             //本地用户的 UserId
    @objc public var mErrCode: Int = 0               //要连接设备的 DeviceId
}

/*
 * @brief 设备媒体文件播放状态机
 */
@objc public enum DevMediaStatus : Int{
    case stopped                                       //当前播放器关闭
    case playing                                      //当前正在播放
    case paused                                       //当前暂停播放
    case seeking                                      //当前正在SEEK操作
}

/*
 * @brief 设备端媒体文件管理器
 */
public protocol IDevMediaMgr {
    
    
    /**
     * @brief 根据查询条件来分页查询相应的设备端 媒体文件列表，该方法是异步调用，通过回调返回查询结果
     * @param queryParam: 查询参数
     * @param queryListener : 查询结果回调监听器
     * @return 返回错误码
     */
    func queryMediaList(queryParam:QueryParam,queryListener: @escaping (_ errCode:Int,_ mediaList:[DevMediaItem]) -> Void)
    
    
    /**
     * @brief 根据媒体文件的Url来删除设备端多个媒体文件，该方法是异步调用，通过回调返回删除结果
     * @param deletingList: 要删除的 媒体文件Url的列表
     * @param deleteListener : 删除结果回调监听器
     * @return 返回错误码
     */
    func deleteMediaList(deletingList:[UInt64],deleteListener: @escaping (_ errCode:Int,_ undeletedList:[DevMediaDelResult]) -> Void)
    
    
    /**
     * @brief 设置播放器视频帧显示控件
     * @param displayView: 视频帧显示控件
     * @return 返回错误码
     */
    func setDisplayView(peerView: UIView?)
    
    //todo:
    //play
    
    
    /**
     * @brief 停止当前播放，成功后切换到 DEVPLAYER_STATE_STOPPED 状态
     * @return 错误码
     */
    func stop()->Int
    
    
    /**
     * @brief 暂停播放，切换到 DEVPLAYER_STATE_PAUSED 状态
     * @return 错误码
     */
    func pause()->Int
    
    /**
     * @brief 恢复暂停的播放，切换到 DEVPLAYER_STATE_PLAYING 状态
     * @return 错误码
     */
    func resume()->Int
    
    /**
     * @brief 直接跳转播放进度，先切换成 DEVPLAYER_STATE_SEEKING状态，之后切换回原先 播放/暂停状态
     * @param seekPos: 需要跳转到的目标时间戳，单位ms
     * @return 返回错误码
     */
    func seek(seekPos:UInt64)->Int
    
    /**
     * @brief 设置快进、快退播放倍速，默认是正常播放速度（speed=1）
     * @param speed: 固定几个倍速：-4；-2；1；2；4
     * @return 返回错误码
     */
    func setPlayingSpeed(speed:Int)->Int
    
    /**
     * @brief 获取当前播放的时间戳，单位ms
     * @return 播放进度时间戳
     */
    func getPlayingProgress()->UInt64
    
    /**
     * @brief 获取当前播放状态机
     * @return 返回当前播放状态
     */
    func getPlayingState()->Int
}
