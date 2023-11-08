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
@objc public class QueryParam : NSObject {
    @objc public var mFileId: String = ""            //文件Id, 0表示则返回根目录文件夹目录
    @objc public var mBeginTimestamp: UInt64 = 0     //查询时间段的开始时间戳，单位秒
    @objc public var mEndTimestamp: UInt64 = 0       //查询时间段的结束时间戳，单位秒
//    @objc public var mPageIndex: Int = 0             //查询开始的页索引，从1开始
//    @objc public var mPageSize: Int = 0              //一页文件数量
    
    @objc public init(mFileId:String ,
                mBeginTimestamp:UInt64,
                mEndTimestamp:UInt64){
        self.mFileId = mFileId
        self.mBeginTimestamp = mBeginTimestamp
        self.mEndTimestamp = mEndTimestamp
//        self.mPageIndex = mPageIndex
//        self.mPageSize = mPageSize
    }
}


/*
 * @brief 查询到的有视频内容的日期
 */
@objc public class DevMediaGroupItem : NSObject {
    @objc public var mStartTime: UInt64 = 0                  //设备录像文件的开始时间（时间戳精确到秒）
    @objc public var mStopTime: UInt64 = 0                   //设备录像文件的结束时间（时间戳精确到秒）
    @objc public var mPicUrl : String = ""                   //设备录像封面图片地址
    
    @objc public init(mStartTime:UInt64,
                      mStopTime:UInt64,
                      mPicUrl:String){
        self.mStartTime = mStartTime
        self.mStopTime = mStopTime
        self.mPicUrl = mPicUrl
    }
}

/*
 * @brief 查询到的 设备媒体项
 */
@objc public class DevMediaItem : NSObject {
    @objc public var mFileId: String = ""                       //设备录像文件Id，是文件的唯一标识
    @objc public var mStartTimestamp: UInt64 = 0                //录制开始时间，单位秒
    @objc public var mStopTimestamp: UInt64 = 0                 //录制结束时间，单位秒
    @objc public var mType: Int = 0                             //文件类型：0-文件、1-文件夹
    
    @objc public init(mFileId:String ,
                mStartTimestamp:UInt64,
                mStopTimestamp:UInt64,
                mType:Int){
        self.mFileId = mFileId
        self.mStartTimestamp = mStartTimestamp
        self.mStopTimestamp = mStopTimestamp
        self.mType = mType
    }
}

/*
 * @brief 查询到的 设备事件项
 */
@objc public class DevEventItem : NSObject {
    @objc public var mEventType: UInt = 0                    //告警类型：0-画面变动、1-异常情况、2-有人移动、3-异常响声、4-宝宝哭声
    @objc public var mStartTime: UInt64 = 0                  //设备录像文件的开始时间（时间戳精确到秒）
    @objc public var mStopTime: UInt64 = 0                   //设备录像文件的结束时间（时间戳精确到秒）
    @objc public var mPicUrl : String = ""                   //设备录像封面图片地址
    @objc public var mVideoUrl : String = ""                 //设备录像下载地址
    
    @objc public init(mEventType:UInt ,
                      mStartTime:UInt64,
                      mStopTime:UInt64,
                      mPicUrl:String,
                      mVideoUrl:String){
        self.mEventType = mEventType
        self.mStartTime = mStartTime
        self.mStopTime = mStopTime
        self.mPicUrl = mPicUrl
        self.mVideoUrl = mVideoUrl
    }
}


/*
 * @brief 设备端单个文件媒体信息
 */
@objc public class DevMediaInfo : NSObject {
    @objc public var mMediaUrl: String = ""              //媒体文件Url
    @objc public var mDuration: UInt64 = 0               //播放时长，单位ms
    @objc public var mVideoWidth: Int = 0                //视频帧宽度
    @objc public var mVideoHeight: Int = 0               //视频帧高度
    
    @objc public init(mMediaUrl:String ,
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
@objc public class DevMediaDelResult : NSObject {
    @objc public var mFileId: String = ""            //媒体文件Id，是文件唯一标识
    @objc public var mErrCode: Int = 0               //错误码
    @objc public var mStartTime: UInt64 = 0          //文件夹开始时间戳
    @objc public var mStopTime: UInt64 = 0           //文件夹结束时间戳
    
    @objc public init(mFileId:String ,
                      mErrCode:Int,
                      mStartTime: UInt64,
                      mStopTime: UInt64){
        self.mFileId = mFileId
        self.mErrCode = mErrCode
        self.mStartTime = mStartTime
        self.mStopTime = mStopTime
    }
}

/*
 * @brief 设备信息，(productKey+mDeviceId) 构成设备唯一标识
 */
@objc public class DevFileDownloadResult : NSObject {
    @objc public var mFileId: String = ""            //媒体文件Id，是文件唯一标识
    @objc public var mFileName: String = ""          //单个文件项全录节目
    
    @objc public init(mFileId:String ,
                      mFileName:String){
        self.mFileId = mFileId
        self.mFileName = mFileName
    }
}

/*
 * @brief 设备媒体文件播放状态机
 */
@objc public enum DevMediaStatus : Int{
    case stopped                                      //当前播放器关闭
    case opening                                      //正在打开媒体文件
    case playing                                      //当前正在播放
    case pausing                                      //正在暂停当前播放
    case paused                                       //当前播放已经暂停
    case resuming                                     //正在恢复当前播放
    case seeking                                      //当前正在SEEK操作
}

/*
 *@brief 设备媒体文件 播放回调接口
 */
@objc public protocol IPlayingCallbackListener{
    
    /**
     * @brief 设备媒体文件打开完成事件
     * @param mediaUrl : 媒体文件Id
     * @param errCode : 错误码，0表示打开成功直接播放，切换为 DEVPLAYER_STATE_PLAYING 状态
     *                  其他值表示打开失败，状态还是原先的 DEVPLAYER_STATE_STOPPED 状态
     */
    func onDevMediaOpenDone(fileId:String,errCode:Int)
    
    /**
     * @brief 媒体文件播放完成事件，此时状态机切换为 DEVPLAYER_STATE_STOPPED 状态
     * @param fileId : 媒体文件Id
     */
    func onDevMediaPlayingDone(fileId:String)
    
    /**
     * @brief 暂停操作完成事件
     * @param fileId : 媒体文件Id
     * @param errCode : 错误码，0表示暂停成功，状态切换为 DEVPLAYER_STATE_PAUSED；
     *                        其他值表示暂停失败，状态还是原先的 DEVPLAYER_STATE_PLAYING 状态
     */
    func onDevMediaPauseDone(fileId:String,errCode:Int)
    
    /**
     * @brief 恢复操作完成事件
     * @param fileId : 媒体文件Id
     * @param errCode : 错误码，0表示恢复成功，状态切换为 DEVPLAYER_STATE_PLAYING；
     *                        其他值表示暂停失败，状态还是原先的 DEVPLAYER_STATE_PAUSED 状态
     */
    func onDevMediaResumeDone(fileId:String,errCode:Int)
    
    /**
     * @brief 设备媒体文件Seek完成事件
     * @param fileId : 媒体文件Id
     * @param errCode : 错误码，0表示Seek成功
     * @param targetPos : 要seek到的时间戳
     * @param seekedPos : 实际跳转到的时间戳
     */
    func onDevMediaSeekDone(fileId:String,errCode:Int,targetPos:UInt64,seekedPos:UInt64)
    
    /**
     * @brief 播放过程中遇到错误，并且不能恢复，此时上层只能调用 stop()关闭播放器
     * @param fileId : 媒体文件Id
     * @param errCode : 错误码
     */
    func onDevPlayingError(fileId:String,errCode:Int)
    
}

/*
 * @brief 设备端媒体文件管理器
 */
@objc public protocol IDevMediaMgr {
    
    /**
     * @brief 根据查询条件来查询有视频内容的日期
     * @param queryParam: 查询参数
     * @param queryListener : 查询结果回调监听器
     * @return 返回错误码
     */
    func queryMediaGroupList(queryParam: QueryParam, queryListener: @escaping (_ errCode:Int, _ groupList:[DevMediaGroupItem]) -> Void)
    
    /**
     * @brief 根据媒体文件夹的start和end来删除，该方法是异步调用，通过回调返回删除结果
     * @param deletingList: 要删除的 媒体文件夹列表
     * @param deleteListener : 删除结果回调监听器
     * @return 返回错误码
     */
    func deleteMediaGroupList(deletingList: [Dictionary<String,Any>], deleteListener: @escaping (Int, [DevMediaDelResult]) -> Void)
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
    func deleteMediaList(deletingList:[String],deleteListener: @escaping (_ errCode:Int,_ undeletedList:[DevMediaDelResult]) -> Void)
    
    /**
     * @brief 根据图片路径查询图片内容（新增）
     * @param cmdListener: 命令完成回调(errCode : 查询结果错误码，0标识查询成功,imgUrl : 封面文件路径,coverData : 封面图像的数据)
     * @return 返回错误码
     */
    func getMediaCoverData(imgUrlList:[String],cmdListener: @escaping (_ errCode:Int, _ result:Any) -> Void)
    
    
    /**
     * @brief 设置播放器视频帧显示控件
     * @param displayView: 视频帧显示控件
     * @return 返回错误码
     */
    func setDisplayView(displayView: UIView?)->Int
    
    /**
     * @brief 开始播放，先切换到 DEVPLAYER_STATE_OPENING 状态
     *        操作完成后触发 onDevMediaOpenDone() 回调，并且更新状态
     * @param globalStartTime: 全局开始时间
     * @param playingCallback : 播放回调接口
     * @return 返回错误码
     */
    func playTimeline(globalStartTime:UInt64,playSpeed:Int,playingCallListener:IPlayingCallbackListener)->Int
    
    
    /**
     * @brief  获取当前回看SD卡存储录像的进度
     * @param queryListener : 回调接口(errCode：错误码 ，offSet:当前播放文件的开始时间（时间戳秒）+播放的进度（秒）)
     * @return 返回错误码
     */
    func getCurrentTimelineOffset(queryTimeLineOffsetListener: @escaping (_ errCode:Int,_ offSet :UInt64)->Void)
    
    
    /**
     * @brief 开始播放，先切换到 DEVPLAYER_STATE_OPENING 状态
     *        操作完成后触发 onDevMediaOpenDone() 回调，并且更新状态
     * @param fileId: 要播放的媒体文件Id
     * @param startPos: 开始播放的开始时间点
     * @param playSpeed: 播放倍速
     * @param playingCallback : 播放回调接口
     * @return 返回错误码
     */
    func play(fileId:String,startPos:UInt64,playSpeed:Int,playingCallListener:IPlayingCallbackListener)->Int
     
    /**
     * @brief 停止当前播放，成功后切换到 DEVPLAYER_STATE_STOPPED 状态
     * @return 错误码
     */
    func stop(fileId: String)->Int
    
    /**
    * @brief 停止时间轴播放，成功后切换到 DEVPLAYER_STATE_STOPPED 状态
    * @return 错误码
    */
   func stopGlobal()->Int
    
    
    /**
     * @brief 暂停播放，切换到 DEVPLAYER_STATE_PAUSED 状态
     *        操作完成后触发 onDevMediaPauseDone() 回调，并且更新状态
     * @return 错误码
     */
    func pause()->Int
    
    /**
     * @brief 恢复暂停的播放，切换到 DEVPLAYER_STATE_PLAYING 状态
     *        操作完成后触发 onDevMediaResumeDone() 回调，并且更新状态
     * @return 错误码
     */
    func resume()->Int
    
    /**
     * @brief 获取当前播放的时间戳，单位ms
     * @return 播放进度时间戳
     */
    func getPlayingProgress()->UInt64
    
    /**
     * @brief 获取当前播放状态机
     * @return 返回当前播放状态
     */
    func getPlayingState() -> DevMediaStatus
    
    /**
      * @brief 设置播放过程中是否有声音
      * @param mute: true--播放静音；  false--正常播放
      * @result: 调用该接口是否成功
      */
    func setAudioMute(mute:Bool,result:@escaping (Int,String)->Void)
    
    /**
     * @brief 根据媒体文件的filedId来下载设备端多个文件，该方法是异步调用，通过回调返回下载结果
     * @param filedIdList: 要下载的 媒体文件filedId的列表,fileid建议为文件的绝对路径
     * @param OnDownloadListener : 下载结果回调监听器
     * @return 返回错误码
     */
    func DownloadFileList(filedIdList:[String], onDownloadListener: @escaping (Int,[DevFileDownloadResult]) -> Void)
    
    /**
     * @brief 查询事件分布，该方法是异步调用，通过回调返回查询结果
     * @param OnQueryEventListener : 查询结果回调监听器(errCode : 查询结果错误码，0标识查询成功,videoTimeList : 视频时间戳列表)
     * @return 返回错误码
     */
    func queryEventTimeline(onQueryEventListener: @escaping (_ errCode:Int, _ videoTimeList : [UInt64]) -> Void)
    
    
}
