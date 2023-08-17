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
 * @brief SDK初始化参数
 */
public class InitParam : NSObject{
  
    @objc public var mAppId: String = ""                // 项目的 appId
    @objc public var logFilePath : String? = ""         // 设置日志路径 ,nil:不保存到文件,"":保存到默认路径
    @objc public var mServerUrl:String = ""             // 服务器后台地址
}

/*
 * @brief SDK就绪参数
 */
public class PrepareParam : NSObject{
    
    @objc public var mUserId: String = ""         // 用户 userId
    @objc public var mClientType: Int = 2         // 终端类型  1: Web;  2: Phone;  3: Pad;  4: TV;  5: PC;  6: Mini_app
}

/*
 * @brief SDK 状态机
 */
@objc public enum SdkState:Int {
    case invalid        // SDK未初始化
    case initialized    // SDK初始化完成，但还未就绪
    case preparing      // SDK正在就绪中
    case runing         // SDK就绪完成，可以正常使用
    case reconnecting   // SDK正在内部重连中，暂时不可用
    case unpreparing    // SDK正在注销处理，完成后切换到初始化完成状态
}

/*
 * @brief SDK 状态机变化原因
 */
@objc public enum StateChangeReason:Int {
    case none           // 未指定
    case prepareFail    // 节点prepare失败
    case network        // 网络状态原因
    case abort          // 节点被抢占激活
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
     * @biref 获取当前mqtt是否连接 连接:true 断开:false
     */
    func getMqttIsConnected() -> Bool

    /*
     * @brief 初始化Sdk
     * @param initParam : 初始化参数
     * @retrun 返回错误码，XOK--初始化成功，SDK状态会切换到 SDK_STATE_INITIALIZED
     *                   XERR_INVALID_PARAM--参数有错误；XERR_BAD_STATE--当前状态不正确
     * @param OnSdkStateListener：SDK状态机监听回调（参数1:当前状态，参数2:状态原因）
     */
    func initialize(initParam: InitParam,OnSdkStateListener:@escaping(SdkState,StateChangeReason)->Void) -> Int
    
    /*
     * @brief 释放SDK所有资源，所有的组件模块也会被释放
     *        调用该函数后，SDK状态会切换到 SDK_STATE_INVALID
     */
    func release()
    
    /**
     * @brief 获取SDK当前状态机
     * @return 返回当前 SDK状态机值，如：SDK_STATE_XXXX
     */
    func getStateMachine() -> SdkState?
    
    /**
     * @brief 就绪准备操作，仅在 SDK_STATE_INITIALIZED 状态下才能调用，异步调用，
     *        异步操作完成后，通过 prepareListener() 回调就绪操作结果
     *        如果就绪操作成功，则 SDK状态切换到 SDK_STATE_RUNNING 状态
     *        如果就绪操作失败，则 SDK状态切换回 SDK_STATE_INITIALIZED
     * @param prepareParam : 就绪操作的参数
     * @param prepareListener : 就绪操作监听器 errCode=0表示就绪成功 errCode=XERR_NETWORK 表示网络错误，请求失败
     * @return 返回错误码，XOK--就绪操作请求成功，SDK状态会切换到 SDK_STATE_PREPARING 开始异步就绪操作
     *                   XERR_BAD_STATE-- 当前 非SDK_STATE_INITIALIZED 状态下调用本函数
     */
    func prepare(preParam: PrepareParam,prepareListener:@escaping(Int,String)->Void) -> Int
    
    /**
     * @brief 逆就绪停止运行操作，仅在 SDK_STATE_RUNNING 或者 SDK_STATE_RECONNECTING 或者 SDK_STATE_PREPARING
     *         这三种状态下才能调用，同步调用
     *         该函数会触发SDK状态先切换到 SDK_STATE_UNPREPARING 状态，然后切换到 SDK_STATE_INITIALIZED 状态
     * @return 返回错误码， XOK--逆就绪操作请求成功，SDK状态会切换到 SDK_STATE_INITIALIZED
     *                   XERR_BAD_STATE-- 当前SDK状态不是 SDK_STATE_RUNNING 或者 SDK_STATE_RUNNING
     */
    func unprepare() -> Int
    
    /**
     * @brief 获取用户的userId
     * @return 返回当前就绪的 userId，如果当前还未就绪，则返回空字符串
     */
    func getUserId()->String
    
    /**
     * @brief 获取用户的NodeId
     * @return 返回当前就绪的 NodeId，如果当前还未就绪，则返回空字符串
     */
    func getUserNodeId()->String
    
    /*
     * @brief 获取呼叫系统接口
     * @return 返回呼叫组件接口，如果当前还未进行初始化，则返回null
     */
    var callkitMgr: ICallkitMgr{get}
    
    
    
    
    

    /*
     * @brief 获取账号管理接口
     */
    var accountMgr: IAccountMgr{get}

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

public let IAgoraIotSdkVersion = "2.1.0.0"
