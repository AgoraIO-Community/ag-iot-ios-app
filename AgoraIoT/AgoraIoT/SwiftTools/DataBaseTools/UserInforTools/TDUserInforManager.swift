//
//  TDUserInforManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit
import AgoraIotSdk


//登录成功的通知
let cUserLoginSuccessNotify = "cUserLoginSuccessNotify"

//退出登录的通知
let cUserLoginOutNotify = "cUserLoginOutNotify"

public enum UserAccountType: Int{
    
    ///默认
    case none = 0
    
    ///邮箱
    case email = 1
    
    ///手机号
    case phone = 2

}


class TDUserInforManager: NSObject {
    
    //当前用户选择国家码 86默认为中国
    var currentCountryCode:String = "86"
    var curCountryModel:CountryModel?
    
    ///用户类型
    var userType : UserAccountType = .none
    
    ///当前变声类型
    var curEffectId:AudioEffectId = .NORMAL
    
    ///用户是否登陆
    var isLogin : Bool = false
 
    fileprivate lazy var loginVM = LoginMainVM()

    
    static let shared: TDUserInforManager = {
        
        let dataBase:TDUserInforManager = TDUserInforManager()
        
        return dataBase
    }()
    
    fileprivate override init() {
        super.init()
    }
    
    
    //MARK: - 退出登录或者token过期调用
    func userSignOut() {
        
        let uDefault = getUserDefault()
        
        uDefault.setValue(nil, forKey: "accountNumber")
        
        uDefault.setValue(nil, forKey: "LoginType")
        
        uDefault.setValue(nil, forKey: "accountPwd")
        
        uDefault.synchronize()
        
        //退出登录,属性置为空
        curEffectId = .NORMAL
        
        isLogin = false
        
        //退出登录发通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cUserLoginOutNotify), object: nil)

    }
    
    /// 保存上次登录的账号与上次登录的账号的属性
    ///
    /// - Parameters:
    ///   - account: 上次登陆的账号
    ///   - type: 上次登录账号的属性 true:手机号验证码登录 false：账号密码登录
    func saveAccountNumberAndLoginType(account:String, type:Bool) {
        let uDefault = getUserDefault()
        uDefault.setValue(account, forKey: "accountNumber")
        uDefault.setValue(type, forKey: "LoginType")
        uDefault.synchronize()
    }
    
    /// 保存上次登录的账号对应的密码
    ///
    /// - Parameters:
    ///   - pwd: 上次登陆的账号对应的密码
    func saveAccountPassWord(pwd:String) {
        let uDefault = getUserDefault()
        uDefault.setValue(pwd, forKey: "accountPwd")
        uDefault.synchronize()
    }
    
    /// 保存上次登录账号协议是否阅读状态
    func saveUserProcolState(){
        
        let uDefault = getUserDefault()
        uDefault.setValue(true, forKey: "ProcolType")
        uDefault.synchronize()
        
    }
    
    //读取上次登录的账号
    func readAccountNumber() -> String{
        var accNum = ""
        if let num = getUserDefault().object(forKey: "accountNumber") as? String {
            accNum = num
        }
        return accNum
    }
    
    //读取上次登录的密码
    func readPasswordNumber() -> String{
        var pwdNum = ""
        if let num = getUserDefault().object(forKey: "accountPwd") as? String {
            pwdNum = num
        }
        return pwdNum
    }
    
    /// 读取上次登录账号的属性
    ///
    /// - Parameter type:邮箱登录还是手机号登录
    func readLoginType() -> Bool {
        var accNum = Bool(true)
        if let num = getUserDefault().object(forKey: "LoginType") as? Bool {
            accNum = num
        }
        return accNum
    }
    
    /// 读取上次登录账号协议是否阅读状态
    func readUserProcolState() -> Bool {
        var accNum = Bool(false)
        if let num = getUserDefault().object(forKey: "ProcolType") as? Bool {
            accNum = num
        }
        return accNum
    }
    
    
    //检查用户登陆状态
    func checkLoginState(){
        
        //检查隐私协议状态
        guard checkloginProtocolState() == true else { return }
        
        let account = readAccountNumber()
        let password = readPasswordNumber()
        if account.isEmpty == false {
            loginAction(account,password)
        }else{
            
            DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
            
//            loginAction(acc,pwd)
//            saveAccountNumberAndLoginType(account: acc, type: false)
//            saveAccountPassWord(pwd: pwd)
        }
        
    }
    
    //登录
    func loginAction(_ account : String, _ password : String){
        
        loginVM.login(account, password) { [weak self] success, msg in
            if (success) {
                debugPrint("登录成功")
                self?.isLogin = true
                //登录成功发通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cUserLoginSuccessNotify), object: nil)
            }else{
                debugPrint("登录失败")
            }
            
        }
    }
    
    
    fileprivate func getUserDefault() -> UserDefaults {
      
        return UserDefaults.standard
    }
    
    
    fileprivate func saveToUserDefault(value:Any,key:String) {
        
        let uDefault:UserDefaults = getUserDefault()
        
        uDefault.setValue(value, forKey: key)
        
        uDefault.synchronize()
    }
    
}

extension TDUserInforManager{
    
    func checkloginProtocolState() ->Bool{
        
        //协议如果是同意过就不再弹出
        if readUserProcolState() == false{
            showProtocolAlert()
            return false
        }
        return true
        
    }
    //登录注册协议
    func showProtocolAlert(){
        
        let proAlertVC = LoginProtocolAlertVC()
        proAlertVC.proType = .userProtocol
        proAlertVC.pageSource = .loginPage
        proAlertVC.loginProAlertVCBlock = { (type) in
            debugPrint("关闭弹框")
            DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
        }
        
        proAlertVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        proAlertVC.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(proAlertVC, animated: true, completion: nil)
        
    }
}



