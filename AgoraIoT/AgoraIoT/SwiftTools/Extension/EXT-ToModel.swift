//
//  EXT-ToModel.swift
//  TDStarMall
//
//  Created by 邓文磊 on 2019/4/17.
//  Copyright © 2019 tiens. All rights reserved.
//

import Foundation

extension NSObject {
    
    convenience init(dict:[String:Any]) {
    
        self.init()
        
        setValuesForKeys(dict)
        
    }
}

extension NSObject {
    public func convertDictionaryToJSONString(dict:NSDictionary?)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }
    
    public func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            if let dictresult = dict as? NSDictionary{
                return dictresult
            }
            return NSDictionary()
        }
        return NSDictionary()
    }
}
