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
    
    static func getDictionaryFromJSONString(data:[UInt8]) -> Dictionary<String, Any> {
        if let string = String(bytes: data, encoding: .utf8) {
            // 将字符串转化为字典
            if let dictionary = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: []) as? [String: Any] {
                return dictionary
            }else{
                return  Dictionary<String, Any>()
            }
        }else{
            return  Dictionary<String, Any>()
        }
    }
    
    static func getDictionaryFromData(data:Data) -> Dictionary<String, Any> {
        if let string = String(data: data, encoding: .utf8) {
            // 将字符串转化为字典
            if let dictionary = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: []) as? [String: Any] {
                return dictionary
            }else{
                return  Dictionary<String, Any>()
            }
        }else{
            return  Dictionary<String, Any>()
        }
    }
}

extension Dictionary{
    
    public func convertDictionaryToJSONString()->String {
        
        var jsonStr : String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonStr = jsonString
                log.i("convertDictionaryToJSONString:\(jsonString) ")
            }
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
        }
        return jsonStr
        
    }
    
}
