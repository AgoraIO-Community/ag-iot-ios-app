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
  
    @objc public var rtcAppId: String = ""              // appId
    @objc public var logFilePath : String? = ""         // 设置日志路径 ,nil:不保存到文件,"":保存到默认路径
    @objc public var projectId:String = ""              // 项目Id,作为查询产品列表的过滤条件
    @objc public var userId: String = ""                // 用户的登陆账号
}

/*
 * @brief SDK引擎接口
 */
public protocol IAgoraIotAppSdk {
    
    /*
     * @brief 初始化Sdk
     * @param callBackFilter：回调函数返回错误码集中回调(可作为返回错误码/错误消息)过滤。所有带有result回调的接口，都会在调用前触发该回调，参数1:ErrCode,参数2:ErrMessage,返回值:新的(ErrCode,ErrMessage)
     */
    func initialize(initParam: InitParam,callbackFilter:@escaping(Int,String)->(Int,String)) -> Int
    
    /*
     * @brief 释放SDK所有资源
     */
    func release()
    
    /*
     * @biref 获取sdk版本信息
     */
    func getSdkVersion()->String
    
    /*
     * @brief 获取设备连接管理接口
     */
    var deviceSessionMgr: IDeviceSessionMgr{get}
    
    /*
     * @brief 获取云录播放器管理接口
     */
    var vodPlayerMgr: IVodPlayerMgr{get}
    

    
}

public let IAgoraIotSdkVersion = "1.5.1.0"
