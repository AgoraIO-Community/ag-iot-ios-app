//
//  IotSdkBridge.swift
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

import Foundation
import AgoraIotLink


public class IDeviceSessionManager : NSObject,IDeviceSessionMgr{
    
    @objc public func connect(connectParam: AgoraIotLink.ConnectParam, sessionCallback: @escaping (AgoraIotLink.SessionCallback, String, Int) -> Void, memberState: ((AgoraIotLink.MemberState, [UInt], String) -> Void)?) {
        return mgr.connect(connectParam: connectParam, sessionCallback: sessionCallback, memberState: memberState)
    }
    
    @objc public func disconnect(sessionId: String) -> Int {
        return mgr.disconnect(sessionId: sessionId)
    }
    
    @objc public func getSessionList() -> [AgoraIotLink.SessionInfo] {
        return mgr.getSessionList()
    }
    
    @objc public func getSessionInfo(sessionId: String) -> AgoraIotLink.SessionInfo {
        return mgr.getSessionInfo(sessionId: sessionId)
    }
    
    @objc public func getDevPreviewMgr(sessionId: String) -> AgoraIotLink.IDevPreviewMgr? {
        return mgr.getDevPreviewMgr(sessionId: sessionId)
    }
    
    public init(mgr:IDeviceSessionMgr) {
        self.mgr = mgr
    }
    
    let mgr:IDeviceSessionMgr
    
}

public class IDevPreviewManager : NSObject,IDevPreviewMgr{
    
    @objc public func previewStart(previewListener: @escaping (String, Int, Int) -> Void) {
        return mgr.previewStart(previewListener: previewListener)
    }
    
    @objc public func previewStop(result: @escaping (Int, String) -> Void) {
        return mgr.previewStop(result: result)
    }
    
    @objc public func setPeerVideoView(peerView: UIView?) -> Int {
        return mgr.setPeerVideoView(peerView: peerView)
    }
    
    @objc public func muteLocalAudio(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.muteLocalAudio(mute: mute, result: result)
    }
    
    @objc public func mutePeerVideo(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.mutePeerVideo(mute: mute, result: result)
    }
    
    @objc public func mutePeerAudio(mute: Bool, result: @escaping (Int, String) -> Void) {
        return mgr.mutePeerAudio(mute: mute, result: result)
    }
    
    @objc public func setPlaybackVolume(volumeLevel: Int, result: @escaping (Int, String) -> Void) {
        return mgr.setPlaybackVolume(volumeLevel: volumeLevel, result: result)
    }
    
    @objc public func setAudioEffect(effectId: AgoraIotLink.AudioEffectId, result: @escaping (Int, String) -> Void) {
        return mgr.setAudioEffect(effectId: effectId, result: result)
    }
    
    @objc public func recordingStart(result: @escaping (Int, String) -> Void) {
        return mgr.recordingStart(result: result)
    }
    
    @objc public func recordingStop(result: @escaping (Int, String) -> Void) {
        return mgr.recordingStop(result: result)
    }
    
    @objc public func captureVideoFrame(result: @escaping (Int, String, UIImage?) -> Void) {
        return mgr.captureVideoFrame(result: result)
    }
    
    @objc public func getNetworkStatus() -> AgoraIotLink.RtcNetworkStatus {
        return mgr.getNetworkStatus()
    }
    
    @objc public func setRtcPrivateParam(privateParam: String) -> Int {
        return mgr.setRtcPrivateParam(privateParam: privateParam)
    }
    
    public init(mgr:IDevPreviewMgr) {
        self.mgr = mgr
    }
    
    let mgr:IDevPreviewMgr
    
}

public class IotSdk: NSObject {
    
    private static var sdk = IotSdk()
    
    @objc public static func shared()->IotSdk{
        return sdk
    }
    
    @objc func initialize(initParam: InitParam,callback:IotCallbackDelegate?)->Int{
        return iotsdk.initialize(initParam: initParam, callbackFilter: {ec,msg in
            if(callback != nil){
                callback!.filterResult(Int32(ec), errMessage: msg)
                return (ec,msg)
            }
            return (ec,msg)}
        )
    }

    /*
     * @brief 释放SDK所有资源
     */
    @objc func deinitialize(){
        return iotsdk.release()
    }

    @objc public func getDeviceSessionMgr()->IDeviceSessionManager{
        return IDeviceSessionManager(mgr:iotsdk.deviceSessionMgr)
    }

}
