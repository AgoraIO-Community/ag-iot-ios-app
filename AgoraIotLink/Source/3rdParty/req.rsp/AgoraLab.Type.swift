//
//  AgoraLab.Type.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/23.
//

import Foundation


extension AgoraLab{
    class api{
        //内部临时测试使用接口
                               
        static let authLogin =          "/auth/login"
        static let oauthRegister =      "/oauth/register"
        static let oauthResetToken =    "/oauth/rest-token"
        
        static let add =                "/alert-center/alert-message/v1/add"
        static let delete =             "/alert-center/alert-message/v1/delete"
        static let batchDelete =        "/alert-center/alert-message/v1/deleteBatch"
        static let update =             "/alert-center/alert-message/v1/update"
        static let singleRead =         "/alert-center/alert-message/v1/readMessage"
        static let batchRead =          "/alert-center/alert-message/v1/readMessageBatch"
        static let getById =            "/alert-center/alert-message/v1/getById"
        static let getPage =            "/alert-center/alert-message/v1/getPage"
        static let getAlertCount =      "/alert-center/alert-message/v1/count"
        
        //重置设备
        static let  resetDevice = "/call-service/v1/reset"
        //设置用户公钥
        static let  publicKeySet = "/oauth/public-key/set"
        
        //激活用户node
//        static let  nodeActivate = "/iot-core/v2/secret-node/user/activate"
        static let  nodeActivate = "/open-api/v2/iot-core/secret-node/user/activate"
        
        
        //与设备建立链接（2.x）
        static let  connectCreat = "/open-api/v2/connect/create"

    }

    static let tokenExpiredCode = 401

    class RspCode{
        public static let OK = 0
        public static let IN_TALKING = 100001      ///<	对端通话中，无法接听
        public static let ANSWER = 100002          ///<	未通话，无法接听
        public static let HANGUP = 100003          ///<	未通话，无法挂断
        public static let ANSWER_TIMEOUT = 100004  ///< 接听等待超时
        public static let CALL = 100005            ///< 呼叫中，无法再次呼叫
        public static let INVALID_ANSWER = 100006  ///< 无效的Answer应答
        public static let SAME_ID = 100007         ///< 主叫和被叫不能是同一个id
        public static let APPID_NOT_REPORT = 100008 ///< 未上报app id
        public static let APPID_NOT_SAME = 100009  ///< 主控和被控方app id必须一致>
        public static let SYS_ERROR = 999999       ///< 系统异常，具体原因查看错误提示信息
    }
    
    struct Rsp:Decodable{
        let code:Int
        let msg:String
        let timestamp:UInt64
        let success:Bool
    }
    
    class ResetDevice{
        
        struct Payload : Encodable{
            let deviceId:String
            let appId:String
        }
        struct Req : Encodable{
            let header:Header
            let payload:Payload
        }
        
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
        }
        
    }
    
    class PublicKeySet{
        
        struct Payload : Encodable{
            let userId:String
            let publicKey:String
        }
        struct Req : Encodable{
            let header:Header
            let payload:Payload
        }
        
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
        }
        
    }
    
    class ActivateNode{
        
        struct Payload : Encodable{
            let clientType:String
            let userId:String
            let masterAppId:String
            let pusherId:String
        }
        struct Req : Encodable{
            let payload:Payload
        }
        
        struct Data : Decodable{
            let nodeId:String
            let nodeToken:String
            let nodeRegion:String
            let mqttServer:String
            let mqttPort:UInt
            let mqttUsername:String
            let mqttSalt:String
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
        
    }
    
    class ConnectCreat{
        
        struct Payload : Encodable{
            let nodeToken:String
            let localNodeId:String
            let peerNodeId:String
            let appId:String
        }
        struct Req : Encodable{
//            let payload:Payload
            let nodeToken:String
            let localNodeId:String
            let peerNodeId:String
            let appId:String
            let encrypt:Int
        }
        
        struct Data : Decodable{
            let token:String
            let uid:UInt
            let cname:String
            let encryptMode:Int?
            let secretKey:String?
        }
        
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let traceId:String
            let success:Bool
            let data:Data?
        }
        
    }

    
    class Login{
        struct LsToken : Decodable{
            let access_token:String
            let token_type : String
            let refresh_token : String
            let expires_in : UInt
            let scope : String
        }
        struct Pool : Decodable{
            let identifier : String
            let identityId : String
            let identityPoolId : String
            let token : String
        }
        struct Proof : Decodable{
            let accessKeyId : String
            let secretKey : String
            let sessionToken : String
            let sessionExpiration : UInt64
        }
        struct GyToken : Decodable{
            let endpoint:String
            let pool : Pool?
            let expiration : UInt64
            let granwin_token : String
            let proof : Proof?
            let region : String
            let account : String
        }
        struct Data : Decodable{
            let lsToken:LsToken?
            let gyToken:GyToken?
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    class RestToken{
        struct Req:Encodable{
            let grant_type:String  //授权类型。password：密码模式，client_credentials：客户端模式，refresh_token：刷新accessToken
            let username:String //用户名
            let password:String //密码
            let scope:String //当前固定值：read
            let client_id:String //"9598156a7d15428f83f828a70f40aad5", //AK
            let client_secret:String //"MRbRz1kGau9BZE0gWRh9YMZSYc1Ue06v" //SK
        }
        struct Data:Decodable{
            let access_token:String
            let token_type:String
            let refresh_token:String
            let expires_in:UInt
            let scope:String
        }
        struct Rsp:Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }

    class Register{
        struct Rsp : Decodable{
            let code:Int
            let message:String
            struct Data : Decodable{
                let agoraUid:UInt
                let customerAccountId:String
            }
            let data:Data?
        }
    }

    struct Header : Encodable {
        let traceId:String
        let timestamp:UInt64
        init(traceId:String = ""){
            let timeInterval: TimeInterval = Date().timeIntervalSince1970
            timestamp = UInt64(round(timeInterval*1000))
            
            if traceId == ""{
                self.traceId = "\(timestamp)"
            }else{
                self.traceId = traceId
            }
        }
    }
    class AlertMessageDelete{
        struct Req : Encodable{
            let header : Header
            let payload : Int
            init(_ header:Header,_ index:Int){
                self.header = header
                self.payload = index
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    class AlertMessageBatchDelete{
        struct Req : Encodable{
            let header : Header
            let payload : [Int]
            init(_ header:Header,_ indexes:[Int]){
                self.header = header
                self.payload = indexes
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    class AlertMessageUpdate{
        struct Payload : Encodable{
            let alertMessageId:Int
            let tenantId:String
            let productId:String
            let deviceId : String
            let description:String
            let fileUrl:String
            let status:Int
            let messageType:Int
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    class AlertMessageAdd{
        struct Payload : Encodable{
            let tenantId:String
            let productId:String
            let deviceId:String
            let deviceName:String
            let description:String
            let fileUrl:String
            let status:Int
            let messageType:Int //0,1,99
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            init(_ header:Header,_ payload: Payload){
                self.header = header
                self.payload = payload
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:UInt
        }
    }
    class AlertMessageRead{
        struct Req : Encodable{
            let header : Header
            let payload : UInt64
            init(_ header:Header,_ index:UInt64){
                self.header = header
                self.payload = index
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    
    class RtcToken{
        struct Payload : Encodable{
            let appId:String
            let channelName:String
            init(appId:String,channelName:String){
                self.appId = appId
                self.channelName = channelName
            }
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
        }
        struct Data : Decodable{
            let rtcToken : String
            let channelName : String
            let uid : UInt
        }
        
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    class ControlInfo{
        struct Payload : Encodable{
            let controllerId:String
            let controlledId:String
            init(localVirtualNumb:String,peerVirtualNumb:String){
                controlledId = peerVirtualNumb
                controllerId = localVirtualNumb
            }
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
        }
        //{"code":0,"msg":"SUCCESS","timestamp":1660725206380,"data":{"rtmToken":"006d0177a34373b482a9c4eb4dedcfa586aIABOc4bBb8WteljZDyvY8tDu+qBfCf2AnS0Bq1Rd++HdKEFsvPUAAAAAEADBzeFEVvn9YgEA6AMAAAAA"},"success":true}
        struct Data : Decodable{
            let rtmToken:String
            //let uid:String
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    class AlertMessageBatchRead{
        struct Req : Encodable{
            let header : Header
            let payload : [UInt64]
            init(_ header:Header,_ indexes:[UInt64]){
                self.header = header
                self.payload = indexes
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    class AlertMessageGetById{
        struct Req : Encodable{
            let header:Header
            let payload:UInt64
            init(_ header:Header,_ alertMessageId:UInt64){
                self.header = header
                self.payload = alertMessageId
            }
        }
        struct Data : Decodable{
            let alertMessageId:UInt64
            let messageType:UInt
            let description:String?
            let fileUrl:String?
            let status:UInt
            let tenantId:String
            let productId:String
            let deviceId:String
            let deviceName:String
            let deleted:Bool
            let createdBy:UInt
            let createdDate:UInt64
            let changedBy:UInt?
            let changedDate:UInt64?
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data : Data?
        }
    }
    class AlertCount{
        struct Payload : Encodable{
            let tenantId:String?
            var productId:String? = nil
            var deviceId:String? = nil
            var messageType:Int? = nil //0:sound dectect,1:motion dectect, 99:other
            var status:Int? = nil      //0:not read,1:have read
            var createdDateBegin:String? = nil
            var createdDateEnd:String? = nil
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            init(_ header:Header,_ payload:Payload){
                self.header = header
                self.payload = payload
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:UInt
        }
    }
    class SysAlertCount{
        struct Payload : Encodable{
            let tenantId:String?
            var productId:String? = nil
            var deviceIds:[String]? = nil
            var messageType:Int? = nil //0:sound dectect,1:motion dectect, 99:other
            var status:Int? = nil      //0:not read,1:have read
            var createdDateBegin:String? = nil
            var createdDateEnd:String? = nil
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            init(_ header:Header,_ payload:Payload){
                self.header = header
                self.payload = payload
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:UInt
        }
    }
    class SysAlertMessageGetPage{
        struct Payload : Encodable{
            var tenantId:String? = nil
            var productId:String? = nil
            var deviceIds:[String]? = nil
            var messageType:Int? = nil //0:sound dectect,1:motion dectect, 99:other
            var status:Int? = nil      //0:not read,1:have read
            var createdDateBegin:String? = nil
            var createdDateEnd:String? = nil
        }
        struct PageInfo : Encodable{
            let currentPage : Int
            let pageSize : Int
            init(_ currPage:Int,_ pageSize:Int){
                self.currentPage = currPage
                self.pageSize = pageSize
            }
        }
        struct SortMap : Encodable{
            let systemMessageId : String //asc / desc, default:desc
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            let pageInfo : PageInfo
            init(_ header:Header,_ payload:Payload,_ pageInfo : PageInfo){
                self.header = header
                self.payload = payload
                self.pageInfo = pageInfo
            }
        }
        struct PageResults:Decodable{
            let systemMessageId:UInt64
            let messageType:UInt
            let description:String?
            let fileUrl:String?
            let status:UInt
            let tenantId:String?
            let productId:String?
            let deviceId:String
            let deviceName:String?
            let deleted:Bool
            let createdBy:UInt
            let createdDate:UInt64?
            let changedBy:UInt?
            let changedDate:UInt64?
        }
        struct Data:Decodable{
            let pageResults:[PageResults]?
            let pageSize:Int
            let currentPage:Int
            let totalCount:Int
            let totalPage:Int
//            let next:Bool      //whether next page exist
//            let previous:Bool  //whether prev page exist
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    class AlertMessageGetPage{
        struct Payload : Encodable{
            let tenantId:String
            var productId:String? = nil
            var deviceId:String? = nil
            var messageType:Int? = nil //0:sound dectect,1:motion dectect, 99:other
            var status:Int? = nil      //0:not read,1:have read
            var createdDateBegin:String? = nil
            var createdDateEnd:String? = nil
        }
        struct PageInfo : Encodable{
            let currentPage : Int
            let pageSize : Int
            init(_ currPage:Int,_ pageSize:Int){
                self.currentPage = currPage
                self.pageSize = pageSize
            }
        }
        struct SortMap : Encodable{
            let alertMessageId : String //asc / desc, default:desc
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            let pageInfo : PageInfo
            init(_ header:Header,_ payload:Payload,_ pageInfo : PageInfo){
                self.header = header
                self.payload = payload
                self.pageInfo = pageInfo
            }
        }
        struct PageResults:Decodable{
            let alertMessageId:UInt64
            let messageType:UInt
            let description:String?
            let fileUrl:String?
            let status:UInt
            let tenantId:String
            let productId:String
            let deviceId:String
            let deviceName:String
            let deleted:Bool
            let createdBy:UInt
            let createdDate:UInt64
            let changedBy:UInt?
            let changedDate:UInt64?
        }
        struct Data:Decodable{
            let pageResults:[PageResults]?
            let pageSize:Int
            let currentPage:Int
            let totalCount:Int
            let totalPage:Int
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    class AlertImageUrl{
        struct Req : Encodable{
            let header : Header
            let payload : String
            init(_ header:Header,_ payload:String){
                self.header = header
                self.payload = payload
            }
        }
        struct Data : Decodable{
//            let recordId:UInt64
//            let imageId:String
//            let userId:String
//            let productId:String
//            let deviceName:String?
//            let fileName:String
//            let bucket:String
//            let remark:String?
//            let deleted:Bool
//            let createBy:UInt64?
//            let createdTime:String
            let vodUrl:String
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    class AlertVideoUrl{
        struct Payload : Encodable{
            let userId:String
            let deviceId:String
            let beginTime:UInt64
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            init(_ header:Header,_ indexes:Payload){
                self.header = header
                self.payload = indexes
            }
        }
        struct Data : Decodable{
            let videoRecordId:UInt64
            let type:Int ////类型，0表示计划录像，1表示报警录像，2表示主动录像，99表示所有录像
            let userId:String
            let productId:String
            let deviceId:String
            let deviceName:String?
            let beginTime:UInt64
            let endTime:UInt64
            let fileName:String
            let bucket:String
            let remark:String?
            let vodUrl:String
            let deleted:Bool
            let createdBy:UInt64
            let createdTime:UInt64
            let videoSecretKey:String?
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    class AlertMessageBatchDeleteV2{
        struct Req : Encodable{
            let header : Header
            let payload : [UInt64]
            init(_ header:Header,_ indexes:[UInt64]){
                self.header = header
                self.payload = indexes
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    
    class AlertMessageDeleteV2{
        struct Req : Encodable{
            let header : Header
            let payload : UInt64
            init(_ header:Header,_ index:UInt64){
                self.header = header
                self.payload = index
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    
    class AlertMessageBatchReadV2{
        struct Req : Encodable{
            let header : Header
            let payload : [UInt64]
            init(_ header:Header,_ indexes:[UInt64]){
                self.header = header
                self.payload = indexes
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    
    class AlertMessageAddV2{
        struct Payload : Encodable{
            let beginTime:UInt64
            let tenantId:String
            let productId:String
            let deviceId:String
            let deviceName:String
            let description:String
            let status:Int
            let messageType:Int
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            init(_ header:Header,_ payload:Payload){
                self.header = header
                self.payload = payload
            }
        }
        
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:UInt64
        }
    }
    
    class AlertMessageReadV2{
        struct Req : Encodable{
            let header : Header
            let payload : UInt64
            init(_ header:Header,_ index:UInt64){
                self.header = header
                self.payload = index
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Bool
        }
    }
    class AlertCountV2{
        struct Payload : Encodable{
            let tenantId:String?
            var productId:String? = nil
            var deviceId:String? = nil
            var messageType:Int? = nil //0:sound dectect,1:motion dectect, 99:other
            var status:Int? = nil      //0:not read,1:have read
            var createdDateBegin:String? = nil
            var createdDateEnd:String? = nil
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            init(_ header:Header,_ payload:Payload){
                self.header = header
                self.payload = payload
            }
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:UInt
        }
    }
    class AlertMessageGetByIdV2{
        struct Req : Encodable{
            let header:Header
            let payload:UInt64
            init(_ header:Header,_ alertMessageId:UInt64){
                self.header = header
                self.payload = alertMessageId
            }
        }
        struct Data : Decodable{
            let alarmMessageId:UInt64
            let messageType:UInt
            let description:String?
            let fileUrl:String?
            let status:UInt
            let tenantId:String
            let productId:String
            let deviceId:String
            let deviceName:String
            let deleted:Bool
            let beginTime:UInt64
            let createdBy:UInt
            let createdDate:UInt64
            let changedBy:UInt?
            let changedDate:UInt64?
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data : Data?
        }
    }
    class AlertMessageGetPageV2{
        struct Payload : Encodable{
            let tenantId:String
            var productId:String? = nil
            var deviceId:String? = nil
            var messageType:Int? = nil //0:sound dectect,1:motion dectect, 99:other
            var status:Int? = nil      //0:not read,1:have read
            var createdDateBegin:String? = nil
            var createdDateEnd:String? = nil
        }
        struct PageInfo : Encodable{
            let currentPage : Int
            let pageSize : Int
            init(_ currPage:Int,_ pageSize:Int){
                self.currentPage = currPage
                self.pageSize = pageSize
            }
        }
        struct SortMap : Encodable{
            let alertMessageId : String //asc / desc, default:desc
        }
        struct Req : Encodable{
            let header : Header
            let payload : Payload
            let pageInfo : PageInfo
            init(_ header:Header,_ payload:Payload,_ pageInfo : PageInfo){
                self.header = header
                self.payload = payload
                self.pageInfo = pageInfo
            }
        }
        struct PageResults:Decodable{
            let alarmMessageId:UInt64
            let messageType:UInt
            let description:String?
            let fileUrl:String?
            let status:UInt
            let tenantId:String
            let productId:String
            let deviceId:String
            let deviceName:String
            let beginTime:UInt64
            let deleted:Bool
            let createdBy:UInt
            let createdDate:UInt64
            let changedBy:UInt?
            let changedDate:UInt64?
            let imageId:String?
        }
        struct Data:Decodable{
            let pageResults:[PageResults]?
            let pageSize:Int
            let currentPage:Int
            let totalCount:Int
            let totalPage:Int
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }

    //typealias Login = Register

    class Alarm{
        struct RecordInfo : Decodable{
            let deviceId:String
            let deviceUid:UInt64
            let recordChannel:String
            let recordSid:String
        }
        struct Data : Decodable{
            let alarmId:UInt64
            let alarmType:Int
            let alarmDescription:String
            let attachMsg:String
            let date:String
            let timestamp:UInt64
            let recordInfo:RecordInfo
            let read:Bool
        }
        struct Rsp : Decodable{
            let code:Int
            let message:String
            let data:[Data]?
        }
        
        struct Req: Encodable {
            let appId: String
            let deviceIdList: [String]
            let date:String
            let page:Int
            let size:Int
            let type:Int
            init(appId:String,deviceIdList:[String],date:String,page:Int,size:Int,type:Int){
                self.appId = appId
                self.deviceIdList = deviceIdList
                self.date = date
                self.page = page
                self.size = size
                self.type = type
            }
        }
    }
    
    class UploadImage{
        struct Rsp:Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let data:String?
            let success:Bool
        }
    }

    class Call{
        struct Payload : Encodable{
            let callerId:String
            let calleeIds:[String]
            let attachMsg:String
            let appId:String
        }
        struct Req : Encodable{
            let header:Header
            let payload:Payload
        }
        struct Data : Decodable{
            let appId:String
            let channelName:String
            let rtcToken:String
            let uid:String
            let peerUid:String
            let sessionId:String
            let callStatus:Int
            let cloudRecordStatus:Int
            //let deviceAlias:String
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let data:Data?
        }
    }
    
    //osspinlock
    //os_unfair_lock
    
    //322  284
    class CallSimple{
        struct Payload : Encodable{
            let appId:String
            let deviceId:String
            let userId:String
            let extraMsg:String
        }
        struct Req : Encodable{
            let header:Header
            let payload:Payload
        }
        struct Data : Decodable{
            let token:String
            let uid:Int
            let cname:String
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let traceId:String
            let data:Data?
        }
    }

    class Answer{
        struct Payload : Encodable{
            let sessionId:String
            let calleeId:String
            let callerId:String
            let localId:String
            let answer:Int //0:接听，1:挂断
        }
        struct Req : Encodable{
            let header:Header
            let payload:Payload
        }
        struct Data : Decodable{
            let sessionId:String
        }
        struct Rsp : Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
            let data:Data?
        }
    }
    
    func handleRspGetImageUrl(_ ret:AlertImageUrl.Rsp,_ rsp:@escaping (Int,String,String?)->Void){
        if(ret.code == AgoraLab.tokenExpiredCode){
            log.w("al handleRspGetImageUrl fail \(ret.msg)(\(ret.code))")
            rsp(ErrCode.XERR_TOKEN_INVALID,ret.msg,nil)
            return
        }
        
        if(ret.code != 0){
            log.w("al handleRspGetImageUrl fail \(ret.msg)(\(ret.code))")
            return rsp(ErrCode.XERR_SYSTEM,ret.msg,nil)
        }
        
        guard let data = ret.data else{
            log.e("al handleRspGetImageUrl rsp no data found,the premission may be expired")
            return rsp(ErrCode.XERR_UNKNOWN,"no data found",nil)
        }
        
        rsp(ErrCode.XOK,ret.msg,data.vodUrl)
    }
}
