//
//  SetPasswordVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/26.
//

import UIKit
import IQKeyboardManagerSwift

public enum SetPasswordType: Int{
    
    ///默认
    case none = 0
    
    ///注册
    case registerAccount = 1
    
    ///重置密码
    case forgotPassword = 2

}

class SetPasswordVC: LoginBaseVC {
    
    ///验证类型
    var style:SetPasswordType = .none
    ///邮箱或手机号
    var accountText = ""
    ///验证码
    var captchaText = ""
    
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
        
        view.addSubview(setPasswordView)
        setPasswordView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
    }
    
    lazy var setPasswordView : SetPasswordView = {
        
        let view = SetPasswordView()
        view.delegate = self
        return view
        
    }()
    
}

extension SetPasswordVC : SetPasswordViewDelegate{
    
    func confrimBtnClick(pwd: String) {
        
        guard verficationPassword(pwd) == true else {
            print("密码为8至20位大小写字母及数字")
            setPasswordView.showTipsMessage("密码为8至20位大小写字母及数字")
            return
        }
        setPasswordAction(pwd: pwd)
    }
 
}

extension SetPasswordVC{
    
    //校验密码格式
    func verficationPassword(_ password:String?) -> Bool{
        guard let text = password, text.count != 0 else {
            return false
        }
        
        if VerifyManager.checkPassword(text: text) == true {
            return true
        }
        
        return false
    }
    
}

extension SetPasswordVC{
    
    //设置密码
    func setPasswordAction( pwd: String){
        
        //这里目前有注册和重置密码两种
        if style == .registerAccount {
            registerAccount(pwd)
        }else if style == .forgotPassword{
            resetPassword(pwd)
        }
        
    }
    
    //账号注册
    func registerAccount(_ pwd: String){
        
        var email : String?
        var phone : String?
        if TDUserInforManager.shared.userType ==  .email {//邮箱类型
            email = accountText
        }else if TDUserInforManager.shared.userType ==  .phone {//手机号类型
            phone = "+" + TDUserInforManager.shared.currentCountryCode + accountText
        }
        
        AGToolHUD.showNetWorkWait()
        loginVM.register(accountText, pwd, captchaText,email: email,phone: phone) { [weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success {
                debugPrint("注册成功")
                AGToolHUD.showInfo(info: "注册成功")
                self?.jumpRootVC()
            }else{
                AGToolHUD.showInfo(info: msg)
                self?.setPasswordView.showTipsMessage(msg)
            }
            print("\(msg)")
        }
        
    }
    
    //重置密码
    func resetPassword(_ pwd: String){
        
        AGToolHUD.showNetWorkWait()
        loginVM.resetPassword(accountText, pwd, captchaText) { [weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success {
                AGToolHUD.showInfo(info: "密码重置成功")
                debugPrint("密码重置成功")
                self?.jumpRootVC()
            }else{
                AGToolHUD.showInfo(info: msg)
                self?.setPasswordView.showTipsMessage(msg)
            }
            print("\(msg)")
        }
        
    }
    
    //MARK: - 返回到登录首页
    func jumpRootVC() {
        for vc in self.navigationController!.viewControllers {
            if vc.isKind(of: LoginMainVC.self) {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    
}
