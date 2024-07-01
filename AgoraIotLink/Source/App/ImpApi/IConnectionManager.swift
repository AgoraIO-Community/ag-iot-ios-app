//
//  IConnectionManager.swift
//  AgoraIotLink
//
//  Created by admin on 2024/2/20.
//

import UIKit

class IConnectionManager: IConnectionMgr {

    private var app:IotLibrary
    private let rtc:RtcEngine
    private let conListenerMgr = ConnectListenerManager.sharedInstance
    
    init(app:IotLibrary){
        self.app = app
        self.rtc = app.proxy.rtc
    }
    
    func registerListener(connectionMgrListener: IConnectionMgrListener) -> Int {
        ConnectListenerManager.sharedInstance.registerConnectBackListener(connectBackListener: connectionMgrListener)
        return ErrCode.XOK
    }
    
    func unregisterListener() -> Int {
        ConnectListenerManager.sharedInstance.unregisterConnectListener()
        return ErrCode.XOK
    }
    
    func connectionCreate(
        connectParam: ConnectCreateParam)->IConnectionObj? {
        
        if conListenerMgr.isCallTaking(connectParam.mPeerNodeId) == true{
            log.e("connectionCreate: connect device is already mPeerNodeId:\(connectParam.mPeerNodeId)")
            return nil
        }
        let curTimestamp:Int = String.dateTimeRounded()
        let mConnectionId = connectParam.mPeerNodeId + "&" + "\(curTimestamp)"
        let connectionObj = conListenerMgr.connect(connectionId: mConnectionId, connectParam: connectParam)
        
        return connectionObj
        
    }
    
    func connectionDestroy(connectObj:IConnectionObj)->Int {
        
        return conListenerMgr.disConnect(connectObj)
        
    }
    
    func getConnectionList() -> [IConnectionObj]? {
        
        return conListenerMgr.getConnectionList()
        
    }

}
