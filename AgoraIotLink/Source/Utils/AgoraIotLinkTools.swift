//
//  AgoraIotLinkTools.swift
//  AgoraIotLink
//
//  Created by admin on 2023/7/20.
//

import UIKit

class AgoraIotLinkTools: NSObject {
    
    static let shareInstance = AgoraIotLinkTools()
    
    open class func share() -> AgoraIotLinkTools {
        
        return shareInstance
        
    }
    
    open class func loadBundle() -> Bundle? {
        
     //   print(Bundle.init(for: TDProfitTools.self).path(forResource: "AgoraIotLink", ofType: "bundle", inDirectory: nil))
        
        return Bundle.init(path: Bundle.init(for: AgoraIotLinkTools.self).path(forResource: "AgoraIotLink", ofType: "bundle", inDirectory: nil)!)
        
    }
}
