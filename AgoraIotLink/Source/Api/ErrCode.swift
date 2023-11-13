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
 * @brief 全局错误码定义
 */
public class ErrCode : NSObject{
    // 0: 表示正确
    @objc public static let XERR_NONE = 0                               ///< 成功
    @objc public static let XOK = 0                                     ///< 成功
    //@objc public static let XERR_TOKEN_INVALID = -3                     ///< Token过期
    //
    // 通用错误码
    //
    @objc public static let XERR_BASE = -10000
    @objc public static let XERR_UNKNOWN = -10001                       ///< 未知错误
    @objc public static let XERR_INVALID_PARAM = -10002                 ///< 参数错误
    @objc public static let XERR_UNSUPPORTED = -10003                   ///< 当前操作不支持
    @objc public static let XERR_BAD_STATE = -10004                     ///< 当前状态不正确，不能操作
    @objc public static let XERR_NOT_FOUND = -10005                     ///< 没有找到相关数据
    @objc public static let XERR_NO_MEMORY = -10006                     ///< 内存不足
    @objc public static let XERR_BUFFER_OVERFLOW = -10007               ///< 缓冲区中数据不足
    @objc public static let XERR_BUFFER_UNDERFLOW = -10008              ///< 缓冲区中数据过多放不下
    @objc public static let XERR_TIMEOUT = -10009                       ///< 操作超时
    @objc public static let XERR_NETWORK = -10012                       ///< 网络错误
    @objc public static let XERR_TOKEN_INVALID = -10015                 ///< Token无效
    @objc public static let XERR_API_RET_FAIL = -10016                  ///< 调用依赖api返回失败
    //
    // 呼叫系统相关错误
    //
    @objc public static let XERR_CALLKIT_BASE = -40000
    @objc public static let XERR_CALLKIT_TIMEOUT = -40001                ///< 呼叫超时无响应
    @objc public static let XERR_CALLKIT_DIAL = -40002                   ///< 呼叫拨号失败
    @objc public static let XERR_CALLKIT_HANGUP = -40003                 ///< 呼叫挂断失败
    @objc public static let XERR_CALLKIT_ANSWER = -40004                 ///< 呼叫接听失败
    @objc public static let XERR_CALLKIT_REJECT = -40005                 ///< 呼叫拒绝失败
    @objc public static let XERR_CALLKIT_PEER_BUSY = -40006              ///< 对端忙
    @objc public static let XERR_CALLKIT_PEERTIMEOUT = -40007            ///< 对端超时无响应
    @objc public static let XERR_CALLKIT_LOCAL_BUSY = -40008             ///< 本地端忙
    @objc public static let XERR_CALLKIT_ERR_OPT = -40009                ///< 不支持的错误操作


}
