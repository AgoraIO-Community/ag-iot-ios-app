//
//  demo
//
//  Created by ADMIN on 2022/2/9.
//

import Foundation
import Alamofire

class IotLink{
    var http:String
    init(http:String){
        self.http = http
    }
    public func reqLogin(_ account: String, _ password: String,_ rsp: @escaping (Int,String,IotLinkSession?)->Void){
        let params:Dictionary = ["account":account,"password":password]
        let url = http + api.Login
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of: Login.Rsp.self) { (dataRsp : AFDataResponse<Login.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspLogin(value, rsp)
                case .failure(let error):
                    log.e("iotlink login \(url) fail for \(account), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                }
        }
    }
    public func reqSessInventCert(grawinToken:String,_ rsp:@escaping(Int,String,IotLinkSession.Cert?)->Void){
        let headers : HTTPHeaders = ["token":grawinToken]
        let url = http + api.CerGet
        AF.request(url,method: .post,headers: headers)
            .validate()
            .responseDecodable(of: CertGet.Rsp.self) { (dataRsp : AFDataResponse<CertGet.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspCert(value, rsp)
                case .failure(let error):
                    log.e("iotlink reqSessInventCert \(url) fail detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                }
        }
    }
    public func reqVerifyCodeByPhone(_ phone:String,_ type:String,_ lang:String,_ rsp:@escaping (Int,String)->Void){
        let params:Dictionary = ["phone":phone,"type":type,"lang":lang,"merchantId":IotLink.arg.merchantId]
        let url = http + api.GetSms
        log.v("iotlink reqVerifyCodeByPhone:\(phone) type:\(type)")
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of:Rsp.self){(dataRsp:AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    var ec = ErrCode.XOK
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink reqVerifyCodeByPhone failed:\(value.tip)(\(value.code))")
                            if(10001 == value.code){
                                ec = ErrCode.XERR_ACCOUNT_ALREADY_EXIST
                            }
                            else{
                                ec = ErrCode.XERR_ACCOUNT_GETCODE
                            }
                        }
                        rsp(ec,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink request \(url) fail for \(phone), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,"访问网络失败")
                }
            }
    }
    
    public func reqVerifyCodeByEmail(_ email:String,_ type:String,_ rsp:@escaping (Int,String)->Void){
        let params:Dictionary = ["email":email,"type":type,"merchantId":IotLink.arg.merchantId]
        let url = http + api.GetCode
        log.v("iotlink reqVerifyCodeByEmail:\(email) type:\(type)")
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of:Rsp.self){(dataRsp:AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    var ec = ErrCode.XOK
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink reqVerifyCodeByEmail failed:\(value.tip)(\(value.code))")
                            if(10001 == value.code){
                                ec = ErrCode.XERR_ACCOUNT_ALREADY_EXIST
                            }
                            else{
                                ec = ErrCode.XERR_ACCOUNT_GETCODE
                            }
                        }
                        rsp(ec,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink request \(url) fail for \(email), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,"访问网络失败")
                }
            }
    }
    public func reqAllDevice(_ token:String, _ rsp: @escaping (Int,String,[IotDevice])->Void){
        let headers : HTTPHeaders = ["token":token]
        let url = http + api.DeviceList
        AF.request(url,method: .post,headers: headers)
            .validate()
            .responseDecodable(of:DevList.Rsp.self) { (dataRsp : AFDataResponse<DevList.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspDevList(value, rsp)
                case .failure(let error):
                    log.e("iotlink reqAllDevice \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",[])
                }
            }
        }
    public func reqChangePwd(_ token:String, _ account:String,_ oldPwd:String,_ newPwd:String,_ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary = ["oldPassword":oldPwd,"newPassword":newPwd]
        let url = http + api.PasswordUpdate
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink reqChangePwd failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_CHGPSWD,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqChangePwd \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    
    public func reqResetPwd(_ account:String,_ newPwd:String,_ code:String, _ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"text/html;charset=utf-8"]
        let params:Dictionary<String,String> = ["account":account,"newPassword":newPwd,"code":code]
        let url = http + api.PasswordReset
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink reqResetPwd failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_CHGPSWD,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqResetPwd \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    
    public func reqUnRegister(_ token:String,_ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let url = http + api.UserCancel
        AF.request(url,method: .post,headers:header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("gw reqUnRegister failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_UNREGISTER,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqUnRegister \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    
    public func reqUpdateAccountInfo(_ token:String,_ info:UserInfo,_ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let req = UserInfoUpdate.Req(info)
        let url = http + api.UserInfoUpdate
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default,headers:header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("gw reqUpdateAccountInfo failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_INVALID_PARAM,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqUpdateAccountInfo \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    
    public func reqAccountInfo(_ token:String,_ rsp: @escaping (Int,String,UserInfo?)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let url = http + api.UserInfo
        AF.request(url,method: .post,headers:header)
            .validate()
            .responseDecodable(of:UserInfoGet.Rsp.self) { (dataRsp : AFDataResponse<UserInfoGet.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspAccountInfo(value,rsp)
                case .failure(let error):
                    log.e("iotlink reqAccountInfo \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                }
            }
    }
    
    public func reqBindDevice(_ token:String,_ productKey:String,_ mac:String, _ rsp: @escaping (Int,String)->Void){
        let params:Dictionary = ["token":token,"productKey":productKey,"mac":mac]
        let url = http + api.BindDevice
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink reqBindDevice failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_DEVMGR_ADD,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqBindDevice \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    public func reqProductList(_ token : String,_ query:ProductQueryParam,_ rsp:@escaping(Int,String,[ProductInfo])->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        var params:Dictionary<String,String> = query.blurry != "" ? ["blurry":query.blurry] : [:]
        if(query.pageNo >= 0){
            params["pageNo"] = String(query.pageNo)
        }
        if(query.pageSize != 0){
            params["pageSize"] = String(query.pageSize)
        }
        if(query.productId != 0){
            params["productId"] = String(query.productId)
        }
        if(query.productTypeId != 0){
            params["productTypeId"] =  String(query.productTypeId)
        }
        let url = http + api.ProductList
        log.v("iotlink reqProductList \(params)")
        AF.request(url,method: .post, parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of:ProductList.Rsp.self) { (dataRsp : AFDataResponse<ProductList.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspProductList(value, rsp)
                case .failure(let error):
                    log.e("iotlink reqProductList \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",[])
                }
            }
    }
    public func reqRenameDevice(_ token:String,_ deviceId:String,_ deviceNickName:String, _ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["mac":deviceId,"deviceNickName":deviceNickName]
        let url = http + api.RenameDevice
        log.v("iotlink renameDevice \(deviceId) with name:\(deviceNickName)")
        AF.request(url,method: .post, parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink unbind failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_DEVMGR_ADD,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqRenameDevice \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    public func reqUnbindDevice(_ token:String,_ deviceId:String,_ rsp: @escaping (Int,String)->Void){
        //let params:Dictionary = ["token":token,"deviceId":String(deviceId)]
        let headers : HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["mac":deviceId]
        let url = http + api.UnbindDevice
        log.v("iotlink unbind \(deviceId)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink unbind failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_DEVMGR_DEL,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqUnbindDevice \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    
    public func reqProperty(_ token:String,_ deviceId:String, _ productNumber:String,_ rsp:@escaping(Int,String,[Property])->Void){
        let headers : HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = deviceId == "" ? ["productId":productNumber] : ["mac":deviceId]
        let url = http + api.PointList
        log.v("iotlink reqProperty \(productNumber)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of:PointList.Rsp.self) { (dataRsp : AFDataResponse<PointList.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspPointList(value, rsp)
                case .failure(let error):
                    log.e("iotlink reqProperty \(url) fail for \(deviceId),\(productNumber), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",[])
                }
            }
    }
    
    public func reqRegister(_ account: String, _ password: String,_ code:String,_ email:String?,_ phone:String?,_ rsp: @escaping (Int,String)->Void){
        let clientId = arg.clientId
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        var params:Dictionary<String,String> = ["merchantId":clientId, "account":account,"password":password,"code":code]
        if(email == nil && phone == nil){
            log.e("iotlink email and phone can't both be nil")
            rsp(ErrCode.XERR_INVALID_PARAM,"邮箱和电话不能同时为空")
            return
        }
        if(email != nil){
            params["email"] = email!
        }
        else if(phone != nil){
            params["mobilephone"] = phone!
        }
        let url = http + api.Register
        log.i("iotlink register with:\(params)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers:header)
            .validate()
            .responseDecodable(of:DevList.Rsp.self) { (dataRsp : AFDataResponse<DevList.Rsp>) in
            switch dataRsp.result{
            case .success(let value):
                if(value.code == IotLink.tokenInvalidCode){
                    rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                }
                else{
                    if(value.code != 0){
                        log.e("iotlink reqRegister failed:\(value.tip)(\(value.code))")
                    }
                    rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_REGISTER,value.tip)
                }
            case .failure(let error):
                log.e("iotlink reqRegister \(url) fail for \(account), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    func reqLogout(_ rsp: @escaping (Int,String)->Void){
        //log.w("gw no api for logout")
        rsp(ErrCode.XOK,"")
        return
        //let params:Dictionary = []
        let url = http + api.Logout
        AF.request(url,method: .post)
            .validate()
            .responseString(completionHandler: {(response) in
            switch response.result{
            case .success(let value):
                _ = JSON(value)
                rsp(ErrCode.XOK,"")
            case .failure(let error):
                log.e("iotlink account logout fail \(error)")
                rsp(ErrCode.XOK,"")
            }
        })
    }
    
    func reqOtaInfo(_ token:String,_ deviceId:String, _ rsp:@escaping(Int,String,FirmwareInfo?)->Void){
        let headers : HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["mac":deviceId]
        let url = http + api.OtaGetInfo
        log.v("iotlink reqOtaInfo \(deviceId) token：\(token)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of:OtaInfo.Rsp.self) { (dataRsp : AFDataResponse<OtaInfo.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    log.i("reqOtaInfo response \(value)")
                    self.handleRspOtaInfo(value, rsp)
                case .failure(let error):
                    log.e("iotlink reqOtaInfo \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                }
            }
    }
    
    func reqOtaStatus(_ token:String,_ upgradeId:String,_ rsp:@escaping(Int,String,FirmwareStatus?)->Void){
        let headers : HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["upgradeId":upgradeId]
        let url = http + api.OtaStatus
        
        log.v("iotlink reqOtaStatus token：\(token)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of:OtaStatus.Rsp.self) { (dataRsp : AFDataResponse<OtaStatus.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspOtaStatus(value, rsp)
                case .failure(let error):
                    log.e("iotlink reqOtaStatus \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                }
            }
    }
    
    func reqOtaUpdate(_ token:String,_ upgradeId:String,_ decide:Int,_ rsp:@escaping(Int,String)->Void){
        let headers : HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["upgradeId":upgradeId,"decide":String(decide)]
        let url = http + api.OtaUpdate
        log.v("iotlink reqOtaUpdate token：\(token)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code == IotLink.tokenInvalidCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("iotlink reqOtaUpdate failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_REGISTER,value.tip)
                    }
                case .failure(let error):
                    log.e("iotlink reqOtaUpdate \(url) fail, detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
}
