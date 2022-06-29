//
//  LoginInputView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
//

import UIKit

//MARK: - 账号的View
class LoginInputView: UIView {
    
    var placeholder = String() {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var leftImage:UIImage? {
        didSet {
            showLeftImageV.image = leftImage
        }
    }

    
    var isShowLeft = true {
        didSet {
            if isShowLeft == true {
                textField.leftViewMode = UITextField.ViewMode.always
            } else {
                textField.leftViewMode = UITextField.ViewMode.never
            }
        }
    }
    
    var isShowRight = false {
        didSet {
            if isShowRight == true {
                textField.rightViewMode = UITextField.ViewMode.always
                textField.isSecureTextEntry = true
            } else {
                textField.rightViewMode = UITextField.ViewMode.never
                textField.isSecureTextEntry = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setUpUI()
    }
    
    func setUpUI() {
        
        addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(60*ScreenHS)
        }
        
        backView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(-40.S)
        }
        
        backView.addSubview(eyeBtn)
        eyeBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20.S)
            make.size.equalTo(CGSize(width: 19.S, height: 13.S))
        }
        
//        addSubview(lineV)
//        lineV.snp.makeConstraints { (make) in
//            make.left.equalTo(backView.snp_left)
//            make.right.equalTo(backView.snp_right)
//            make.top.equalTo(backView.snp_bottom)
//            make.height.equalTo(0.5)
//        }
        
//        addSubview(tipsLabel)
//        tipsLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(backView.snp_bottom).offset(8.S)
//            make.left.equalTo(backView.snp_left)
//            make.right.equalTo(backView.snp_right)
//            make.bottom.equalToSuperview()
//        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var backView: UIView = {
        let vew = UIView()
        vew.borderColor = UIColor.gray
        vew.borderWidth = 0.5
        vew.backgroundColor = UIColor.white
        vew.layer.cornerRadius = 11
        vew.layer.masksToBounds = true
        return vew
    }()
    
    lazy var textField:PassWordTextField = {
        let textField = PassWordTextField()
        textField.backgroundColor = UIColor.white

        textField.placeholder = placeholder
        textField.placeholderColor = UIColor(hexString: "#DEDEDE")
        textField.placeholderFont = FontPFRegularSize(13)
        textField.font = FontPFRegularSize(13)
        textField.autocapitalizationType = .none

        textField.leftView = showLeftImageV
        textField.leftViewMode = UITextField.ViewMode.always
//        textField.rightView = eyeBtn
//        textField.rightViewMode = UITextField.ViewMode.never
        
        textField.clearButtonMode = .whileEditing
        textField.isSecureTextEntry = true
        textField.length = -1

        return textField
    }()
    
    fileprivate lazy var showLeftImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.frame = CGRect(x: 0, y: 0, width: 16.S, height: 16.S)
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    
    lazy var eyeBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 19.S, height: 13.S)
        btn.setImage(UIImage.init(named: "login_eye_close"), for: .normal)
        btn.setImage(UIImage.init(named: "login_eye_open"), for: .selected)
        btn.addTarget(self, action: #selector(showImgBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var lineV:UIView = {
        let lineV = UIView()
        lineV.backgroundColor = UIColor(hexString: "#DEDEDE")
        return lineV
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#F02818")
        label.font = FontPFRegularSize(12)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    
}
extension LoginInputView {
    
    @objc func showImgBtnEvent(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        textField.isSecureTextEntry = !btn.isSelected
    }
}

