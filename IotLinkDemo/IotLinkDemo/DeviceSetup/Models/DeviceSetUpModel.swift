//
//  DeviceSetUpModel.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/23.
//

import UIKit

class DeviceSetUpModel: NSObject {
    
    var funcName = "" //功能名称
    
    var funcId : Int = 0 //功能code
    
    var funcBoolValue = false //当前值
    
    var lastFuncBoolValue = false //上次设置的值
}
