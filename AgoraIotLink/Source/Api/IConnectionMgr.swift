//
//  IConnectionMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2024/2/19.
//

import Foundation



/*
 * @brief 链接管理产生的行为/事件
 */
@objc public enum ConnectCallback:Int{
    case onConnectDone               //链接创建完成事件
    case onDisconnected              //正常连接成功后，对端主动断开链接事件
}

/*
 *@brief 链接操作的回调接口
 */
@objc public protocol IConnectionMgrListener{
    
    /**
     * @brief 链接创建完成事件
     * @param connectObj : 链接对象
     * @param errCode : 创建错误码，XOK----表示创建成功
     *                           XERR_UNSUPPORTED----本地端连接时产生错误
     *                           XERR_HTTP_RESP_CODE----服务器返回连接失败
     *                           XERR_INVALID_PARAM----服务器返回连接失败，连接参数有错误
     *                           XERR_TIMEOUT----连接超时，对端无回应
     */
    func onConnectionCreateDone(connectObj:IConnectionObj?, errCode:Int)
    
    /**
     * @brief 正常连接成功后，对端主动断开链接事件
     * @param connectObj : 链接对象
     * @param errCode : 错误代码，0表示对端主动正常断开； 1表示因为网络问题对端掉线断开
     */
    func onPeerDisconnected(connectObj:IConnectionObj?, errCode:Int)
    
    /**
      * @brief 对端接听或者拒绝回应事件
      * @param connectObj : 链接对象
      * @param answer : true--表示对端接听;  false--表示对端拒绝
    */
    func onPeerAnswerOrReject(connectObj:IConnectionObj?, answer:Bool)
    
    
}

/*
 * @brief 创建链接的参数
 */
public class ConnectCreateParam : NSObject {
    @objc public var mPeerNodeId: String = ""          //要链接对端设备的 NodeId
    @objc public var mEncrypt: Bool = false            //开启内容加密
    @objc public var mAttachMsg: String = ""           //链接附带信息
    
    @objc public init(
                mPeerNodeId:String,
                mEncrypt:Bool,
                mAttachMsg:String){
        self.mPeerNodeId = mPeerNodeId
        self.mAttachMsg = mAttachMsg
        self.mEncrypt = mEncrypt
    }
}

/*
 * @brief 链接管理器接口
 */
public protocol IConnectionMgr {
    
    /**
     * @brief 注册回调接口
     * @param callBackListener : 回调接口
     * @return 返回错误码，XOK--注册成功； XERR_UNSUPPORTED--注册失败
     */
    func registerListener(connectionMgrListener:IConnectionMgrListener)->Int
    
    /**
     * @brief 注销回调接口
     * @return 返回错误码，XOK--注销成功； XERR_UNSUPPORTED--注销失败
     */
    func unregisterListener()->Int
    
    /**
     * @brief 创建新的链接，该方法是异步处理，链接创建结果通过 onConnectionCreateDone() 回调来通知
     * @param createParam : 链接创建参数
     * @return 如果创建成功，则返回 链接对象实例
     */
    func connectionCreate(
        connectParam: ConnectCreateParam)->IConnectionObj?
    
    /**
     * @brief 销毁指定的链接，该方法是同步处理
     * @param connectionId : 链接唯一标识
     * @return 错误码，XOK--销毁成功； XERR_UNSUPPORTED--销毁失败
     */
    func connectionDestroy(connectObj:IConnectionObj)->Int
    
    /**
     * @brief  获取当前所有链接对象的列表
     * @return 返回所有链接对象列表
     */
    func getConnectionList()->[IConnectionObj]?
    
    
}
