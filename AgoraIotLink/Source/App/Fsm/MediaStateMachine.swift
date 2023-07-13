//
//  MediaStateMachine.swift
//  AgoraIotLink
//
//  Created by admin on 2023/7/10.
//

import UIKit

@objc protocol MediaStateMachineListener : NSObjectProtocol {
    
    @objc func do_LEAVEANDDESTROY()  //srcState:stopAll
     
    @objc func do_CREATEANDENTER()   //srcState:ready
    
 }

enum MediaEvent {
    case startCall             // 发起呼叫请求
    case toPaused              // 暂停
    case toReplay              // 重新播放
    case toSeeking             // seeking
    case peerOnline            // 对端上线
    case peerOffline           // 对端离线
    case endCall               // 结束通话事件
}

class MediaStateMachine: NSObject {
    
    weak var delegate : CallStateMachineListener?
    
    var currentState: DevMediaStatus = .stopped
    
    func handleEvent(_ event: MediaEvent) {
        switch currentState {
        case .stopped:
            switch event {
            case .startCall:
                delegate?.do_CREATEANDENTER()
                break
            case .peerOnline:
                currentState = .playing
                break
            default:
                break
            }
            
        case .playing:
            switch event {
            case .toPaused:
                currentState = .paused
            case .toSeeking:
                currentState = .seeking
            case .peerOffline:
                currentState = .stopped
            case .endCall:
                currentState = .stopped
                break
            default:
                break
            }
            
        case .paused:
            switch event {
            case .toReplay:
                currentState = .playing
            case .endCall:
                currentState = .stopped
            default:
                break
            }
            
        case .seeking:
            switch event {
            case .toReplay:
                currentState = .playing
            case .endCall:
                currentState = .stopped
            default:
                break
            }
            
        }
    }
    
    deinit {
        delegate = nil
        log.i("MediaStateMachine 销毁了")
    }
    
}
