//
//  IotSdkBridge.swift
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

import Foundation
import AgoraIotLink


public class IDeviceSessionManager : NSObject,IDeviceSessionMgr{
    @objc public func connect(connectParam: AgoraIotLink.ConnectParam, sessionCallback: @escaping (AgoraIotLink.SessionCallback, String, Int) -> Void, memberState: ((AgoraIotLink.MemberState, [UInt], String) -> Void)?) -> AgoraIotLink.ConnectResult {
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
    
    @objc public func getDevController(sessionId: String) -> AgoraIotLink.IDevControllerMgr? {
        return mgr.getDevController(sessionId: sessionId)
    }
    
    @objc public func getDevMediaMgr(sessionId: String) -> AgoraIotLink.IDevMediaMgr? {
        return mgr.getDevMediaMgr(sessionId: sessionId)
    }
    
    public init(mgr:IDeviceSessionMgr) {
        self.mgr = mgr
    }

    let mgr:IDeviceSessionMgr
    
}

public class IDevPreviewManager : NSObject,IDevPreviewMgr{

    @objc public func previewStart(bSubAudio: Bool,previewListener: @escaping (String, Int, Int) -> Void) {
        return mgr.previewStart(bSubAudio:bSubAudio,  previewListener: previewListener)
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
    
    @objc public func recordingStart(outFilePath: String,result: @escaping (Int, String) -> Void) {
        return mgr.recordingStart(outFilePath:outFilePath,result: result)
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

public class IDevControllerManager : NSObject,IDevControllerMgr{
    
    @objc public func sendCmdPtzCtrl(action: Int, direction: Int, speed: Int, cmdListener: @escaping (Int, String) -> Void) {
        return mgr.sendCmdPtzCtrl(action: action, direction: direction, speed: speed, cmdListener: cmdListener)
    }
    
    @objc public func sendCmdPtzReset(cmdListener: @escaping (Int, String) -> Void) {
        return mgr.sendCmdPtzReset(cmdListener: cmdListener)
    }
    
    @objc public func sendCmdPtzCtrl(cmdListener: @escaping (Int, String) -> Void) {
        return mgr.sendCmdPtzCtrl(cmdListener: cmdListener)
    }
    
    @objc public func sendCmdDevReset(cmdListener: @escaping (Int, String) -> Void) {
        return mgr.sendCmdDevReset(cmdListener: cmdListener)
    }
    
    public init(mgr:IDevControllerMgr) {
        self.mgr = mgr
    }
    
    let mgr:IDevControllerMgr
 
}

public class IDevMediaManager : NSObject,IDevMediaMgr{
    
    @objc public func queryMediaList(queryParam: AgoraIotLink.QueryParam, queryListener: @escaping (Int, [AgoraIotLink.DevMediaItem]) -> Void) {
        return mgr.queryMediaList(queryParam: queryParam, queryListener: queryListener)
    }
    
    @objc public func deleteMediaList(deletingList: [String], deleteListener: @escaping (Int, [AgoraIotLink.DevMediaDelResult]) -> Void) {
        return mgr.deleteMediaList(deletingList: deletingList, deleteListener: deleteListener)
    }
    
    @objc public func getMediaCoverData(imgUrl: String, cmdListener: @escaping (Int, String, Data) -> Void) {
        return mgr.getMediaCoverData(imgUrl: imgUrl, cmdListener: cmdListener)
    }
    
    @objc public func setDisplayView(displayView : UIView?) -> Int {
        return mgr.setDisplayView(displayView: displayView)
    }
    
    @objc public func play(globalStartTime: UInt64, playSpeed: Int, playingCallListener: AgoraIotLink.IPlayingCallbackListener) -> Int {
        return mgr.play(globalStartTime: globalStartTime, playSpeed: playSpeed, playingCallListener: playingCallListener)
    }
    
    @objc public func play(fileId: String, startPos: UInt64, playSpeed: Int, playingCallListener: AgoraIotLink.IPlayingCallbackListener) -> Int {
        return mgr.play(fileId: fileId, startPos: startPos, playSpeed: playSpeed, playingCallListener: playingCallListener)
    }
    
    @objc public func stop() -> Int {
        return mgr.stop()
    }
    
    @objc public func pause() -> Int {
        return mgr.pause()
    }
    
    @objc public func resume() -> Int {
        return mgr.resume()
    }
    
    @objc public func seek(seekPos: UInt64) -> Int {
        return mgr.seek(seekPos: seekPos)
    }
    
    @objc public func setPlayingSpeed(speed: Int) -> Int {
        return mgr.setPlayingSpeed(speed: speed)
    }
    
    @objc public func getPlayingProgress() -> UInt64 {
        return mgr.getPlayingProgress()
    }
    
    @objc public func getPlayingState() -> Int {
        return mgr.getPlayingState()
    }
    
    public init(mgr:IDevMediaMgr) {
        self.mgr = mgr
    }
    
    let mgr:IDevMediaMgr
    
}

public class IVodPlayerManager : NSObject,IVodPlayerMgr{
    
    @objc public func open(mediaUrl: String, callback: @escaping (Int, UIView) -> Void) {
        return mgr.open(mediaUrl: mediaUrl, callback: callback)
    }
    
    @objc public func close() {
        return mgr.close()
    }
    
    @objc public func getPlayingProgress() -> Double {
        return mgr.getPlayingProgress()
    }
    
    @objc public func getPlayDuration() -> Double {
        return mgr.getPlayDuration()
    }
    
    public func getCurrentPlaybackTime() -> Double {
        return mgr.getCurrentPlaybackTime()
    }
    
    @objc public func play() {
        return mgr.play()
    }
    
    @objc public func pause() {
        return mgr.pause()
    }
    
    @objc public func stop() {
        return mgr.stop()
    }
    
    @objc public func seek(seekPos: Double) {
        return mgr.seek(seekPos: seekPos)
    }
    
    public init(mgr:IVodPlayerMgr) {
        self.mgr = mgr
    }
    
    let mgr:IVodPlayerMgr
    
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
    
    @objc public func getVodPlayerMgr()->IVodPlayerManager{
        return IVodPlayerManager(mgr:iotsdk.vodPlayerMgr)
    }

}
