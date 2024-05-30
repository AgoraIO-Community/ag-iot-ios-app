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
    #elseif true //dev 2.1.0.4
        static let http_3rdParty = "https://api.sd-rtn.com/cn/iot/link" //"http://api.sd-rtn.com/cn/iot/link"
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
        
        static var privateKey : PrivateKey? = nil
        class func testPublicKeySet(){
            let keyPair = try? SwiftyRSA.generateRSAKeyPair(sizeInBits: 1024)
            let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
            let publicKey = try? keyPair?.publicKey.base64String()
            guard let publicKey = try? keyPair?.publicKey.base64String() else {
                return
            }
            
//            AgoraIotLink.iotsdk.accountMgr.publicKeySet(publicKey: publicKey) { code, msg in
//                debugPrint("\(code)")
//            }
            
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
        
//        if let storedAuthBase64Str = UserDefaults.standard.string(forKey: KeyCenter.kAuthorizationBase64Key) {
//            
//            return storedAuthBase64Str
//            
//        }else{
//            
//            let plainCredentials = TDUserInforManager.shared.curCustomKey + ":" + TDUserInforManager.shared.curCustomSecret
//            let authData = plainCredentials.data(using: .utf8)
//            
//            guard let base64Credentials = authData?.base64EncodedString(options: .endLineWithLineFeed) else {
//                print("转base64失败")
//                return ""
//            }
//            UserDefaults.standard.set(base64Credentials, forKey: KeyCenter.kAuthorizationBase64Key)
//            UserDefaults.standard.synchronize()
//        
//            return base64Credentials
//        }
        
    }
    
    class func nodeCreate(_ account : String, _ rsp:@escaping(Int,String,String)->Void){
        let header = ThirdAccountManager.configCommonHeader()
        let paramsDic = ["userId":account,"clientType":"2","appId":TDUserInforManager.shared.curMasterAppId]
        let url = api.http_3rdParty + api.nodeCreate
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
        
        
        //------------激活设备请求参数，仅在绑定设备demo时需要-------------
//        let header = ThirdAccountManager.configCommonHeader()
//        let paramsDic = ["appId":"5ea8ad97b4684c798966b99a965beb9a","nodeId":"01HR439Q2WKYM8AC2EKY0J4MN2","nodeSecret":"655bad4ca9691dd5bff47325975a18a7",]
//        let url = api.http_3rdParty + api.nodeDeviceActivate
//        print("url:\(url) header:\(header) paramsDic:\(paramsDic)")
        //------------激活设备请求参数，仅在绑定设备demo时需要-------------
        
//        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8","traceId":"123456"]
        let header = ThirdAccountManager.configCommonHeader()
        let paramsDic = ["userId":account,"clientType":"2","appId":TDUserInforManager.shared.curMasterAppId,"pusherId":"d0177a34"]
        let url = api.http_3rdParty + api.nodeActivate
   
//        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default, headers: header) .validate().responseString() { reData in
//
//            guard  reData != nil else{
//                return
//            }
//            print("123456")
//
//        }

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

class Utils{

    class func loadAlertImage(_ alertImageId:String,_ rsp:@escaping(Int,String,UIImage?)->Void){
        ImageCache.default.retrieveImage(forKey: alertImageId) { result in
            switch(result){
            case .success(let data):
                if(data.image != nil){
                    rsp(ErrCode.XOK,"load image from cache",data.image)
                }
                else{
                    log.v("3rd retrieveImage is nil,try download image:\(alertImageId)")
//                    self.loadAlertById(alertImageId, rsp)
                }
            case .failure(let err):
                log.e("3rd retrieveImage fail,try load image:\(err)")
                //log.e("al loadImage failed(\(err)):\(msg) for \(alertMessageId) url:\(String(describing: url))")
//                self.loadAlertById(alertImageId, rsp)
            }
        }
    }
    
//    class func loadAlertVideoUrl(_ deviceId:String,_ tenantId:String, _ beginTime:UInt64,_ rsp:@escaping(Int,String,AlarmVideoInfo?)->Void){
//        //rsp(ErrCode.XOK,"","http://aios-personalized-wuw.oss-cn-beijing.aliyuncs.com/conn-1.m3u8")
//        AgoraIotLink.iotsdk.alarmMgr.queryAlarmVideoUrl(deviceId: deviceId,tenantId: tenantId, beginTime: beginTime,result:{ ec, msg, info in
//            guard let info = info else{
//                return rsp(ec,msg,info)
//            }
//            
//            //如果没有加密，则正常播放
//            guard  info.videoSecretKey != "" else {
//                return rsp(ec,msg,info)
//            }
//            
//            guard let privateKey = ThirdAccountManager.privateKey else{
//                return rsp(ErrCode.XERR_INVALID_PARAM,"3rd private key is nil",info)
//            }
//            
//            let encrypted = try? EncryptedMessage(base64Encoded: info.videoSecretKey)
//            let clear = try? encrypted?.decrypted(with: privateKey, padding: .PKCS1)
//            
//            guard let clear = clear else{
//                return rsp(ErrCode.XERR_INVALID_PARAM,"3d key can't be decoded",info)
//            }
//            
//            info.videoSecretKey = clear.base64String
//            info.url = info.url + "&agora-key=" + info.videoSecretKey
//            return rsp(ec,msg,info)
//            
//        })
//    }
}
