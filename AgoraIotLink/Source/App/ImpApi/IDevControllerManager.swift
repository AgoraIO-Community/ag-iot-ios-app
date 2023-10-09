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
        
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:String = "ptz_ctrl"
        let payloadParam = ["action": action, "direction": direction, "speed": speed] as [String : Any]
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId, "param": payloadParam] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
    
    }
    
    func sendCmdPtzReset(cmdListener: @escaping (Int, String) -> Void) {//云台校准
        
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:String = "ptz_reset"
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
        
    }
    
    func sendCmdPtzCtrl(cmdListener: @escaping (Int, String) -> Void) {//SD卡格式化
        
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:String = "sd_format"
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
 
        
    }
    
    func sendCmdDevReset(cmdListener: @escaping (Int, String) -> Void) {//设备重启
        let curSequenceId : UInt32 = getSequenceId()
        
        let commanId:String = "restart"
        let paramDic = ["sequenceId": curSequenceId, "commandId": commanId] as [String : Any]
        sendGeneralData(paramDic, curSequenceId,cmdListener)
    }
    
    func sendCmdCustomize(customizeData:String, cmdListener: @escaping (_ errCode:Int,_ result:String) -> Void){//发送自定义命令
        
        log.i("sendCmdCustomize:\(customizeData)")
        
        let curTimestamp:UInt32 = getSequenceId()
        let commanId:Int = 3001
        let sendParam = String.getDictionaryFromJSONString(jsonString: customizeData)
        
        let payloadParam = ["sendData":sendParam] as [String : Any]
        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId, "param": payloadParam] as [String : Any]
        
        sendGeneralDicData(paramDic, curTimestamp) { errCode, resutDic in
            log.i("sendCmdCustomize resutDic:\(resutDic)")
            guard let recvData = resutDic["recvData"] as? String else{
                cmdListener(errCode,"")
                return
            }
            cmdListener(errCode,recvData)
        }
        
    }
    
    
    func sendGeneralDicData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, Dictionary<String, Any>) -> Void){
        
        guard let peer =  rtm.curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
        rtm.sendRawMessageDic(sequenceId: "\(sequenceId)", toPeer: peer, data: data, description: "\(sequenceId)",cb: cmdListener)
    }
    
    func sendGeneralData(_ paramDic:[String:Any],_ sequenceId:UInt32,_ cmdListener: @escaping (Int, String) -> Void){
        
        guard let peer =  rtm.curSession?.peerVirtualNumber else{
            log.i("peerVirtualNumber is nil")
            return
        }
        
        let jsonString = paramDic.convertDictionaryToJSONString()
        let data:Data = jsonString.data(using: .utf8) ?? Data()
        rtm.sendRawMessage(sequenceId: "\(sequenceId)", toPeer: peer, data: data, description: "\(sequenceId)",cb: cmdListener)
    }
  
    func getSequenceId()->UInt32{
        
        let curSequenceId : UInt32 = app.config.counter.increment()
        return curSequenceId
    }
}
