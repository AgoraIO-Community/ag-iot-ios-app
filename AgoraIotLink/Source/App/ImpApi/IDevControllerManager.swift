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
    
    func sendCmdPtzCtrl(action: Int, direction: Int, speed: Int, cmdListener: @escaping (Int, String) -> Void) {
        
        rtm.sendStringMessage(toPeer: "", message: "test msg") { code, msg in
            
        }
    }
    
    func sendCmdPtzReset(cmdListener: @escaping (Int, String) -> Void) {
        
    }
    
    func sendCmdPtzCtrl(cmdListener: @escaping (Int, String) -> Void) {
        
    }
  
}
