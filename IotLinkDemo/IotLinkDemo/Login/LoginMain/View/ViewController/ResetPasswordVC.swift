//
//  ResetPasswordVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/26.
//

import UIKit
import IQKeyboardManagerSwift

class ResetPasswordVC: LoginBaseVC {
    
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
//            resetPwdView.selectCountry.textField.text = countryName
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
        
        view.addSubview(resetPwdView)
        resetPwdView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
    }
    
    lazy var resetPwdView : ResetPasswordView = {
        
        let view = ResetPasswordView()
        view.delegate = self
        return view
        
    }()

}

extension ResetPasswordVC : ResetPasswordViewDelegate{
    
    func countryBtnClick() {
      
        //去除国家选择需求注释
//        let  tempVC = CountrySelectVC()
//        tempVC.countryArray = [CountryModel]()
//        tempVC.countryVCBlock = { [weak self] (code,countryName) in
//            self?.resetPwdView.selectCountry.textField.text = countryName
//        }
//        self.navigationController?.pushViewController(tempVC, animated: true)
        
    }
    
    func resetPwdBtnEvent(acc: String) {
        
        //去除国家选择需求注释
//        if TDUserInforManager.shared.currentCountryCode == "" {
//            AGToolHUD.showInfo(info: "请选择国家/地区")
//            return
//        }
        
        let verficationAccount = verficationAccount(acc)
        guard verficationAccount.isEmpty == false else {
            print("账号为空")
            resetPwdView.showTipsMessage("账号为空")
            return
        }
        
        if verficationAccount.isEmail == true {
            TDUserInforManager.shared.userType = .email
//            resetPasswordAction(acc:acc,type: .forgotEmailCode)
            sendResetPwdCaptchaCode(accountText:acc,type: .forgotEmailCode)
        }else if verficationAccount.isPhone == true {
            TDUserInforManager.shared.userType = .phone
//            resetPasswordAction(acc:acc,type: .forgotPhoneCode)
            sendResetPwdCaptchaCode(accountText:acc,type: .forgotPhoneCode)
        }else{
            resetPwdView.showTipsMessage("请输入正确的手机号")
//            resetPwdView.showTipsMessage("请输入正确的邮箱或手机号")
        }
    }
  
}

extension ResetPasswordVC{
    
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

extension ResetPasswordVC{
    
//    func resetPasswordAction(acc:String, type:VerifyInputType){
//
//        //跳转发送验证码
//        DispatchCenter.DispatchType(type: .verifyCode(account: acc, type: type), vc: self, style: .push)
//
//    }
    
    //重置密码发送手机号验证码
    func sendResetPwdCaptchaCode(accountText:String, type:VerifyInputType){
        
        AGToolHUD.showNetWorkWait()
        
//        let phone = "+" + TDUserInforManager.shared.currentCountryCode + accountText
        let phone = accountText //"+" + TDUserInforManager.shared.currentCountryCode + accountText
        loginVM.doGetResetPwdPhoneCode(phone, type:"PWD_RESET_SMS","ZH_CN") { [weak self] success, msg in
           
            AGToolHUD.disMiss()
            if success == true {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: msg)
                DispatchCenter.DispatchType(type: .verifyCode(account: accountText, type: type), vc: self, style: .push)
                
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        
    }
}
