//
//  CallListenerManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/25.
//

import UIKit

class CallListenerManager: NSObject {

    static let sharedInstance = CallListenerManager()
    
    var callListener:CallStateListener?
    
    func startCall(actionAck:@escaping(ActionAck)->Void,memberState:((MemberState,[UInt])->Void)?){
        let callLister = CallStateListener(actionAck: actionAck, memberState: memberState)
        callListener = callLister
    }
    
    func callRequest(_ suc:Bool){
        callListener?.callRequest(suc)
    }
    
    func hangUp(){
        callListener?.hangUp()
    }
    
    func incomeCall(incoming: @escaping (String,String, ActionAck) -> Void){
        let callLister = CallStateListener(incoming: incoming)
        callListener = callLister
    }
    
    func acceptCall(){
        callListener?.endTime()
    }
}
