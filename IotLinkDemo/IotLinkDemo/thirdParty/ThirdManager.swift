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

class ConnectDeviceNode{
    
    struct Data : Decodable{
        let cname:String
        let uid:UInt
        let rtcToken:String
        let rtmToken:String
        let userId:String
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

class ActivateNode{
    
    struct Data : Decodable{
        let nodeId:String
        let nodeToken:String
        let nodeRegion:String
        let mqttServer:String
        let mqttPort:UInt
        let mqttUsername:String
    }
    struct Rsp : Decodable{
        let code:Int
        let msg:String
        let timestamp:UInt64
        let success:Bool
        let data:Data?
    }
}

class ThirdAccountManager{
    class api{
    #if false //dev 国内环境
        static let http_3rdParty = "https://third-user.sh.agoralab.co/third-party"
    #elseif true //prd 国内环境
        static let http_3rdParty = "https://third-user.sh3.agoralab.co/third-party"
    #elseif false //dev 国外
        static let http_3rdParty = "https://third-user.la3.agoralab.co/third-party"
    #elseif false //prd 国外
        
    #endif
        static let authRegister =    "/auth/register" //不需要短信验证码
        static let authRegister2 =    "/auth/register2" //需短信验证码
        static let resetPassword =    "/auth/resetPwd" //重置密码，需短信验证码
        static let authLogin =       "/auth/login"
        static let authUnRegister =  "/auth/removeAccount"
        static let getUid =          "/auth/getUidByUsername"
        static let getVerifyCode =   "/sys-verification-code/v1/sendRegisterCode" //注册 发送验证码
        static let getResetPwdVerifyCode =   "/sys-verification-code/v1/sendResetPwdCode" //重置密码 发送验证码
        
        //创建用户mode
        static let  nodeCreate = "/iot-core/v2/secret-node/user/create"
        //激活用户node
        static let  nodeActivate = "/iot-core/v2/secret-node/user/activate"
        
        //获取连接设备参数
        static let  connectDevice = "/iot/link/open-api/v2/iot-core/connect-device"
        
        
        struct Rsp:Decodable{
            let code:Int
            let msg:String
            let timestamp:UInt64
            let success:Bool
        }
        
        struct GetUidRsp:Decodable{
            let code:Int
            let msg:String
            let success:Bool
            let timestamp:UInt64
            let data:String?
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
 
        public class func handleLoginRsp(_ ret:Login.Rsp,_ rsp:@escaping (Int,String,LoginParam?)->Void){
            if(ret.code != 0){
                log.e("3rd handleLoginRsp fail \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let data = ret.data else{
                log.e("3rd handleLoginRsp data is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let lsToken = data.lsToken else {
                log.e("3rd handleLoginRsp lsToken is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let gyToken = data.gyToken else {
                log.e("3rd handleLoginRsp gyToken is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let pool = gyToken.pool else {
                log.e("3rd handleLoginRsp pool is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let proof = gyToken.proof else {
                log.e("3rd handleLoginRsp proof is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            
            let param = LoginParam()
            
            param.tokenType = lsToken.token_type
            param.accessToken = lsToken.access_token
            param.refreshToken = lsToken.refresh_token
            param.expireIn = lsToken.expires_in
            param.scope = lsToken.scope
            
            param.grawin_token = gyToken.granwin_token
            param.expiration = gyToken.expiration
            param.endPoint = gyToken.endpoint
            param.region = gyToken.region
            param.account = gyToken.account
            
            param.proof_secretKey = proof.secretKey
            param.proof_sessionToken = proof.sessionToken
            param.proof_accessKeyId = proof.accessKeyId
            param.proof_sessionExpiration = proof.sessionExpiration
            
            param.pool_token = pool.token
            param.pool_identifier = pool.identifier
            param.pool_identityId = pool.identityId
            param.pool_identityPoolId = pool.identityPoolId
            
            rsp(ErrCode.XOK,ret.msg,param)
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
        
    class func reqRegister(_ userName:String,_ password:String,_ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":userName,"password":password]
        let url = api.http_3rdParty + api.authRegister

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("第三方 reqRegister fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("第三方 reqRegister \(url) fail for \(userName), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    class func reqGetVerifyCode( phoneNumber:String, _ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["mobile":phoneNumber]
        let url = api.http_3rdParty + api.getVerifyCode

        AF.request(url,method:.get,parameters:params,encoder: URLEncodedFormParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd reqGetVerifyCode fail \(ret.msg)(\(ret.code))")
                }
                if ret.code == 9999{
                    rsp(ErrCode.XERR_UNKNOWN,ret.msg)
                }else{
                    rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
                }
                
            case .failure(let error):
                log.e("3rd reqGetVerifyCode \(url) fail for \(phoneNumber), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    class func reqGetResetPwdVerifyCode( phoneNumber:String, _ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["mobile":phoneNumber]
        let url = api.http_3rdParty + api.getResetPwdVerifyCode

        AF.request(url,method:.get,parameters:params,encoder: URLEncodedFormParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd reqGetVerifyCode fail \(ret.msg)(\(ret.code))")
                }
                if ret.code == 9999{
                    rsp(ErrCode.XERR_UNKNOWN,ret.msg)
                }else{
                    rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
                }
                
            case .failure(let error):
                log.e("3rd reqGetVerifyCode \(url) fail for \(phoneNumber), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    class func reqRegisterByPhone(_ phoneNumber:String,_ password:String,_ verifyCode:String,_ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":phoneNumber,"password":password,"verificationCode":verifyCode]
        let url = api.http_3rdParty + api.authRegister2

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd reqRegister fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("3rd reqRegister \(url) fail for \(phoneNumber), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    static var privateKey : PrivateKey? = nil
    class func reqLogin(_ username:String,_ password:String,rsp:@escaping(Int,String,LoginParam?)->Void){
        
        let keyPair = try? SwiftyRSA.generateRSAKeyPair(sizeInBits: 1024)
        privateKey = keyPair?.privateKey
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let publicKey = try? keyPair?.publicKey.base64String()
        
 
        let params = ["username":username,"password":password,"publicKey":publicKey]
        let url = api.http_3rdParty + api.authLogin
        
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Login.Rsp.self){(dataRsp:AFDataResponse<api.Login.Rsp>) in
                URLCache.shared.removeAllCachedResponses()
                switch dataRsp.result{
                case .success(let ret):
                    api.handleLoginRsp(ret,rsp)
                case .failure(let error):
                    log.e("3rd reqLogin \(url) fail for \(username), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                }
            }
    }
    
    class func reqUnRegister(_ account: String,_ password:String,_ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":account,"password":password]
        let url = api.http_3rdParty + api.authUnRegister

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("3rd reqUnRegister \(url) fail for \(account), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    class func reqUseridByAccount(_ account:String,_ rsp:@escaping(Int,String,String?)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":account]
        let url = api.http_3rdParty + api.getUid

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.GetUidRsp.self){(dataRsp:AFDataResponse<api.GetUidRsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret.data)
            case .failure(let error):
                log.e("3rd reqUidByAccount \(url) fail for \(account), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
            }
        }
    }
    
    class func resetPassword(_ phoneNumber:String,_ password:String,_ verifyCode:String,_ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":phoneNumber,"password":password,"verificationCode":verifyCode]
        let url = api.http_3rdParty + api.resetPassword

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd resetPassword fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("3rd resetPassword \(url) fail for \(phoneNumber), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    
    
    
    class func nodeActivate(userId:String, _ rsp:@escaping(Int,String, ActivateNode.Rsp?)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8","traceId":"123456"]
        let params = ["userId":userId,"clientType":"2","masterAppId":"d0177a34373b482a9c4eb4dedcfa586a","pusherId":"d0177a34"]
        let paramsDic = ["payload":params]
        let url = "https://iot-api-gateway.sh.agoralab.co/api" + api.nodeActivate
        
//        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default, headers: header) .validate().responseString() { reData in
//
//            guard  reData != nil else{
//                return
//            }
//
//
//            print("123456")
//
//        }

        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:ActivateNode.Rsp.self){(dataRsp:AFDataResponse<ActivateNode.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd resetPassword fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret)
            case .failure(let error):
                log.e("3rd resetPassword \(url) , detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
            }
        }
    }
    
    class func getConnectDeviceParam( _ rsp:@escaping(Int,String, ConnectDeviceNode.Rsp?)->Void){
        
        let username = "8620fd479140455388f99420fd307363"
        let password = "492c18dcdb0a43c5bb10cc1cd217e802"
        
        let loginString = "\(username):\(password)"
        let base64LoginString = loginString.data(using: String.Encoding.utf8)?.base64EncodedString()
        
        guard let base64LoginString = base64LoginString else{
            return
        }
        let header:HTTPHeaders = ["Authorization":"Basic \(base64LoginString)","Content-Type":"application/json;charset=utf-8"]
        let paramsDic = ["appId":keyCenter.AppId,"deviceNo":keyCenter.deviceId,"userId":"F6F0CF370FD68850C10AF3F8A2700563"]
        let url = "https://api-test.sd-rtn.com/" + api.connectDevice //"https://api-test.sd-rtn.com/iot/cn"
        
//        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default, headers: header) .validate().responseString() { reData in
//
//            guard  reData != nil else{
//                return
//            }
//
//
//            print("123456")
//
//        }

        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:ConnectDeviceNode.Rsp.self){(dataRsp:AFDataResponse<ConnectDeviceNode.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd resetPassword fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret)
            case .failure(let error):
                log.e("3rd resetPassword \(url) , detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
            }
        }
    }
    
}

class Utils{
    class private func loadAlertById(_ alertImageId:String,_ rsp:@escaping(Int,String,UIImage?)->Void){
//        AgoraIotLink.iotsdk.alarmMgr.queryAlarmImage(alertImageId: alertImageId) { ec, msg, url in
//            if(ec != ErrCode.XOK || url == nil){
//                rsp(ec,msg,nil)
//                return
//            }
//            let fullurl = URL(string: url!)
//            guard let fullurl = fullurl else{
//                log.e("3rd loadImage url:\(url!) error:\(msg) for \(alertImageId)")
//                rsp(ec,msg,nil)
//                return
//            }
//
//            ImageDownloader.default.downloadImage(with: fullurl, options: nil) { result in
//                switch(result){
//                case .success(let data):
//                    ImageCache.default.store(data.image, forKey: String(alertImageId))
//                    rsp(ErrCode.XOK,"cache image:\(alertImageId)",data.image)
//                case .failure(let err):
//                    log.e("3rd ImageDownloader failed(\(err)):\(msg) for \(alertImageId) url:\(url!)")
//                    rsp(ErrCode.XERR_API_RET_FAIL,"download image fail: \(alertImageId)",nil)
//                }
//            }
//        }
    }

    class func loadAlertImage(_ alertImageId:String,_ rsp:@escaping(Int,String,UIImage?)->Void){
        ImageCache.default.retrieveImage(forKey: alertImageId) { result in
            switch(result){
            case .success(let data):
                if(data.image != nil){
                    rsp(ErrCode.XOK,"load image from cache",data.image)
                }
                else{
                    log.v("3rd retrieveImage is nil,try download image:\(alertImageId)")
                    self.loadAlertById(alertImageId, rsp)
                }
            case .failure(let err):
                log.e("3rd retrieveImage fail,try load image:\(err)")
                //log.e("al loadImage failed(\(err)):\(msg) for \(alertMessageId) url:\(String(describing: url))")
                self.loadAlertById(alertImageId, rsp)
            }
        }
    }
    
    class func loadAlertVideoUrl(_ deviceId:String,_ tenantId:String, _ beginTime:UInt64,_ rsp:@escaping(Int,String,AlarmVideoInfo?)->Void){
        //rsp(ErrCode.XOK,"","http://aios-personalized-wuw.oss-cn-beijing.aliyuncs.com/conn-1.m3u8")
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
    }
}
