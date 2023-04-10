//
//  AccountManager.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

class AccountManager : IAccountMgr{
    private var app:Application
    private var rule:RuleManager
    
    init(app:Application){
        self.app = app
        self.rule = app.rule
    }
    
    private func asyncResult(_ ec:Int,_ msg:String,_ result:@escaping(Int,String)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1)
        }
    }
    
    private func asyncResultData<T>(_ ec:Int,_ msg:String,_ data:T?,_ result:@escaping(Int,String,T?)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data)
        }
    }
    
//    func register2(account: String, password: String, result: @escaping (Int, String) -> Void) {
//        DispatchQueue.main.async {
//            self.doRegister2(account, password,{ec,msg in
//                let filter = self.app.context.callbackFilter
//                let ret = filter(ec,msg)
//                result(ret.0,ret.1)
//            })
//        }
//    }
    
//    func login(account: String, password: String, result: @escaping (Int, String) -> Void) {
//        app.rule.trans(FsmApp.Event.LOGIN,
//                       {self.doLogin(account, password,{ec,msg in self.asyncResult(ec,msg,result)})},
//                       {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
//    }
    
    func login(param: LoginParam, result: @escaping (Int, String) -> Void) {
        app.rule.trans(FsmApp.Event.LOGIN,
                       {self.doLogin(param,{ec,msg in
            
                        self.asyncResult(ec,msg,result)
            
                        }//{self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
                       )}
                )
    }
    
    func getUserId() -> String {
        let n = app.context.gyiot.session.pool_identifier.findLast("_")
        if(n == -1){
            return ""
        }
        let next = n + 1;
        let ret = app.context.gyiot.session.pool_identifier.substring(from: next)
        return ret
    }
    
    func doRegister(_ account: String, _ password: String,_ code:String,_ email:String?,_ phone:String?, _ result:@escaping (Int,String)->Void) {
        self.app.proxy.gw.reqRegister(account, password, code, email,phone, result)
    }
    
//    func doRegister2(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void) {
//        let cb = {(ec:Int,msg:String) in
//            log.i("reqRegister \(account) result:\(ec),msg:\(msg)")
//            result(ec,msg)
//        }
//        self.app.proxy.al.reqRegister2(account, password,cb)
//    }
    
    func resetPassword(account: String, password: String, code: String, result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            self.app.proxy.gw.reqResetPwd(account,password, code, {ec,msg in self.asyncResult(ec,msg,result)})
        }
    }
    
    func unregister(result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqUnRegister(token,{ec,msg in
                if(ec == ErrCode.XOK){
                    self.app.context.gyiot.session.reset()
                    self.logout(result: result)
                }
                else{
                    self.asyncResult(ec,msg,result)
                }
            });
        }
    }
    
    private func doLoginGw(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void){
        let gwcb = {(ec:Int,msg:String,sess:IotLinkSession?) in
            log.i("iotlink reqLogin result:\(ec) \(msg)")
            if(ec == ErrCode.XOK){
                let gwsess = sess!
                self.app.context.gyiot.session = gwsess
                self.app.proxy.gw.reqSessInventCert(grawinToken: gwsess.iotlink_token, {ec,msg,cert in
                    if(ec == ErrCode.XOK){
                        let succ = ec == ErrCode.XOK
                        //self.app.context.account = account
                        if let cert = cert {
                            self.app.context.gyiot.session.cert = cert
                            self.rule.trans(succ ? .LOGIN_SUCC : .LOGIN_FAIL,
                                            {result(succ ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,msg)},
                                            {result(ErrCode.XERR_BAD_STATE,"state error")})
                        }
                        else{
                            log.e("iotlink reqSessCert cert is nil:\(msg)(\(ec))")
                            self.rule.trans(.LOGIN_FAIL)
                            self.app.context.gyiot.session.reset()
                        }
                    }
                    else{
                        log.e("iotlink reqSessCert result error:\(msg)(\(ec))")
                        self.rule.trans(.LOGIN_FAIL)
                        self.app.context.gyiot.session.reset()
                    }
                })
            }
            else{
                log.e("iotlink reqLogin result error:\(msg)(\(ec))")
                self.rule.trans(.LOGIN_FAIL)
                self.app.context.gyiot.session.reset()
                result(ec,msg)
            }
        }
        
        self.app.proxy.gw.reqLogin(account, password, gwcb)
    }
    
    private func doRegisterAl(_ account:String,_ result:@escaping(Int,String)->Void){
        self.app.proxy.al.reqRegister(account,result)
    }
    
//    private func doGetTokenAl(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void){
//        doRegisterAl(account, {ec,msg in
//            if(ec != ErrCode.XOK){
//                result(ec,msg)
//                return
//            }
//            let cb = {(ec:Int,msg:String) in
//                result(ec,msg)
//            }
//            //self.app.context.aglab.session.userName = account
//            let sess = self.app.context.aglab.session
//            self.app.proxy.al.reqGetToken(account, sess.password, sess.scope, sess.clientId, sess.secretKey,{ec,msg,token in
//                if(token != nil){
//                    self.app.context.aglab.session.token = token!
//                    self.app.context.aglab.session.token.accessToken = "Bearer " + token!.accessToken
//                }
//                cb(ec,msg)
//            })
//        })
//    }
#if false //old login version
   private func doLogin(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void) {
        doGetTokenAl(account, password, {ec,msg in
            if(ec != ErrCode.XOK){
                self.rule.trans(.LOGIN_FAIL)
                result(ec,msg)
            }
            else{
                self.doLoginGw(account, password, {ec,msg in
                    if(ec != ErrCode.XOK){
                        self.rule.trans(.LOGIN_FAIL)
                    }
                    else{
                        self.app.context.account = account
                    }
                    result(ec,msg)
                })
            }
        })
    }
#endif
//    private func doLogin(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void) {
//        self.app.proxy.al.reqLogin(account, password) { ec, msg, data in
//            if(ec != ErrCode.XOK){
//                self.rule.trans(.LOGIN_FAIL)
//                self.app.context.gyiot.session.reset()
//                result(ec,msg)
//                return
//            }
//            guard let data = data else{
//                log.e("doLogin ret data is nil")
//                self.rule.trans(.LOGIN_FAIL)
//                self.app.context.gyiot.session.reset()
//                result(ErrCode.XERR_INVALID_PARAM,msg)
//                return
//            }
//            //self.app.context.aglab.session.userName = account
//            self.app.context.aglab.session.token = data.agToken
//            self.app.context.aglab.session.token.accessToken = "Bearer " + data.agToken.accessToken
//
//            self.app.context.gyiot.session = data.gyToken
//            let pool_identifier = data.gyToken.pool_identifier
//            let first = pool_identifier.findFirst("_")
//            let last = pool_identifier.findLast("_")
//            let certId = pool_identifier.substring(to: first)
//            let rear = pool_identifier.substring(from: last + 1)
//            let thingName = certId + "-" + rear
//            //self.app.context.account = account
//            self.app.context.virtualNumber = thingName
//            self.app.context.gyiot.session.cert.thingName = thingName
//            self.rule.trans(ec == ErrCode.XOK ? .LOGIN_SUCC : .LOGIN_FAIL,
//                            {result(ec == ErrCode.XOK ? ErrCode.XOK : ec,msg)},
//                            {result(ErrCode.XERR_BAD_STATE,"state error")})
//        }
//    }
    
    private func doLogin(_ param:LoginParam,_ result:@escaping (Int,String)->Void) {
        let data = param
        //self.app.context.aglab.session.userName = data.account
        self.app.context.aglab.session = AgoraLabSession(
            tokenType: data.tokenType,
            accessToken: "Bearer " + data.accessToken,
            refreshToken: data.refreshToken,
            expireIn: data.expireIn,
            scope: data.scope)
        
        self.app.context.gyiot.session = IotLinkSession(
            granwin_token: data.grawin_token,
            expiration: data.expiration,
            endPoint: data.endPoint,
            region: data.region,
            account: data.account,
            
            proof_sessionToken: data.proof_sessionToken,
            proof_secretKey: data.proof_secretKey,
            proof_accessKeyId: data.proof_accessKeyId,
            proof_sessionExpiration: data.proof_sessionExpiration,
            
            pool_token: data.pool_token,
            pool_identityId: data.pool_identityId,
            pool_identityPoolId: data.pool_identityId,
            pool_identifier: data.pool_identifier)
        
        let pool_identifier = data.pool_identifier
        let first = pool_identifier.findFirst("_")
        let last = pool_identifier.findLast("_")
        let certId = pool_identifier.substring(to: first)
        let rear = pool_identifier.substring(from: last + 1)
        let thingName = certId + "-" + rear
        
        self.app.context.account = data.account
        self.app.context.virtualNumber = thingName
        self.app.context.gyiot.session.cert.thingName = thingName
        self.rule.trans(.LOGIN_SUCC,
                        {result(ErrCode.XOK,"succ")}
                        )//{result(ErrCode.XERR_BAD_STATE,"state error")}
        
        resetDevice()
        
    }
    
    func resetDevice(){
        let deviceId = self.app.context.gyiot.session.cert.thingName
        let appid = self.app.config.appId
        let agToken = app.context.aglab.session.accessToken
        self.app.proxy.al.resetDevice(deviceId, appid, agToken) { code, msg in
            log.i("---resetDevice--\(code):--\(msg)")
        }
        
    }
    
    func publicKeySet(publicKey:String, _ result:@escaping (Int,String)->Void){
        let uid =  self.app.context.gyiot.session.cert.thingName
        let agToken = app.context.aglab.session.accessToken
        let cb = { (ec:Int,msg:String) in
            if(ec != ErrCode.XOK){
                log.e("publicKeySet fail:\(ec):\(msg)")
            }
            result(ec,msg)
        }
        self.app.proxy.al.publicKeySet(uid,publicKey,agToken,cb)
    }
    
   private var onLogoutResult:()->Void = {}
   private func doLogout(_ result:@escaping (Int,String)->Void){
        let cbal = {(ec:Int,msg:String) in
            if(ec != ErrCode.XOK){
                log.w("agoralab logout exception:\(ec):\(msg)")
            }
            self.app.context.aglab.session.reset()
            self.app.context.call.session.reset()
            self.rule.trigger.logout_watcher = {result(ErrCode.XOK,"")}
            self.rule.trans(FsmApp.Event.LOGOUT)
        }
        
        let cbHttp = {(ec:Int,msg:String) in
            self.app.context.gyiot.session.reset()
            if(ec != ErrCode.XOK){
                log.w("iotlink.logout exception:\(ec) msg: \(msg)")
            }
            self.app.proxy.al.reqLogout(cbal)
        }
        app.proxy.gw.reqLogout(cbHttp);
    }
    
   private func doGetCode(_ email: String,_ type : String,_ result:@escaping (Int,String)->Void){
        let cb = {(ec:Int,msg:String) in
            log.i("doGetCode:\(ec) type:\(type)")
            result(ec,msg)
        }
        if(type == "REGISTER"){
            app.proxy.gw.reqVerifyCodeByEmail(email,type,cb)
        }
        else if(type == "PWD_RESET"){
            app.proxy.gw.reqVerifyCodeByEmail(email,type, cb)
        }
        else{
            log.e("unknown type \(type)")
        }
    }
    
   private func doGetSms(_ phone: String,_ type : String,_ lang:String,_ result:@escaping (Int,String)->Void){
        let cb = {(ec:Int,msg:String) in
            log.i("doGetCode:\(ec) type:\(type)")
            result(ec,msg)
        }
        if(type == "REGISTER_SMS"){
            app.proxy.gw.reqVerifyCodeByPhone(phone,type,lang,cb)
        }
        else if(type == "PWD_RESET_SMS"){
            app.proxy.gw.reqVerifyCodeByPhone(phone,type,lang, cb)
        }
        else{
            log.e("unknown type \(type)")
        }
    }

    func register(account: String, password: String,code:String,email:String?,phone:String?, result:@escaping (Int,String)->Void) {
        DispatchQueue.main.async {
            self.doRegister(account, password, code,email,phone,{ec,msg in self.asyncResult(ec,msg,result)})
        }
    }
    
    func getSms(phone: String, type: String, lang: String, result: @escaping (Int, String) -> Void) {
        var fullPhone = phone
        if(lang == "ZH_CN"){
            //caution:还是判断带上吧，这个接口不带+86也能会收到短信消息，但就是注册会报错
            if(!phone.starts(with: "+86")){
                fullPhone = "+86"+phone;
            }
        }
        DispatchQueue.main.async {
            var dotype = type
            if(type == "REGISTER"){
                dotype = "REGISTER_SMS"
            }
            else if(type == "PWD_RESET"){
                dotype = "PWD_RESET_SMS"
            }
            if(dotype == "REGISTER_SMS"){
                self.doGetSms(fullPhone,dotype,lang,{ec,msg in self.asyncResult(ec,msg,result)})
            }
            else if(dotype == "PWD_RESET_SMS"){
                self.doGetSms(fullPhone,dotype,lang,{ec,msg in self.asyncResult(ec,msg,result)})
            }
            else{
                log.e("unknown type \(type) for getCode")
                self.asyncResult(ErrCode.XERR_INVALID_PARAM,"param error",result)
            }
        }
    }
    
    func getCode(email: String, type: String, result:@escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            if(type == "REGISTER"){
                self.doGetCode(email,type,{ec,msg in self.asyncResult(ec,msg,result)})
            }
            else if(type == "PWD_RESET"){
                self.doGetCode(email,type,{ec,msg in self.asyncResult(ec,msg,result)})
            }
            else{
                log.e("unknown type \(type) for getCode")
                self.asyncResult(ErrCode.XERR_INVALID_PARAM,"param error",result)
            }
        }
    }
    
    func updateHeadIcon(image: UIImage,result:@escaping(Int,String,String?)->Void) {
        let agToken = app.context.aglab.session.accessToken
        let traceId = app.context.call.session.traceId
        DispatchQueue.main.async {
            self.app.proxy.al.reqUploadIcon(agToken, image, traceId, {ec,msg,url in self.asyncResultData(ec,msg,url,result)})
        }
    }
#if false //old login() version,will be removed later
    func login(account: String, password: String,result:@escaping (Int,String)->Void){
        app.rule.trans(FsmApp.Event.LOGIN,
                       {self.doLogin(account, password,{ec,msg in self.asyncResult(ec,msg,result)})},
                       {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
    }
#endif
    func logout(result:@escaping (Int,String)->Void){
        app.rule.trans(FsmApp.Event.LOGOUT,
                       {self.doLogout({ec,msg in self.asyncResult(ec,msg,result)})},
                       {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
    }
    
    private func doChangePassword(account:String,oldPwd:String,newPwd:String,result:@escaping(Int,String)->Void){
        let token = self.app.context.gyiot.session.iotlink_token
        app.proxy.gw.reqChangePwd(token, account,oldPwd,newPwd,{ec,msg in self.asyncResult(ec,msg,result)})
    }
    
    func changePassword(account: String, oldPassword: String, newPassword: String,result:@escaping (Int,String)->Void){
        self.doChangePassword(account: account, oldPwd: oldPassword, newPwd: newPassword, result: {ec,msg in self.asyncResult(ec,msg,result)})
    }
    
    func updateAccountInfo(info: AccountInfo, result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqUpdateAccountInfo(token,info,{ec,msg in self.asyncResult(ec,msg,result)})
        }
    }
    
    func getAccountInfo(result: @escaping (Int, String, AccountInfo?) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqAccountInfo(token,{ec,msg,info in self.asyncResultData(ec,msg,info,result)})
        }
    }
}


