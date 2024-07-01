//
//  AgoraLab.Type.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/23.
//

import Foundation

extension AgoraLab{
    class api{
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
    
    class ConnectCreat{
        
        struct Payload : Encodable{
            let nodeToken:String
            let localNodeId:String
            let peerNodeId:String
            let appId:String
        }
        struct Req : Encodable{
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
   
}
