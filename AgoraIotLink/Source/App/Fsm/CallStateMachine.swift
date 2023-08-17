//
//  CallStateMachine.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/24.
//

import UIKit

@objc protocol CallStateMachineListener : NSObjectProtocol {
    
    @objc func do_LEAVEANDDESTROY()  //srcState:stopAll
     
    @objc func do_CREATEANDENTER()   //srcState:ready
    
 }

enum CallEvent {
    case startCall             // 发起呼叫请求
    case localJoining          // 本地开始加入频道
    case localJoinSuc          // 本地加入频道成功
    case peerOnline            // 对端上线
    case peerOffline           // 对端离线
    case incomingCall          // 来电事件
    case endCall               // 结束通话事件
}

class CallStateMachine: NSObject {
    
    weak var delegate : CallStateMachineListener?
    
    var currentState: CallState = .idle
    
    func handleEvent(_ event: CallEvent) {
        switch currentState {
        case .idle:
            switch event {
            case .startCall:
                currentState = .callRequest
            case .incomingCall:
                currentState = .incoming
                delegate?.do_CREATEANDENTER()
                break
            default:
                break
            }
            
        case .callRequest:
            switch event {
            case .localJoining:
                delegate?.do_CREATEANDENTER()
            case .localJoinSuc:
                currentState = .dialing
            case .endCall:
                currentState = .idle
                break
            default:
                break
            }
            
        case .dialing:
            switch event {
            case .peerOnline:
                currentState = .onCall
            case .endCall:
                currentState = .idle
            default:
                break
            }
            
        case .incoming:
            switch event {
            case .peerOnline:
                currentState = .onCall
            case .endCall:
                currentState = .idle
            default:
                break
            }
            
        case .onCall:
            switch event {
            case .endCall:
                currentState = .idle
            default:
                break
            }
            
        }
    }
    
    deinit {
        delegate = nil
        log.i("CallStateMachine 销毁了")
    }
    
}
