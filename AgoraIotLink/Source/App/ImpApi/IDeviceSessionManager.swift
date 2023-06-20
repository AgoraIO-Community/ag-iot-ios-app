//
//  IDeviceSessionManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/18.
//


class IDeviceSessionManager : IDeviceSessionMgr{
    
    func connect(connectParam: ConnectParam, sessionCallback: @escaping (SessionCallback, String, Int) -> Void, memberState: ((MemberState, [UInt], String) -> Void)?) {
        
        if CallListenerManager.sharedInstance.isCallTaking(connectParam.mPeerDevId) == true{
            log.i("---connect--device is already---:\(connectParam.mPeerDevId)")
            sessionCallback(.onError,"",ErrCode.XERR_CALLKIT_LOCAL_BUSY)
            return
        }
        
        let curTimestamp:Int = String.dateTimeRounded()
        
        let mSessionId = connectParam.mPeerDevId + "&" + "\(curTimestamp)"
        CallListenerManager.sharedInstance.startCall(sessionId:mSessionId, dialParam:connectParam,actionAck: sessionCallback, memberState: memberState)
        CallListenerManager.sharedInstance.callRequest(mSessionId)
        
    }
    
    func disconnect(sessionId: String) -> Int {
        CallListenerManager.sharedInstance.hangUp(sessionId)
        return ErrCode.XOK
    }
    
    func getSessionList() -> [SessionInfo] {
        return [SessionInfo]()
    }
    
    func getSessionInfo(sessionId: String) -> SessionInfo {
        
        let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        let sessionInfor = SessionInfo()
        sessionInfor.mSessionId = callSession?.mSessionId ?? ""
        sessionInfor.mPeerDevId = callSession?.cname ?? ""
        sessionInfor.mUserId = app.config.userId
        sessionInfor.mState = CallListenerManager.sharedInstance.getCurrentCallState(sessionId)
        sessionInfor.mType = callSession?.callType.rawValue ?? 0
        return SessionInfo()
    }
    
    func getDevPreviewMgr(sessionId: String) -> IDevPreviewMgr? {
        
        let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        
        return callSession?.devPreviewMgr!
    }
    
    
    
    private var app:Application
    private let rtc:RtcEngine
    
    init(app:Application){
        self.app = app
        self.rtc = app.proxy.rtc
    }
    
    func onSessionDisconnected(sessionId: String) {
        log.i("onSessionDisconnected:\(sessionId)")
        
    }
    
    
    
}
