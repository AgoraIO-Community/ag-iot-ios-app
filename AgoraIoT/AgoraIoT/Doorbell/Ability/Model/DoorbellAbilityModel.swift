//
//  DoorbellAbilityModel.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit

class DoorbellAbilityModel: AGBaseModel {
    
    var abilityIcon = "" //功能图片
    
    var abilitySecectIcon = "" //功能选中图片
    
    var abilityName = "" //功能名称
    
    var abilityId : Int = 0 //功能code
    
    var abilityValue = 0 //当前值
    
    var lastValue = 0 //上次设置的值
    
    var selectIndex = 0 //选中索引，适用于弹框多选列表选中
    
    var isSelected : Bool = false //是否选中
    
}
