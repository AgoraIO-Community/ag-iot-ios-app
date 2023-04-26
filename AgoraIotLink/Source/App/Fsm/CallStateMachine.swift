//
//  CallStateMachine.swift
//  AgoraIotLink
//
//  Created by admin on 2023/4/24.
//

import UIKit

protocol CallStateMachineListener : NSObjectProtocol {

    func on_callHangup()
    
    //srcState:stopAll
    func do_LEAVEANDDESTROY()
     //srcState:ready
    func do_CREATEANDENTER()
    
 }

enum CallState {
    case idle           // 空闲状态
    case callRequest    // 呼叫请求状态
    case outgoing       // 去电状态
    case onCall         // 通话状态
    case incoming       // 来电状态
}

enum CallEvent {
    case startCall             // 发起呼叫请求
    case makeCalling           // 发起去电呼叫事件
    case peerOnline            // 对端上线
    case peerOffline           // 对端离线
    case incomingCall          // 来电事件
    case IncomingCallSuc       // 来电加入频道成功
    case endCall               // 结束通话事件
}

class CallStateMachine: NSObject {
    
    weak var delegate : CallStateMachineListener?
    
    private var currentState: CallState = .idle
    
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
            case .makeCalling:
                currentState = .outgoing
                delegate?.do_CREATEANDENTER()
            case .endCall:
                currentState = .idle
                break
            default:
                break
            }
            
        case .outgoing:
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
            case .IncomingCallSuc:
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
}
