//
//  RdtPktMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2024/4/7.
//

import Foundation


/*
 * @brief 数据传输状态机
 */
@objc public enum RdtChannelState:Int {
    case closed                // 通道关闭
    case opened                // 通道已打开
    case unknown               // 未知
}

/*
 * @brief 数据传输状态机
 */
@objc public enum TransferFileState:Int {
    case ideal                 // 空闲
    case transfering           // 正在传输
}

public enum PktType : Int{
    case pktStart
    case pktContentData
    case pktEnd
}

class RdtPktMgr {
    
    class func handelPktData(_ data : Data) {
        
    }
    
    class func getPktType(_ receiceData : Data)->PktType?{
        guard receiceData.count > 13 else { return nil }
        let cmdType :Int = Int(receiceData[12])
        log.i("getPktType:\(cmdType)")
        if cmdType == 1 {
            return .pktStart
        }else if cmdType == 2 {
            return .pktContentData
        }else if cmdType == 3 {
            return .pktEnd
        }
        return nil
    }
    
    class func getPktEof(_ receiceData : Data)->Bool?{
        guard receiceData.count > 14 else { return nil }
        let eofValue :Int = Int(receiceData[13])
        log.i("getPktEof:\(eofValue)")
        if eofValue == 0 {
            return false
        }else if eofValue == 1 {
            return true
        }
        return nil
    }
    
    class func configRdtData(_ parmStr: String)->Data?{
        
        // 第5位的索引
        let insertionIndex = 4

        // 将字符串转换为字节类型数组
        if let data = parmStr.data(using: .utf8) {
            
            // 创建目标字节数组
            var targetArray = [UInt8](repeating: 0, count: insertionIndex + data.count + 1)

            // 将目标数组的第1和第2两个字节都设置为 0x01
            targetArray[0] = UInt8(0x01)
            targetArray[1] = UInt8(0x01)
            
            // 获取 data 的字节长度
            let dataLength = data.count
            let byteDataLen = UInt16(dataLength)
            // 将 data 的字节长度按小端写入 targetArray 的第3和第4位
            targetArray[2] =  UInt8((byteDataLen & 0xFF))
            targetArray[3] =  UInt8(((byteDataLen >> 8) & 0xFF))
            // 将字符串的字节内容复制到目标字节数组中的指定位置
            for (index, byte) in data.enumerated() {
                if insertionIndex + index < targetArray.count {
                    targetArray[insertionIndex + index] = byte
                } else {
                    break // 如果超出目标数组长度则跳出循环
                }
            }
            targetArray[4+dataLength] = UInt8(0x00)
            
            
            let retData = Data(targetArray)
            
            return retData

        } else {
            print("Failed to convert string to bytes.")
        }
        
        return nil
    }
    
    
    
}
