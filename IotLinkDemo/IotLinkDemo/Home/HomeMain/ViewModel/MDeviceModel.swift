//
//  MDeviceModel.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/26.
//

import UIKit
import AgoraIotLink

class MDeviceModel: AGBaseModel {
    
    var connectObj : IConnectionObj?
    
    var peerNodeId = "" //对端设备Id
    
    var isSelected : Bool = false //是否选中
    
    var canEdit : Bool = false //是否可编辑
    
}

class MStreamModel: AGBaseModel {
    
    var connectObj : IConnectionObj?
    
    var streamId : StreamId = .BROADCAST_STREAM_1 //对端streamId
    
    var isSubcribedAV : Bool = false
    
}
