//
//  Extension.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/15.
//

import Foundation

extension String{
        func subStringFrom(_ index: Int) -> String {
             let theIndex = self.index(self.endIndex, offsetBy: index - self.count)
             return String(self[theIndex..<endIndex])
         }
    
         //从0索引处开始查找是否包含指定的字符串，返回Int类型的索引
         //返回第一次出现的指定子字符串在此字符串中的索引
         func findFirst(_ sub:String)->Int {
             var pos = -1
             if let range = range(of:sub, options: .literal ) {
                 if !range.isEmpty {
                     pos = self.distance(from:startIndex, to:range.lowerBound)
                 }
             }
             return pos
         }
    
         //从0索引处开始查找是否包含指定的字符串，返回Int类型的索引
         //返回最后出现的指定子字符串在此字符串中的索引
         func findLast(_ sub:String)->Int {
             var pos = -1
             if let range = range(of:sub, options: .backwards ) {
                 if !range.isEmpty {
                     pos = self.distance(from:startIndex, to:range.lowerBound)
                 }
             }
             return pos
         }
}
