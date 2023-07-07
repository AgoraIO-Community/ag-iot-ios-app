//
//  IDevControllerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation


class IDevControllerManager : IDevControllerMgr{

    private var app:Application
    private var curSessionId:String //当前sessionId
    private var rtm:RtmEngine
    
    init(app:Application,rtm:RtmEngine,sessionId:String){
        self.app = app
        self.rtm = rtm
        self.curSessionId = sessionId
    }
    
    deinit {
        log.i("IDevControllerManager 销毁了")
    }
    
    func sendCmdPtzCtrl(action: Int, direction: Int, speed: Int, cmdListener: @escaping (Int, String) -> Void) {//云台控制
        
        let curSequenceId : UInt32 = app.config.curSequenceId
        app.config.curSequenceId = app.config.curSequenceId+1
        
        let commanId:Int = 1001
        let payloadParam = ["action": action, "direction": direction, "speed": speed] as [String : Any]
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
    
    }
    
    func sendCmdPtzReset(cmdListener: @escaping (Int, String) -> Void) {//云台校准
        
        let curSequenceId : UInt32 = app.config.curSequenceId
        app.config.curSequenceId = app.config.curSequenceId+1
        
        let commanId:Int = 1002
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
        
    }
    
    func sendCmdPtzCtrl(cmdListener: @escaping (Int, String) -> Void) {//SD卡格式化
        
        let curSequenceId : UInt32 = app.config.curSequenceId
        app.config.curSequenceId = app.config.curSequenceId+1
        
        let commanId:Int = 2001
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
 
        
    }
    
    func sendCmdDevReset(cmdListener: @escaping (Int, String) -> Void) {
        let curSequenceId : UInt32 = app.config.curSequenceId
        app.config.curSequenceId = app.config.curSequenceId+1
        
        let commanId:Int = 3002
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
    }
    
    func sendGeneralData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, String) -> Void){
        
        guard let peer =  rtm.curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
//        rtm.sendStringMessage(sequenceId: "\(sequenceId)", toPeer: peer, message: jsonString, cb: cmdListener)
        rtm.sendRawMessage(sequenceId: "\(sequenceId)", toPeer: peer, data: data, description: "\(sequenceId)",cb: cmdListener)
    }
  
}
