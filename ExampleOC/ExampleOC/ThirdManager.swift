//
//  Service.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/10.
//

import Foundation
import Alamofire
import AgoraIotLink

class ThirdAccountManager{
    class api{
        #if false //dev 环境
            static let http_3rdParty = "https://third-user.sh.agoralab.co/third-party"
        #elseif true //prd 环境
            static let http_3rdParty = "https://third-user.sh3.agoralab.co/third-party"
        #endif
        static let authRegister = "/auth/register"
        static let authLogin = "/auth/login"
        static let authUnRegister = "/auth/removeAccount"
        static let getUid = "/auth/getUidByUsername"
        
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
        
        public class func handleLoginRsp(_ ret:Login.Rsp,_ rsp:@escaping (Int,String,LoginParam?)->Void){
            if(ret.code != 0){
                log.e("第三方 handleLoginRsp fail \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let data = ret.data else{
                log.e("第三方 handleLoginRsp data is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let lsToken = data.lsToken else {
                log.e("第三方 handleLoginRsp lsToken is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let gyToken = data.gyToken else {
                log.e("第三方 handleLoginRsp gyToken is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let pool = gyToken.pool else {
                log.e("第三方 handleLoginRsp pool is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            guard let proof = gyToken.proof else {
                log.e("第三方 handleLoginRsp proof is nil \(ret.msg)(\(ret.code))")
                return rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,nil)
            }
            
            var param = LoginParam()
            
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
    }
        
    class func reqRegister(_ userName:String,_ password:String,_ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":userName,"password":password]
        let url = api.http_3rdParty + api.authRegister

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("第三方 reqRegister fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("第三方 reqRegister \(url) fail for \(userName), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
            }
        }
    }
    
    class func reqLogin(_ username:String,_ password:String,rsp:@escaping(Int,String,LoginParam?)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":username,"password":password]
        let url = api.http_3rdParty + api.authLogin

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Login.Rsp.self){(dataRsp:AFDataResponse<api.Login.Rsp>) in
                switch dataRsp.result{
                case .success(let ret):
                    api.handleLoginRsp(ret,rsp)
                case .failure(let error):
                    log.e("第三方 reqLogin \(url) fail for \(username), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                }
            }
    }
    
    class func reqLogout(_ rsp:@escaping(Int,String)->Void){
        rsp(ErrCode.XOK,"第三方 退出成功")
    }
    
    class func reqUnRegister(_ account: String,_ password:String,_ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":account,"password":password]
        let url = api.http_3rdParty + api.authUnRegister

        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:api.Rsp.self){(dataRsp:AFDataResponse<api.Rsp>) in
            switch dataRsp.result{
            case .success(let ret):
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("第三方 reqUnRegister \(url) fail for \(account), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
            switch dataRsp.result{
            case .success(let ret):
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret.data)
            case .failure(let error):
                log.e("第三方 reqUidByAccount \(url) fail for \(account), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
            }
        }
    }
}
