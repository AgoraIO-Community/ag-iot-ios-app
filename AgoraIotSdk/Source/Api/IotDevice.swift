/**
 * @file IotDevice.java
 * @brief This file define the data structure of IoT device
 * @author xiaohua.lu
 * @email luxiaohua@agora.io
 * @version 1.0.0.1
 * @date 2022-01-26
 * @license Copyright (C) 2021 AgoraIO Inc. All rights reserved.
 */

/*
 * @brief 设备信息，(productKey+mDeviceId) 构成设备唯一标识
 */
public class IotDevice : NSObject {
    @objc public var userId : String            ///< 用户Id
    @objc public var userType : Int             ///< 用户角色：1--所有者; 2--管理员; 3--成员

    @objc public var deviceId : String            ///< 设备唯一的Id
    @objc public var deviceName : String          ///< 设备名
    @objc public var deviceNumber : String        ///< 设备号
    @objc public var tenantId : String            ///< 租户id
    
    @objc public var productId : String           ///< 产品id
    @objc public var productNumber : String       ///< 产品号
    
    @objc public var sharer : String              ///< 分享人的用户Id，如果自己配网则是 0

    @objc public var createTime : UInt64          ///< 创建时间戳
    @objc public var updateTime : UInt64          ///< 最后一次更新时间戳
    
    @objc public var productInfo : ProductInfo?   ///产品信息
    
    @objc public var connected : Bool             ///< 是否在线
    
    @objc public var props: Dictionary<String,Any>? = nil   ///<设备属性>
    
    init(userId:String ,
         userType:Int ,
         deviceId:String,
         deviceName:String,
         deviceNumber:String,
         tenantId:String,
         
         productId:String,
         productNumber:String,
         
         sharer:String,
         createTime:UInt64 = 0,
         updateTime:UInt64 = 0,
         connected:Bool){
        self.userId = userId
        self.userType = userType
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.deviceNumber = deviceNumber
        self.tenantId = tenantId
        
        self.productId = productId
        self.productNumber = productNumber

        self.sharer = sharer
        self.createTime = createTime
        self.updateTime = updateTime
        self.connected = connected
    }
}

