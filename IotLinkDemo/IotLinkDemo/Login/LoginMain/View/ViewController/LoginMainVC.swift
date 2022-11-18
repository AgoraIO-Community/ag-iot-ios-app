//
//  LoginMainVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/19.
//

import UIKit
import IQKeyboardManagerSwift

class LoginMainVC: LoginBaseVC {

    fileprivate lazy var loginVM = LoginMainVM()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去除国家选择需求注释
//        if let countryName = TDUserInforManager.shared.curCountryModel?.countryName {
//            loginV.selectCountry.textField.text = countryName
//        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setUpViews()
        
    }
    
    func setUpViews(){
        
        view.addSubview(loginV)
        loginV.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
    }
    
    lazy var loginV : LoginView = {
        
        let loginV = LoginView()
        loginV.delegate = self
        return loginV
        
    }()


}

extension LoginMainVC : LoginViewDelegate{
    
    //登录
    func loginBtnClick(acc: String, pwd: String) {
       
        //去除国家选择需求注释
//        if TDUserInforManager.shared.currentCountryCode == "" {
//            AGToolHUD.showInfo(info: "请选择国家/地区")
//            return
//        }
        
        let verficationAccount = verficationAccount(acc)
        guard verficationAccount.isEmpty == false else {
            debugPrint("账号为空")
            loginV.showTipsMessage("账号为空")
            return
        }
        
        //guard verficationPassword(pwd) == true else {
        guard !pwd.isEmpty else{
            debugPrint("密码为空")
            loginV.showTipsMessage("密码为空")
            return
        }
        
        loginAction(acc:acc,pwd:pwd)
        
//        if verficationAccount.isEmail == true {
//            TDUserInforManager.shared.userType = .email
//            loginAction(acc:acc,pwd:pwd)
//        }else if verficationAccount.isPhone == true {
//            TDUserInforManager.shared.userType = .phone
//            loginAction(acc:acc,pwd:pwd)
//        }else
        //{
        //    loginV.showTipsMessage("账号格式不正确")
         //   return
        //}
 
    }
        
    //忘记密码点击
//    func forgetPwdBtnClick() {
//        
//        DispatchCenter.DispatchType(type: .resetPassword, vc: self, style: .push)
//        
//    }
    
    //注册点击
    func registerBtnClick(acc: String, pwd: String) {
        //note: registers
        //gzh:手机注册
        let easyRegister = false
        if(!easyRegister){
            DispatchCenter.DispatchType(type: .register, vc: self, style: .push)
        }
        else{
            let verficationAccount = verficationAccount(acc)
            guard verficationAccount.isEmpty == false else {
                //debugPrint("账号为空")
                loginV.showTipsMessage("账号为空")
                return
            }
            
            guard verficationPassword(pwd) == true else {
                //debugPrint("密码为8至20位大小写字母及数字")
                loginV.showTipsMessage("密码为空")
                return
            }
            
//            guard verficationAccount.isPhone == true else {
//                //debugPrint("账号为空")
//                loginV.showTipsMessage("无效手机号")
//                return
//            }
            registerAction(acc:acc,pwd:pwd)
        }
        
        
//        if verficationAccount.isEmail == true {
//            TDUserInforManager.shared.userType = .email
//            registerAction(acc:acc,pwd:pwd)
//        }else if verficationAccount.isPhone == true {
//            TDUserInforManager.shared.userType = .phone
//            registerAction(acc:acc,pwd:pwd)
//        }else
        //{
        //    loginV.showTipsMessage("账号格式不正确")
            return
        //}
    }
    

    //选择国家
    func countryBtnClick() {
        
        //去除国家选择需求注释
//        let  tempVC = CountrySelectVC()
//        tempVC.countryArray = [CountryModel]()
//        tempVC.countryVCBlock = { [weak self] (code,countryName) in
//            self?.loginV.selectCountry.textField.text = countryName
//        }
//        self.navigationController?.pushViewController(tempVC, animated: true)
        
    }

}

extension LoginMainVC{
    
    //校验账号格式
    func verficationAccount(_ account:String?) -> (isEmpty:Bool, isEmail:Bool,isPhone:Bool) {
            
        guard let text = account, text.count != 0 else {
            return (true,false,false)
        }
        if VerifyManager.checkEmail(text: text) == true {
            return (false,true,false)
        }
        if text.checkPhone() == true {
            return (false,false,true)
        }
        return (false,false,false)
    }
    
    //校验密码格式
    func verficationPassword(_ password:String?) -> Bool{
        guard let text = password, text.count != 0 else {
            return false
        }
        
        return true
        
        //todo:
//        if VerifyManager.checkPassword(text: text) == true {
//            return true
//        }
//        return false
        
    }
    
}

extension LoginMainVC{
    
    //登录
    func loginAction(acc: String, pwd: String){
        loginV.hide()
        AGToolHUD.showNetWorkWait()
        //note: login2
        loginVM.login2(acc, pwd) { [weak self] success, msg in
            
            AGToolHUD.disMiss()
            if (success) {
                debugPrint("登录成功")
                TDUserInforManager.shared.saveKeyChainAccountInfor(acc: acc, pwd: pwd)
                TDUserInforManager.shared.isLogin = true
                //登录成功发通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cUserLoginSuccessNotify), object: nil)
                self?.dismiss(animated: true, completion: { })
            }else{
                debugPrint("登录失败")
                self?.loginV.showTipsMessage(msg)
            }

        }
        
    }
    
    func registerAction(acc:String,pwd:String){
        loginV.hide()
        AGToolHUD.showNetWorkWait()
        loginVM.register2(acc, pwd) { [weak self]succ, msg in
            AGToolHUD.disMiss()
            if (succ) {
                debugPrint("注册成功")
                TDUserInforManager.shared.saveKeyChainAccountInfor(acc: acc, pwd: pwd)
                TDUserInforManager.shared.isLogin = false
                //登录成功发通知
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: cUserLoginSuccessNotify), object: nil)
                //self?.dismiss(animated: true, completion: { })
                //self?.loginV.showTipsMessage(msg)
                //
                AGToolHUD.showInfo(info: msg)
                
            }else{
                debugPrint("注册失败")
                self?.loginV.showTipsMessage(msg)
            }
        }
    }
    
}
