//
//  LoginMainVM.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/19.
//

import UIKit
import AgoraIotLink

//class Config{
//    public static let DEBUG = true
//    public static let productKey = "EJ5IJK4m7Fl4EJI"
//}

class LoginMainVM: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var password:String = ""

    func register(_ acc: String, _ pwd:String,_ code:String,email:String?,phone:String?,_ cb:@escaping (Bool,String)->Void){
        log.i("demo app register(\(acc.replacePhone()),********,\(code)")
        if(sdk == nil){
            cb(false,"sdk 未初始化")
        }
        let result = {
            (ec:Int,msg:String)->Void in
            var hint = ErrCode.XOK == ec ? "注册成功" : "注册失败"
            hint = hint + ":" + msg
            cb(ErrCode.XOK == ec ? true : false , hint)
        }
        //sdk?.accountMgr.register(account: acc, password: pwd,code:code,email:email,phone: phone, result: result)
        ThirdAccountManager.reqRegisterByPhone(acc, pwd, code,result)
    }
    
    func register2(_ acc: String, _ pwd:String,_ cb:@escaping (Bool,String)->Void){
        log.i("demo app register(\(acc.replacePhone()),********,\(pwd)")
        let result = {
            (ec:Int,msg:String)->Void in
            var hint = ErrCode.XOK == ec ? "注册成功" : "注册失败"
            hint = hint + ":" + msg
            self.password = pwd
            cb(ErrCode.XOK == ec ? true : false , hint)
        }
        ThirdAccountManager.reqRegister(acc, pwd, result)
    }

    func resetPassword(_ acc: String, _ pwd:String, _ code:String, _ cb:@escaping (Bool,String)->Void){
        log.i("demo app resetPassword(\(acc.replacePhone()),********,\(code)")
        if(sdk == nil){
            cb(false,"sdk 未初始化")
        }
        let result = {
            (ec:Int,msg:String)->Void in
            var hint = ErrCode.XOK == ec ? "重置密码成功" : "重置密码失败"
            hint = hint + ":" + msg
            cb(ErrCode.XOK == ec ? true : false , hint)
        }
        
        ThirdAccountManager.resetPassword(acc, pwd, code,result)
        
        //sdk?.accountMgr.resetPassword(account: acc, password: pwd,code:code,result: result)
    }
//note:removed
//    func changePassword(_ oldPwd:String,_ newPwd:String,_ cb:@escaping(Bool,String)->Void){
//        log.i("demo app change password")
//        sdk?.accountMgr.changePassword(account: "", oldPassword: oldPwd, newPassword: newPwd, result: {ec,msg in
//            cb(ec == ErrCode.XOK ? true : false , msg)
//        })
//    }
    
//note:removed
//    func login(_ acc:String,_ pwd:String,_ cb:@escaping (Bool,String)->Void){
//        log.i("demo app login(\(acc))")
//        if(sdk == nil){
//            cb(false,"sdk 未初始化")
//        }
//        let result = {
//            (ec:Int,msg:String)->Void in
//            var hint = ErrCode.XOK == ec ? "登录成功" : "登录失败"
//            if(AgoraIotConfig.DEBUG){
//                hint = hint + ":" + msg
//            }
//            cb(ErrCode.XOK == ec ? true : false , msg)
//        }
//        sdk?.accountMgr.login(account: acc, password: pwd,result: result)
//    }
    
    func login2(_ acc:String,_ pwd:String,_ cb:@escaping (Bool,String)->Void){
//        log.i("demo app login(\(acc.replacePhone()))")
//        if(sdk == nil){
//            cb(false,"sdk 未初始化")
//        }
//        
//        ThirdAccountManager.reqLogin(acc, pwd) { ec, msg, param in
//            if(ec != ErrCode.XOK){
//                cb(false,"第三方接口登录失败")
//                return
//            }
//            guard let param = param else {
//                cb(false,"第三方接口登录返回空")
//                return
//            }
//            let result = {
//                (ec:Int,msg:String)->Void in
//                var hint = ErrCode.XOK == ec ? "登录成功" : "登录失败"
//                hint = hint + ":" + msg
//                cb(ErrCode.XOK == ec ? true : false , msg)
//            }
//            self.sdk?.accountMgr.login(param:param,result: result)
//        }
    }

    func doGetCode(_ acc: String, type: String, _ cb:@escaping (Int,String)->Void){
//        sdk?.accountMgr.getCode(email: acc, type: type, result: { code, msg in
//            print("\(msg)")
//            cb(code,msg)
//        })
    }

    func doGetPhoneCode(_ phone:String, type: String, _ lang:String,_ cb:@escaping (Bool,String)->Void){
        log.i("demo app bindPhone(\(phone.replacePhone()))")
        if(sdk == nil){
            cb(false,"sdk 未初始化")
        }
        let result = {
            (ec:Int,msg:String)->Void in
            let msg = ErrCode.XOK == ec ? "请求成功" : msg
            cb(ErrCode.XOK == ec ? true : false , msg)
        }
        //sdk?.accountMgr.getSms(phone: phone, type: type,lang:"ZH_CN", result: result)
        ThirdAccountManager.reqGetVerifyCode(phoneNumber: phone) { ec, msg in
            cb(ErrCode.XOK == ec ? true : false , msg)
        }
    }
    
    func doGetResetPwdPhoneCode(_ phone:String, type: String, _ lang:String,_ cb:@escaping (Bool,String)->Void){
        log.i("demo app bindPhone(\(phone.replacePhone()))")
        if(sdk == nil){
            cb(false,"sdk 未初始化")
        }
        let result = {
            (ec:Int,msg:String)->Void in
            let msg = ErrCode.XOK == ec ? "请求成功" : msg
            cb(ErrCode.XOK == ec ? true : false , msg)
        }
        //sdk?.accountMgr.getSms(phone: phone, type: type,lang:"ZH_CN", result: result)
        ThirdAccountManager.reqGetResetPwdVerifyCode(phoneNumber: phone) { ec, msg in
            cb(ErrCode.XOK == ec ? true : false , msg)
        }
    }
    
//note:removed
//    func doUnregister(_ acc: String ,_ cb:@escaping(Bool,String)->Void){
//        sdk?.accountMgr.unregister(result: { ec, msg in
//            print("\(msg)")
//            cb(ec == ErrCode.XOK ? true : false, msg)
//        })
//    }
    
    func doUnregister2(_ acc: String ,_ cb:@escaping(Bool,String)->Void){
        let pwd = password
        ThirdAccountManager.reqUnRegister(acc, pwd, { ec, msg in
            print("\(msg)")
            cb(ec == ErrCode.XOK ? true : false, msg)
        })
    }
    
    //退出登陆
    func doLogOut(_ cb:@escaping (Bool,String)->Void){
//        log.i("demo app logout()")
//        if(sdk == nil){
//            cb(false,"sdk 未初始化")
//        }
//        sdk?.accountMgr.logoutAccount(true, result: {
//            ec,msg in
//            cb(ec == ErrCode.XOK ? true : false,msg)
//        })
    }
    
    
//    func logout(result:@escaping (Int,String)->Void){
//        app.rule.trans(FsmApp.Event.LOGOUT,
//                       {self.doLogout(result)},
//                       {result(ErrCode.XERR_BAD_STATE,"状态错误")})
//    }
    
}
