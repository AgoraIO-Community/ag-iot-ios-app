//
//  ChooseCountryView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/24.
//

import UIKit

class ChooseCountryView: UIControl {
    
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
        self.backgroundColor = UIColor.white
        setUpUI()
    }
    
    func setUpUI() {
        
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textField:LoginTextField = {
        
        let textField = LoginTextField()
        textField.backgroundColor = UIColor.clear
        textField.placeholder = placeholder
        textField.placeholderColor = UIColor(hexString: "#DEDEDE")
        textField.placeholderFont = FontPFRegularSize(13)
        textField.font = FontPFRegularSize(13)
        textField.autocapitalizationType = .none
        textField.leftView = showLeftImageV
        textField.leftViewMode = UITextField.ViewMode.always
        textField.rightView = eyeBtn
        textField.rightViewMode = UITextField.ViewMode.always
        textField.length = -1
        textField.isEnabled  = false
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
        btn.frame = CGRect(x: 0, y: 0, width: 16.S, height: 16.S)
        btn.setImage(UIImage.init(named: "Login_left_arrow"), for: .normal)
        return btn
    }()
    
}

