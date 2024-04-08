//
//  RegionToStringMap.swift
//  AgoraIotLink
//
//  Created by admin on 2024/3/26.
//

import Foundation


class RegionToStringMap {
    
    class func getRegionString(_ region: Int) -> String {
        
        var regionString = ""
        switch region {
        case 1:
            regionString = "cn"
            break
        case 2:
            regionString = "na"
            break
        case 3:
            regionString = "ap"
            break
        case 4:
            regionString = "eu"
            break
        default:
            break
        }
        
        return regionString
    }
    
}

