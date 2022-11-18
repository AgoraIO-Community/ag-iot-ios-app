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
 * @brief 设备信息，(productKey+mDeviceId) 构成设备唯一标识
 */
public class IotDevice : NSObject {
    @objc public var userId : String                        //用户Id
    @objc public var userType : Int                         //用户角色：1--所有者; 2--管理员; 3--成员
    @objc public var deviceId : String                      //设备唯一的Id
    @objc public var deviceName : String                    //设备名
    @objc public var deviceNumber : String                  //设备号
    @objc public var tenantId : String                      //租户id
    @objc public var productId : String                     //产品id
    @objc public var productNumber : String                 //产品号
    @objc public var sharer : String                        //分享人的用户Id，如果自己配网则是 0
    @objc public var createTime : UInt64                    //创建时间戳
    @objc public var updateTime : UInt64                    //最后一次更新时间戳
    @objc public var productInfo : ProductInfo?             //产品信息
    @objc public var connected : Bool                       //是否在线
    @objc public var alias : String                         //别名
    @objc public var props: Dictionary<String,Any>? = nil   //<设备属性>
    
    public init(userId:String ,
         userType:Int ,
         deviceId:String,
         deviceName:String,
         deviceNumber:String,
         tenantId:String,
         
         productId:String,
         productNumber:String,
         
         sharer:String,
         createTime:UInt64,
         updateTime:UInt64,
         
         alias:String,
         connected:Bool,
         props:Dictionary<String,String>?){
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
        self.alias = alias
        self.props = props
    }
}

