//
//  EXT-UILabel.swift
//  TDStarMall
//
//  Created by tiens on 2019/8/19.
//  Copyright © 2019 tiens. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    public convenience init(_ fontSize:UIFont,
                            _ color:UIColor,
                            breakMode:NSLineBreakMode? = nil,
                            alignment:NSTextAlignment? = nil) {
        self.init()
        font = fontSize
        textColor = color
        if breakMode != nil { lineBreakMode = breakMode ?? .byCharWrapping}
        if alignment != nil { textAlignment = alignment ?? .natural }
    }
    
    public func setPriceText(text: String, frontFont: CGFloat, behindFont: CGFloat, textColor: UIColor) {
        //分隔字符串
        var lastStr = ""
        var firstStr = ""
        
        if text.contains(".") {
            let range = text.range(of: ".")
            firstStr = String(text.prefix(upTo: range!.lowerBound))
            lastStr = String(text.suffix(from: range!.upperBound))
        }
        
        let attributedStr = NSMutableAttributedString.init(string: text)
        //小数点前面的字体大小
        attributedStr.addAttribute(NSAttributedString.Key.font, value: FontPFRegularSize(frontFont), range: NSRange(location: 0, length: firstStr.count))
        
        //小数点后面的字体大小
        attributedStr.addAttribute(NSAttributedString.Key.font, value: FontPFRegularSize(behindFont), range: NSRange(location: firstStr.count, length: lastStr.count))
        
        //字符串颜色
        attributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSRange(location: 0, length: text.count))
        
        self.attributedText = attributedStr
    }
}
