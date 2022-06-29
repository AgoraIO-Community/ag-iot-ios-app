//
//  DeviceInfoCellData.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import Foundation

class DeviceInfoCellData {
    var title = ""
    var subTitle:String?
    
    init(title:String, subTitle:String? = nil) {
        self.title = title
        self.subTitle = subTitle
    }
}
