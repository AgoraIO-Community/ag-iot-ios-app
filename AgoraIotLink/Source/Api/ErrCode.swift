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
    ///
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
    @objc public static let XERR_SYSTEM = -10016                        ///< 系统错误
    @objc public static let XERR_APPID_INVALID = -10017                 ///< AppId不支持
    @objc public static let XERR_NODEID_INVALID = -10018                ///< NodeId无效
    @objc public static let XERR_NOT_AUTHORIZED = -10019                ///< 未认证
    @objc public static let XERR_INVOKE_TOO_OFTEN = -10020              ///< 调用太频繁
    @objc public static let  XERR_JSON_READ = -10022                    ///< JSON解析错误
    @objc public static let  XERR_JSON_WRITE = -10023                   ///< JSON写入错误
    
    //
    // 链接模块相应的错误
    //
    @objc public static let  XERR_CONNOBJ_BASE = -40000;
    @objc public static let XERR_CONNOBJ_SUBSCRIBE_CMD = -40001;    ///< 订阅命令发送失败
    @objc public static let XERR_CONNOBJ_NO_FRAME = -40002;         ///< 订阅后超时没有视频帧过来
    
    //
    // 消息模块相应的错误
    //
    @objc public static let XERR_RTMMGR_BASE = -50000;
    @objc public static let XERR_RTMMGR_LOGIN_UNKNOWN = -50001;            ///< RTM登录失败
    @objc public static let XERR_RTMMGR_LOGIN_REJECTED = -50002;           ///< RTM登录被拒绝
    @objc public static let XERR_RTMMGR_LOGIN_INVALID_ARGUMENT = -50003;   ///< RTM登录时参数错误
    @objc public static let XERR_RTMMGR_LOGIN_INVALID_APP_ID = -50004;     ///< RTM登录时appId错误
    @objc public static let XERR_RTMMGR_LOGIN_INVALID_TOKEN = -50005;      ///< RTM登录时token错误
    @objc public static let XERR_RTMMGR_LOGIN_TOKEN_EXPIRED = -50006;      ///< RTM登录时token过期
    @objc public static let XERR_RTMMGR_LOGIN_NOT_AUTHORIZED = -50007;     ///< RTM登录时鉴权失败
    @objc public static let XERR_RTMMGR_LOGIN_ALREADY_LOGIN = -50008;      ///< RTM已经登录
    @objc public static let XERR_RTMMGR_LOGIN_TIMEOUT = -50009;            ///< RTM登录超时
    @objc public static let XERR_RTMMGR_LOGIN_TOO_OFTEN = -50010;          ///< RTM登录太频繁
    @objc public static let XERR_RTMMGR_LOGIN_NOT_INITIALIZED = -50011;    ///< RTM未初始化
    @objc public static let XERR_RTMMGR_MSG_FAILURE = -50012;              ///< 发送RTM消息失败
    @objc public static let XERR_RTMMGR_MSG_TIMEOUT = -50013;              ///< 发送RTM消息超时
    @objc public static let XERR_RTMMGR_MSG_PEER_UNREACHABLE = -50014;     ///< 消息不可到达
    @objc public static let XERR_RTMMGR_MSG_CACHED_BY_SERVER = -50015;     ///< 消息未发送被缓存了
    @objc public static let XERR_RTMMGR_MSG_TOO_OFTEN = -50016;           ///< 消息发送太频繁
    @objc public static let XERR_RTMMGR_MSG_INVALID_USERID = -50017;       ///< RTM用户账号无效
    @objc public static let XERR_RTMMGR_MSG_INVALID_MESSAGE = -50018;      ///< RTM消息无效
    @objc public static let XERR_RTMMGR_MSG_IMCOMPATIBLE_MESSAGE = -50019; ///< 消息不兼容
    @objc public static let XERR_RTMMGR_MSG_NOT_INITIALIZED = -50020;      ///< RTM未初始化发消息
    @objc public static let XERR_RTMMGR_MSG_USER_NOT_LOGGED_IN = -50021;   ///< RTM未登录发消息
    @objc public static let XERR_RTMMGR_LOGOUT_REJECT = -50022;            ///< RTM登出被拒绝
    @objc public static let XERR_RTMMGR_LOGOUT_NOT_INITIALIZED = -50023;   ///< RTM未初始化登出
    @objc public static let XERR_RTMMGR_LOGOUT_NOT_LOGGED_IN = -50024;     ///< RTM未登录就登出
    @objc public static let XERR_RTMMGR_RENEW_FAILURE = -50025;            ///< RTM Renew token失败
    @objc public static let XERR_RTMMGR_RENEW_INVALID_ARGUMENT = -50026;   ///< RTM Renew参数错误
    @objc public static let XERR_RTMMGR_RENEW_REJECTED = -50027;           ///< RTM Renew被拒绝
    @objc public static let XERR_RTMMGR_RENEW_TOO_OFTEN = -50028;          ///< RTM Renew太频繁
    @objc public static let XERR_RTMMGR_RENEW_TOKEN_EXPIRED = -50029;      ///< RTM Renew过期
    @objc public static let XERR_RTMMGR_RENEW_INVALID_TOKEN = -50030;      ///< RTM Renew无效
    @objc public static let XERR_RTMMGR_RENEW_NOT_INITIALIZED = -50031;    ///< RTM未初始化Renew
    @objc public static let XERR_RTMMGR_RENEW_NOT_LOGGED_IN = -50032;      ///< RTM未登录就Renew
    
    
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
    @objc public static let XERR_CALLKIT_LOCAL_BUSY = -40007             ///< 本地端忙
    @objc public static let XERR_CALLKIT_ERR_OPT = -40008                ///< 不支持的错误操作
    
    
 
}
