//
//  EXT-IBInspectable.swift
//  lianxiSwift
//
//  Created by 邓文磊 on 2018/5/23.
//  Copyright © 2018年 HuoYiJia. All rights reserved.
//

import UIKit

extension UIView{
    
    @IBInspectable public var borderColor:UIColor{
        
        get{
           return UIColor(cgColor: layer.borderColor!)
        }
        set{
          layer.borderColor=newValue.cgColor
        }
    }
    
    @IBInspectable public var borderWidth:CGFloat{
        
        get{
            return layer.borderWidth
        }
        set{
            layer.borderWidth=newValue*ScreenZS
        }
    }
    
    @IBInspectable public var cornerRadius:CGFloat{
    
       get{
          return layer.cornerRadius
       }
       set{
        layer.cornerRadius=newValue*ScreenZS
        layer.masksToBounds=true
       }
    }
}
