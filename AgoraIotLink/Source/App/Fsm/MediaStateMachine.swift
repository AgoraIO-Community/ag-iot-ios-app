//
//  MediaStateMachine.swift
//  AgoraIotLink
//
//  Created by admin on 2023/7/10.
//

import UIKit

@objc protocol MediaStateMachineListener : NSObjectProtocol {
    
    @objc func do_LEAVEANDDESTROY()
     
    @objc func do_CREATEANDENTER() 
    
 }

enum MediaEvent {
    case openCall              // 获取呼叫参数
    case startCall             // 发起呼叫请求
    case toWillPaused          // 去暂停
    case toHavePaused          // 已暂停
    case toResuming            // resuming
    case toReplay              // 重新播放
    case toSeeking             // seeking
    case peerOnline            // 对端上线
    case endCall               // 结束通话事件
}

class MediaStateMachine: NSObject {
    
    weak var delegate : CallStateMachineListener?
    
    var currentState: DevMediaStatus = .stopped
    var lastState : DevMediaStatus = .stopped
    
    func handleEvent(_ event: MediaEvent) {
        
        lastState = currentState
        
        switch currentState {
        case .stopped:
            switch event {
            case .openCall:
                currentState = .opening
            case .endCall:
                currentState = .stopped
            default:
                break
            }
        case .opening:
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
            break
        case .playing:
            switch event {
            case .toWillPaused:
                currentState = .pausing
            case .toSeeking:
                currentState = .seeking
            case .endCall:
                currentState = .stopped
                break
            default:
                break
            }
            break
        case .pausing:
            switch event {
            case .toHavePaused:
                currentState = .paused
            case .endCall:
                currentState = .stopped
                break
            default:
                break
            }
            break
        case .paused:
            switch event {
            case .toResuming:
                currentState = .resuming
            case .endCall:
                currentState = .stopped
            default:
                break
            }
            break
        case .seeking:
            switch event {
            case .toReplay:
                currentState = .playing
            case .endCall:
                currentState = .stopped
            default:
                break
            }
            break
        case .resuming:
            switch event {
            case .toReplay:
                currentState = .playing
            case .endCall:
                currentState = .stopped
                break
            default:
                break
            }
            break
        }
    }
    
    deinit {
        delegate = nil
        log.i("MediaStateMachine 销毁了")
    }
    
}
