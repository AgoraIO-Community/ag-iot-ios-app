//
//  AgoraIotManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/21.
//

import UIKit
import AgoraIotLink

class AgoraIotManager: NSObject {

    public static let shared = AgoraIotManager()
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    func updateToken(deviceToken: Data){
        //todo:
//        sdk?.notificationMgr.updateToken(deviceToken)
    }
}
