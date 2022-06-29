/**
 * @file IotAlarm.java
 * @brief This file define the data structure of alarm information
 * @author xiaohua.lu
 * @email luxiaohua@agora.io
 * @version 1.0.0.1
 * @date 2022-01-26
 * @license Copyright (C) 2021 AgoraIO Inc. All rights reserved.
 */

import Foundation

/*
 * @brief 告警信息,设备告警和系统告警的数据
 */
public class IotAlarm : NSObject{
    @objc public let alertMessageId:UInt64  //告警消息ID
    //设备告警时：messageType 0:声音检测,1:移动监测, 2:PIR红外检测，4:按钮报警 99:其他告警,nil: all
    //系统告警时：messageType 1:设备上线 2:设备下线 3:设备绑定 4:设备解绑 99 其他， nil:all
    @objc public var messageType:UInt = 0
    @objc public var desc:String = ""               //告警描述
    @objc public var fileUrl:String = ""            //告警视频url
    @objc public var status:UInt = 0                //状态：0 未读 1 已读
    @objc public var tenantId:String = ""           //租户id
    @objc public var productId:String? = ""         //产品ID
    @objc public var deviceId:String = ""           //设备ID
    @objc public var deviceName:String = ""         //设备名
    @objc public var deleted:Bool = false           //是否释放
    @objc public var createdBy:UInt = 0             //被谁创建
    @objc public var createdDate:UInt64 = 0         //创建日期时间戳
    @objc public var changedBy:UInt = 0             //被谁修改
    @objc public var changedDate:UInt64 = 0         //修改日期时间戳
    @objc public init(messageId:UInt64){
        alertMessageId = messageId
    }
    
    @objc public var readed:Bool{get{return status == 1}set{status = newValue ? 1 : 0}}
}

