//
//  AGCellData.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/19.
//

import UIKit

protocol AGTitleCellData {
    var title: String {get set}
}

class AGRightImageCellData: AGTitleCellData {
    var title = ""
    var imagUrl: String?
    var image: UIImage?
    
    init(title:String, imagUrl:String? = nil, image:UIImage? = nil) {
        self.title = title
        self.imagUrl = imagUrl
        self.image = image
    }
}

class AGSubtitleCellData: AGTitleCellData {
    var title = ""
    var subtitle = ""
    var showArrow = false
    
    init(title:String, subtitle:String, showArrow:Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.showArrow = showArrow
    }
}
