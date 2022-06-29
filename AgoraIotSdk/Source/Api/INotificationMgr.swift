/**
 * @file INotificationMgr.java
 * @brief This file define the interface of notification management
 * @author xiaohua.lu
 * @email luxiaohua@agora.io
 * @version 1.0.0.1
 * @date 2022-01-26
 * @license Copyright (C) 2021 AgoraIO Inc. All rights reserved.
 */

public class IotNotification {
    var mNotificationId ///< 通知信息Id，是通知信息唯一标识
            : String? = nil
    var mOccurTime ///< 通知时间
            : Date? = nil
    var mEvent ///< 通知事件
            : String? = nil
    var mMarkFlag ///< 标记信息
            = 0
  init() {
  }
}

/*
 * @brief 通知信息回调接口
 */
public protocol INotificationMgrCallback {
    /*
     * @brief 接收到一个新的通知事件
     * @param alarm : 通知消息
     */
    func onReceivedNotification(newNotification: IotNotification)

    /*
     * @brief 查询所有通知完成事件
     * @param errCode : 查询结果错误码，0表示查询成功
     * @param notificationList : 返回查询到的通知信息列表
     */
    func onAllNotificationQueryDone(
        errCode: Int,
        notificationList: Array<IotNotification?>?
    )

    /*
     * @brief 查询指定设备通知信息完成事件
     * @param errCode : 查询结果错误码，0表示查询成功
     * @param device : 指定设备信息
     * @param notificationList : 返回查询到的通知信息列表
     */
    func onDeviceNotificationQueryDone(
        errCode: Int, device: IotDevice?,
        notificationList: Array<IotNotification?>?
    )

    /*
     * @brief 通知删除完成回调
     * @param errCode : 通知删除结果错误码，0表示删除成功
     * @param deletedList : 返回成功删除的通知信息列表
     */
    func onNotificationDeleteDone(
        errCode: Int,
        deletedList: Array<IotNotification?>?
    )

    /*
     * @brief 通知标记完成回调
     * @param errCode : 通知标记结果错误码，0表示标记成功
     * @param markFlag : 标记值
     * @param markedList : 返回成功标记的通知信息列表
     */
    func onNotificationMarkDone(
        errCode: Int, markFlag: Int,
        markedList: Array<IotNotification?>?
    )
}
/*
 * @brief 通知管理接口
 */
public protocol INotificationMgr {
    /*
     * @brief 离线推送时需要AppDelegate穿出来的deviceToken
     */
    func updateToken(_ deviceToken:Data)

    /*
     * @brief 查询所有通知信息，触发 onAllNotificationQueryDone() 回调
     * @return 错误码
     */
    func queryAll(result:@escaping(Int,String)->Void)

    /*
     * @brief 查询指定设备的所有通知信息，触发 onDeviceNotificationQueryDone() 回调
     * @param productKey : 对端制造商Id
     * @param deviceId : 对端设备Id
     * @return 错误码
     */
    func queryByDevice(productKey: String, deviceId: String,result:@escaping(Int,String)->Void)

    /*
     * @brief 删除多个通知信息，触发 onNotificationDeleteDone() 回调
     * @param notificationIdList : 要删除的通知信息Id列表
     * @return 错误码
     */
    func delete(notificationIdList: [String],result:@escaping(Int,String)->Void)

    /*
     * @brief 标记多个通知信息，触发 onNotificationMarkDone() 回调
     * @param markFlag : 要标记的值
     * @param notificationIdList : 要标记的通知信息Id列表
     * @return 错误码
     */
    func mark(markFlag: Int, notificationIdList: [String],result:@escaping(Int,String)->Void)
    /*
     * @brief 是否接受推送消息
     */
    func enableNotify(enable:Bool,result:@escaping(Int,String)->Void)
    /*
     * @brief 查询是否接受推送消息
     */
    func notifyEnabled()->Bool
}
