//
//  ResetPasswordView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/26.
//

import UIKit

protocol ResetPasswordViewDelegate : NSObjectProtocol{
    
    func countryBtnClick()
    func resetPwdBtnEvent(acc:String)
    
}

class ResetPasswordView: UIView {
    
    weak var delegate : ResetPasswordViewDelegate?
    
    let accontTopSpace:CGFloat = 263.VS-moreSafeAreaTopSpace()
    let margain:CGFloat = 46.S
    let cHeight:CGFloat = 60.VS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        self.addSubview(backView)
//        backView.addSubview(selectCountry)
        backView.addSubview(titleLabel)
        backView.addSubview(subTitleLabel)
        backView.addSubview(phoneNumView)
        backView.addSubview(tipsLabel)
        backView.addSubview(loginBtn)
        
        backView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
//        selectCountry.snp.makeConstraints { (make) in
//            make.top.equalTo(accontTopSpace)
//            make.left.equalTo(margain)
//            make.right.equalTo(-margain)
//            make.height.equalTo(cHeight)
//        }
        
        phoneNumView.snp.makeConstraints { (make) in
//            make.top.equalTo(selectCountry.snp.bottom).offset(26.VS)
            make.top.equalTo(accontTopSpace)
            make.left.equalTo(margain)
            make.right.equalTo(-margain)
            make.height.equalTo(cHeight)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneNumView.snp.top).offset(-63.VS)
            make.left.equalTo(margain)
            make.height.equalTo(30.S)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneNumView.snp.top).offset(-28.VS)
            make.left.equalTo(margain)
            make.height.equalTo(22.S)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumView.snp.bottom).offset(8.VS)
            make.left.equalTo(phoneNumView.snp.left)
            make.right.equalTo(phoneNumView.snp.right)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumView.snp.bottom).offset(52.VS)
            make.left.equalTo(phoneNumView.snp.left)
            make.right.equalTo(phoneNumView.snp.right)
            make.height.equalTo(56.S)
        }
    }
    
    private lazy var backView:UIView={
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hexString: "#000000")
        label.font = FontPFRegularSize(28)
        label.text = "重置密码"
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hexString: "#000000")
        label.alpha = 0.5
        label.font = FontPFRegularSize(16)
        label.text = "请输入注册的账号"
        return label
    }()

    //去除国家选择需求注释
    ///选择国家
//    lazy var selectCountry: ChooseCountryView = {
//
//        let btn = ChooseCountryView()
//        btn.leftImage = UIImage.init(named: "login_area")
//        btn.placeholder = "请选择国家"
//        btn.layer.cornerRadius = 11.S
//        btn.layer.borderWidth = 0.5
//        btn.layer.borderColor = UIColor(hexString: "#DEDEDE").cgColor
//        btn.tag = 99
//        btn.addTarget(self, action: #selector(selectCountryEvent(btn:)), for: .touchUpInside)
//
//        return btn
//    }()
    
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
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#F02818")
        label.font = FontPFRegularSize(12)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.isHidden = true
        label.text = "账号输入有误"
        return label
    }()
    
    lazy var loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("获取验证码", for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#1A1A1A")
        
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.setTitleColor(UIColor.init(hexString: "#25DEDE"), for: .normal)
        btn.layer.cornerRadius = 28.S
        btn.addTarget(self, action: #selector(loginBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    
    //验证邮箱手机号是否输入合法
    @objc func textDidChangeNotification(textField:UITextField)  {
        debugPrint("\(textField.text)")
    }
 
   
}

extension ResetPasswordView {
    
    //MARK: - 账号密码登陆事件
    @objc func loginBtnEvent(btn: UIButton) {
        
        self.delegate?.resetPwdBtnEvent(acc: phoneNumView.textField.text ?? "")
                
    }
    
    //MARK: - 选择国家事件
    @objc func selectCountryEvent(btn:UIButton) {
        
        self.delegate?.countryBtnClick()
        
    }
}

extension ResetPasswordView {
    
    func showTipsMessage(_ text: String){
        tipsLabel.isHidden = false
        tipsLabel.text = text
    }
}

extension ResetPasswordView : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
