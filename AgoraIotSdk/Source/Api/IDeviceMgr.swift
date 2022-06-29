import SwiftUI
/**
 * @file IDeviceMgr.java
 * @brief This file define the interface of devices management
 * @author zhihe.gu
 * @email guzhihe@agora.io
 * @version 1.0.0.1
 * @date 2022-01-26
 * @license Copyright (C) 2021 AgoraIO Inc. All rights reserved.
 */

/*
 *@brief 产品信息
 */
public class ProductInfo:NSObject{
    @objc public var alias : String = ""            //别名
    @objc public var bindType:UInt = 0              //绑定类型
    @objc public var connectType : UInt = 0         //连接类型
    @objc public var createTime : UInt64 = 0        //创建时间
    @objc public var deleted : UInt = 0             //是否删除
    @objc public var number : String = ""           //设备号
    @objc public var imgBig : String = ""           //大图标
    @objc public var imgSmall : String = ""         //小图标
    @objc public var merchantId : UInt64 = 0        //租户号
    @objc public var merchantName : String = ""     //租户名
    @objc public var name : String = ""             //名称
    @objc public var id : String = ""               //id
    @objc public var productTypeId : UInt64  = 0    //类型id
    @objc public var productTypeName : String = ""  //类型名
    @objc public var status : UInt = 0              //状态
    @objc public var updateBy : UInt64 = 0          //更新
    @objc public var updateTime : UInt64 = 0        //更新时间
    public init(alias:String,
                bindType:UInt,
                connectType:UInt,
                createTime:UInt64,
                deleted:UInt,
                number:String,
                imgBig:String,
                imgSmall:String,
                merchantId:UInt64,
                merchantName:String,
                name:String,
                id:String,
                productTypeId:UInt64,
                productTypeName:String,
                status:UInt,
                updateBy:UInt64,
                updateTime:UInt64) {
        self.alias = alias
        self.bindType = bindType
        self.connectType = connectType
        self.createTime = createTime
        self.deleted = deleted
        self.number = number
        self.imgBig = imgBig
        self.imgSmall = imgSmall
        self.merchantId = merchantId
        self.merchantName = merchantName
        self.name = name
        self.id = id
        self.productTypeId = productTypeId
        self.productTypeName = productTypeName
        self.status = status
        self.updateBy = updateBy
        self.updateTime = updateTime
    }
}
/*
 *@brief 设备状态改变回调接口
 */
public protocol IDeviceStateListener{
    /*
     * @brief 设备上线与下线回调
     * @param online     : true:上线 false:下线
     * @param deviceId   : 设备id
     * @param productId  : 产品型号id
     */
    func onDeviceOnOffline(online:Bool,deviceId:String,productId:String)
    /*
     * @brief 设备发生行为改变
     * @param deviceId     : 设备id
     * @param actionType   : add:绑定  delete:解绑
     */
    func onDeviceActionUpdated(deviceId:String,actionType:String)
    /*
     * @brief 设备发生属性改变
     * @param deviceId       : 设备id
     * @param deviceNumber   : 设备号
     * @param props          : 被改变的属性
     */
    func onDevicePropertyUpdated(deviceId:String,deviceNumber:String,props:[String:Any]?)
}

public class DeviceShare : NSObject{
    @objc public var nickName:String = ""   //用户设备昵称
    @objc public var count:Int = 0          //设备被分享次数
    @objc public var time:UInt64 = 0        //创建时间
    @objc public var deviceNumber:String = "" //设备编号
    @objc public var deviceId:String = ""   //设备id
}

public class DeviceCancelable : NSObject{
    @objc public var appuserId:String  = ""     //用户ID
    @objc public var avatar:String = ""         //用户头像
    @objc public var connect:Bool = false       //
    @objc public var createTime:UInt64 = 0      //创建时间
    @objc public var deviceNumber:String = ""   //设备号
    @objc public var deviceNickname:String = "" //设备名称
    @objc public var email:String = ""          //用户邮箱
    @objc public var deviceId:String = ""       //设备id
    @objc public var nickName:String = ""       //用户昵称
    @objc public var phone:String = ""          //用户手机
    @objc public var productId:String = ""      //产品Id
    @objc public var productKey:String = ""     //产品Key
    @objc public var sharer:String = ""         //分享人ID
    @objc public var uType:String = ""          //用户角色 1所有者 2管理员 3成员
    @objc public var updateTime:UInt64 = 0      //更新时间
}

public class ShareDetail : NSObject{
    @objc public var auditStatus:Bool = false   //消息处理状态 【t】已处理、【f】未处理
    @objc public var content:String = ""        //推送内容
    @objc public var createBy:UInt64 = 0        //创建人ID
    @objc public var createTime:UInt64 = 0      //创建时间
    @objc public var deleted:Int = 0            //已删除：【0】未删除、【1】已删除
    @objc public var id:UInt64 = 0              //主键
    @objc public var merchantId:UInt64 = 0      //商户ID
    @objc public var merchantName:String = ""   //商户名称
    @objc public var msgType:Int = 0            //消息类型【1】设备分享消息
    @objc public var para:String = ""           //分享口令
    @objc public var permission:Int = 0         //推送的权限【2】管理员 ，【3】成员
    @objc public var status:Int = 0             //状态：【1】发送成功、【2】发送失败 、【3】待发送
    @objc public var title:String = ""          //推送标题
    @objc public var type:Int = 0               //推送类型【1】App消息 【2】短信消息 【3】邮箱信息
    @objc public var updateBy:UInt64 = 0        //更新人ID
    @objc public var updateTime:UInt64 = 0      //更新时间
    @objc public var userId:UInt64 = 0          //用户ID（被分享人ID）
}

public class ShareItem : NSObject{
    @objc public var auditStatus:Bool = false   //消息处理状态 【t】已处理、【f】未处理
    @objc public var content:String = ""        //推送内容
    @objc public var createBy:UInt64 = 0        //创建者ID
    @objc public var createTime:UInt64 = 0      //创建时间
    @objc public var deleted:Int = 0            //已删除：【0】未删除、【1】已删除
    @objc public var deviceNumber:UInt64 = 0    //对应IotDevice里面的deviceNumber
    @objc public var id:UInt64 = 0              //该条信息ID
    @objc public var img:String = ""            //产品图片地址
    @objc public var merchantId:UInt64 = 0      //商户ID
    @objc public var merchantName:String = ""   //商户名称
    @objc public var msgType:Int = 0            //消息类型【1】设备分享消息
    @objc public var para:String = ""           //分享口令,shareDeviceAccept()的order
    @objc public var permission:Int = 0         //推送的权限【2】管理员 ，【3】成员
    @objc public var productName:String = ""    //产品名称
    @objc public var pushTime:UInt64 = 0        //定时推送时间
    @objc public var shareName:String = ""      //分享设备名称
    @objc public var status:Int = 0             //状态：【1】发送成功、【2】发送失败 、【3】待发送
    @objc public var title:String = ""          //推送标题
    @objc public var type:Int = 0               //推送类型【1】App消息 【2】短信消息 【3】邮箱
    @objc public var userId:UInt64 = 0          //用户ID（被分享人ID）
}

public class PageTurn:NSObject{
    @objc var currentPage : Int = 0             //当前页
    @objc var pageCount : Int = 0               //页面总数
    @objc var firstPage : Int = 0               //首页索引
    @objc var prevPage : Int = 0                //上一页面索引
    @objc var nextPage : Int = 0                //下一页面索引
    @objc var page : Int = 0                    //请求页
    @objc var pageSize : Int = 0                //请求的页内容条数
    @objc var rowCount : Int = 0                //记录数
    @objc var start : Int = 0                   //当前页开始条数
    @objc var end : Int = 0                     //当前页结束条数
    @objc var startIndex : Int = 0              //开始记录
}
/*
 * @brief 设备管理接口
 */
public protocol IDeviceMgr {
    func register(listener:IDeviceStateListener)
    /*
     * @brief 查询产品列表
     * @param productId  : 对应productId作为过滤字段
     * @param result     : 调用该接口的返回值
     */
    func queryProductList(result:@escaping(Int,String,[ProductInfo])->Void)
    /*
     * @brief 查询设备列表
     * @param result     : 调用该接口的返回值
     */
    func queryAllDevices(result:@escaping(Int,String,[IotDevice])->Void)
    /*
     * @brief 添加设备，暂未实现
     * @param productKey : 设备key
     * @param deviceMac  : 设备Mac
     * @param result     : 调用该接口的返回值
     */
    func addDevice(productId: String, deviceId: String,result:@escaping(Int,String)->Void)
    /*
     * @brief 移除设备
     * @param device     : 设备
     * @param result     : 调用该接口的返回值
     */
    func removeDevice(device:IotDevice,result:@escaping(Int,String)->Void)
    /*
     * @brief 修改设备名
     * @param device     : 设备
     * @param newName    : 新名字
     * @param result     : 调用该接口的返回值
     */
    func renameDevice(device:IotDevice,newName:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 修改设备属性
     * @param device     : 对应设备
     * @param propertites: 需要设置的属性
     * @param result     : 调用该接口的返回值以及被修改的属性
     */
    func setDeviceProperty(device:IotDevice,properties:Dictionary<String,Any>,result:@escaping(Int,String)->Void)
    
    /*
     * @brief 查询设备属性
     * @param device     : 需要取得属性的设备
     * @param result     : 调用该接口的返回值
     */
    func getDeviceProperty(device:IotDevice,result:@escaping(Int,String,Dictionary<String, Any>?)->Void)
    /*
     * @brief 分享设备给其他人
     * @param device:被分享的设备
     * @param account:分享对象，目前广云文档描述支持用户邮箱
     * @param type :被分享人权限 2管理员 3成员（默认成员）
     */
    func shareDeviceTo(deviceNumber:String,account:String,type:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 接收他人的分享，使用场景参看 sharePushList()接口
     * @param deviceNickName:设备新昵称
     * @param order：分享口令,来自于 sharePushList()返回列表中对应设备的 para 字段
     */
    func shareDeviceAccept(deviceNickName:String,order:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 用户可分享设备列表
     */
    func shareGetOwnDevices(result:@escaping(Int,String,[DeviceShare]?)->Void)
    /*
     * @brief 分享给自己的设备
     */
    func shareWithMe(result:@escaping(Int,String,[DeviceShare]?)->Void)
    /*
     * @brief 查询分享出去的设备
     * @param deviceNumber:设备号
     */
    func shareCancelable(deviceNumber:String,result:@escaping(Int,String,[DeviceCancelable]?)->Void)
    /*
     * @brief 设备所有者解除分享权限 同时发送消息给被分享者
     * @param deviceNumber:设备号
     * @param userId: 用户编号
     */
    func shareRemoveMember(deviceNumber:String,userId:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 用户分享设备，生成分享推送消息，需被分享人接收分享，使用场景参看 sharePushList()接口
     * @param deviceNumber:设备号
     * @email :被分享人账号
     * @type  :被分享权限 2--管理员; 3--成员
     */
    func sharePushAdd(deviceNumber:String,email:String,type:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 删除用户分享设备推送信息，使用场景参看 sharePushList()接口
     * @id : 对应ShareItem.id
     */
    func sharePushDel(id:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 设备推送消息-详情，使用场景参看 sharePushList()接口
     * @id : 对应ShareItem.id
     */
    func sharePushDetail(id:String,result:@escaping(Int,String,ShareDetail?)->Void)
    /*
     * @brief 按分页方式查询接收的分享消息列表，场景： 当用户A使用sharePushAdd()将设备分享给用户B时，用户B使用该接口查询消息，之后可以用sharePushDetail（）查看详情，用sharePushDel（）拒绝，用shareDeviceAccept（）接受分享
     * @param auditStatus : 消息处理状态 【t】已处理、【f】未处理
     */
    func sharePushList(pageNo:Int,pageSize:Int,auditStatus:String,result:@escaping(Int,String,[ShareItem]?,PageTurn?)->Void)
}
