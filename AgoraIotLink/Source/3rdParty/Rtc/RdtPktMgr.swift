//
//  RdtPktMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2024/4/7.
//

import Foundation

public enum PktType : Int{
    case pktStart
    case pktContentData
    case pktEnd
}

class RdtPktMgr {
    
    class func handelPktData(_ data : Data) {
        
    }
    
    class func getPktType(_ receiceData : Data)->PktType?{
        guard receiceData.count > 4 else { return nil }
        let cmdType :Int = Int(receiceData[3])
        if cmdType == 1 {
            return .pktStart
        }else if cmdType == 2 {
            return .pktContentData
        }else if cmdType == 3 {
            return .pktEnd
        }
        log.i("getPktType:\(cmdType)")
        return nil
    }
    
    
    
}
