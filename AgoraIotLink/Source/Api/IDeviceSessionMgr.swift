//
//  IDeviceSessionMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/18.
//

import Foundation


/*
 * @brief 设备信息，(productKey+mDeviceId) 构成设备唯一标识
 */
public class ConnectParam : NSObject {
    @objc public var mUserId: String = ""             //本地用户的 UserId
    @objc public var mPeerDevId: String = ""          //要连接设备的 DeviceId
    @objc public var mLocalRtcUid: UInt = 0           //本地 RTC uid
    @objc public var mChannelName: String = ""        //要会话的RTC频道名
    @objc public var mRtcToken: String = ""           //要会话的RTC Token
    @objc public var mRtmToken: String = ""           //要会话的 RTM Token
    
    @objc public init(mUserId:String ,
                mPeerDevId:String,
                mLocalRtcUid:UInt,
                mChannelName:String,
                mRtcToken:String,
                mRtmToken:String){
        self.mUserId = mUserId
        self.mPeerDevId = mPeerDevId
        self.mLocalRtcUid = mLocalRtcUid
        self.mChannelName = mChannelName
        self.mRtcToken = mRtcToken
        self.mRtmToken = mRtmToken
    }
}

/*
 * @brief 会话信息
 */
@objc public class SessionInfo : NSObject{
    
    public var mSessionId:String = ""                 //会话的唯一标识
    public var mUserId:String = ""                    //当前用户的 UserId
    public var mPeerDevId:String = ""                 //对端设备的 DeviceId
    @objc public var mLocalRtcUid: Int = 0            //本地 RTC uid
    @objc public var mChannelName: String = ""        //要会话的RTC频道名
    @objc public var mRtcToken: String = ""           //要会话的RTC Token
    @objc public var mRtmToken: String = ""           //要会话的 RTM Token
    public var mState:CallState = .idle               //会话的状态机
    
    public var mAttachMsg:String = ""                 // 呼叫或者来电时的附带消息
    public var mType: Int = 0                         // 会话类型 1主叫，2被叫
     
}

/*
 * @brief 与对端通话时的产生的行为/事件
 */
@objc public enum SessionCallback:Int{
    case onConnectDone           //设备连接连接完成
    case onDisconnected          //设备断开连接
    case onError                 //会话错误
    case UnknownAction           //未知错误
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
 * @brief 设备连接接口
 */
public protocol IDeviceSessionMgr {
    
    
    /**
     * @brief 连接设备，每次连接设备会产生一个会话，并且自动分配sessionId，作为连接的唯一标识
     * @param connectParam : 设备连接参数
     * @param sessionCallback  : 设备回调
     * @param memberState: 多人通话时他人的状态，uid:成员uid ,sessionId
     */
    func connect(
        connectParam: ConnectParam,
        sessionCallback:@escaping(SessionCallback,_ sessionId:String,_ errCode:Int)->Void,
        memberState:((_ state:MemberState,_ uid:[UInt],String)->Void)?)
  
    
    /**
     * @brief 断开设备连接，同步调用，会断开设备所有的连接并且停止所有的预览、控制处理等
     * @param sessionId : 设备连接会话Id
     * @return 返回错误码
     */
    func disconnect(sessionId:String)->Int
    
    
    /**
     * @brief 获取当前所有的会话列表
     * @return 返回当前活动的会话列表
     */
    func getSessionList()->[SessionInfo]
   
    
    /**
     * @brief 根据 sessionId 获取会话状态信息
     * @param sessionId : 会话唯一标识
     * @return 返回会话信息，如果没有查询到会话，则返回null
     */
    func getSessionInfo(sessionId:String)->SessionInfo
    
    
    /**
     * @brief 获取设备预览的组件接口
     * @param sessionId : 会话唯一标识
     * @return 返回该会话的预览控制接口
     */
    func getDevPreviewMgr(sessionId:String)->IDevPreviewMgr?
    
}
