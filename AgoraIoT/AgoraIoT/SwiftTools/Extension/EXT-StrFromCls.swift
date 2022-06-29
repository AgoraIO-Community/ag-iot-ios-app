//
//  EXT-StrFromCls.swift
//  TDStarMall
//
//  Created by 邓文磊 on 2019/5/17.
//  Copyright © 2019 tiens. All rights reserved.
//

import Foundation

extension NSObject {
    //类方法
    public class func stringFromClass() -> String {
        let clsArr = NSStringFromClass(self.classForCoder()).components(separatedBy: ".")
        if clsArr.count > 1 {
            return clsArr[1]
        } else {
            return clsArr[0]
        }
    }
    
    //对象方法
    public func objStringFromClass() -> String {
        let clsArr = NSStringFromClass(self.classForCoder).components(separatedBy: ".")
        if clsArr.count > 1 {
            return clsArr[1]
        } else {
            return clsArr[0]
        }
    }
    
}
