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
 * @brief 初始化参数
 */
public class InitParam : NSObject{
    @objc public var rtcAppId: String = ""      ///appId
    @objc public var logFilePath : String? = nil    ///< 设置日志路径
    @objc public var publishAudio = true    ///< 通话时是否推流本地音频
    @objc public var publishVideo = false    ///< 通话时是否推流本地视频
    @objc public var subscribeAudio = true  ///< 通话时是否订阅对端音频
    @objc public var subscribeVideo = true  ///< 通话时是否订阅对端视频
    @objc public var ntfAppKey: String = "" ///<离线推送的appkey
    @objc public var ntfApnsCertName:String = ""///<离线推送的AnpsCertName
    @objc public var masterServerUrl:String = ""   ///< 主服务器后台地址
    @objc public var slaveServerUrl:String = ""   ///< 副服务器后台地址
    @objc public var projectId:String = ""  ///< 项目Id,作为查询产品列表的过滤条件
}

/*
 * @brief sdk状态
 */
@objc public enum SdkStatus : Int{
    case NotReady           //登录成功但还在初始化各个子模块中，处于未就绪状态
    case InitCallFail       //登录成功后，初始化呼叫模块出错
    case InitMqttFail       //登录成功后，初始化Mqtt模块出错
    case InitPushFail       //登录成功后，初始化推送模块出错
    case InitRtmFail        //登录成功后，初始化RTM模块出错
    case AllReady           //登录成功后，初始化过程完毕，处于就绪状态
    case Reconnected        //登录成功后，Mqtt重连成功
    case Disconnected       //登录成功后，Mqtt断开连接
}

/*
 * @brief SDK引擎接口
 */
public protocol IAgoraIotAppSdk {
    /*
     * @biref 获取sdk版本信息
     */
    func getSdkVersion()->String
    /*
     * @brief 初始化Sdk
     * @param netStatus:返回当前mqtt网络状态
     * @param callBackFilter：回调函数返回错误码集中回调(可作为返回错误码/错误消息)过滤。所有带有result回调的接口，都会在调用前触发该回调，参数1:ErrCode,参数2:ErrMessage,返回值:新的(ErrCode,ErrMessage)
     */
    func initialize(initParam: InitParam,sdkStatus:@escaping(SdkStatus,String)->Void,callbackFilter:@escaping(Int,String)->(Int,String)) -> Int

    /*
     * @brief 释放SDK所有资源
     */
    func release()

    /*
     * @brief 获取账号管理接口
     */
    var accountMgr: IAccountMgr{get}

    /*
     * @brief 获取呼叫系统接口
     */
    var callkitMgr: ICallkitMgr{get}

    /*
     * @brief 获取设备管理接口
     */
    var deviceMgr: IDeviceMgr{get}

    /*
     * @brief 获取告警信息管理接口
     */
    var alarmMgr: IAlarmMgr{get}

    /*
     * @brief 获取通知信息管理接口
     */
    var notificationMgr: INotificationMgr{get}
}

public let IAgoraIotSdkVersion = "1.1.0.3"
