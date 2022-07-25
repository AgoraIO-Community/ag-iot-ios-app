//
//  VerifyManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/28.
//

import UIKit

class VerifyManager: NSObject {
    
    /// 判断字符串是手机号还是邮箱
    ///
    /// - Parameter text: 入参
    /// - Returns: 1: 手机号 2： 邮箱   否则：其他
    public class func checkAccountCodeType(text: String) -> NSNumber {
        if checkPhoneNumber(text: text) == 1 {
            return 1
        }
        
        if checkEmailNumber(text: text) == 2 {
            return 2
        }
        
        return 3
    }
    
    public class func checkPhoneNumber(text: String) -> NSNumber{
        if text.count > 0 && text.checkNumber() {
            return 1
        }
        return 3
    }
    
    public class func checkEmailNumber(text: String) -> NSNumber {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if (pred.evaluate(with: text)) {
            if text.count <= 39 {
                return 2
            }
            return 3
        }else{
            return 3
        }
    }
    
    /// 判断密码
    ///
    /// - Parameter text: 入参
    /// - Returns: true: 合法 false： 不合法
    public class func checkPassword(text: String) -> Bool {
        
        let regex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])[0-9A-Za-z]{8,20}$" //(同时包含大小写字母和数字)
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if (pred.evaluate(with: text)) {
            
            return true
        }
        
        return false
    }
    
    /// 判断邮箱
    ///
    /// - Parameter text: 入参
    /// - Returns: true: 合法 false： 不合法
    public class func checkEmail(text: String) -> Bool {
        
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if (pred.evaluate(with: text)) {
            
            return true
        }
        
        return false
    }
    /// 判断电话号码
    ///
    /// - Parameter text: 入参
    /// - Returns: true: 合法 false： 不合法
    public class func checkPhone(text: String) -> Bool {
        if checkPhoneNumber(text: text) == 1 {
            return true
        }
        return false
    }
}
