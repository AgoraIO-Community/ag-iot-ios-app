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
    
    var isRegistering : Bool = false
    
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
        if isRegistering == false{
            isRegistering = true
            createUserNode(acc)
        }
    }
    
    //创建Node
    func createUserNode(_ account :String ){
        
        ThirdAccountManager.nodeCreate(account) { [weak self] success, msg,nodeId in
            AGToolHUD.disMiss()
            self?.isRegistering = false
            if success == 0 {
                debugPrint("注册成功")
                AGToolHUD.showInfo(info: "注册成功")
                self?.jumpRootVC()
            }else{
                AGToolHUD.showInfo(info: msg)
                self?.registerView.showTipsMessage("\(msg)")
            }
            print("\(msg)")
        }
        
    }
    
    //MARK: - 返回到登录首页
    func jumpRootVC() {
        guard let viewControllers = self.navigationController?.viewControllers else {
            debugPrint("jumpRootVC:navigationController is nil")
            return
        }
        debugPrint("jumpRootVC:success")
        for vc in viewControllers {
            if vc.isKind(of: LoginMainVC.self) {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
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
        
        let phone = accountText //"+" + TDUserInforManager.shared.currentCountryCode + accountText
        loginVM.doGetPhoneCode(phone, type:"REGISTER_SMS","ZH_CN") { [weak self] success, msg in
           
            AGToolHUD.disMiss()
            if success == true {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: msg)
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
