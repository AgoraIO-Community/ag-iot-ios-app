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
    
//    func setRdtChannelState(_ state:AgoraRdtState){
//        if state == .opened {
//            rdtChannelState = .opened
//        }else if state == .close{
//            rdtChannelState = .closed
//        }else{
//            rdtChannelState = .unknown
//        }
//        
//    }
    
    func setRdtTransferState(_ state:TransferFileState){
        rdtTransferState = state
    }
    
    func getRdtTransferState()->TransferFileState{
        return rdtTransferState
    }
    
    func sendRdtMessage(startMessage: String)->Int {
        
        guard let rtcKit = getRtcObject() else {
           log.e("rtc engine is nil")
           return ErrCode.XERR_BAD_STATE
        }
        
        guard rdtChannelState == .opened else {
            return ErrCode.XERR_BAD_STATE
        }
        
        guard rdtTransferState == .transfering else {
            return ErrCode.XERR_BAD_STATE
        }
        
        guard let paramData = RdtPktMgr.configRdtData(startMessage) else {
            log.e("sendRdtMessage: configRdtData fail")
            return ErrCode.XERR_INVALID_PARAM
        }

//       let ret = rtcKit.sendRdtMessageEx(1, type: .data, data: paramData, connection: connection)
        
        return  0 //Int(ret)
    }
    
    func sendRdtMessage(stopMessage: String) {
        
        guard let rtcKit = getRtcObject() else {
           log.e("rtc engine is nil")
           return
        }
        
        guard rdtChannelState == .opened else {
            return
        }
        
        guard let paramData = RdtPktMgr.configRdtData(stopMessage) else {
            log.e("sendRdtMessage: configRdtData stopMessage fail")
            return
        }

        setRdtTransferState(.ideal)
//        let ret = rtcKit.sendRdtMessageEx(1, type: .data, data: paramData, connection: connection)
//        log.i("sendRdtMessage stop ret:\(ret)")
       
    }
    
    
    
    
}
