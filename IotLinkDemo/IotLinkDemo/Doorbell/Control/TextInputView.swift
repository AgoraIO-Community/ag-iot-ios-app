//
//  TextInputView.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/12.
//

import Foundation

import UIKit

class TextInputField: UITextField {
    
    var length:CGFloat = -1.0

    /// 控制默认文本的位置(placeholder)
//    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        let rect = super.placeholderRect(forBounds: bounds)
//
//        return self.setTextEdgeRect(rect)
//
//    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)

        return self.setTextEdgeRect(rect)

    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)

        return self.setTextEdgeRect(rect)
    }


    fileprivate func setTextEdgeRect(_ rect:CGRect)  -> CGRect {

        if length != -1 {
            return CGRect(x: length, y: rect.origin.y, width: rect.size.width - 2*length, height: rect.size.height)
        } else {
            return CGRect(x: rect.origin.x+15, y: rect.origin.y+1.5, width: rect.size.width-30, height: rect.size.height)
        }
    }
    
    //leftView 距离左侧距离
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        
        var rect = super.leftViewRect(forBounds:bounds )
        rect.origin.x += 27
        
        return rect
    }
    
    //rightView 距离右侧距离
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        
        var rect = super.rightViewRect(forBounds:bounds )
        rect.origin.x -= 27
        
        return rect
    }
    
    // 清除按钮距离右侧距离
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {

        var rect = super.clearButtonRect(forBounds:bounds )
        rect.origin.x -= 5

        return rect
    }
    
}


class TextInputView: UIView {
    
    var placeholder = String() {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
//    var leftImage:UIImage? {
//        didSet {
//            showLeftImageV.image = leftImage
//        }
//    }
    
//    var isShowLeft = true {
//        didSet {
//            if isShowLeft == true {
//                textField.leftViewMode = UITextField.ViewMode.always
//            } else {
//                textField.leftViewMode = UITextField.ViewMode.never
//            }
//        }
//    }
    
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
    
    lazy var textField:TextInputField = {
        
        let textField = TextInputField()
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black

        textField.placeholder = placeholder
        textField.placeholderColor = UIColor(hexString: "#DEDEDE")
        textField.placeholderFont = FontPFRegularSize(13)
        textField.font = FontPFRegularSize(13)

        textField.autocapitalizationType = .none

        //textField.leftView = showLeftImageV
        textField.leftViewMode = UITextField.ViewMode.never
        textField.rightViewMode = UITextField.ViewMode.never
        
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
//        textField.borderStyle = .roundedRect

        return textField
    }()
    
//    fileprivate lazy var showLeftImageV: UIImageView = {
//        let imageV = UIImageView()
//        imageV.frame = CGRect(x: 0, y: 0, width: 16.S, height: 16.S)
//        imageV.contentMode = .scaleAspectFit
//        return imageV
//    }()
    
    fileprivate lazy var lineV:UIView = {
        let lineV = UIView()
        lineV.backgroundColor = UIColor(hexString: "#DEDEDE")
        return lineV
    }()
    
    
}
