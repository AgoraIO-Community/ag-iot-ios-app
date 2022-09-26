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

//public class AlarmQueryParam : NSObject{
//    public var messageType : Int? = nil //设备告警：0:sound dectect,1:motion dectect, 99:other,nil: all
//
//    public var status : Int? = nil      //0:未读,1:已读，nil：所有
//
//    public var createdDateBegin:Date? = nil
//    public var createdDateEnd:Date = Date()
//
//    public var currentPage:Int = 1 //page index start from 1
//    public var pageSize:Int = 5
//
//    public var desc:Bool = true   //sort type : asc,desc
//
//    public var device:IotDevice?
//
//    public init(dateBegin:Date? = nil){
//        self.createdDateBegin = dateBegin
//    }
//}

/*
 * @brief 告警查询参数
 */
public class AlarmQueryParam : NSObject{
    public var productId:String?                         //产品id
    public var deviceId:String?                          //设备id
    public var messageType : Int? = nil                  //设备告警：0:sound dectect,1:motion dectect, 99:other,nil: all
    public var status : Int? = nil                       //0:未读,1:已读，nil：所有
    public var createdDateBegin:Date? = nil              //开始时间
    public var createdDateEnd:Date? = nil                //结束时间
    public var currentPage:Int = 1                       //page index start from 1
    public var pageSize:Int = 5                          //分页大小
    public var desc:Bool = true                          //sort type : asc,desc
    
    public init(dateBegin:Date? = nil){
        self.createdDateBegin = dateBegin
    }
}

public class SysAlarmQueryParam : NSObject{
    public var messageType : Int? = nil                  //系统告警：1:设备上线 2:设备下线 3:设备绑定 4:设备解绑 99 其他
    public var status : Int? = nil                       //0:未读,1:已读，nil：所有
    public var createdDateBegin:Date? = nil              //开始时间
    public var createdDateEnd:Date = Date()              //结束时间
    public var currentPage:Int = 1                       //page index start from 1
    public var pageSize:Int = 5                          //分页大小
    public var desc:Bool = true                          //sort type : asc,desc
    public var deviceIds:[String] = []                   //注意：当查询所有设备的信息时，需要填充所有设备的deviceId!!
    
    public init(dateBegin:Date? = nil){
        self.createdDateBegin = dateBegin
    }
}

/*
 * @brief 告警信息管理接口
 */
public protocol IAlarmMgr {

    typealias QueryParam = AlarmQueryParam
    typealias SysQueryParam = SysAlarmQueryParam

    /*
     * @brief 根据id查询告警
     * @alarmMessageId   : 告警id
     * @param result     : 调用该接口的返回值
     */
    func queryById(alertMessageId:UInt64, result:@escaping (Int,String,IotAlarm?) -> Void)
    /*
     * @brief 根据id查询告警
     * @param queryParam : 查询参数
     * @param result     : 调用该接口的返回值
     */
    func queryByParam(queryParam:QueryParam,result:@escaping(Int,String,[IotAlarm]?)->Void)
    /*
     * @brief 删除告警
     * @param alarmIdList: 告警id列表
     * @param result     : 调用该接口的返回值
     */
    func delete(alarmIdList: [UInt64],result:@escaping(Int,String)->Void)
    /*
     * @brief 标记已读
     * @param alarmIdList: 告警id列表
     * @param result     : 调用该接口的返回值
     */
    func mark(alarmIdList: [UInt64],result:@escaping(Int,String)->Void)
    /*
     * @brief 根据过滤条件查询告警条数
     * @param productId : 产品id
     * @param deviceId: 设备id
     * @param messageType:告警类型 //设备告警：0:sound dectect,1:motion dectect, 99:other,nil: all
     * @param status:状态 //0:未读    1:已读
     * @param createDateBegin:开始日志
     * @param createDateEnd:结束日期
     */
    func queryCount(productId:String?,deviceId:String?,messageType:Int?,status:Int?,createDateBegin:Date?,createDateEnd:Date? , result:@escaping(Int,String,UInt)->Void)
    
    func addAlarm(device:IotDevice,desc:String,result:@escaping(Int,String)->Void)
    
    func queryAlarmImage(alertImageId:String,result:@escaping(Int,String,String?)->Void)
    
    func queryAlarmVideoUrl(deviceId:String,beginTime:UInt64,result:@escaping(Int,String,String?)->Void)
    /*
     * @brief 根据id查询告警
     * @alarmMessageId   : 告警id
     * @param result     : 调用该接口的返回值
     */
    func querySysById(alertMessageId:UInt64, result:@escaping (Int,String,IotAlarm?) -> Void)
    /*
     * @brief 根据id查询告警
     * @param queryParam : 查询参数
     * @param result     : 调用该接口的返回值
     */
    func querySysByParam(queryParam:SysQueryParam,result:@escaping(Int,String,[IotAlarm]?)->Void)
    /*
     * @brief 标记已读
     * @param alarmIdList: 告警id列表
     * @param result     : 调用该接口的返回值
     */
    func markSys(alarmIdList: [UInt64],result:@escaping(Int,String)->Void)
    /*
     * @brief 根据过滤条件查询告警条数
     * @param productId : 产品id
     * @param deviceId: 设备id，不能为空
     * @param messageType:告警类型 //系统告警：1:设备上线 2:设备下线 3:设备绑定 4:设备解绑 99 其他
     * @param status:状态 //0:未读    1:已读
     * @param createDateBegin:开始日志
     * @param createDateEnd:结束日期
     */
    func querySysCount(productId:String?,deviceIds:[String],messageType:Int?,status:Int?,createDateBegin:Date?,createDateEnd:Date? , result:@escaping(Int,String,UInt)->Void)
}
