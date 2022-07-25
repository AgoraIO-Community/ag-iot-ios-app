//
//  AgoraLab.Type.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/23.
//

import Foundation

extension AgoraLab{
    class api{
        static let call = "/call-service/v1/call"
        static let answer = "/call-service/v1/answer"
        
        static let add = "/alert-center/alert-message/v1/add"
        static let delete = "/alert-center/alert-message/v1/delete"
        static let batchDelete = "/alert-center/alert-message/v1/deleteBatch"
        static let update = "/alert-center/alert-message/v1/update"
        static let singleRead = "/alert-center/alert-message/v1/readMessage"
        static let batchRead = "/alert-center/alert-message/v1/readMessageBatch"
        static let getById = "/alert-center/alert-message/v1/getById"
        static let getPage = "/alert-center/alert-message/v1/getPage"
        
        static let oauthRegister = "/oauth/register"
        static let oauthResetToken = "/oauth/rest-token"
        static let getAlertCount = "/alert-center/alert-message/v1/count"
        
        static let sysReadMsg = "/alert-center/system-message/v1/readMessage"
        static let sysReadMsgBatch = "/alert-center/system-message/v1/readMessageBatch"
        static let sysGetById = "/alert-center/system-message/v1/getById"
        static let sysGetPage = "/alert-center/system-message/v1/getPage"
        static let sysGetAlertCount = "/alert-center/system-message/v1/count"
        
        static let uploadHeadIcon = "/file-system/image/v1/uploadFile"
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
        public static let SYS_ERROR = 999999      ///< 系统异常，具体原因查看错误提示信息
    }
    
    struct Rsp:Decodable{
        let code:Int
        let msg:String
        let timestamp:UInt64
        let success:Bool
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
            self.traceId = traceId
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

    typealias Login = Register

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
}
