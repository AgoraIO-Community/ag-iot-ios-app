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
    case endCall               // 结束通话事件
}

class CallStateMachine: NSObject {
    
    weak var delegate : CallStateMachineListener?
    
    var currentState: ConnectState = .disconnected
    
    func handleEvent(_ event: CallEvent) {
        switch currentState {
        case .disconnected:
            switch event {
            case .startCall:
                currentState = .connectReqing
            default:
                break
            }
            
        case .connectReqing:
            switch event {
            case .localJoining:
                delegate?.do_CREATEANDENTER()
            case .localJoinSuc:
                currentState = .connecting
            case .endCall:
                currentState = .disconnected
                break
            default:
                break
            }
            
        case .connecting:
            switch event {
            case .peerOnline:
                currentState = .connected
            case .endCall:
                currentState = .disconnected
            default:
                break
            }
            
        case .connected:
            switch event {
            case .endCall:
                currentState = .disconnected
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
