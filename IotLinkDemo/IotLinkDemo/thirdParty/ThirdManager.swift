//
//  Service.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/10.
//

import Foundation
import Alamofire
import AgoraIotLink
import SwiftyRSA
import Kingfisher

class ThirdAccountManager{
     
    class api{
    #if false //dev 国内环境
        static let http_3rdParty = "https://third-user.sh.agoralab.co/third-party"
    #elseif false //prd 国内环境
        static let http_3rdParty = "https://third-user.sh3.agoralab.co/third-party"
    #elseif false //dev 国外
        static let http_3rdParty = "https://third-user.la3.agoralab.co/third-party"
    #elseif true //dev 2.0
//        static let http_3rdParty =  "http://api.sd-rtn.com/cn/iot/link"
//        static let http_3rdParty =  "http://api-test-huzhou1.agora.io/eu/iot/link"
        //"https://api.sd-rtn.com/"
        //"http://api-test-huzhou1.agora.io/"
        static let httpPre =  "https://api.sd-rtn.com/"
        static let httpEnd = "/iot/link"
    #elseif false //prd 国外
        
    #endif
        //创建用户mode
        static let  nodeCreate = "/open-api/v2/iot-core/secret-node/user/create"
        //激活用户node
        static let  nodeActivate = "/open-api/v2/iot-core/secret-node/user/activate"
        //激活设备node
        static let  nodeDeviceActivate = "/open-api/v2/iot-core/secret-node/device/activate"
        
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
        
        class activateNode{
            
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
        
        class func getRegionString() -> String {
            let region = TDUserInforManager.shared.curRegion
            var regionString = ""
            switch region {
            case "CN":
                regionString = "cn"
                break
            case "NA":
                regionString = "na"
                break
            case "AP":
                regionString = "ap"
                break
            case "EU":
                regionString = "eu"
                break
            default:
                break
            }
            
            return regionString
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
        let plainCredentials = TDUserInforManager.shared.curCustomKey + ":" + TDUserInforManager.shared.curCustomSecret
        let authData = plainCredentials.data(using: .utf8)
        
        guard let base64Credentials = authData?.base64EncodedString(options: .endLineWithLineFeed) else {
            print("转base64失败")
            return ""
        }
        UserDefaults.standard.set(base64Credentials, forKey: KeyCenter.kAuthorizationBase64Key)
        UserDefaults.standard.synchronize()
    
        return base64Credentials
    }
    
    class func nodeCreate(_ account : String, _ rsp:@escaping(Int,String,String)->Void){
        let baseUrl =  api.httpPre + api.getRegionString() + api.httpEnd
        let header = ThirdAccountManager.configCommonHeader()
        let paramsDic = ["userId":account,"clientType":"2","appId":TDUserInforManager.shared.curMasterAppId]
        let url = baseUrl + api.nodeCreate
        print("url:\(url) header:\(header) paramsDic:\(paramsDic)")
        
//        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default, headers: header) .validate().responseString() { reData in
//
//            guard  reData != nil else{
//                return
//            }
//
//            print("123456")
//
//        }

        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.createNode.Rsp.self){(dataRsp:AFDataResponse<api.createNode.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd nodeCreate fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret.data?.nodeId ?? "")
            case .failure(let error):
                log.e("3rd nodeCreate \(url) , detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error","")
            }
        }
    }
    
    class func nodeActivate(_ account : String,_ rsp:@escaping(Int,String,api.activateNode.Rsp?)->Void){
        
        let baseUrl =  api.httpPre + api.getRegionString() + api.httpEnd
        
        //------------激活设备请求参数，仅在绑定设备demo时需要-------------
//        let header = ThirdAccountManager.configCommonHeader()
//        
//        let paramsDic = ["appId":"5ea8ad97b4684c798966b99a965beb9a","nodeId":"01HR439Q2WKYM8AC2EKY0J4MN2","nodeSecret":"655bad4ca9691dd5bff47325975a18a7",]
//        let paramsDic = ["appId":"00d53e0d1eb549f58e8123cd8a249cb3","nodeId":"01HR439Q1A2EH2B5S1N8J278K6","nodeSecret":"2141912ed55dcfa79de8815b4a65b8cf",]
//        let url = api.http_3rdParty + api.nodeDeviceActivate
//        print("url:\(url) header:\(header) paramsDic:\(paramsDic)")
        //------------激活设备请求参数，仅在绑定设备demo时需要-------------
        
        
        let header = ThirdAccountManager.configCommonHeader()
        let paramsDic = ["userId":account,"clientType":"2","appId":TDUserInforManager.shared.curMasterAppId,"pusherId":"d0177a34"]
        let url = baseUrl + api.nodeActivate
        print("url:\(url) header:\(header) paramsDic:\(paramsDic)")
   
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
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret)
            case .failure(let error):
                log.e("3rd nodeActivate \(url) , detail: \(error) ")
                let _ = getErrorCode(from: error)
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
