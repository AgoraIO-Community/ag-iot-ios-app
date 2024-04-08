//
//  LoginView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
//

import UIKit
import AgoraIotLink

protocol LoginViewDelegate : NSObjectProtocol{
    
    func countryBtnClick()
    func registerBtnClick(acc: String, pwd: String)
    func forgetPwdBtnClick()
    func loginBtnClick(acc:String,pwd:String)
    
}

class LoginView: UIView {

    weak var delegate : LoginViewDelegate?
    
    let logoTopSpace:CGFloat = 100.0.VS-moreSafeAreaTopSpace()
    let accontTopSpace:CGFloat = 71.VS-moreSafeAreaTopSpace()
    let margain:CGFloat = 46.S
    let cHeight:CGFloat = 60.VS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        self.addSubview(backView)
        
        backView.addSubview(bgImgV)
        backView.addSubview(titleLabel)
//        backView.addSubview(subTitleLabel)
//        backView.addSubview(selectCountry)
        backView.addSubview(forgetBtn)
        backView.addSubview(phoneNumView)
//        backView.addSubview(passwordView)
        backView.addSubview(tipsLabel)
        backView.addSubview(loginBtn)
        backView.addSubview(registerBtn)
        
        backView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        bgImgV.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoTopSpace)
            make.centerX.equalToSuperview()
            make.width.equalTo(200.S)
            make.height.equalTo(50.S)
        }
        
//        subTitleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(titleLabel.snp.bottom).offset(2.S)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(100.S)
//            make.height.equalTo(22.S)
//        }
        
        //去除国家选择需求注释
//        selectCountry.snp.makeConstraints { (make) in
//            make.top.equalTo(subTitleLabel.snp.bottom).offset(accontTopSpace)
//            make.left.equalTo(margain)
//            make.right.equalTo(-margain)
//            make.height.equalTo(cHeight)
//        }
        
        phoneNumView.snp.makeConstraints { (make) in
//            make.top.equalTo(selectCountry.snp.bottom).offset(28.VS)
            make.top.equalTo(titleLabel.snp.bottom).offset(accontTopSpace+24.S)
            make.left.equalTo(margain)
            make.right.equalTo(-margain)
            make.height.equalTo(cHeight)
        }
        
//        passwordView.snp.makeConstraints { (make) in
//            make.top.equalTo(phoneNumView.snp.bottom).offset(28.VS)
//            make.left.equalTo(margain)
//            make.right.equalTo(-margain)
//            make.height.equalTo(cHeight)
//        }
        
//        forgetBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(passwordView.snp.bottom).offset(12.VS)
//            make.right.equalTo(passwordView.snp.right).offset(-10.S)
//            make.height.equalTo(18.S)
//        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumView.snp.bottom).offset(8.VS)
            make.left.equalTo(phoneNumView.snp.left)
            make.right.equalTo(phoneNumView.snp.right).offset(-65.S)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumView.snp.bottom).offset(61.VS)
            make.centerX.equalToSuperview()
            make.width.equalTo(140.S)
            make.height.equalTo(56.S)
        }
        
        registerBtn.snp.makeConstraints { (make) in
            make.top.equalTo(loginBtn.snp.bottom).offset(54.VS)
            make.centerX.equalToSuperview()
            make.width.equalTo(80.S)
            make.height.equalTo(25.S)
        }
    }
    
    private lazy var backView:UIView={
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private lazy var bgImgV : UIImageView = {
        let bgV = UIImageView.init()
        bgV.backgroundColor = UIColor.clear
        bgV.isUserInteractionEnabled = true
        bgV.image = UIImage.init(named: "white_bg")
        return bgV
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#000000")
        label.font = FontPFRegularSize(36)
        label.textAlignment = .center
        label.text = "agoraLink".L
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#000000")
        label.font = FontPFRegularSize(16)
        label.text = "Agora Link"
        return label
    }()
    
    ///选择国家
    lazy var selectCountry: ChooseCountryView = {
        
        let btn = ChooseCountryView()
        btn.leftImage = UIImage.init(named: "login_area")
        btn.placeholder = "请选择国家"
        btn.layer.cornerRadius = 11.S
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor(hexString: "#DEDEDE").cgColor
        btn.tag = 99
        btn.addTarget(self, action: #selector(selectCountryEvent(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    ///手机号输入框
    lazy var phoneNumView: PhoneInputView = {
        
        let vew = PhoneInputView()
        vew.leftImage = UIImage.init(named: "login_user")
        vew.textField.placeholder = "请输入账号"
        vew.textField.delegate = self
        vew.textField.tag = 88
        vew.textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        vew.textField.keyboardType = UIKeyboardType.default
        
        return vew
    }()
    
    lazy var passwordView: LoginInputView = {
        let vew = LoginInputView()
        vew.leftImage = UIImage.init(named: "login_password")
        vew.placeholder = "请输入密码"
        vew.textField.tag = 200
        vew.textField.delegate = self
        vew.textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        return vew
    }()
    
    lazy var forgetBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("忘记密码", for: .normal)
        btn.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btn.titleLabel?.font = FontPFRegularSize(13)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(forgetEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#E02020")
        label.font = FontPFRegularSize(13)
        label.adjustsFontSizeToFitWidth = true
//        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.isHidden = true
        label.text = "账号或密码输入有误"
        return label
    }()
    
    lazy var loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("login".L, for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#1A1A1A")
        
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.setTitleColor(UIColor.init(hexString: "#25DEDE"), for: .normal)
        btn.layer.cornerRadius = 28.S
        btn.addTarget(self, action: #selector(loginBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var registerBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("register".L, for: .normal)
        btn.setTitleColor(UIColor(hexString: "#49A0FF"), for: .normal)
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addTarget(self, action: #selector(registerEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    //验证邮箱手机号是否输入合法
    @objc func textDidChangeNotification(textField:UITextField)  {
        print("\(textField.text)")
//        if TDAddressAreaCodePickerView.areaCodeView != nil {
//            TDAddressAreaCodePickerView.areaCodeView?.cancelAction()
//        }
//
//        verificationInputTextUpdateState(textField)

    }
 
   
}

extension LoginView {
    
    //MARK: - 账号密码登陆事件
    @objc func loginBtnEvent(btn: UIButton) {
        
        self.delegate?.loginBtnClick(acc: phoneNumView.textField.text ?? "", pwd: passwordView.textField.text ?? "")
                
    }
    
    //MARK: - 忘记密码
    @objc func forgetEvent(btn: UIButton) {
        
        self.delegate?.forgetPwdBtnClick()
        
    }
    
    //MARK: - 注册账号
    @objc func registerEvent(btn: UIButton) {
        
        self.delegate?.registerBtnClick(acc: phoneNumView.textField.text ?? "", pwd: passwordView.textField.text ?? "")
        
    }
    
    //MARK: - 选择国家事件
    @objc func selectCountryEvent(btn:UIButton) {
        
        self.delegate?.countryBtnClick()
        
    }
}

extension LoginView {
    
    func showTipsMessage(_ text: String){
        tipsLabel.isHidden = false
        tipsLabel.text = text
    }
    
    func hide(){
        tipsLabel.isHidden = true
    }
}

extension LoginView : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
