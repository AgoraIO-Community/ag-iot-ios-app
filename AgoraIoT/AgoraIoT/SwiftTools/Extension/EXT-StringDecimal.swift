//
//  String_Category.swift
//  SwIftOperation
//
//  Created by tiens on 2020/2/29.
//  Copyright © 2020 tiens. All rights reserved.
//

import UIKit
/*
extension String {
    public enum RoundingType : UInt {
        /// 取整
        case plain
        /// 只舍不入
        case down
        /// 只入不舍
        case up
        /// 四舍五人
        case bankers
    }
    /**
     加
     */
   public func add(num:String) -> String {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        let summation = number1.adding(number2)
        return summation.stringValue
    }
    /**
     减
     */
    public func minus(num:String) -> String {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        let summation = number1.subtracting(number2)
        return summation.stringValue
    }
    /**
     乘
     */
    public func multiplying(num:String) -> String {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        let summation = number1.multiplying(by: number2)
        return summation.stringValue
    }
    /**
     除
     */
    public func dividing(num:String) -> String {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        let summation = number1.dividing(by:number2)
        return summation.stringValue
    }
    
    /**
     大于
     */
    public func descend(num: String) -> Bool {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        if number1.compare(number2) == ComparisonResult.orderedDescending {
            return true
        }
        return false
    }
    
    /**
     小于
     */
    public func ascend(num: String) -> Bool {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        if number1.compare(number2) == ComparisonResult.orderedAscending {
            return true
        }
        return false
    }
    
    /**
     等于
     */
    public func same(num: String) -> Bool {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        if number1.compare(number2) == ComparisonResult.orderedSame {
            return true
        }
        return false
    }
    
    /**
     大于等于  >=
     */
    public func descendOrSame(num: String) -> Bool {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        if number1.compare(number2) == ComparisonResult.orderedDescending {
            return true
        }
        if number1.compare(number2) == ComparisonResult.orderedSame {
            return true
        }
        return false
    }
    
    /**
     小于等于 <=
     */
    public func ascendOrSame(num: String) -> Bool {
        let number1 = NSDecimalNumber(string: self)
        let number2 = NSDecimalNumber(string: num)
        if number1.compare(number2) == ComparisonResult.orderedAscending {
            return true
        }
        if number1.compare(number2) == ComparisonResult.orderedSame {
            return true
        }
        return false
    }
    
    /**
     num 保留几位小数 type 取舍类型
     */
    public func numType(num : Int , type : RoundingType) -> String {
        /*
         enum NSRoundingMode : UInt {
         
         case RoundPlain     // Round up on a tie  貌似取整
         case RoundDown      // Always down == truncate  只舍不入
         case RoundUp        // Always up  只入不舍
         case RoundBankers   // on a tie round so last digit is even  貌似四舍五入
         }
         */
        
        // 90.7049 + 0.22 然后四舍五入
        var tp = NSDecimalNumber.RoundingMode.down
        switch type {
        case RoundingType.plain:
            tp = NSDecimalNumber.RoundingMode.plain
        case RoundingType.down:
            tp = NSDecimalNumber.RoundingMode.down
        case RoundingType.up:
            tp = NSDecimalNumber.RoundingMode.up
        case RoundingType.bankers:
            tp = NSDecimalNumber.RoundingMode.bankers
        }
        let roundUp = NSDecimalNumberHandler(roundingMode: tp, scale:Int16(num), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        
        let discount = NSDecimalNumber(string: self)
        let subtotal = NSDecimalNumber(string: "0")
        // 加 保留 2 位小数
        let total = subtotal.adding(discount, withBehavior: roundUp).stringValue
//        let flot = Float(total)!
//        let str = String(format: "%.2f", flot)
        
        var mutstr = String()
        
        if total.contains(".") {
            let float = total.components(separatedBy: ".").last!;
            if float.count == Int(num) {
                mutstr .append(total);
                return mutstr
            } else {
                mutstr.append(total)
                let all = num - float.count
                for _ in 1...all {
                    mutstr += "0"
                }
                return mutstr
            }
        } else {
            mutstr.append(total)
            if num == 0 {
            } else {
                for _ in 1...num {
                    mutstr += "0"
                }
            }
            return mutstr
        }
        // 加 保留 2 位小数
    }
    
    // string -> CGFloat
    public func StringToFloat(str:String)->(CGFloat) {
        
       let string = str
        
       var cgFloat:CGFloat = 0
        
        if let doubleValue = Double(string)
        {
            cgFloat = CGFloat(doubleValue)
            
        }
        
        return cgFloat
    }
    
    /// 属性字符串处理
    /// - Parameters:
    ///   - subString: 需要截取的字符串
    ///   - colorStr: 颜色
    ///   - fontSize: 大小
    public func attributeString(subString:String,colorStr: String,fontSize:CGFloat) -> NSMutableAttributedString {
         
         let attrst = NSMutableAttributedString(string:self)
                 
         let range = rangeOfString(string: NSString.init(string: self), subString: subString).first
        
         if range?.location != NSNotFound {
            
             attrst.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: colorStr), range: range!)
             attrst.addAttribute(NSAttributedString.Key.font, value: FontPFMediumSize(fontSize), range: range!)
         }
        
         return attrst
     }
    
    /// 返回range 数组
    /// - Parameters:
    ///   - string: 整个字符串
    ///   - subString: 子串
    public func rangeOfString(string:NSString,
                               subString:String) -> [NSRange] {
        
        var arrRange = [NSRange]()
        var _fullText = string
        var rang:NSRange = _fullText.range(of: subString)
        
        while rang.location != NSNotFound {
            var location:Int = 0
            if arrRange.count > 0 {
                if arrRange.last!.location + arrRange.last!.length < string.length {
                     location = arrRange.last!.location + arrRange.last!.length
                }
            }

            _fullText = NSString.init(string: _fullText.substring(from: rang.location + rang.length))

            if arrRange.count > 0 {
                  rang.location += location
            }
            arrRange.append(rang)
            
            rang = _fullText.range(of: subString)
        }
        
        return arrRange
    }
    
    /// 正则匹配
    /// - Parameter rules: 匹配规则
    public func isMatch(_ rules: String ) -> Bool {
        let rules = NSPredicate(format: "SELF MATCHES %@", rules)
        let isMatch: Bool = rules.evaluate(with: self)
        return isMatch
    }
    
    /// 字符串中汉字个数
    public var chCount: Int {
      
        var count = 0
      
        let regex: String = "[\\u4e00-\\u9fa5]"
      
        for i in self.indices {
          
            if String(self[i]).isMatch(regex) {
              
                count += 1
            }
        }
      
        return count
    }
}
*/
