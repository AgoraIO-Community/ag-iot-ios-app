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
 * @breif 查询产品信息时的输入参数
 */
public class ProductQueryParam : NSObject{
    @objc public var pageNo:Int = -1                    //查询的页码，<0表示不设置该参数
    @objc public var pageSize:UInt = 0                  //分页大小，0 表示不设置该参数
    @objc public var productTypeId:UInt64 = 0           //产品类型型号, 0 表示不设置该参数
    @objc public var productId:UInt64 = 0               //产品型号,0 表示不设置该参数
    @objc public var blurry:String = ""                 //保留
}
/*
 *@brief 产品信息
 */
public class ProductInfo:NSObject{
    @objc public var alias : String = ""                //别名
    @objc public var bindType:UInt = 0                  //绑定类型
    @objc public var connectType : UInt = 0             //连接类型
    @objc public var createTime : UInt64 = 0            //创建时间
    @objc public var deleted : UInt = 0                 //是否删除
    @objc public var number : String = ""               //设备号
    @objc public var imgBig : String = ""               //大图标
    @objc public var imgSmall : String = ""             //小图标
    @objc public var merchantId : UInt64 = 0            //租户号
    @objc public var merchantName : String = ""         //租户名
    @objc public var name : String = ""                 //名称
    @objc public var id : String = ""                   //id
    @objc public var productTypeId : UInt64  = 0        //类型id
    @objc public var productTypeName : String = ""      //类型名
    @objc public var status : UInt = 0                  //状态
    @objc public var updateBy : UInt64 = 0              //更新
    @objc public var updateTime : UInt64 = 0            //更新时间
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
 * @brief 设备属性描述信息
 */
public class Property : NSObject{
    @objc public var productId:UInt64 = 0               //产品ID
    @objc public var markName = ""                      //数据点标识
    @objc public var maxValue = ""                      //最大值
    @objc public var minValue = ""                      //最小值
    @objc public var params = ""                        //类型参数值
    @objc public var pointName = ""                     //数据点名称
    @objc public var pointType:UInt = 0                 //数据点类型：【1】整型、【2】布尔值、【3】枚举、【4】字符串、【5】浮点型、【6】bit类型、【7】raw类型
    @objc public var readType:UInt = 0                  //读写类型：【1】只读、【2】读写
    @objc public var remark = ""                        //备注
    @objc public var status:UInt = 0                    //状态：【1】启用、【2】停用
    @objc public var createBy:UInt64 = 0                //创建人ID
    @objc public var createTime:UInt64 = 0              //创建时间
    @objc public var deleted:UInt = 0                   //已删除：【0】未删除、【1】已删除
    @objc public var tip:String = ""                    //描述
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
/*
 * @breif 分享设备信息
 */
public class DeviceShare : NSObject{
    @objc public var nickName:String = ""               //用户设备昵称
    @objc public var count:Int = 0                      //设备被分享次数
    @objc public var time:UInt64 = 0                    //创建时间
    @objc public var deviceNumber:String = ""           //设备编号
    @objc public var deviceId:String = ""               //设备id
}
/*
 * @breif 可取消共享设备的信息
 */
public class DeviceCancelable : NSObject{
    @objc public var appuserId:String  = ""             //用户ID
    @objc public var avatar:String = ""                 //用户头像
    @objc public var connect:Bool = false               //连接中
    @objc public var createTime:UInt64 = 0              //创建时间
    @objc public var deviceNumber:String = ""           //设备号
    @objc public var deviceNickname:String = ""         //设备名称
    @objc public var email:String = ""                  //用户邮箱
    @objc public var deviceId:String = ""               //设备id
    @objc public var nickName:String = ""               //用户昵称
    @objc public var phone:String = ""                  //用户手机
    @objc public var productId:String = ""              //产品Id
    @objc public var productKey:String = ""             //产品Key
    @objc public var sharer:String = ""                 //分享人ID
    @objc public var uType:String = ""                  //用户角色 1所有者 2管理员 3成员
    @objc public var updateTime:UInt64 = 0              //更新时间
}
/*
 * @brief 共享设备的信息
 */
public class ShareDetail : NSObject{
    @objc public var auditStatus:Bool = false           //消息处理状态 【t】已处理、【f】未处理
    @objc public var content:String = ""                //推送内容
    @objc public var createBy:UInt64 = 0                //创建人ID
    @objc public var createTime:UInt64 = 0              //创建时间
    @objc public var deleted:Int = 0                    //已删除：【0】未删除、【1】已删除
    @objc public var id:UInt64 = 0                      //主键
    @objc public var merchantId:UInt64 = 0              //商户ID
    @objc public var merchantName:String = ""           //商户名称
    @objc public var msgType:Int = 0                    //消息类型【1】设备分享消息
    @objc public var para:String = ""                   //分享口令
    @objc public var permission:Int = 0                 //推送的权限【2】管理员 ，【3】成员
    @objc public var status:Int = 0                     //状态：【1】发送成功、【2】发送失败 、【3】待发送
    @objc public var title:String = ""                  //推送标题
    @objc public var type:Int = 0                       //推送类型【1】App消息 【2】短信消息 【3】邮箱信息
    @objc public var updateBy:UInt64 = 0                //更新人ID
    @objc public var updateTime:UInt64 = 0              //更新时间
    @objc public var userId:UInt64 = 0                  //用户ID（被分享人ID）
}
/*
 * @brief 共享设备消息的描述
 */
public class ShareItem : NSObject{
    @objc public var auditStatus:Bool = false           //消息处理状态 【t】已处理、【f】未处理
    @objc public var content:String = ""                //推送内容
    @objc public var createBy:UInt64 = 0                //创建者ID
    @objc public var createTime:UInt64 = 0              //创建时间
    @objc public var deleted:Int = 0                    //已删除：【0】未删除、【1】已删除
    @objc public var deviceNumber:UInt64 = 0            //对应IotDevice里面的deviceNumber
    @objc public var id:UInt64 = 0                      //该条信息ID
    @objc public var img:String = ""                    //产品图片地址
    @objc public var merchantId:UInt64 = 0              //商户ID
    @objc public var merchantName:String = ""           //商户名称
    @objc public var msgType:Int = 0                    //消息类型【1】设备分享消息
    @objc public var para:String = ""                   //分享口令,shareDeviceAccept()的order
    @objc public var permission:Int = 0                 //推送的权限【2】管理员 ，【3】成员
    @objc public var productName:String = ""            //产品名称
    @objc public var pushTime:UInt64 = 0                //定时推送时间
    @objc public var shareName:String = ""              //分享设备名称
    @objc public var status:Int = 0                     //状态：【1】发送成功、【2】发送失败 、【3】待发送
    @objc public var title:String = ""                  //推送标题
    @objc public var type:Int = 0                       //推送类型【1】App消息 【2】短信消息 【3】邮箱
    @objc public var userId:UInt64 = 0                  //用户ID（被分享人ID）
}
/*
 * @breif 换页信息
 */
public class PageTurn:NSObject{
    @objc public var currentPage : Int = 0              //当前页
    @objc public var pageCount : Int = 0                //页面总数
    @objc public var firstPage : Int = 0                //首页索引
    @objc public var prevPage : Int = 0                 //上一页面索引
    @objc public var nextPage : Int = 0                 //下一页面索引
    @objc public var page : Int = 0                     //请求页
    @objc public var pageSize : Int = 0                 //请求的页内容条数
    @objc public var rowCount : Int = 0                 //记录数
    @objc public var start : Int = 0                    //当前页开始条数
    @objc public var end : Int = 0                      //当前页结束条数
    @objc public var startIndex : Int = 0               //开始记录
}
/*
 * @biref 固件版本信息
 */
public class FirmwareInfo : NSObject{
    @objc public var  releaseTime:UInt64 = 0            //发布时间
    @objc public var  size:UInt = 0                     //文件大小
    @objc public var  currentVersion:String = ""        //设备当前MCU版本
    @objc public var  upgradeVersion:String = ""        //最新固件版本
    @objc public var  remark:String = ""                //备注说明
    @objc public var  isUpgrade:Bool = false            //是否可以升级
    @objc public var  deviceNumber:UInt64 = 0           //设备号
    @objc public var  upgradeId:String = ""             //升级记录id
    @objc public var  deviceId:String = ""              //设备ID
}
/*
 * @brief 固件升级状态事件
 */
public class FirmwareStatus : NSObject{
    @objc public var  deviceNumber:String = ""          //设备号
    @objc public var  deviceName:String = ""            //设备名
    @objc public var  deviceId:String = ""              //设备ID
    @objc public var  currentVersion:String = ""        //当前版本
    @objc public var  status:Int = 0                    //设备升级状态【1】升级完成、【2】升级失败、【3】升级取消、【4】待升级、【5】升级中
}
/*
 * @brief rtm通信时的状态事件
 */
@objc public enum MessageChannelStatus : Int{
    case DataArrived                                    //收到数据
    case Disconnected                                   //连接断开
    case Connecting                                     //连接中
    case Connected                                      //连接成功
    case Reconnecting                                   //重连中
    case Aborted                                        //中断
    case TokenWillExpire                                //token将要过期
    case TokenDidExpire                                 //token已经过期
    case UnknownError                                   //未知错误
}
/*
 * @brief 播放sd卡时的状态事件
 */
@objc public enum PlaybackStatus : Int{
    case RemoteJoin                                     //设备连接成功
    case RemoteLeft                                     //设备断开
    case LocalReady                                     //本地准备好播放
    case LocalError                                     //本地错误
    case VideoReady                                     //收到远端视频
}
/*
 * @brief 设备管理接口
 */
public protocol IDeviceMgr {
    /*
     * @brief 注册设备事件回调
     * @param listener  : 设备状态改变回调
     * @param setOnDataArrived : 设备发送消息回调
     */
    func register(listener:IDeviceStateListener)
    /*
     * @brief 查询产品列表
     * @param productId  : 对应productId作为过滤字段
     * @param result     : 调用该接口的返回值
     */
    func queryProductList(query:ProductQueryParam,result:@escaping(Int,String,[ProductInfo])->Void)
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
     * @param deviceId   : 设备Id
     * @param result     : 调用该接口的返回值
     */
    func removeDevice(deviceId:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 修改设备名
     * @param deviceId     : 设备Id
     * @param newName    : 新名字
     * @param result     : 调用该接口的返回值
     */
    func renameDevice(deviceId:String,newName:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 查询所有属性描述符，触发 onQueryAllPropertyDescDone() 回调
     *        deviceID 和 productNumber 两者取其一，另外一个参数为""
     * @param deviceID : 根据设备ID来查询
     * @param productNumber : 根据productNumber查询
     */
    func getPropertyDescription(deviceId:String,productNumber:String,result:@escaping(Int,String,[Property])->Void)
    /*
     * @brief 修改设备属性值
     * @param deviceId   : 设备对应id
     * @param propertites: 需要设置的属性
     * @param result     : 调用该接口的返回值以及被修改的属性
     */
    func setDeviceProperty(deviceId:String, properties:Dictionary<String,Any>,result:@escaping(Int,String)->Void)
    
    /*
     * @brief 查询设备属性值
     * @param deviceId   : 设备对应id
     * @param result     : 调用该接口的返回值,desired:期望设置给设备的参数信息，reported:设备设置成功后当前的参数信息
     */
    func getDeviceProperty(deviceId:String,result:@escaping(Int,String,_ desired:Dictionary<String, Any>?,_ reported:Dictionary<String, Any>?)->Void)
    /*
     * @brief 分享设备给其他人
     * @param deviceId  : 被分享的设备Id
     * @param userId    : 分享对象
     * @param type      : 被分享人权限 2管理员 3成员（默认成员）
     */
    func shareDeviceTo(deviceId:String,userId:String,type:String,result:@escaping(Int,String)->Void)
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
     * @param deviceId   : 设备Id
     */
    func shareCancelable(deviceId:String,result:@escaping(Int,String,[DeviceCancelable]?)->Void)
    /*
     * @brief 设备所有者解除分享权限 同时发送消息给被分享者
     * @param deviceId       : 设备Id
     * @param userId         : 用户编号
     */
    func shareRemoveMember(deviceId:String,userId:String,result:@escaping(Int,String)->Void)
//    /*
//     * @brief 接收他人的分享，使用场景参看 sharePushList()接口
//     * @param deviceNickName   : 设备新昵称
//     * @param order            : 分享口令,来自于 sharePushList()返回列表中对应设备的 para 字段
//     */
//    func shareDeviceAccept(deviceNickName:String,order:String,result:@escaping(Int,String)->Void)
//    /*
//     * @brief 用户分享设备，生成分享推送消息，需被分享人接收分享，使用场景参看 sharePushList()接口
//     * @param deviceNumber     : 设备号
//     * @email                  : 被分享人账号
//     * @type                   : 被分享权限 2--管理员; 3--成员
//     */
//    func sharePushAdd(deviceNumber:String,email:String,type:String,result:@escaping(Int,String)->Void)
//    /*
//     * @brief 删除用户分享设备推送信息，使用场景参看 sharePushList()接口
//     * @id                     : 对应ShareItem.id
//     */
//    func sharePushDel(id:String,result:@escaping(Int,String)->Void)
//    /*
//     * @brief 设备推送消息-详情，使用场景参看 sharePushList()接口
//     * @id                     : 对应ShareItem.id
//     */
//    func sharePushDetail(id:String,result:@escaping(Int,String,ShareDetail?)->Void)
//    /*
//     * @brief 按分页方式查询接收的分享消息列表，场景： 当用户A使用sharePushAdd()将设备分享给用户B时，用户B使用该接口查询消息，之后可以用sharePushDetail（）查看详情，用sharePushDel（）拒绝，用shareDeviceAccept（）接受分享
//     * @param auditStatus      : 消息处理状态 【t】已处理、【f】未处理
//     */
//    func sharePushList(pageNo:Int,pageSize:Int,auditStatus:String,result:@escaping(Int,String,[ShareItem]?,PageTurn?)->Void)
    /*
     * @brief 获取设备的固件信息
     * @param deviceId           : 设备的id
     */
    func otaGetInfo(deviceId:String,result:@escaping(Int,String,FirmwareInfo?)->Void)
    /*
     * @brief ota升级固件
     * @param upgradeId          : MCU版本中的 升级ID,来自于otaGetInfo()返回的FirmwareInfo.upgradeId
     */
    func otaUpgrade(upgradeId:String,result:@escaping(Int,String)->Void)
    /*
     * @brief ota升级固件状态查询
     * @param upgradeId          : MCU版本中的 升级ID
     */
    func otaQuery(upgradeId:String,result:@escaping(Int,String,FirmwareStatus?)->Void)
    /*
     * @brief 开始发送消息给设备
     * @param deviceId           : 对端设备Id
     * @param result             : 调用sendMessageBegin()是否成功
     * @param statusUpdated      : 在sendMessageBegin()和sendMessageEnd()之间，状态变化回调
     */
    func sendMessageBegin(deviceId:String,result:@escaping(Int,String)->Void,statusUpdated:@escaping(_ status:MessageChannelStatus,_ msg:String,_ data:Data?)->Void)
    /*
     * @brief 结束发送消息给设备
     */
    func sendMessageEnd()
    /*
     * @brief 发送消息给设备，在sendMessageBegin()返回Connected成功后，调用sendMessageEnd()前调用该接口
     * @param device           : 对端设备
     * @param data             : 发送的数据，每次发送数据大小不能超过1k
     * @param description      : 消息描述
     */
    func sendMessage(data:Data,description:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 开始播放sd卡上的视频记录
     * @param channelName      : 频道名
     */
    func startPlayback(channelName:String,result:@escaping(Int,String)->Void,stateChanged:@escaping(PlaybackStatus,String)->Void)
    /*
     * @brief 将播放的视频和view关联
     * @param peerView         : 需要关联的UIView
     * @return                 : 0 成功，非零：失败
     */
    func setPlaybackView(peerView: UIView?) -> Int
    /*
     * @param 停止播放
     */
    func stopPlayback()
}
