//
//  VerifyInputCodeVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
//

import UIKit

public enum VerifyInputType: Int{
    ///默认
    case none = 0
    
    ///注册邮箱验证码
    case registerEmailCode = 1
    ///注册验证手机验证码
    case registerPhoneCode = 2
    
    ///忘记密码邮箱验证码
    case forgotEmailCode = 3
    ///忘记密码验证手机验证码
    case forgotPhoneCode = 4
}

class VerifyInputCodeVC: LoginBaseVC {

    ///验证码已发送
    fileprivate let VERIFY_SEND_CODE = "验证码已发送 "
    ///重新发送
    fileprivate let RE_VERIFY_SEND_CODE = "重新发送"
    
    ///验证类型
    var style:VerifyInputType = .none
    ///邮箱或手机号
    var accountText = ""
    ///验证码
    var captchaText = ""
    
    //验证码倒计时
    fileprivate let countDownNum:Int = 60
    fileprivate var startCount:Int = 0
    
    fileprivate var timer: Timer!
    
    fileprivate lazy var loginVM = LoginMainVM()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //每次进入都弹起键盘
        verifyCodeView.showKeyBoard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        jumpBackOrNext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //开始计时
        startTimer()
        //重新发送按钮置为不可用
        verifyCodeView.configTimeOutLabelAction()
        
        setUpViews()
    }
    
    func setUpViews(){
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(verifyCodeView)
        verifyCodeView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
    }
    
    lazy var verifyCodeView : VerficaCodeView = {
        
        let view = VerficaCodeView()
        view.delegate = self
        return view
        
    }()
    
    deinit {
        print("验证码页面销毁了")
    }
    
}

extension VerifyInputCodeVC : VerficaCodeViewDelegate{
    
    //重新发送
    func reSendCode() {
        //发送验证码
        sendVerfyRequest()
    }
    
    
    func codeBackComplete(_ code: String) {
        var type : SetPasswordType = .none
        if style == .registerEmailCode || style == .registerPhoneCode {
            type = .registerAccount
        }else if style == .forgotEmailCode || style == .forgotPhoneCode{
            type = .forgotPassword
        }
        debugPrint("---\(code)")
        DispatchCenter.DispatchType(type: .setPassword(account: accountText, captchaCode: code, type: type), vc: self, style: .push)
    }
}

extension VerifyInputCodeVC{
    
    func sendVerfyRequest(){
        
        switch style {
        case .registerEmailCode:
            sendEmailCaptchaCode("REGISTER")
            break
        case .registerPhoneCode:
            sendPhoneCaptchaCode("REGISTER_SMS")
            break
        case .forgotEmailCode:
            sendEmailCaptchaCode("PWD_RESET")
            break
        case .forgotPhoneCode:
            sendResetPwdCaptchaCode("PWD_RESET_SMS")
            break
        default:
            break
        }
    }
}

extension VerifyInputCodeVC{
    
    //发送邮箱验证码
    func sendEmailCaptchaCode(_ type:String){
        
        AGToolHUD.showNetWorkWait()
        loginVM.doGetCode(accountText, type: type) { [weak self]code, msg in
            
            AGToolHUD.disMiss()
            if code == 0 {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: "验证码发送成功")
                //开始计时
                self?.startTimer()
                //重新发送按钮置为不可用
                self?.verifyCodeView.configTimeOutLabelAction()
            }else{
                AGToolHUD.showInfo(info: msg)
                self?.verifyCodeView.configTimeOutLabel(msg)
            }
        }
        
    }
    
    //发送手机号验证码  
    func sendPhoneCaptchaCode(_ type:String){
        
        AGToolHUD.showNetWorkWait()
        
//        let phone = "+" + TDUserInforManager.shared.currentCountryCode + accountText
        let phone = accountText //"+" + TDUserInforManager.shared.currentCountryCode + accountText
        loginVM.doGetPhoneCode(phone, type:type,"ZH_CN") { [weak self] success, msg in
           
            AGToolHUD.disMiss()
            if success == true {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: msg)
                //开始计时
                self?.startTimer()
                //重新发送按钮置为不可用
                self?.verifyCodeView.configTimeOutLabelAction()
            }else{
                AGToolHUD.showInfo(info: msg)
//                self?.verifyCodeView.configTimeOutLabel(msg)
            }
        }
        
    }
    
    //重置密码发送手机号验证码
    func sendResetPwdCaptchaCode(_ type:String){
        
        AGToolHUD.showNetWorkWait()
        
//        let phone = "+" + TDUserInforManager.shared.currentCountryCode + accountText
        let phone = accountText //"+" + TDUserInforManager.shared.currentCountryCode + accountText
        loginVM.doGetResetPwdPhoneCode(phone, type:type,"ZH_CN") { [weak self] success, msg in
           
            AGToolHUD.disMiss()
            if success == true {
                debugPrint("验证码发送成功")
                AGToolHUD.showInfo(info: msg)
                //开始计时
                self?.startTimer()
                //重新发送按钮置为不可用
                self?.verifyCodeView.configTimeOutLabelAction()
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        
    }
    
}

//倒计时
extension VerifyInputCodeVC{
    
    func startTimer(){
        
        //发送成功之后进行倒计时
        startCount = countDownNum
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    
    //MARK: - 倒计时开始
    @objc func countDown() {
        
        startCount -= 1
        let text = "\(VERIFY_SEND_CODE)(\(startCount)s)"
        verifyCodeView.configTimeOutLabel(text)
        
        //倒计时完成后停止定时器，移除动画
        if startCount <= 0 {
            
            if timer == nil {
                return
            }
            //重新发送按钮置为可用
            verifyCodeView.configTimeOutLabel(RE_VERIFY_SEND_CODE,true)
            
            timer.invalidate()
            timer = nil

        }
    }
    
}

extension VerifyInputCodeVC{
    
    //返回上一个或跳转下个页面
    func jumpBackOrNext(){
        let viewControllers = self.navigationController?.viewControllers
        if let count = viewControllers?.count, count > 1, viewControllers?[count-2] == self {
            //跳转到下个页面
        }else{
            //返回上个页面
            if timer != nil {
                timer.invalidate()
                timer = nil
            }
        }
    }
}
