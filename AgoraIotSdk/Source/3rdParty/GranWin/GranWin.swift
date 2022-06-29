//
//  GranWin.swift
//  demo
//
//  Created by ADMIN on 2022/2/9.
//

import Foundation
import Alamofire

class GranWin{
    var http:String
    init(http:String){
        self.http = http
    }
    public func reqLogin(_ account: String, _ password: String,_ rsp: @escaping (Int,String,GranWinSession?)->Void){
        let params:Dictionary = ["account":account,"password":password]
        let url = http + api.Login
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of: Login.Rsp.self) { (dataRsp : AFDataResponse<Login.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspLogin(value, {ec,msg,sess in
                        DispatchQueue.main.async {
                            rsp(ec,msg,sess)
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw login \(url) fail for \(account), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
        }
//                    .responseString(completionHandler: {(response) in
//                    switch response.result{
//                    case .success(let value):
//                        log.e(value)
//                        _ = JSON(value)
//                        //cb(ErrCode.XERR_ALARM_NOT_FOUND,value,nil)
//                    case .failure(let error):
//                        log.e("http request detail: \(error) ")
//                        //cb(ErrCode.XERR_ACCOUNT_REGISTER,"")
//                    }
//                   })
    }
    public func reqSessInventCert(grawinToken:String,_ rsp:@escaping(Int,String,GranWinSession.Cert?)->Void){
        let headers : HTTPHeaders = ["token":grawinToken]
        let url = http + api.CerGet
        AF.request(url,method: .post,headers: headers)
            .validate()
            .responseDecodable(of: CertGet.Rsp.self) { (dataRsp : AFDataResponse<CertGet.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    self.handleRspCert(value, {ec,msg,cert in
                        DispatchQueue.main.async {
                            if(value.code == GranWin.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,nil)
                            }
                            else{
                                rsp(ec,msg,cert)
                            }
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqSessInventCert \(url) fail detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
        }
    }
    public func reqVerifyCodeByPhone(_ phone:String,_ type:String,_ lang:String,_ rsp:@escaping (Int,String)->Void){
        let params:Dictionary = ["phone":phone,"type":type,"lang":lang,"merchantId":GranWin.arg.merchantId]
        let url = http + api.GetSms
        log.i("gw reqVerifyCodeByPhone:\(phone) type:\(type)")
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of:Rsp.self){(dataRsp:AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw reqVerifyCodeByPhone \(url) fail for \(phone), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw reqVerifyCodeByPhone: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                                if(10001 == value.code){
                                    ec = ErrCode.XERR_ACCOUNT_ALREADY_EXIST
                                }
                                else{
                                    ec = ErrCode.XERR_ACCOUNT_GETCODE
                                }
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw request \(url) fail for \(phone), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,"访问网络失败")
                    }
                }
            }
    }
    
    public func reqVerifyCodeByEmail(_ email:String,_ type:String,_ rsp:@escaping (Int,String)->Void){
        let params:Dictionary = ["email":email,"type":type,"merchantId":GranWin.arg.merchantId]
        let url = http + api.GetCode
        log.i("gw reqVerifyCodeByEmail:\(email) type:\(type)")
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseDecodable(of:Rsp.self){(dataRsp:AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw reqVerifyCodeByEmail \(url) fail for \(email), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw reqVerifyCodeByEmail: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw reqVerifyCodeByEmail failed:\(value.tip)(\(value.code))")
                                if(10001 == value.code){
                                    ec = ErrCode.XERR_ACCOUNT_ALREADY_EXIST
                                }
                                else{
                                    ec = ErrCode.XERR_ACCOUNT_GETCODE
                                }
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw request \(url) fail for \(email), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,"访问网络失败")
                    }
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
                    self.handleRspDevList(value, {ec,msg,list in
                        DispatchQueue.main.async {
                            if(value.code == GranWin.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,list)
                            }
                            else{
                                rsp(ec,msg,list)
                            }
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqAllDevice \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",[])
                    }
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
                    if(value.code != 0){
                        log.e("gw reqChangePwd \(url) fail for \(account), detail: \(value.tip)(\(value.code)) ")
                    }
                    else{
                        log.i("gw reqChangePwd: \(value.tip)(\(value.code))")
                    }
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_CHGPSWD,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqChangePwd \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
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
                    if(value.code != 0){
                        log.e("gw reqResetPwd \(url) fail for \(account), detail: \(value.tip)(\(value.code)) ")
                    }
                    else{
                        log.i("gw reqResetPwd: \(value.tip)(\(value.code))")
                    }
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_CHGPSWD,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqResetPwd \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
            }
    }
    
    public func reqUnRegister(_ token:String,_ account:String,_ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let url = http + api.UserCancel
        AF.request(url,method: .post,headers:header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    if(value.code != 0){
                        log.e("gw reqUnRegister \(url) fail for \(account), detail: \(value.tip)(\(value.code)) ")
                    }
                    else{
                        log.i("gw reqUnRegister: \(value.tip)(\(value.code))")
                    }
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_UNREGISTER,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqUnRegister \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
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
                    if(value.code != 0){
                        log.e("gw reqUpdateAccountInfo \(url) fail, detail: \(value.tip)(\(value.code)) ")
                    }
                    else{
                        log.i("gw reqUpdateAccountInfo: \(value.tip)(\(value.code))")
                    }
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_INVALID_PARAM,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqUpdateAccountInfo \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
            }
    }
    
    public func reqAccountInfo(_ token:String,_ account:String,_ rsp: @escaping (Int,String,UserInfo?)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let url = http + api.UserInfo
        AF.request(url,method: .post,headers:header)
            .validate()
            .responseDecodable(of:UserInfoGet.Rsp.self) { (dataRsp : AFDataResponse<UserInfoGet.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    var userInfo:UserInfo? = nil
                    if(value.code != 0){
                        log.e("gw reqAccountInfo \(url) fail for \(account), detail: \(value.tip)(\(value.code)) ")
                    }
                    else{
                        log.i("gw reqAccountInfo: \(value.tip)(\(value.code))")
                        if(value.info == nil){
                            log.e("gw reqAccountInfo value.info is nil")
                        }
                        else{
                            let info = value.info!
                            userInfo = UserInfo(name: info.name, avatar: info.avatar, sex: info.sex ?? 0, age: info.age ?? 0, birthday: info.birthday, height: info.height, weight: info.weight, countryId: info.countryId, country: info.country, provinceId: info.provinceId, province: info.province, cityId: info.cityId, city: info.city, areaId: info.areaId, area: info.area, address: info.address, background: info.background, email: info.email, phone: info.phone)
                        }
                    }
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,userInfo)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw reqAccountInfo failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_INVALID_PARAM,value.tip,userInfo)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqAccountInfo \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
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
                    if(value.code != 0){
                        log.e("gw reqBindDevice \(url) fail for \(mac), detail: \(value.tip)(\(value.code)) ")
                    }
                    else{
                        log.i("gw reqBindDevice: \(value.tip)(\(value.code))")
                    }
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_DEVMGR_ADD,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqBindDevice \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
            }
    }
    public func reqProductList(_ token : String,_ filter:String,_ rsp:@escaping(Int,String,[ProductInfo])->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = filter != "" ? ["blurry":filter] : [:]
        let url = http + api.ProductList
        log.i("gw reqProductList \(params)")
        AF.request(url,method: .post, parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of:ProductList.Rsp.self) { (dataRsp : AFDataResponse<ProductList.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    log.i("gw reqProductList \(value.tip)(\(value.code))")
                    self.handleRspProductList(value, { ec, msg, list in
                        DispatchQueue.main.async {
                            if(value.code == GranWin.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,list)
                            }
                            else{
                                rsp(ec,msg,list)
                            }
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqProductList \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",[])
                    }
                }
            }
    }
    public func reqRenameDevice(_ token:String,_ deviceId:String,_ deviceNickName:String, _ rsp: @escaping (Int,String)->Void){
        let header:HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["deviceId":deviceId,"deviceNickName":deviceNickName]
        let url = http + api.RenameDevice
        log.i("gw renameDevice \(deviceId) with name:\(deviceNickName)")
        AF.request(url,method: .post, parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        //log.i("gw renameDevice \(value.tip)(\(value.code))")
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_DEVMGR_ADD,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqRenameDevice \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
            }
    }
    public func reqUnbindDevice(_ token:String,_ deviceId:String,_ rsp: @escaping (Int,String)->Void){
        //let params:Dictionary = ["token":token,"deviceId":String(deviceId)]
        let headers : HTTPHeaders = ["token":token,"Content-Type":"text/html; charset=utf-8"]
        let params:Dictionary<String,String> = ["deviceId":deviceId]
        let url = http + api.UnbindDevice
        log.i("gw unbind \(deviceId)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of:Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw unbind failed:\(value.tip)(\(value.code))")
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_DEVMGR_DEL,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw reqUnbindDevice \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
            }
    }
    public func reqRegister(_ account: String, _ password: String,_ code:String,_ email:String?,_ phone:String?,_ rsp: @escaping (Int,String)->Void){
        let clientId = arg.clientId
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        var params:Dictionary<String,String> = ["merchantId":clientId, "account":account,"password":password,"code":code]
        if(email == nil && phone == nil){
            log.e("gw email and phone can't both be nil")
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
        log.i("gw register with:\(params)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers:header)
            .validate()
            .responseDecodable(of:DevList.Rsp.self) { (dataRsp : AFDataResponse<DevList.Rsp>) in
            switch dataRsp.result{
            case .success(let value):
                DispatchQueue.main.async {
                    if(value.code == GranWin.tokenExpiredCode){
                        rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
                    }
                    else{
                        if(value.code != 0){
                            log.e("gw reqRegister failed:\(value.tip)(\(value.code))")
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_REGISTER,value.tip)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    log.e("gw reqRegister \(url) fail for \(account), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                }
            }
        }
    }
    
    func reqLogout(_ account: String,_ rsp: @escaping (Int,String)->Void){
        //log.w("gw no api for logout")
        rsp(ErrCode.XOK,"")
        return
        let params:Dictionary = ["account":account]
        let url = http + api.Logout
        AF.request(url,method: .post,parameters: params)
            .validate()
            .responseString(completionHandler: {(response) in
            switch response.result{
            case .success(let value):
                DispatchQueue.main.async {
                    _ = JSON(value)
                    rsp(ErrCode.XOK,"")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    log.e("gw account logout fail \(error)")
                    rsp(ErrCode.XOK,"")
                }
            }
        })
    }
}
