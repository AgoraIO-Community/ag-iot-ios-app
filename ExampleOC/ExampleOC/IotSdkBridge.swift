//
//  IotSdkBridge.swift
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

import Foundation
import AgoraIotLink

public class ConnectionObjManager : NSObject,IConnectionObj{
    @objc public func registerListener(callBackListener: AgoraIotLink.ICallbackListener) -> Int {
        return mgr.registerListener(callBackListener: callBackListener)
    }
    
    @objc public func unregisterListener() -> Int {
        return mgr.unregisterListener()
    }
    
    @objc public func getInfo() -> AgoraIotLink.ConnectionInfo {
        return mgr.getInfo()
    }
    
    @objc public func publishVideoEnable(pubVideo: Bool,
                                   result: @escaping (Int, String) -> Void) -> Int {
        return mgr.publishVideoEnable(pubVideo: pubVideo, 
                                      result: result)
    }
    
    @objc public func publishAudioEnable(pubAudio: Bool,
                                   codecType: AgoraIotLink.AudioCodecType,
                                   result: @escaping (Int, String) -> Void) -> Int {
        return mgr.publishAudioEnable(pubAudio: pubAudio,
                                      codecType: codecType,
                                      result: result)
    }
    
    @objc public func getStreamStatus(peerStreamId: AgoraIotLink.StreamId) -> AgoraIotLink.StreamStatus {
        return mgr.getStreamStatus(peerStreamId: peerStreamId)
    }
    
    @objc public func streamSubscribeStart(peerStreamId: AgoraIotLink.StreamId,
                                     attachMsg: String,
                                     result: @escaping (Int, String) -> Void) {
        return mgr.streamSubscribeStart(peerStreamId: peerStreamId, 
                                        attachMsg: attachMsg,
                                        result: result)
    }
    
    @objc public func streamSubscribeStop(peerStreamId: AgoraIotLink.StreamId) {
        return mgr.streamSubscribeStop(peerStreamId: peerStreamId)
    }
    
    @objc public func setVideoDisplayView(subStreamId: AgoraIotLink.StreamId,
                                    displayView: UIView?) -> Int {
        return mgr.setVideoDisplayView(subStreamId: subStreamId, 
                                       displayView: displayView)
    }
    
    @objc public func muteAudioPlayback(subStreamId: AgoraIotLink.StreamId,
                                  previewAudio: Bool,
                                  result: @escaping (Int, String) -> Void) {
        return mgr.muteAudioPlayback(subStreamId: subStreamId,
                                     previewAudio: previewAudio,
                                     result: result)
    }
    
    @objc public func setAudioPlaybackVolume(subStreamId: AgoraIotLink.StreamId,
                                       volumeLevel: Int,
                                       result: @escaping (Int, String) -> Void) {
        return mgr.setAudioPlaybackVolume(subStreamId: subStreamId,
                                          volumeLevel: volumeLevel,
                                          result: result)
    }
    
    @objc public func streamVideoFrameShot(subStreamId: AgoraIotLink.StreamId,
                                     saveFilePath: String,
                                     cb: @escaping (Int, Int, Int) -> Void) -> Int {
        return mgr.streamVideoFrameShot(subStreamId: subStreamId, 
                                        saveFilePath: saveFilePath,
                                        cb: cb)
    }
    
    @objc public func streamRecordStart(subStreamId: AgoraIotLink.StreamId,
                                  outFilePath: String) -> Int {
        return mgr.streamRecordStart(subStreamId: subStreamId, 
                                     outFilePath: outFilePath)
    }
    
    @objc public func streamRecordStop(subStreamId: AgoraIotLink.StreamId) -> Int {
        return mgr.streamRecordStop(subStreamId: subStreamId)
    }
    
    @objc public func isStreamRecording(subStreamId: AgoraIotLink.StreamId) -> Bool {
        return mgr.isStreamRecording(subStreamId: subStreamId)
    }
    
    @objc public func sendMessageData(messageData: Data) -> UInt32 {
        return mgr.sendMessageData(messageData: messageData)
    }
    
    @objc public func fileTransferStart(startMessage: String) -> Int {
        return mgr.fileTransferStart(startMessage: startMessage)
    }
    
    @objc public func fileTransferStop() {
        return mgr.fileTransferStop()
    }
    
    @objc public func isFileTransfering() -> Bool {
        return mgr.isFileTransfering()
    }
    
    @objc public func getNetworkStatus() -> AgoraIotLink.NetworkStatus {
        return mgr.getNetworkStatus()
    }
    
    public init(mgr:IConnectionObj) {
        self.mgr = mgr
    }
    
    let mgr:IConnectionObj
}

public class ConnectionManager : NSObject,IConnectionMgr {
    @objc public func registerListener(connectionMgrListener: AgoraIotLink.IConnectionMgrListener) -> Int {
        return mgr.registerListener(connectionMgrListener: connectionMgrListener)
    }
    
    @objc public func unregisterListener() -> Int {
        return mgr.unregisterListener()
    }
    
    @objc public func connectionCreate(connectParam: AgoraIotLink.ConnectCreateParam) -> AgoraIotLink.IConnectionObj? {
        return mgr.connectionCreate(connectParam: connectParam)
    }
    
    @objc public func connectionDestroy(connectObj: AgoraIotLink.IConnectionObj) -> Int {
        return mgr.connectionDestroy(connectObj: connectObj)
    }
    
    @objc public func getConnectionList() -> [AgoraIotLink.IConnectionObj]? {
        return mgr.getConnectionList()
    }
    
    public init(mgr:IConnectionMgr) {
        self.mgr = mgr
    }
    
    let mgr:IConnectionMgr
}

public class IotSdk: NSObject {
    
    private static var sdk = IotSdk()
    
    @objc public static func shared()->IotSdk{
        return sdk
    }

    @objc public func initialize(initParam: AgoraIotLink.InitParam) -> Int {
        return iotsdk.initialize(initParam: initParam)
    }
    
    @objc public func setPublishAudioEffect(effectId: AgoraIotLink.AudioEffectId, 
                                            result: @escaping (Int, String) -> Void) -> Int {
        return iotsdk.setPublishAudioEffect(effectId: effectId, 
                                            result: result)
    }
    
    @objc public func getPublishAudioEffect() -> AgoraIotLink.AudioEffectId {
        return iotsdk.getPublishAudioEffect()
    }
    
    @objc public func getSdkVersion() -> String {
        return iotsdk.getSdkVersion()
    }

    /*
     * @brief 释放SDK所有资源
     */
    @objc func deinitialize(){
        return iotsdk.release()
    }

    @objc public func getConnectionMgr()->ConnectionManager{
        return ConnectionManager(mgr:iotsdk.connectionMgr)
    }
}
