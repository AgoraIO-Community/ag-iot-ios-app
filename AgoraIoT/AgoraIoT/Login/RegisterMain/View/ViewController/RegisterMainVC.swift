//
//  RegisterMainVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
//

import UIKit
import IQKeyboardManagerSwift

class RegisterMainVC: LoginBaseVC {

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //去除国家选择需求注释
//        if let countryName = TDUserInforManager.shared.curCountryModel?.countryName {
//            registerView.selectCountry.textField.text = countryName
//        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setUpViews()
    }
    
    func setUpViews(){
        
        view.addSubview(registerView)
        registerView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
    }
    
    lazy var registerView : RegisterView = {
        
        let view = RegisterView()
        view.delegate = self
        return view
        
    }()
    
    deinit {
        print("注册页面销毁了")
    }


}

extension RegisterMainVC : RegisterViewDelegate{
    
    //选择国家
    func countryBtnClick() {

        //去除国家选择需求注释
//        let  tempVC = CountrySelectVC()
//        tempVC.countryArray = [CountryModel]()
//        tempVC.countryVCBlock = { [weak self] (code,countryName) in
//            self?.registerView.selectCountry.textField.text = countryName
//        }
//        self.navigationController?.pushViewController(tempVC, animated: true)
        
    }
    
    func registerBtnEvent(acc: String) {
        
        //去除国家选择需求注释
//        if TDUserInforManager.shared.currentCountryCode == "" {
//            AGToolHUD.showInfo(info: "请选择国家/地区")
//            return
//        }
        
        let verficationAccount = verficationAccount(acc)
        guard verficationAccount.isEmpty == false else {
            print("账号为空")
            registerView.showTipsMessage("账号为空")
            return
        }
        
        if verficationAccount.isEmail == true {
            
            AGToolHUD.showInfo(info: "请使用手机号注册")
            registerView.showTipsMessage("请使用手机号注册")
            return
            
            //去除国家选择需求注释
//            if TDUserInforManager.shared.currentCountryCode == "86" {
//                AGToolHUD.showInfo(info: "请使用手机号注册")
//                registerView.showTipsMessage("请使用手机号注册")
//                return
//            }
            
            TDUserInforManager.shared.userType = .email
            sendEmailCaptchaCode(acc,.registerEmailCode)
            
        }else if verficationAccount.isPhone == true {
            
            //去除国家选择需求注释
//            if TDUserInforManager.shared.currentCountryCode == "1" {
//                AGToolHUD.showInfo(info: "请使用邮箱注册")
//                registerView.showTipsMessage("请使用邮箱注册")
//                return
//            }
            
            TDUserInforManager.shared.userType = .phone
            sendPhoneCaptchaCode(acc,.registerPhoneCode)
            
        }else{
            registerView.showTipsMessage("请输入正确的手机号")
//            registerView.showTipsMessage("请输入正确的邮箱或手机号")
        }
    }
}

extension RegisterMainVC{
    
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
    
}

extension RegisterMainVC{
    
//    func registerAction(acc:String, type:VerifyInputType){
//
//        switch type {
//        case .registerEmailCode:
//            sendEmailCaptchaCode(acc, type)
//            break
//        case .registerPhoneCode:
//            sendPhoneCaptchaCode(acc, type)
//            break
//        default:
//            break
//        }
//
//    }
    
}

extension RegisterMainVC{
    
    //发送邮箱验证码
    func sendEmailCaptchaCode(_ accountText:String, _ type:VerifyInputType){
        
        AGToolHUD.showNetWorkWait()
        loginVM.doGetCode(accountText, type: "REGISTER") { [weak self]code, msg in
            
            AGToolHUD.disMiss()
            if code == 0 {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: "验证码发送成功")
                //跳转
                DispatchCenter.DispatchType(type: .verifyCode(account: accountText, type: type), vc: self, style: .push)
//                //开始计时
//                self?.startTimer()
//                //重新发送按钮置为不可用
//                self?.verifyCodeView.configTimeOutLabelAction()
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        
    }
    
    //发送手机号验证码
    func sendPhoneCaptchaCode(_ accountText:String, _ type:VerifyInputType){
        
        AGToolHUD.showNetWorkWait()
        
        let phone = "+" + TDUserInforManager.shared.currentCountryCode + accountText
        loginVM.doGetPhoneCode(phone, type:"REGISTER_SMS","ZH_CN") { [weak self] success, msg in
           
            AGToolHUD.disMiss()
            if success == true {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: "验证码发送成功")
                //跳转
                DispatchCenter.DispatchType(type: .verifyCode(account: accountText, type: type), vc: self, style: .push)
//                //开始计时
//                self?.startTimer()
//                //重新发送按钮置为不可用
//                self?.verifyCodeView.configTimeOutLabelAction()
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        
    }
    
}
