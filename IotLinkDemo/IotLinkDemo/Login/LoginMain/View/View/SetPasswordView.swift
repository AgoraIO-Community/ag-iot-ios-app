//
//  SetPasswordView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/26.
//

import UIKit

protocol SetPasswordViewDelegate : NSObjectProtocol{
    
    func confrimBtnClick(pwd:String)
    
}

class SetPasswordView: UIView, UITextFieldDelegate {
    
    weak var delegate : SetPasswordViewDelegate?
    
    let accontTopSpace:CGFloat = 223.VS-moreSafeAreaTopSpace()
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
        backView.addSubview(titleLabel)
        backView.addSubview(passwordView)
        backView.addSubview(tipsLabel)
        backView.addSubview(confirmBtn)
        
        backView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        passwordView.snp.makeConstraints { (make) in
            make.top.equalTo(accontTopSpace)
            make.left.equalTo(margain)
            make.right.equalTo(-margain)
            make.height.equalTo(cHeight)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(passwordView.snp.top).offset(-23.VS)
            make.left.equalTo(passwordView.snp.left)
            make.height.equalTo(30.S)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(passwordView.snp.bottom).offset(8.VS)
            make.left.equalTo(passwordView.snp.left)
            make.right.equalTo(passwordView.snp.right)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(passwordView.snp.bottom).offset(52.VS)
            make.left.equalTo(passwordView.snp.left)
            make.right.equalTo(passwordView.snp.right)
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
        label.textColor =  UIColor.init(hexString: "#000000")
        label.font = FontPFRegularSize(28)
        label.text = "设置密码"
        return label
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
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#F02818")
        label.font = FontPFRegularSize(12)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.isHidden = true
        label.text = ""
        return label
    }()
    
    lazy var confirmBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("完成", for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#1A1A1A")
        
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.setTitleColor(UIColor.init(hexString: "#25DEDE"), for: .normal)
        btn.layer.cornerRadius = 28.S
        btn.addTarget(self, action: #selector(confirmBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    
    //验证邮箱手机号是否输入合法
    @objc func textDidChangeNotification(textField:UITextField)  {
        debugPrint("\(textField.text)")
        if textField.text == "" {
            showTipsMessage("")
        }

    }
 
   
}

extension SetPasswordView {
    
    //MARK: - 账号密码登陆事件
    @objc func confirmBtnEvent(btn: UIButton) {
        
        self.delegate?.confrimBtnClick(pwd: passwordView.textField.text ?? "")
                
    }
}

extension SetPasswordView {
    
    func showTipsMessage(_ text: String){
        tipsLabel.isHidden = false
        tipsLabel.text = text
    }
}
