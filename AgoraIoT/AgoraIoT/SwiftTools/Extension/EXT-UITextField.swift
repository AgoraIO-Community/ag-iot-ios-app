//
//  EXT-UITextField.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/24.
//

import UIKit

extension UITextField{
    //MARK:设置暂位文字的颜色
    var placeholderColor: UIColor {
        
        get{
            guard let ivar: Ivar = class_getInstanceVariable(UITextField.classForCoder(), "_placeholderLabel") else { return UIColor.lightText}
            guard let placeHolderLabel: UILabel = (object_getIvar(self, ivar) as? UILabel) else { return UIColor.lightText}
            return placeHolderLabel.textColor
        }
        
        set{
            guard let ivar: Ivar = class_getInstanceVariable(UITextField.classForCoder(), "_placeholderLabel") else { return }
            guard let placeHolderLabel: UILabel = (object_getIvar(self, ivar) as? UILabel) else { return }
            placeHolderLabel.textColor = newValue
        }
    }
    //MARK:设置暂位文字的字体
    var placeholderFont:UIFont{
        set{
            guard let ivar: Ivar = class_getInstanceVariable(UITextField.classForCoder(), "_placeholderLabel") else { return }
            guard let placeHolderLabel: UILabel = (object_getIvar(self, ivar) as? UILabel) else { return }
            placeHolderLabel.font = newValue
        }
        
        get{
            guard let ivar: Ivar = class_getInstanceVariable(UITextField.classForCoder(), "_placeholderLabel") else { return UIFont.systemFont(ofSize: 14)}
            guard let placeHolderLabel: UILabel = (object_getIvar(self, ivar) as? UILabel) else { return UIFont.systemFont(ofSize: 14)}
            return placeHolderLabel.font
        }
    }
}
