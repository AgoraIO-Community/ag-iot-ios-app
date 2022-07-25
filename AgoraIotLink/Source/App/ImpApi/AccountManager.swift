//
//  AccountManager.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

class AccountManager : IAccountMgr{
    
    func getUserId() -> String {
        let n = app.context.gran.session.pool_identifier.findLast("_")
        if(n == -1){
            return ""
        }
        let next = n + 1;
        let ret = app.context.gran.session.pool_identifier.substring(from: next)
        return ret
    }
    
    func doRegister(_ account: String, _ password: String,_ code:String,_ email:String?,_ phone:String?, _ result:@escaping (Int,String)->Void) {
        let cb = {(ec:Int,msg:String) in
            log.i("reqRegister \(account) result:\(ec),msg:\(msg)")
            result(ec,msg)
        }
        self.app.proxy.gw.reqRegister(account, password, code, email,phone, cb)
    }
    
    func resetPassword(account: String, password: String, code: String, result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            
            self.app.proxy.gw.reqResetPwd(account,password, code, {ec,msg in
                let filter = self.app.context.callbackFilter
                let ret = filter(ec,msg)
                result(ret.0,ret.1)
            })
        }
    }
    
    func unregister(result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let token = self.app.context.gran.session.granwin_token
            let account = self.app.context.account
            self.app.proxy.gw.reqUnRegister(token,account,{ec,msg in
                if(ec == ErrCode.XOK){
                    self.app.context.gran.session.reset()
                    self.logout(result: result)
                }
                else{
                    let filter = self.app.context.callbackFilter
                    let ret = filter(ec,msg)
                    result(ret.0,ret.1)
                }
            });
        }
    }
    
    private func doLoginGw(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void){
        let gwcb = {(ec:Int,msg:String,sess:GranWinSession?) in
            log.i("granwin reqLogin result:\(ec) \(msg)")
            if(ec == ErrCode.XOK){
                let gwsess = sess!
                self.app.context.gran.session = gwsess
                self.app.proxy.gw.reqSessInventCert(grawinToken: gwsess.granwin_token, {ec,msg,cert in
                    if(ec == ErrCode.XOK){
                        let succ = ec == ErrCode.XOK
                        self.app.context.account = account
                        if let cert = cert {
                            self.app.context.gran.session.cert = cert
                            self.rule.trans(succ ? .LOGIN_SUCC : .LOGIN_FAIL,
                                            {result(succ ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,msg)},
                                            {result(ErrCode.XERR_BAD_STATE,"状态不正确")})
                        }
                        else{
                            log.e("granwin reqSessCert cert is nil:\(msg)(\(ec))")
                            self.rule.trans(.LOGIN_FAIL)
                            self.app.context.gran.session.reset()
                        }
                        
                    }
                    else{
                        log.e("granwin reqSessCert result error:\(msg)(\(ec))")
                        self.rule.trans(.LOGIN_FAIL)
                        self.app.context.gran.session.reset()
                    }
                })
            }
            else{
                log.e("granwin reqLogin result error:\(msg)(\(ec))")
                self.rule.trans(.LOGIN_FAIL)
                self.app.context.gran.session.reset()
                result(ec,msg)
            }
        }
        
        self.app.proxy.gw.reqLogin(account, password, gwcb)
    }
    
    private func doRegisterAl(_ account:String,_ result:@escaping(Int,String)->Void){
        self.app.proxy.al.reqRegister(account, result)
    }
    
    private func doGetTokenAl(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void){
        doRegisterAl(account, {ec,msg in
            if(ec != ErrCode.XOK){
                result(ec,msg)
                return
            }
            let cb = {(ec:Int,msg:String) in
                result(ec,msg)
            }
            self.app.context.aglab.session.userName = account
            let sess = self.app.context.aglab.session
            self.app.proxy.al.reqGetToken(sess.userName, sess.password, sess.scope, sess.clientId, sess.secretKey,{ec,msg,token in
                if(token != nil){
                    self.app.context.aglab.session.token = token!
                    self.app.context.aglab.session.token.acessToken = "Bearer " + token!.acessToken
                }
                cb(ec,msg)
            })
        })
    }
    
    func doLogin(_ account: String, _ password: String,_ result:@escaping (Int,String)->Void) {
        if(app.config.supportAgoraAuth){
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
                        result(ec,msg)
                    })
                }
            })
        }
        else{
            app.context.aglab.session.token.acessToken = "Basic YWdvcmFpb3RhcGFhczphc2JoZTdjeDJuYTMwYQ=="
            doLoginGw(account, password, result)
        }
    }
    
    var onLogoutResult:()->Void = {}
    func doLogout(_ result:@escaping (Int,String)->Void){
        let cbal = {(ec:Int,msg:String) in
            if(ec != ErrCode.XOK){
                log.w("agoralab logout exception:\(ec):\(msg)")
            }
            self.app.context.aglab.session.reset()
            self.rule.trigger.logout_watcher = {result(ErrCode.XOK,"")}
            self.rule.trans(FsmApp.Event.LOGOUT)
        }
        
        let cbHttp = {(ec:Int,msg:String) in
            self.app.context.gran.session.reset()
            if(ec != ErrCode.XOK){
                log.w("granwin.logout exception:\(ec) msg: \(msg)")
            }
            self.app.proxy.al.reqLogout(self.app.context.gran.session.account, cbal)
        }
        app.proxy.gw.reqLogout(app.context.gran.session.account,cbHttp);
    }
    
    func doGetCode(_ email: String,_ type : String,_ result:@escaping (Int,String)->Void){
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
    
    func doGetSms(_ phone: String,_ type : String,_ lang:String,_ result:@escaping (Int,String)->Void){
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
            self.doRegister(account, password, code,email,phone,{ec,msg in
                let filter = self.app.context.callbackFilter
                let ret = filter(ec,msg)
                result(ret.0,ret.1)
            })
        }
    }
    
    func getSms(phone: String, type: String, lang: String, result: @escaping (Int, String) -> Void) {
        var fullPhone = phone
        if(lang == "ZH_CN"){
            //caution:还是判断带上吧，广云的这个接口不带+86也能会收到短信消息，但就是注册会报错
            if(!phone.starts(with: "+86")){
                fullPhone = "+86"+phone;
            }
        }
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            var dotype = type
            if(type == "REGISTER"){
                dotype = "REGISTER_SMS"
            }
            else if(type == "PWD_RESET"){
                dotype = "PWD_RESET_SMS"
            }
            if(dotype == "REGISTER_SMS"){
                self.doGetSms(fullPhone,dotype,lang,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
            }
            else if(dotype == "PWD_RESET_SMS"){
                self.doGetSms(fullPhone,dotype,lang,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
            }
            else{
                log.e("unknown type \(type) for getCode")
                let ret = filter(ErrCode.XERR_INVALID_PARAM,"参数错误")
                result(ret.0,ret.1)
            }
        }
    }
    
    func getCode(email: String, type: String, result:@escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            if(type == "REGISTER"){
                self.doGetCode(email,type,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
            }
            else if(type == "PWD_RESET"){
                self.doGetCode(email,type,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
            }
            else{
                log.e("unknown type \(type) for getCode")
                let ret = filter(ErrCode.XERR_INVALID_PARAM,"参数错误")
                result(ret.0,ret.1)
            }
        }
    }
    
    func updateHeadIcon(image: UIImage,result:@escaping(Int,String,String?)->Void) {
        let agToken = app.context.aglab.session.token.acessToken
        let traceId = app.context.call.session.traceId
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            self.app.proxy.al.reqUploadIcon(agToken, image, traceId, {ec,msg,url in let ret = filter(ec,msg);result(ret.0,ret.1,url)})
        }
    }
    
    func login(account: String, password: String,result:@escaping (Int,String)->Void){
        let filter = self.app.context.callbackFilter
        app.rule.trans(FsmApp.Event.LOGIN,
                       {self.doLogin(account, password,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})},
                       {let ret = filter(ErrCode.XERR_BAD_STATE,"状态错误");result(ret.0,ret.1)})
    }
    
    func logout(result:@escaping (Int,String)->Void){
        let filter = self.app.context.callbackFilter
        app.rule.trans(FsmApp.Event.LOGOUT,
                       {self.doLogout({ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})},
                       {let ret = filter(ErrCode.XERR_BAD_STATE,"状态错误");result(ret.0,ret.1)})
    }
    
    private func doChangePassword(account:String,oldPwd:String,newPwd:String,result:@escaping(Int,String)->Void){
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        app.proxy.gw.reqChangePwd(token, account,oldPwd,newPwd,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
    }
    
    func changePassword(account: String, oldPassword: String, newPassword: String,result:@escaping (Int,String)->Void){
        let filter = self.app.context.callbackFilter
        self.doChangePassword(account: account, oldPwd: oldPassword, newPwd: newPassword, result: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
    }
    func updateAccountInfo(info: AccountInfo, result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gran.session.granwin_token
            let filter = self.app.context.callbackFilter
            self.app.proxy.gw.reqUpdateAccountInfo(token,info,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    func getAccountInfo(result: @escaping (Int, String, AccountInfo?) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gran.session.granwin_token
            let account = self.app.context.gran.session.account
            let filter = self.app.context.callbackFilter
            self.app.proxy.gw.reqAccountInfo(token,account,{ec,msg,info in let ret = filter(ec,msg);result(ret.0,ret.1,info)})
        }
    }
    
    private var app:Application
    private var rule:RuleManager
    
    init(app:Application){
        self.app = app
        self.rule = app.rule
    }
}


