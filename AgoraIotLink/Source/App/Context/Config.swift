//
//  Cfg.swift
//  demo
//
//  Created by ADMIN on 2022/1/28.
//

import Foundation

class Config {
    
    /*
     2.0新增参数
     */
    var masterAppId : String = ""
    
    /*
     2.1新增参数
     */
    var mLocalNodeId : String = ""  // 本地 NodeId
    var mAuthToken : String = ""    // 认证的Token

    /*
     0, Output all logs
     1, Output warnings and errors
     2  Output errors only
     */
    var ntfLogLevel:Int = 0 //
    var mqttLogLevel:Int = 1
    
    var logFilePath : String? = nil
    
    let calloutTimeOut:Double = 15 //呼叫超时时间
    let inComingTimeOut:Double = 15 //来电超时时间
    
    var cRegion:Int = 1
    
    var maxRtmPackage = 1024*1
    
    let counter = ThreadSafeCounter()
    
    
    static let kAuthorizationBase64Key = "kAuthorizationBase64Key"
    // 客户 ID
    var customerKey = ""
    // 客户密钥
    var customerSecret = ""
}
