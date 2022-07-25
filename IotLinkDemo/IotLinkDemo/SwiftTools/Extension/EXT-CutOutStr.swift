//
//  EXT-CutOutStr.swift
//  lianxiSwift
//
//  Created by 邓文磊 on 2018/5/24.
//  Copyright © 2018年 HuoYiJia. All rights reserved.
//

import Foundation
import UIKit

extension String{
    
    /// 字符串是否为空，不计算空格和换行符
    public var isBlank: Bool {
        let tempString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return tempString.isEmpty
    }
    
    /// 获取 宽度
    /// - Parameter font: 字体
    public func stringWidth(_ font:UIFont) -> CGFloat{
        
       let nsStr = self as NSString
       
       return nsStr.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT),
                                              height: ScreenHeight),
                                 options: .usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font : font],
                                 context: nil).width
    }
    
    ///  获取高度
    /// - Parameters:
    ///   - maxWidth: 宽度
    ///   - font: 字体
    public func stringHeight(_ maxWidth:CGFloat ,_ font:UIFont) -> CGFloat{
        
        let nsStr = self as NSString
        
        return nsStr.boundingRect(with: CGSize(width:maxWidth,
                                               height: CGFloat(MAXFLOAT)),
                                  options: .usesLineFragmentOrigin,
                                  attributes: [NSAttributedString.Key.font : font],
                                  context: nil).height
    }
    
    
    /// 校验图片路径是否需要被替换  图片尺寸裁剪
    /// - Parameter size: 200x200
    public func checkImgURLWithSize(_ size:String) -> String {
       
        var oriUrlStr = self
        
        if oriUrlStr.contains("jtmm.com") || oriUrlStr.contains("?t=pro") {
            
            oriUrlStr = oriUrlStr.replacingOccurrences(of: "?t=pro", with: "")
            
            guard let backRange = oriUrlStr.range(of: ".",
                                                  options: .backwards,
                                                  range: nil,
                                                  locale: nil) else {return oriUrlStr}
            
           let imgUrl = oriUrlStr.replacingCharacters(in: backRange, with: "_\(size).")
            
           return imgUrl
        }
        
       return oriUrlStr
    }

    /**时间戳转化日期化字符串
     举个栗子: let timeStr = "1546598856000".timeFromInterval1970
     print(timeStr)  打印结果: 2019-01-04 18:47:36*/
    public var timeFromInterval1970:String{
        
        if self.isEmpty{return ""}
        
        guard let time = Double(self) else {return ""}
        
        let second = time/1000.0
        
        let date = Date(timeIntervalSince1970: second)
        
        let format = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return format.string(from: date)
    }
    
    
    public var shortTimeFromInterval1970:String{
        
        if self.isEmpty{return ""}
        
        guard let time = Double(self) else {return ""}
        
        let second = time/1000.0
        
        let date = Date(timeIntervalSince1970: second)
        
        let format = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd"
        
        return format.string(from: date)
    }
    
    //时间轴
    /*
    刚刚（1分钟内）
    XX分钟前（1小时内）
    XX小时前（当天）
    昨天XX：XX（昨天）
    XX月XX日 XX：XX（当年）
    XXXX年XX月XX日 XX：XX（去年及更早）*/
    public var timeAxis:String {
        
        let oldF = DateFormatter()
                
        oldF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let oldDate = oldF.date(from: self) else {return ""}
         
        let timeDiff = Date().timeIntervalSince(oldDate)
        
        if timeDiff/60 < 1 {

        return "刚刚"
        }
        
        let mins = Int(timeDiff / 60)
        
        if mins < 60 {
        
        return "\(mins)分钟前"
        }
        
         let calendar = Calendar.current
         
         let oldCalendar = calendar.component(Calendar.Component.year, from: oldDate)
         
         let nowCalendar = calendar.component(Calendar.Component.year, from: Date())
        
//         let isYear = (oldCalendar.years == nowCalendar.years)
        
//         if isYear{
//
//             let isToday = calendar.isDateInToday(oldDate)
//
//             let isYesterday = calendar.isDateInYesterday(oldDate)
//
//             if isToday {
//
//               let hours = Int(timeDiff / 3600)
//
//               return "\(hours)小时前"
//
//             }else if isYesterday {
//
//               let yesterdayF = DateFormatter()
//
//               yesterdayF.dateFormat = "HH:mm"
//
//               return "昨天" + yesterdayF.string(from: oldDate)
//
//             }else{
//
//             let thisYearF = DateFormatter()
//
//              thisYearF.dateFormat = "MM月dd日 HH:mm"
//
//              return thisYearF.string(from: oldDate)
//             }
//
//         }else{
             
             let oldYearF = DateFormatter()
                     
              oldYearF.dateFormat = "yyyy年MM月dd日 HH:mm"
              
             return oldYearF.string(from: oldDate)
//         }
        
    }
    
    /// url字符串转字典
    ///
    /// - Returns: [String: Any]
    public func getURLStringParams() -> [String: Any]? {
        var dict:[String: Any] = [:]
        if let  urlComponents = NSURLComponents.init(string: self) {
            
            urlComponents.queryItems?.forEach({ (queryItem) in
               
                var value = ""
                if let  tempValue = queryItem.value?.removingPercentEncoding {
                    value = tempValue
                }else {
                    value = queryItem.value ?? ""
                }
                if value.contains("://") && queryItem.name != "thumImageUrl"{
                    if let tempDict =  value.getURLStringParams() {
                        var resDict:[String: Any] = [:]
                        resDict[queryItem.name] = value
                        resDict.merge(tempDict) { (resDictValue, tempValue) -> Any in
                            return tempValue
                        }
                        dict[queryItem.name] = resDict
                    }else {
                        dict[queryItem.name] = [queryItem.name:value]
                    }
                }else {
                    dict[queryItem.name] = value
                }
            })
            return dict
        }
        return nil
    }
    
    //从后台跳转路径中截取 skuid和itemid
    public func checkOutSkuIDItemID() -> (itmeID:String,skuID:String)? {
        
        let pattern = "id=(\\d+).*?skid=(\\d+)"
        
        guard let regular = try? NSRegularExpression(pattern: pattern, options:[]) else {return nil}
        
        guard let result = regular.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) else {return nil}
        
        let range1 = result.range(at: 1)
        
        let range2 = result.range(at: 2)
        
        let itemID = (self as NSString).substring(with: range1)
        
        let skuID = (self as NSString).substring(with: range2)
        
        return (itemID,skuID)
    }

    /// url字符串转字典
    ///
    /// - Returns: [String: Any]
    public func urlStringtoParams() -> [String: Any] {
        // 1 保存参数
        var url_array = [""]
        // 2 内容中是否存在?或者//
        if self.contains("?") {
            url_array = self.components(separatedBy:"?")
        }else{
            url_array = self.components(separatedBy: "//")
        }
        // 3 多个参数，分割参数
        let urlComponents = url_array[1].components(separatedBy: "&")
        // 4 保存返回值
        var params = [String: Any]()
        // 5 遍历参数
        for keyValuePair in urlComponents {
            // 5.1 分割参数 生成Key/Value
            let pairComponents = keyValuePair.components(separatedBy:"=")
            // 5.2 获取数组首元素作为key
            let key = pairComponents.first?.removingPercentEncoding
            // 5.3 获取数组末元素作为value
            let value = pairComponents.last?.removingPercentEncoding
            // 5.4 判断参数是否是数组
            if let key = key, let value = value {
                // 5.5 已存在的值，生成数组
                if let existValue = params[key] {
                    // 5.8 如果是已经生成的数组
                    if var existValue = existValue as? [Any] {
                        // 5.9 把新的值添加到已经生成的数组中去
                        existValue.append(value)
                        params[key] = existValue
                    } else {
                        // 5.7 已存在的值，先将他生成数组
                        params[key] = [existValue, value]
                    }
                } else {
                    // 5.6 参数是非数组
                    params[key] = value
                }
            }
        }
        return params
    }
    
    //订单拼接前面的券-图文混排
    public func appendImg(_ imgName:String,_ strColor:UIColor = RGBColor(51,51,51),_ width:CGFloat,_ height:CGFloat = 13.S) -> NSAttributedString {
        
        let attrStr = NSAttributedString(string: " "+self, attributes: [.foregroundColor : strColor])
        
        guard let img = UIImage(named: imgName) else {return attrStr}
        
        let attachment = NSTextAttachment()
        
        attachment.image = img
        
        //img.size.width.S  img.size.height.S
        attachment.bounds = CGRect(x: 0, y: -2.S, width: width, height: height)
        
        let attrImage = NSAttributedString(attachment: attachment)
        
        let attrMub = NSMutableAttributedString()
        
        attrMub.append(attrImage)
        
        attrMub.append(attrStr)
        
        let para = NSMutableParagraphStyle()
        
        para.lineSpacing = 3.S
        
        attrMub.addAttributes([.paragraphStyle:para], range: NSRange(location: 0, length: attrMub.length))
        
        return attrMub
        
    }
    
    //优惠券拼接前面的券-图文混排
    public func appendImg(_ imgName:String,_ strColor:UIColor = RGBColor(51,51,51)) -> NSAttributedString {
        
        let attrStr = NSAttributedString(string: " "+self, attributes: [.foregroundColor : strColor])
        
        guard let img = UIImage(named: imgName) else {return attrStr}
        
        let attachment = NSTextAttachment()
        
        attachment.image = img
        
        //img.size.width.S  img.size.height.S
        attachment.bounds = CGRect(x: 0, y: -4.S, width: 53.S, height: 16.S)
        
        let attrImage = NSAttributedString(attachment: attachment)
        
        let attrMub = NSMutableAttributedString()
        
        attrMub.append(attrImage)
        
        attrMub.append(attrStr)
        
        let para = NSMutableParagraphStyle()
        
        para.lineSpacing = 3.S
        
        attrMub.addAttributes([.paragraphStyle:para], range: NSRange(location: 0, length: attrMub.length))
        
        return attrMub
        
    }
    
    //优惠券邀请人拼接头像-图文混排
    public func appendHeadImg( _ img:UIImage?, _ defaultImgStr:String = "default_heard_coupon", _ strColor:UIColor = RGBColor(51,51,51)) -> NSAttributedString {
        
        let attrStr = NSAttributedString(string: " "+self, attributes: [.foregroundColor : strColor])
        
        guard let img = img else { return attrStr }
        
        let attachment = NSTextAttachment()
        
        attachment.image = img
        
        //img.size.width.S  img.size.height.S
        attachment.bounds = CGRect(x: 0, y: -4.S, width: 20.S, height: 20.S)
        
        let attrImage = NSAttributedString(attachment: attachment)
        
        let attrMub = NSMutableAttributedString()
        
        attrMub.append(attrImage)
        
        attrMub.append(attrStr)
        
        let para = NSMutableParagraphStyle()
        
        para.lineSpacing = 3.S
        
        para.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        para.alignment = .center
        
        attrMub.addAttributes([.paragraphStyle:para], range: NSRange(location: 0, length: attrMub.length))
        
        return attrMub
        
    }
    
    //优惠券邀请人拼接头像 前后都有文字 -图文混排
    public func appendFrontHeadImg(_ frontStr :String, _ img:UIImage?, _ defaultImgStr:String = "default_heard_coupon", _ strColor:UIColor = RGBColor(51,51,51)) -> NSAttributedString {
        
        let attrFrontStr = NSAttributedString(string:frontStr + " ", attributes: [.foregroundColor : strColor])
        
        let attrStr = NSAttributedString(string: " "+self, attributes: [.foregroundColor : strColor])
        
        guard let img = img else { return attrStr }
        
        let attachment = NSTextAttachment()
        
        attachment.image = img
        
        //img.size.width.S  img.size.height.S
        attachment.bounds = CGRect(x: 0, y: -4.S, width: 20.S, height: 20.S)
        
        let attrImage = NSAttributedString(attachment: attachment)
        
        let attrMub = NSMutableAttributedString()
        
        attrMub.append(attrFrontStr)
        
        attrMub.append(attrImage)
        
        attrMub.append(attrStr)
        
        let para = NSMutableParagraphStyle()
        
        para.lineSpacing = 3.S
        
        attrMub.addAttributes([.paragraphStyle:para], range: NSRange(location: 0, length: attrMub.length))
        
        return attrMub
        
    }
}


