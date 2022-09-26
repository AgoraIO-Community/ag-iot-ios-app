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
     * @param productKey           : 对端制造商Id
     * @param deviceId             : 对端设备Id
     * @return 错误码
     */
    func queryByDevice(productKey: String, deviceId: String,result:@escaping(Int,String)->Void)

    /*
     * @brief 删除多个通知信息，触发 onNotificationDeleteDone() 回调
     * @param notificationIdList   : 要删除的通知信息Id列表
     * @return 错误码
     */
    func delete(notificationIdList: [String],result:@escaping(Int,String)->Void)

    /*
     * @brief 标记多个通知信息，触发 onNotificationMarkDone() 回调
     * @param markFlag             : 要标记的值
     * @param notificationIdList   : 要标记的通知信息Id列表
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
    /*
     * @brief 查询推送eid
     */
    func getEid()->String
}
