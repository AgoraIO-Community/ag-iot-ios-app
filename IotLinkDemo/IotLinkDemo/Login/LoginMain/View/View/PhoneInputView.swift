//
//  PhoneInputView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
//

import UIKit

class PhoneInputView: UIView {
    
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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var backView: UIView = {
        let vew = UIView()
//        vew.backgroundColor = rgba(221, 221, 221, 1)
        vew.borderColor = UIColor.gray
        vew.borderWidth = 0.5
        vew.layer.cornerRadius = 11
        vew.layer.masksToBounds = true
        return vew
    }()
    
    lazy var textField:LoginTextField = {
        
        let textField = LoginTextField()
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black

        textField.placeholder = placeholder
        textField.placeholderColor = UIColor(hexString: "#DEDEDE")
        textField.placeholderFont = FontPFRegularSize(13)
        textField.font = FontPFRegularSize(13)

        textField.autocapitalizationType = .none

        textField.leftView = showLeftImageV
        textField.leftViewMode = UITextField.ViewMode.always
        textField.rightViewMode = UITextField.ViewMode.never
        
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
//        textField.borderStyle = .roundedRect

        return textField
    }()
    
    fileprivate lazy var showLeftImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.frame = CGRect(x: 0, y: 0, width: 16.S, height: 16.S)
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    
    fileprivate lazy var lineV:UIView = {
        let lineV = UIView()
        lineV.backgroundColor = UIColor(hexString: "#DEDEDE")
        return lineV
    }()
    
    
}

extension PhoneInputView {
    

}
