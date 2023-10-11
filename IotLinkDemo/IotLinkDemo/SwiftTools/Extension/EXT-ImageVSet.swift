
//
//  EXT-ImageVSet.swift
//  DouYu
//
//  Created by 邓文磊 on 2018/7/10.
//  Copyright © 2018年 DWL. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView{
    
    func setImageWithURL(_ urlStr: String,placeH: Placeholder? = nil,option: KingfisherOptionsInfo? = nil){
       //option 例子 [.forceRefresh]
        
        let ratio = bounds.width / bounds.height
        //基本上都是宽高相等,或者宽大于高
        var img:UIImage?
        
        if placeH != nil {
            //如果外界有占位图,则用外界的
            img = placeH as? UIImage
            
        }else{
          //如果外界没有占位图,则自己创建
            if ratio < 1.3 {
                //正方形的图
                img = UIImage(named: "ph160")
                
            }else{
                //长方形的图
                img = UIImage(named: "ph170125")
            }
        }
       
        kf.setImage(with: URL(string: urlStr), placeholder: img, options: option, progressBlock: nil, completionHandler: nil)
        
    }
}

//MARK: - UIButton
extension UIButton {
    
    public func setButton(url:String,placeholder:String){
        let placegholderImage = UIImage(named: placeholder)
//        if url.count > 0 {
//            let urlImage:ImageResource = ImageResource(downloadURL: URL(string: url)!)
//            self.kf.setImage(with: urlImage as! Resource, for: .normal, placeholder: placegholderImage)
//        } else {
//            self.setImage(placegholderImage, for: .normal)
//        }
    }
}
