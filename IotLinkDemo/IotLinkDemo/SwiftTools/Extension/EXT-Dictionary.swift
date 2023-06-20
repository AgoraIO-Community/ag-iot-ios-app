//
//  EXT-Dictionary.swift
//  TDStarMall
//
//  Created by 邓文磊 on 2019/5/17.
//  Copyright © 2019 tiens. All rights reserved.
//

import Foundation

extension Dictionary{
    
    /**
     不知道模型里的属性写成什么类型,请用字典调用此方法
     */
    
    public var description: Void{
        
        var str = "{\n"
        
        for (key,value) in self {
            
            guard let valueType = object_getClass(value) else{continue}
            
            str = str + "\t\(key) = \(value) : \(valueType)\n"
            
        }
        
        str += "}\n"
        
        print(str)
    }
    
    
    
//    func getObjPropertyClassType() {
//
//        var str = "{\n"
//
//        for (key,value) in self {
//
////            if let subValue = value as? [String:Any] {
////
////                subValue.getObjPropertyClassType()
////            }
//
//            guard let valueType = object_getClass(value) else{continue}
//
//            str = str + "\t\(key) = \(value) : \(valueType)\n"
//
//        }
//
//        str += "}\n"
//
//        print(str)
//    }
//
}

extension Dictionary{
    
    public func convertDictionaryToJSONString()->String {
        
        var jsonStr : String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonStr = jsonString
                print("convertDictionaryToJSONString:\(jsonString) ")
            }
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
        }
        return jsonStr
        
    }
    
}

//
//extension Array {
//    
//    func getArrayObjPropertyClassType() {
//        
//        self.forEach { (element) in
//            
//            if let dict = element as? [String:Any] {
//                
//                dict.getObjPropertyClassType()
//            }
//        }
//    }
//    
//}
