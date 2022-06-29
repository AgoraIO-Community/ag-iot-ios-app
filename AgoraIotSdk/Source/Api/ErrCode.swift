/**
 * @file ErrCode.java
 * @brief This file define the common error code for SDK
 * @author xiaohua.lu
 * @email luxiaohua@agora.io
 * @version 1.0.0.1
 * @date 2022-01-26
 * @license Copyright (C) 2021 AgoraIO Inc. All rights reserved.
 */

/*
 * @brief 全局错误码定义
 */
public class ErrCode : NSObject{
    // 0: 表示正确
    @objc public static let XERR_NONE = 0
    @objc public static let XOK = 0
    @objc public static let XERR_TOKEN_INVALID = -3        ///< Token过期
    //
    // 通用错误码
    //
    @objc public static let XERR_BASE = -10000
    @objc public static let XERR_UNKNOWN = -10001 ///< 未知错误
    @objc public static let XERR_INVALID_PARAM = -10002 ///< 参数错误
    @objc public static let XERR_UNSUPPORTED = -10003 ///< 当前操作不支持
    @objc public static let XERR_BAD_STATE = -10004 ///< 当前状态不正确，不能操作
    @objc public static let XERR_NOT_FOUND = -10005 ///< 没有找到相关数据
    @objc public static let XERR_NO_MEMORY = -10006 ///< 内存不足
    @objc public static let XERR_BUFFER_OVERFLOW = -10007 ///< 缓冲区中数据不足
    @objc public static let XERR_BUFFER_UNDERFLOW = -10008 ///< 缓冲区中数据过多放不下
    @objc public static let XERR_TIMEOUT = -10009 ///< 操作超时
    @objc public static let XERR_NETWORK = -10012              ///< 网络错误
    @objc public static let XERR_TOKEN_EXPIRED = -10015        ///< Token过期

    //
    // 账号相关错误
    //
    @objc public static let XERR_ACCOUNT_BASE = -30000;
    @objc public static let XERR_ACCOUNT_NOT_EXIST = -30001;        ///< 账号不存在
    @objc public static let XERR_ACCOUNT_ALREADY_EXIST = -30002;    ///< 账号已经存在
    @objc public static let XERR_ACCOUNT_PASSWORD_ERR = -30003;     ///< 密码错误
    @objc public static let XERR_ACCOUNT_NOT_LOGIN = -30004;        ///< 账号未登录
    @objc public static let XERR_ACCOUNT_REGISTER = -30005;         ///< 账号注册失败
    @objc public static let XERR_ACCOUNT_UNREGISTER = -30006;       ///< 账号注销失败
    @objc public static let XERR_ACCOUNT_LOGIN = -30007;            ///< 账号登录失败
    @objc public static let XERR_ACCOUNT_LOGOUT = -30008;           ///< 账号登出失败
    @objc public static let XERR_ACCOUNT_CHGPSWD = -30009;          ///< 账号更换密码失败@objc
    @objc public static let XERR_ACCOUNT_RESETPSWD = -30010;        ///< 账号重置密码失败
    @objc public static let XERR_ACCOUNT_GETCODE = -30011;          ///< 获取验证码失败
    @objc public static let XERR_ACCOUNT_USRINFO_QUERY = -30013;    ///< 查询用户信息失败
    @objc public static let XERR_ACCOUNT_USRINFO_UPDATE = -30014;   ///< 更新用户信息失败
    //
    // 呼叫系统相关错误
    //
    @objc public static let XERR_CALLKIT_BASE = -40000
    @objc public static let XERR_CALLKIT_TIMEOUT = -40001          ///< 呼叫超时无响应
    @objc public static let XERR_CALLKIT_DIAL = -40002             ///< 呼叫拨号失败
    @objc public static let XERR_CALLKIT_HANGUP = -40003           ///< 呼叫挂断失败
    @objc public static let XERR_CALLKIT_ANSWER = -40004           ///< 呼叫接听失败
    @objc public static let XERR_CALLKIT_REJECT = -40005           ///< 呼叫拒绝失败
    @objc public static let XERR_CALLKIT_PEER_BUSY = -40006        ///< 对端忙
    @objc public static let XERR_CALLKIT_PEERTIMEOUT = -40007      ///< 对端超时无响应
    @objc public static let XERR_CALLKIT_LOCAL_BUSY = -40008       ///< 本地端忙
    @objc public static let XERR_CALLKIT_ERR_OPT = -40009          ///< 不支持的错误操作
    @objc public static let XERR_CALLKIT_PEER_UNREG = -40010       ///< 对端未注册
    @objc public static let XERR_CALLKIT_NO_APPID = -40011         ///< 未上报appid
    @objc public static let XERR_CALLKIT_SAME_ID = -40012         ///< 主叫和被叫同一个id
    //
    // 设备管理相关错误
    //
    @objc public static let XERR_DEVMGR_BASE = -50000
    @objc public static let XERR_DEVMGR_NO_DEVICE = -50001         ///< 没有找到设备
    @objc public static let XERR_DEVMGR_ONLINE = -50002            ///< 设已解决在线
    @objc public static let XERR_DEVMGR_OFFLINE = -50003           ///< 设备不在线
    @objc public static let XERR_DEVMGR_QUEYR = -50004             ///< 设备查询失败
    @objc public static let XERR_DEVMGR_ADD = -50005               ///< 设备添加失败
    @objc public static let XERR_DEVMGR_DEL = -50006               ///< 设备删除失败
    @objc public static let XERR_DEVMGR_CMD = -50007               ///< 设备命令失败
    @objc public static let XERR_DEVMGR_PROPERTY = -50008          ///< 设备命属性查询失败
    @objc public static let XERR_DEVMGR_RENAME = -50009          ///< 设备重命名失败
    @objc public static let XERR_DEVMGR_SHARE_ALREADY_BIND = -50010      ///< 共享的设备已经被绑定
    @objc public static let XERR_DEVMGR_SHARE_TARGET_NOT_EXIST = -50011      ///< 共享的用户不存在

    @objc public static let XERR_ALARM_NOT_FOUND = -60001 ///< 没有找到告警信息
}
