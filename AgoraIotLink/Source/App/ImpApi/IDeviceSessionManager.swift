//
//  IDeviceSessionManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/18.
//


class IDeviceSessionManager : IDeviceSessionMgr{

    func connect(connectParam: ConnectParam, sessionCallback: @escaping (SessionCallback, String, Int) -> Void, memberState: ((MemberState, [UInt], String) -> Void)?)->ConnectResult {
        
        CallListenerManager.sharedInstance.startConnectTime = String.dateCurrentTime()
        
        if CallListenerManager.sharedInstance.isCallTaking(connectParam.mPeerDevId) == true{
            log.i("---connect--device is already---:\(connectParam.mPeerDevId)")
//            sessionCallback(.onError,"",ErrCode.XERR_CALLKIT_LOCAL_BUSY)
            let result = ConnectResult(mSessionId: "", mErrCode:ErrCode.XERR_CALLKIT_LOCAL_BUSY)
            return result
        }
        
        let curTimestamp:Int = String.dateTimeRounded()
        
        let mSessionId = connectParam.mPeerDevId + "&" + "\(curTimestamp)"
        CallListenerManager.sharedInstance.startCall(sessionId:mSessionId, dialParam:connectParam,actionAck: sessionCallback, memberState: memberState)
        CallListenerManager.sharedInstance.callRequest(mSessionId)
        
        let result = ConnectResult(mSessionId: mSessionId, mErrCode:ErrCode.XOK)
        return result
    }
    
    func disconnect(sessionId:String)->Int{
        
        guard CallListenerManager.sharedInstance.getCurrentCallState(sessionId) != .idle else{
            log.i("disconnect fail:\(CallListenerManager.sharedInstance.getCurrentCallState(sessionId))")
            return ErrCode.XERR_BAD_STATE
        }
        CallListenerManager.sharedInstance.disConnect(sessionId)
        return ErrCode.XOK
    }
    
    func renewToken(sessionId: String, renewParam: TokenRenewParam) -> Int {
        
        guard CallListenerManager.sharedInstance.getCurrentCallState(sessionId) == .onCall else{  return ErrCode.XERR_BAD_STATE }
        CallListenerManager.sharedInstance.renewToken(sessionId: sessionId, renewParam: renewParam)
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
        return sessionInfor
    }
    
    func getDevPreviewMgr(sessionId: String) -> IDevPreviewMgr? {
        
        let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        return callSession?.devPreviewMgr!
    }
    
    func getDevController(sessionId: String) -> IDevControllerMgr? {
        
        let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        return callSession?.devControlMgr!
    }
    
    func getDevMediaMgr(sessionId: String) -> IDevMediaMgr? {
        let callSession = CallListenerManager.sharedInstance.getCurrentCallSession(sessionId)
        return callSession?.devMediaMgr!
    }
    
    
    
    private var app:Application
    private let rtc:RtcEngine
    
    init(app:Application){
        self.app = app
        self.rtc = app.proxy.rtc
    }
    
}
