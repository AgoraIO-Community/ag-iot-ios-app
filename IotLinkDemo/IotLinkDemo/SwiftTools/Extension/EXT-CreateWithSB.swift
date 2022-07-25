//
//  EXT-CreateWithSB.swift
//  lianxiSwift
//
//  Created by 邓文磊 on 2018/5/18.
//  Copyright © 2018年 HuoYiJia. All rights reserved.
//

import UIKit

extension UIViewController{

    /// 快速创建sb对象
    /// - Parameters:
    ///   - sbName: sb文件名称
    ///   - isInitial: 是否是箭头指向的控制器
    /// - Returns: 控制器对象
    public class func createVCFromSB(sbName:String?=nil,isInitial:Bool=true) -> UIViewController {
      
        if let sbName=sbName{
            
            if isInitial{
         //sb单独命名,是箭头指向的
        return UIStoryboard(name: sbName, bundle: nil).instantiateInitialViewController()!
                
            }else{
         //sb单独命名,类名加SBID是标记
        let className = NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
        
        return UIStoryboard(name: sbName, bundle: nil).instantiateViewController(withIdentifier: "\(className)SBID")
                
            }
          
        }else{
       //sb名和类名相同,且是箭头指向的
      let className = NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
            
      return UIStoryboard(name: className, bundle: nil).instantiateInitialViewController()!
        }
    
    }
}
