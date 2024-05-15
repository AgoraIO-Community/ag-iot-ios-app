//
//  RdtTransferFileMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2024/4/16.
//

import Foundation
import AgoraRtcKit


class RdtTransferFileMgr: NSObject {
    
    private var rdtTransferState: TransferFileState = .ideal
    private var rdtChannelState:  RdtChannelState = .unknown

    private var connection  : AgoraRtcConnection = AgoraRtcConnection()
    
    init(connection:AgoraRtcConnection){
        self.connection = connection
    }
    
    func getRtcObject() -> AgoraRtcEngineKit? {
        return AgoraRtcEngineMgr.sharedInstance.loadAgoraRtcEngineKit()
    }
    
    deinit {
        log.i("InnerCmdManager 销毁了")
    }
    
    func setRdtChannelState(_ state:AgoraRdtState){
        if state == .opened {
            rdtChannelState = .opened
        }else if state == .close{
            rdtChannelState = .closed
        }else{
            rdtChannelState = .unknown
        }
        
    }
    
    func setRdtTransferState(_ state:TransferFileState){
        log.i("setRdtTransferState: \(state)")
        rdtTransferState = state
    }
    
    func getRdtTransferState()->TransferFileState{
        log.i("getRdtTransferState: \(rdtTransferState)")
        return rdtTransferState
    }
    
    func sendRdtStartMessage(_ peerUid:Int,_ startMessage: String)->Int {
        
        guard let rtcKit = getRtcObject() else {
           log.e("sendRdtStartMessage: rtc engine is nil")
           return ErrCode.XERR_BAD_STATE
        }
        
        guard rdtChannelState == .opened else {
            log.e("sendRdtStartMessage: fail rdtChannelState:\(rdtChannelState)")
            return ErrCode.XERR_BAD_STATE
        }
        
        guard rdtTransferState != .transfering else {
            log.e("sendRdtStartMessage: fail  rdtTransferState:\(rdtTransferState)")
            return ErrCode.XERR_BAD_STATE
        }
        
        guard let paramData = RdtPktMgr.configRdtData(startMessage) else {
            log.e("sendRdtMessage: configRdtData fail")
            return ErrCode.XERR_INVALID_PARAM
        }

        let ret = rtcKit.sendRdtMessageEx(peerUid, type: .data, data: paramData, connection: connection)
        if ret == ErrCode.XOK {
            setRdtTransferState(.transfering)
        }
        return Int(ret)
        
    }
    
    func sendRdtStopMessage(_ peerUid:Int,_ stopMessage: String) {
        
        guard let rtcKit = getRtcObject() else {
           log.e("sendRdtStopMessage: rtc engine is nil")
           return
        }
        
        guard rdtChannelState == .opened else {
            log.e("sendRdtStopMessage: fail  rdtChannelState:\(rdtChannelState)")
            return
        }
        
        guard let paramData = RdtPktMgr.configRdtData(stopMessage) else {
            log.e("sendRdtStopMessage: configRdtData stopMessage fail")
            return
        }

        setRdtTransferState(.ideal)
        let ret = rtcKit.sendRdtMessageEx(peerUid, type: .data, data: paramData, connection: connection)
        log.i("sendRdtStopMessage stop ret:\(ret)")

    }
    
    
    
    
}
