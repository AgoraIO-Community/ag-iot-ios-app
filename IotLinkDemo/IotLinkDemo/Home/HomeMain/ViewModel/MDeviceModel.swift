//
//  MDeviceModel.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/26.
//

import UIKit

class MDeviceModel: AGBaseModel {

    var sessionId = "" //会话Id
    
    var peerNodeId = "" //对端设备Id
    
    var isSelected : Bool = false //是否选中
    
    var canEdit : Bool = false //是否可编辑
    
}
