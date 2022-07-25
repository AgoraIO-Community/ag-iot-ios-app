//
//  PassWordTextField.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/6/10.
//

import UIKit

class PassWordTextField: UITextField {
    
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
            //(30+35)30为右侧眼睛宽度，35为清除按钮宽度
            return CGRect(x: rect.origin.x+15, y: rect.origin.y+1.5, width: rect.size.width-(10), height: rect.size.height)
        }
    }
    
    //leftView 距离左侧距离
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {

        var rect = super.leftViewRect(forBounds:bounds )
        rect.origin.x += 27

        return rect
    }

//    //rightView 距离右侧距离
//    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//
//        var rect = super.rightViewRect(forBounds:bounds )
//        rect.origin.x -= 27
//
//        return rect
//    }
    
    // 清除按钮距离右侧距离
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {

        var rect = super.clearButtonRect(forBounds:bounds )
        rect.origin.x -= 5

        return rect
    }
 
}
