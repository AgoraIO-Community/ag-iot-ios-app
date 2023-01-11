import Foundation
import UIKit


 extension String{

    public func isEmaiNumber() -> Bool{
    
        if self.count == 0 {
            return false
        }
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let regexCodeNumber = NSPredicate(format: "SELF MATCHES %@",regex)
        
        if  regexCodeNumber.evaluate(with: self) == true {
            return true
        }else
        {
            return false
        }
     }
    
    
    public func isTrueIDNumber() -> Bool{
        var value = self
        
        value = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        var length : Int = 0
        
        length = value.count
        
        if length != 15 && length != 18{
            //不满足15位和18位，即身份证错误
            return false
        }
        
        // 省份代码
        let areasArray = ["11","12", "13","14", "15","21", "22","23", "31","32", "33","34", "35","36", "37","41", "42","43", "44","45", "46","50", "51","52", "53","54", "61","62", "63","64", "65","71", "81","82", "91"]
        
        // 检测省份身份行政区代码
        let index = value.index(value.startIndex, offsetBy: 2)
        let valueStart2 = value.substring(to: index)
        
        //标识省份代码是否正确
        var areaFlag = false
        
        for areaCode in areasArray {
            
            if areaCode == valueStart2 {
                areaFlag = true
                break
            }
        }
        
        if !areaFlag {
            return false
        }
        
        var regularExpression : NSRegularExpression?
        
        var numberofMatch : Int?
        
        var year = 0
        
        switch length {
        case 15:
            
            //获取年份对应的数字
            let valueNSStr = value as NSString
            
            let yearStr = valueNSStr.substring(with: NSRange.init(location: 6, length: 2)) as NSString
            
            year = yearStr.integerValue + 1900
            
            if year % 4 == 0 || (year % 100 == 0 && year % 4 == 0) {
                //创建正则表达式 NSRegularExpressionCaseInsensitive：不区分字母大小写的模式
                //测试出生日期的合法性
                regularExpression = try! NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive)
            }else{
                
                //测试出生日期的合法性
                regularExpression = try! NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive)
            }
            
            numberofMatch = regularExpression?.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange.init(location: 0, length: value.count))
            
            if numberofMatch! > 0 {
                return true
            }else{
                
                return false
            }
            
        case 18:
            
            let valueNSStr = value as NSString
            
            let yearStr = valueNSStr.substring(with: NSRange.init(location: 6, length: 4)) as NSString
            
            year = yearStr.integerValue
            
            if year % 4 == 0 || (year % 100 == 0 && year % 4 == 0) {
                
                //测试出生日期的合法性
                regularExpression = try! NSRegularExpression.init(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: NSRegularExpression.Options.caseInsensitive)
                
            }else{
                
                //测试出生日期的合法性
                regularExpression = try! NSRegularExpression.init(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: NSRegularExpression.Options.caseInsensitive)
            }
            
            numberofMatch = regularExpression?.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange.init(location: 0, length: value.count))
            
            if numberofMatch! > 0 {
                
                let a = getStringByRangeIntValue(Str: valueNSStr, location: 0, length: 1) * 7
                
                let b = getStringByRangeIntValue(Str: valueNSStr, location: 10, length: 1) * 7
                
                let c = getStringByRangeIntValue(Str: valueNSStr, location: 1, length: 1) * 9
                
                let d = getStringByRangeIntValue(Str: valueNSStr, location: 11, length: 1) * 9
                
                let e = getStringByRangeIntValue(Str: valueNSStr, location: 2, length: 1) * 10
                
                let f = getStringByRangeIntValue(Str: valueNSStr, location: 12, length: 1) * 10
                
                let g = getStringByRangeIntValue(Str: valueNSStr, location: 3, length: 1) * 5
                
                let h = getStringByRangeIntValue(Str: valueNSStr, location: 13, length: 1) * 5
                
                let i = getStringByRangeIntValue(Str: valueNSStr, location: 4, length: 1) * 8
                
                let j = getStringByRangeIntValue(Str: valueNSStr, location: 14, length: 1) * 8
                
                let k = getStringByRangeIntValue(Str: valueNSStr, location: 5, length: 1) * 4
                
                let l = getStringByRangeIntValue(Str: valueNSStr, location: 15, length: 1) * 4
                
                let m = getStringByRangeIntValue(Str: valueNSStr, location: 6, length: 1) * 2
                
                let n = getStringByRangeIntValue(Str: valueNSStr, location: 16, length: 1) * 2
                
                let o = getStringByRangeIntValue(Str: valueNSStr, location: 7, length: 1) * 1
                
                let p = getStringByRangeIntValue(Str: valueNSStr, location: 8, length: 1) * 6
                
                let q = getStringByRangeIntValue(Str: valueNSStr, location: 9, length: 1) * 3
                
                let S = a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q
                
                let Y = S % 11
                
                var M = "F"
                
                let JYM = "10X98765432"
                
                M = (JYM as NSString).substring(with: NSRange.init(location: Y, length: 1))
                
                let lastStr = valueNSStr.substring(with: NSRange.init(location: 17, length: 1))
                
                if lastStr == "x" {
                    if M == "X" {
                        return true
                    }else{
                        
                        return false
                    }
                }else{
                    
                    if M == lastStr {
                        return true
                    }else{
                        
                        return false
                    }
                }
            }else{
                
                return false
            }
            
        default:
            return false
        }
    }

    public func getStringByRangeIntValue(Str : NSString,location : Int, length : Int) -> Int{
        
        let a = Str.substring(with: NSRange(location: location, length: length))
        
        let intValue = (a as NSString).integerValue
        
        return intValue
    }

    //MARK: 判断输入是有效的固定电话号码（区号加电话号码）
    public func checkFixedTelephone() ->Bool{
        
         let numberRegex:NSPredicate=NSPredicate(format:"SELF MATCHES %@","^(\\([0-9]{3,4}\\)|[0-9]{3,4}-)?[0-9]{7,8}$")
         if numberRegex.evaluate(with: self){
            return true
         }else{
            return false
        }
    }
    
    //手机号
    public func checkPhone() -> Bool {
        
        // 1开头, 11位纯数字
        
        if !self.hasPrefix("1") {
            return false
        }
        
        // 纯数字
        return checkPureNumber(11, 11)
    }
    
    //验证纯数字
    public func checkPureNumber(_ min:NSInteger,_ max:NSInteger) -> Bool {

        let predicateStr = String(format: "^\\d{%ld,%ld}",min,max)
        
        let result = predicateEvaluate(predicateStr)
        
        if !result {
//        SVProgressHUD.showInfoWithStatus("验证码输入有误")
            print("验证码输入有误")
        }
      return result
        
    }
    
    //以6开头的8位纯数字
    public func isNumberEight() -> Bool {

        let pattern = "^6\\d{7}$"

        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {

            return true

        }

        return false

    }
    
    //验证登录密码(同时包含大小写字母和数字)
    public func checkUserLoginPassword(_ min:NSInteger,_ max:NSInteger) -> Bool{
  
        //  .()+=~<>!@#$^&*~`?,|;{}:
        //"^[a-zA-Z0-9]{%ld,%ld}$"//允许输入大小写和数字
        let predicateStr = String(format:"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])[0-9A-Za-z]{%ld,%ld}$",min,max)
        
        let result = predicateEvaluate(predicateStr)
        
        if !result {
        //SVProgressHUD.showInfoWithStatus("密码输入有误")
         print("密码输入有误")
        }
        return result
    }
    
    //校验昵称(字母数字中文)
    public func checkNickName(_ min:NSInteger,_ max:NSInteger) -> Bool{
    
      let predicateStr = String(format: "^[a-z,A-Z,0-9,\\u4e00-\\u9fa5]{%ld,%ld}$",min,max)
        
      let result = predicateEvaluate(predicateStr)
        
        if !result {
        //SVProgressHUD.showInfoWithStatus("昵称应为数字,字母,中文")
            print("昵称为数字,字母,中文")
        }
        return result
        
    }
    
    //检测中文
    public func checkChinese(_ min:NSInteger,_ max:NSInteger) -> Bool {
        
        let predicateStr = String(format: "^[\\u4e00-\\u9fa5]{%ld,%ld}$",min,max)
        
        let result = predicateEvaluate(predicateStr)
        
        if !result {
        //SVProgressHUD.showInfoWithStatus("应为\(min)至\(max)位中文")
            print("应为\(min)至\(max)位中文")
        }
        return result
    }
    
    public func predicateEvaluate(_ predicateStr:String) -> Bool {
        
        let predicate = NSPredicate(format: "SELF MATCHES %@",predicateStr)

        let dest = replacingOccurrences(of: " ", with: "")
        print(dest)
        return predicate.evaluate(with: dest)
    }
     
     public func replaceSpace() -> String {
         
         let array = self.components(separatedBy: " ")
         var beginSpace = ""
         for item in array {
             if item != ""{
                 beginSpace += item
             }
         }
         return beginSpace

//         return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
     }
    
    //将原始的url编码为合法的url
    public func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    public func trim()->String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
    }
    
    
//    func checkBankCard() -> Bool {
//
//        if(self.count==0){
//
////   SVProgressHUD.showInfoWithStatus("请输入银行卡号!")
//          return false;
//        }
////        var digitsOnly = ""
////        char c;
////        for (int i = 0; i < self.length; i++){
////            c = [self characterAtIndex:i];
////            if (isdigit(c)){
////                digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
////            }
////        }
//
//        var sum = 0;
//        var digit = 0;
//        var addend = 0;
//        var timesTwo = false;
//
//        for idx in 0..<self.count {
//
//            digit = Int((self as NSString).character(at: idx))
//            if (timesTwo){
//                addend = digit * 2;
//
//                if (addend > 9) {
//                    addend -= 9;
//                }
//            }
//            else {
//                addend = digit;
//            }
//            sum += addend;
//            timesTwo = !timesTwo;
//        }
//        let modulus = sum % 10;
//
//        var result = false;
//
//        if (modulus == 0) {
//            result=true;
//        }else{
////        SVProgressHUD.showInfoWithStatus("银行卡号输入有误")
//        }
//        return result;
//    }
    
    //
    
    //------------------新增校验-------------------
    
    //判断是否超过一万
    public func alailableWanPrise() -> (result : String, isMore : Bool) {
        
        let tempPrice : Float = Float(self) ?? 0
        if tempPrice >= 10000 {
            return (String(tempPrice/10000), true)
        }
        
        return (self, false)
        
    }
    
    /// 将字符串中间替换成***
    ///
    /// - Returns: 替换后的字符串
    public func replacePhone() -> String {
        if self.count <= 0 {
            return self
        }
        let num = self.count/3
        let start = self.index(self.startIndex, offsetBy: num)
        let addLen = 2*num+1
        let end = self.index(self.startIndex, offsetBy: addLen)
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        var replaceStr = ""
        for _ in 0..<num+1 {
            replaceStr.append("*")
        }
        return self.replacingCharacters(in: range, with: replaceStr)
    }
    
    public func replaceEmail() -> String {
        let replaceStr = "****"
        
        let start = self.index(self.startIndex, offsetBy: 2)
        var end = self.index(self.startIndex, offsetBy: self.count - 4)
        if self.contains(".cn") {
            end = self.index(self.startIndex, offsetBy: self.count - 3)
        }
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        
        return self.replacingCharacters(in: range, with: replaceStr)
        
    }
    
    //判断是否是中文
    public func isCheckChinese() -> Bool {
        let regex = "\u{4e00}-\u{9fa5}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if (pred.evaluate(with: self)) {
            return true
        }else{
            return false
        }
    }
    
    //是否有特殊字符
    public func checkCharacters() -> Bool {
        let pattern: String = "[^a-zA-Z0-9\u{4e00}-\u{9fa5}]"
        let express = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let result = express.matches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count))
        let sources = NSMutableString()
        for item in result {
            sources.append(String(self.prefix(item.range(at: 0).length)))
        }
        if (sources as String).count <= 0 {
            return false
        }
        return true
    }
    
    /// 中英文+数字+标点符号
    public func checkcommonCharacters() -> Bool {
        let predicateStr = "^[a-zA-Z0-9\\u4e00-\\u9fa5\\p{P}\\s*]*$"
        let result = predicateEvaluate(predicateStr)
        return result
    }
    
    
    //        let regex = "^(?=.*[0-9A-Z])(?=.*[0-9a-z])(?=.*[a-zA-Z])[0-9a-zA-Z]{6,20}$" //字母+数字
    ///密码复杂度判断
    public func isPasswordStrength() -> Bool {
        //let regex = "^(?![0-9]+$)(?![a-zA-Z]+$)(?![_]+$)(^[A-Za-z])[0-9A-Za-z_]{6,20}$"
        let regex = "^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*).{6,20}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if (pred.evaluate(with: self)) {
            if self.contains(" "){
                
                return false
            }
            return true
        }else{
            return false
        }
    }
    
    //是否是字符
    public func isCheckCharacters() -> Bool {
        let pattern: String = "[a-zA-Z]*"
        
        let pred = NSPredicate.init(format: "SELF MATCHES %@", pattern)
        
        return pred.evaluate(with: self)
    }
    
    //是否全是数字
    public func checkNumber() -> Bool {
        let pattern: String = "[0-9]*"
        
        let pred = NSPredicate.init(format: "SELF MATCHES %@", pattern)
        
        return pred.evaluate(with: self)
    }
    
    //是否包含数字和字母
    public func checkInputShouldAlphaNum() -> Bool {
        let pattern: String = "^(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$"
        
        let pred = NSPredicate.init(format: "SELF MATCHES %@", pattern)
        
        return pred.evaluate(with: self)
    }
    
    
    public func sellerCheckCharacters() -> Bool {
        //4-20个字符，可由中英文、数字、“_”,”-”组成
        let pattern: String = "[^a-zA-Z0-9\u{4e00}-\u{9fa5}]"
        let express = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let result = express.matches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count))
        let sources = NSMutableString()
        for item in result {
            sources.append(String(self.prefix(item.range(at: 0).length)))
        }
        if (sources as String).count <= 0 || self.contains("-") || self.contains("_") {
            return false
        }
        return true
    }
    
    //只允许输入中文
    public func checkOnlyChineseCharacters() -> Bool {
        let pattern: String = "[\u{4e00}-\u{9fa5}]"
        let express = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let result = express.matches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count))
        let sources = NSMutableString()
        for item in result {
        sources.append(String(self.prefix(item.range(at: 0).length)))
        }
        if (sources as String).count <= 0 {
        return false
        }
        return true
    
    }
    
    ///整数返回整数,小数保留两位，多用于金额，不四舍五入
    /// 替换为: 小数位保留有效非0位数
    public func getNonZeroDecimal() -> String {
        
//        if self.isEmpty {
//            return self
//        }
//
//        if !self.contains(".") {
//            return self
//        }
//        //整数位
//        let intStr: String = self.components(separatedBy: ".")[0]
//        //小数位
//        var decimal: String = self.components(separatedBy: ".")[1]
//
//        var isZero = true
//        for c in decimal {
//            if c != "0" {
//                isZero = false
//                break
//            }
//        }
//
//        // .000000~
//        if isZero {
//            return intStr
//        }
//
//        //小数位小于等于2位  0，1，2
//        if decimal.count <= 2 {
//            if decimal.count == 0 {
//                return self + "00"
//            }
//            if decimal.count == 1  {
//                return self + "0"
//            }
//            if decimal.count == 2 {
//                return self
//            }
//        }
//        //保留两位小数
//        decimal = String(decimal.prefix(2))
//
//        return intStr + "." + decimal
        if self.isEmpty {
            return self
        }
        
        if !self.contains(".") {
            return self
        }
        let intStr: String = self.components(separatedBy: ".")[0]
        //小数位 保留两位
        var decimal: String = self.components(separatedBy: ".")[1]
        decimal = String(decimal.prefix(2))
        
        var isZero = true
        for c in decimal {
            if c != "0" {
                isZero = false
                break
            }
        }
        
        // .000000~
        if isZero {
            return intStr
        }
        
        // 末尾0的位数
        var zeroCount: Int = 0
        for c in decimal.reversed() {
            if c != "0" {
                break
            } else {
                zeroCount += 1
            }
        }
        if zeroCount > 0 {
            let notZeroCount = decimal.count - zeroCount
            decimal = String(decimal.prefix(notZeroCount))
        }
        return "\(intStr).\(decimal)"
    }
    
    /// 邮编正则表达式
    public var postalCodeRE: String {
        //let localID = self.prefix(2)
        switch self {
        case "GB":  // 2-4数字/字母或者 字母空格3数字/字母（空格不是必须的）
            return "^(([0-9a-zA-Z]{2,4})|([a-zA-Z] ?[0-9a-zA-Z]{3}))$"

        case "RO":  //  仅有6数字
            return "^\\d{6}$"

        case "DE", "FR", "ES", "EE", "FI", "MX", "SE":  //  仅有5数字
            return "^\\d{5}$"

        case "AT", "BE", "LU", "HU", "DK", "BG", "LV", "CY", "CH", "NO":  //  仅有4数字
            return "^[\\d]{4}$"

        case "OT":  //  仅有5数字,但不可以是12345
            return "^(?!12345$)\\d{5}$"

        case "NL":  //  4数字+空格+2数字/字母，例如1111 AB
            return "^\\d{4} [0-9a-zA-Z]{2}$"

        case "PL":  //   2数字+"-"+3数字，例如11-222
            return "^\\d{2}-\\d{3}$"

        case "SK", "CZ", "GR":  //   3数字+空格+2数字，例如111 22
            return "^\\d{3} \\d{2}$"

        case "HR":  //   5数字或者“HR-”+5数字，例如11111或者HR-11111
            return "^(HR-)?\\d{5}$"

        case "LT":  //   5数字或者“LT-”+5数字，例如11111或者LT-11111
            return "^(LT-)?\\d{5}$"

        case "MT":  //   3字母+空格+3数字+空格+1数字或者3字母+空格+4数字，例如AAA 111 1或者AAA 1111
            return "^[a-zA-Z]{3} \\d{3} ?\\d$"

        case "PT":  //   4数字+"-"+3数字，例如1111-111
            return "^\\d{4}-\\d{3}$"

        case "SI":  //   4数字或者“SI-”+4数字，例如1111或者SI-1111
            return "^(SI-)?\\d{4}$"
            
        case "IE":  //  不做限制
            return "^*$"

        default:
            return "^*$"
        }
    }
     
     //获取字符串字节数，每个汉字3个字节
     func getStringByteLength() ->Int{

        var bytes: [UInt8] = []

        for char in self.utf8{

            bytes.append(char.advanced(by:0))

        }

        print("\(self):\(bytes.count)")

        return bytes.count

    }

}

extension NSMutableAttributedString {
    
    /// 小数位跟整数位大小不同的Attributed
    ///
    /// - Parameters:
    ///   - aPrice: 金额字符串
    ///   - intFont: 整数位大小
    ///   - decFont: 小数位大小
    public static func getPriceWithUnitAttribute(price aPrice:String, unitStr unit: String, unitFont aUnitFont: UIFont, unitSpace space: Float, integerFont intFont: UIFont, decimalFont decFont: UIFont) -> NSMutableAttributedString {
        
        var firstStr: String?
        var lastStr: String?
        
        if aPrice.contains(".") {
            let range = (aPrice as NSString?)?.range(of: ".")
            lastStr = (aPrice as NSString?)?.substring(from: range?.location ?? 0)
            firstStr = (aPrice as NSString?)?.substring(to: range?.location ?? 0)
        } else {
            firstStr = aPrice
        }
        
        let amountStr = unit+aPrice
        let attributedStr = NSMutableAttributedString(string: amountStr)
        
        // 单位
        attributedStr.addAttribute(.font, value: aUnitFont, range: NSRange(location: 0, length: unit.count))
        attributedStr.addAttribute(.kern, value: space, range: NSRange(location: 0, length: unit.count))
        
        // 整型
        attributedStr.addAttribute(.font, value: intFont, range: NSRange(location: unit.count, length: firstStr?.count ?? 0))
        
        // 小数
        attributedStr.addAttribute(.font, value: decFont, range: NSRange(location: unit.count + (firstStr?.count ?? 0), length: lastStr?.count ?? 0))
        
        return attributedStr
    }
    
}
