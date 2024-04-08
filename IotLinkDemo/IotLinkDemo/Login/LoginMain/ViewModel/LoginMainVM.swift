//
//  LoginMainVM.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/19.
//

import UIKit
import AgoraIotLink

//class Config{
//    public static let DEBUG = true
//    public static let productKey = "EJ5IJK4m7Fl4EJI"
//}

class LoginMainVM: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var password:String = ""

}
