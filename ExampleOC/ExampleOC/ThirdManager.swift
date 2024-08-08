//
//  Service.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/10.
//

import Foundation
import Alamofire
import AgoraIotLink

@objc class ThirdAccountManager: NSObject{
     
    @objc class api: NSObject{
    #if false //dev 国内环境
        static let http_3rdParty = "https://third-user.sh.agoralab.co/third-party"
    #elseif false //prd 国内环境
        static let http_3rdParty = "https://third-user.sh3.agoralab.co/third-party"
    #elseif false //dev 国外
        static let http_3rdParty = "https://third-user.la3.agoralab.co/third-party"
    #elseif true //dev 2.0
        static let http_3rdParty =  "http://api.sd-rtn.com/cn/iot/link" //"http://api-test-huzhou1.agora.io/cn/iot/link" //"https://api-test-huzhou1.agora.io/cn/iot/link"//"https://api.sd-rtn.com/agoralink/cn/api"
    #elseif false //prd 国外
        
    #endif
        static let getVerifyCode =   "/sys-verification-code/v1/sendRegisterCode" //注册 发送验证码
        static let getResetPwdVerifyCode =   "/sys-verification-code/v1/sendResetPwdCode" //重置密码 发送验证码
        
        //创建用户mode
//        static let  nodeCreate = "/iot-core/v2/secret-node/user/create"
        static let  nodeCreate = "/open-api/v2/iot-core/secret-node/user/create"
        //激活用户node
        static let  nodeActivate = "/open-api/v2/iot-core/secret-node/user/activate"

        //激活设备node
        static let  nodeDeviceActivate = "/open-api/v2/iot-core/secret-node/device/activate"
        
        struct Rsp:Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
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
        
        class createNode{
            
            struct Data : Decodable{
                let nodeId:String
                let region:String
            }
            struct Rsp : Decodable{
                let code:Int
                let msg:String
                let timestamp:UInt64
                let success:Bool
                let data:Data?
            }
        }
        
        @objc class activateNode: NSObject{
            
            struct Data : Decodable{
                let nodeId:String
                let nodeToken:String
                let nodeRegion:String
                let mqttPort:Int
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
        
        @objc class ActivateNodeRsp: NSObject {
            @objc var nodeId:String = ""
            @objc var nodeToken:String = ""
            @objc var nodeRegion:String = ""
            @objc var mqttPort:Int = 0
        }
        
    }
    
    static var sessionManager:Alamofire.Session!
    
    //配置请求头的通用参数
    class func configCommonHeader()->HTTPHeaders {
        
        let headers:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8","traceId":"123456789","Authorization":"Basic " + getAuthorizationText()]
        return headers
    }
    
    //获取Authorization Base64编码
    class func getAuthorizationText()-> String {
        
        let plainCredentials = "" + ":" + ""
        let authData = plainCredentials.data(using: .utf8)
        
        guard let base64Credentials = authData?.base64EncodedString(options: .endLineWithLineFeed) else {
            print("转base64失败")
            return ""
        }
    
        return base64Credentials
        
    }
    
    @objc class func nodeActivate(account : String, rsp:@escaping(Int,String,api.ActivateNodeRsp?)->Void){
        let header = ThirdAccountManager.configCommonHeader()
        let paramsDic = ["userId":account,"clientType":"2","appId":"","pusherId":"d0177a34"]
        let url = api.http_3rdParty + api.nodeActivate
   
//        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default, headers: header) .validate().responseString() { reData in
//
//            guard  reData != nil else{
//                return
//            }
//            print("123456")
//
//        }
//        return
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5 // 设置超时时间为5秒
        sessionManager = Alamofire.Session(configuration: configuration)
        
        sessionManager.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.activateNode.Rsp.self){(dataRsp:AFDataResponse<api.activateNode.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd nodeActivate fail \(ret.msg)(\(ret.code))")
                }
                var tempRspModel = api.ActivateNodeRsp()
                tempRspModel.nodeId = ret.data?.nodeId ?? ""
                tempRspModel.nodeToken = ret.data?.nodeToken ?? ""
                tempRspModel.nodeRegion = ret.data?.nodeRegion ?? ""
                tempRspModel.mqttPort = ret.data?.mqttPort ?? 0
                
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,tempRspModel)
            case .failure(let error):
                log.e("3rd nodeActivate \(url) , detail: \(error) ")
                let errCode = getErrorCode(from: error)
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
            }
        }
    }

    
    class func getErrorCode(from error: Error) -> Int? {
        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let sessionError):
                if let nsError = sessionError as NSError?, nsError.domain == NSURLErrorDomain {
                    return nsError.code
                }
            default:
                break
            }
        }
        return nil
    }
    
}
