//
//  StreamIdToUIdMap.swift
//  AgoraIotLink
//
//  Created by admin on 2024/2/28.
//

import Foundation

class StreamIdToUIdMap {
    
    //返回streamId对应的UId
    class func getUId(baseUid:UInt,streamId: UInt) -> UInt {
        if streamId > 9 {
            let tempUId : UInt = mapValue(streamId)
            return baseUid + tempUId
            
        }
        return streamId
    }
    
    class func mapValue(_ value: UInt) -> UInt {
        return (value % 10)
    }
    
    //返回UId对应的streamId
    class func getStreamId(baseUid:UInt,uId: UInt) -> Int {
        if uId > 9 {
            let tempUId : UInt = mapValue(uId)
            return Int(9 + tempUId)
            
        }
        return Int(uId)
    }
}
