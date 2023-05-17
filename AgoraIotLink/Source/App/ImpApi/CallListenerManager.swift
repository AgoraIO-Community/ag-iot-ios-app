//
//  CallListenerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/25.
//

import UIKit

class CallListenerManager: NSObject {

    static let sharedInstance = CallListenerManager()
    
//    var callListener:CallStateListener?
    var callObjectArr = [CallStateListener]()
    
    func startCall(actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?){

          let callLister = CallStateListener(actionAck: actionAck, memberState: memberState)
          callObjectArr.append(callLister)
          callLister.interCallAct = { [weak self] ack in
              if (ack == .RemoteHangup){
                  self?.hangUp()
              }
          }
    }
    
    func callRequest(_ suc:Bool){
        guard callObjectArr.count > 0 else{return}
        let callListen = callObjectArr[0]
        callListen.callRequest(suc)
    }
    
    func hangUp(){
        guard callObjectArr.count > 0 else{return}
        let callListen = callObjectArr[0]
        callListen.hangUp { isSuc, msg in
            self.callObjectArr.removeAll()
        }
        log.i("CallListenerManager hangUp 调用了")
    }
    
    func incomeCall(incoming: @escaping (String,String, ActionAck) -> Void,memberState:((MemberState,[UInt])->Void)?){
        let callLister = CallStateListener(incoming: incoming,memberState: memberState)
        callObjectArr.append(callLister)
    }
    
    func acceptCall(){
        guard callObjectArr.count > 0 else{return}
        let callListen = callObjectArr[0]
        callListen.inComeDealTime()
    }
    
    func isTaking()->Bool{
        if callObjectArr.count > 0{
            log.i("taking coming___")
            return true
        }
        return false
    }
}
