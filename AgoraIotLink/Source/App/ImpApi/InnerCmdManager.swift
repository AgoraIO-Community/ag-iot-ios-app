//
//  InnerCmdManager.swift
//  AgoraIotLink
//
//  Created by admin on 2024/2/26.
//

import UIKit

struct CommandList {
    static let command_ConnectCompelete  = 1001
    static let command_Disconnect        = 1002
    static let command_PeerAct           = 1003
    static let command_EnableAV          = 1004
}

class InnerCmdManager: NSObject {

    private var app:IotLibrary
    private var curConnectId:String //当前connectId
    private var rtm:RtmEngine
    
    init(app:IotLibrary,rtm:RtmEngine,connectId:String){
        self.app = app
        self.rtm = rtm
        self.curConnectId = connectId
    }
    
    deinit {
        log.i("InnerCmdManager 销毁了")
    }
    
    func getConnectSession()->CallSession?{
        return ConnectListenerManager.sharedInstance.getCurrentCallSession(curConnectId)
    }
    
//    func sendCmdCreatConnect(cmdListener: @escaping (Int, String) -> Void) {//创建链接
//        
//        guard let peerId =  rtm.curSession?.peerVirtualNumber else{
//            log.i("peerVirtualNumber is nil")
//            return
//        }
//        
//        guard let localNodeId =  rtm.curSession?.localNodeId else{
//            log.i("localNodeId is nil")
//            return
//        }
//        
//        let curSequenceId : UInt32 = getSequenceId()
//        
//        let commanId:Int = CommandList.command_Connect
//        let payloadParam = ["callerNodeId": localNodeId, "calleeNodeId": peerId] as [String : Any]
//        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId, "param": payloadParam] as [String : Any]
//        sendGeneralData(paramDic, curSequenceId,cmdListener)
//    
//    }
    
    func sendCmdDisConnect(cmdListener: @escaping (Int, String) -> Void) {//销毁链接
        
        guard let callSession =  getConnectSession() else{
            log.i("callSession is nil")
            return
        }
        
        guard let localNodeId =  rtm.curSession?.localNodeId else{
            log.i("localNodeId is nil")
            return
        }
        
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:Int = CommandList.command_Disconnect
        let payloadParam = ["callerNodeId": localNodeId, "calleeNodeId": callSession.peerNodeId] as [String : Any]
        let paramDic = ["traceId": callSession.traceId,"sequenceId": curSequenceId, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
    
    }
    
    //peerUid:要预览的对端Uid,  subscribe: 0–表示不预览音频；1--表示要预览音频
    func sendCmdPreviewAV(peerUid: UInt,subscribe: Int,attachMsg: String,cmdListener: @escaping (Int, String) -> Void) {
        
        guard let callSession =  getConnectSession() else{
            log.i("callSession is nil")
            return
        }
        
        guard let localNodeId =  rtm.curSession?.localNodeId else{
            log.i("localNodeId is nil")
            return
        }
        
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:Int = CommandList.command_EnableAV
        let payloadParam = ["callerNodeId": localNodeId, "calleeNodeId": callSession.peerNodeId, "peerUid": peerUid, "subscribe": subscribe,"attachMsg": attachMsg ] as [String : Any]
        let paramDic = ["traceId": callSession.traceId,"sequenceId": curSequenceId, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
    
    }
    
}


extension InnerCmdManager{
    
    func sendGeneralData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, String) -> Void){
        
//        guard let peer =  rtm.curSession?.peerVirtualNumber else{
//            log.i("peerVirtualNumber is nil")
//            return
//        }
        guard let callSession =  getConnectSession() else{
            log.i("callSession is nil")
            return
        }

        let jsonString = paramDic.convertDictionaryToJSONString()
        guard let data = configInterlData(jsonString) else {
            log.e("sendGeneralData: configInterlData fail")
            return
        }
        
        let cmdBack = { ( sequenceId:UInt32,code :Int, msg:String) in
            cmdListener(code,msg)
        }
        rtm.sendRawGenerlMessage(sequenceId: (sequenceId), toPeer: callSession.peerNodeId, data: data, description: "\(sequenceId)", cb: cmdBack)
    }
  
    func getSequenceId()->UInt32{
        
        let curSequenceId : UInt32 = app.config.counter.increment()
        return curSequenceId
    }
    
    func configInterlData(_ parmStr: String)->Data?{
        
        // 第5位的索引
        let insertionIndex = 4

        // 将字符串转换为字节类型数组
        if let data = parmStr.data(using: .utf8) {
            
            // 创建目标字节数组
            var targetArray = [UInt8](repeating: 0, count: insertionIndex + data.count)

            // 将目标数组的第1和第2两个字节都设置为 0x01
            targetArray[0] = UInt8(0x01)
            targetArray[1] = UInt8(0x01)
            
            // 获取 data 的字节长度
            let dataLength = data.count
            let byteDataLength = UInt16(dataLength)
            // 将 data 的字节长度按大端写入 targetArray 的第3和第4位
            targetArray[2] = UInt8(((byteDataLength >> 8) & 0xFF))
            targetArray[3] = UInt8((byteDataLength & 0xFF))

            // 将字符串的字节内容复制到目标字节数组中的指定位置
            for (index, byte) in data.enumerated() {
                if insertionIndex + index < targetArray.count {
                    targetArray[insertionIndex + index] = byte
                } else {
                    break // 如果超出目标数组长度则跳出循环
                }
            }
            
            
            let retData = Data(targetArray)
            
//            log.i("Target array after insertion:\(targetArray) :\(dataLength)" )
            
            return retData

        } else {
            print("Failed to convert string to bytes.")
        }
        
        return nil
    }
}
