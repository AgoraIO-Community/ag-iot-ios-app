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
 * @brief 声音特效类型
 */
@objc public enum AudioEffectId:Int{
    case NORMAL         ///< 原声
    case KTV            ///< KTV
    case CONCERT        ///< 演唱会
    case STUDIO         ///< 录音棚
    case PHONOGRAPH     ///< 留声机
    case VIRTUALSTEREO  ///< 虚拟立体声
    case SPACIAL        ///< 空旷
    case ETHEREAL       ///< 空灵
    case VOICE3D        ///< 3D人声
    case UNCLE          ///< 大叔
    case OLDMAN         ///< 老男人
    case BOY            ///< 男孩
    case SISTER         ///< 少女
    case GIRL           ///< 女孩
    case PIGKING        ///< 猪八戒
    case HULK           ///< 绿巨人 浩克
    case RNB            ///< R&B
    case POPULAR        ///< 流行
    case PITCHCORRECTION ///< 电音
}

/*
 * @brief SDK初始化参数
 */
public class InitParam : NSObject{
  
    @objc public var mAppId: String = ""                  // 项目的 appId
    @objc public var mLocalNodeId: String = ""            // 本地 NodeId
    @objc public var mLocalNodeToken: String = ""         // 本地 NodeToken
    @objc public var mRegion:Int = 1                      // 地区标识符
    @objc public var mCustomerKey: String = ""            // 定制认证的Key
    @objc public var mCustomerSecret: String = ""         // 定制认证的Secret
    @objc public var mLogFileName : String? = ""          // 日志文件名，路径会固定在应用缓存目录
    
}

/*
 * @brief SDK引擎接口
 */
public protocol IAgoraIotAppSdk {

    /*
     * @brief 初始化Sdk
     * @param initParam : 初始化参数
     * @retrun 返回错误码，XOK--初始化成功，SDK状态会切换到 SDK_STATE_INITIALIZED
     *                   XERR_INVALID_PARAM--参数有错误；XERR_BAD_STATE--当前状态不正确
     */
    func initialize(initParam: InitParam) -> Int
    
    /*
     * @brief 释放SDK所有资源，所有的组件模块也会被释放
     *        调用该函数后，SDK状态会切换到 SDK_STATE_INVALID
     */
    func release()
    
    /*
     * @brief 获取呼叫系统接口
     * @return 返回呼叫组件接口，如果当前还未进行初始化，则返回null
     */
    var connectionMgr: IConnectionMgr{get}
    
    /**
     * @brief 设置音效效果（通常是变声等音效）
     * @param effectId: 音效Id
     * @return 错误码，XOK--设置成功； XERR_UNSUPPORTED--设置失败
     */
    func setPublishAudioEffect(effectId:AudioEffectId, result: @escaping (Int, String) -> Void)->Int
    
    /**
     * @brief 获取当前推流的音效
     * @return 返回当前设置的音效
     */
    func getPublishAudioEffect()->AudioEffectId
    
    /*
     * @biref 获取sdk版本信息
     */
    func getSdkVersion()->String
    

}
