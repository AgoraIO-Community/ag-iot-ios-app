//
//  IDevControllerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation


class IDevControllerManager : IDevControllerMgr{
    
    
    func sendCmdPtzCtrl(action: Int, direction: Int, speed: Int, cmdListener: @escaping (Int, String) -> Void) {
        
    }
    
    func sendCmdPtzReset(cmdListener: @escaping (Int, String) -> Void) {
        
    }
    
    func sendCmdPtzCtrl(cmdListener: @escaping (Int, String) -> Void) {
        
    }
  
}
