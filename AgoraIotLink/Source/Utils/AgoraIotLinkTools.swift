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
        
     //   debugPrint(Bundle.init(for: TDProfitTools.self).path(forResource: "AgoraIotLink", ofType: "bundle", inDirectory: nil))
        
//        return Bundle.init(path: Bundle.init(for: AgoraIotLinkTools.self).path(forResource: "AgoraIotLink", ofType: "bundle", inDirectory: nil)!)
        guard let resourcePath = Bundle(for: AgoraIotLinkTools.self).path(forResource: "AgoraIotLink", ofType: "bundle") else {
               log.e("loadBundle:无法找到资源包")
               return nil
         }
        return Bundle(path: resourcePath)
        
    }
}
