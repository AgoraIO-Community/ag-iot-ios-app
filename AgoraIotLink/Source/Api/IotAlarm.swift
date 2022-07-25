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

