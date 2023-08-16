//
//  IotAppSdkManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/23.
//

import UIKit


/*
 * @brief 本地节点的信息
 */
public class LocalNode : NSObject {
    @objc public var mUserId   : String        //服务器地址
    @objc public var mNodeId   : String
    @objc public var mRegion   : String
    @objc public var mToken    : String
    
    public init(mUserId:String ,
                mNodeId:String,
                mRegion:String,
                mToken:String
    ){
        self.mUserId = mUserId
        self.mNodeId = mNodeId
        self.mRegion = mRegion
        self.mToken = mToken
    }
}

public class IotAppSdkManager: NSObject {

    private var app:Application
    
    private var _onPrepareListener:(SdkStatus,String)->Void = {s,msg in log.w("mqtt _onActionAck not inited")}
    
    var mLocalNode:LocalNode?
    
    init(app:Application){
        self.app = app
    }
    
    func activeNode(_ preParam: PrepareParam){
        
        app.config.userId = preParam.mUserId
        app.config.masterAppId = preParam.mAppId
        app.config.pusherId = preParam.mPusherId
        let traceId:Int = String.dateTimeRounded()
        
//        app.proxy.al.nodeActivate("\(traceId)", preParam.mUserId, preParam.mAppId, preParam.mPusherId) {[weak self] code, msg, rsp in
//            log.i("---activeNode--\(code)")
//            if code == ErrCode.XOK{
//                guard let rsp = rsp else{
//                    log.e("nodeActivate ret XOK, but rsp is nil")
//                    self?._onPrepareListener(.NotReady,msg)
//                    return
//                }
//                guard let data = rsp.data else{
//                    self?._onPrepareListener(.NotReady,msg)
//                    log.e("nodeActivate ret data is nil for \(rsp.msg) (\(rsp.code))")
//                    return
//                }
//                log.i("---activeNode---data:\(data)")
//                self?.mLocalNode = LocalNode(mUserId: preParam.mUserId, mNodeId: data.nodeId, mRegion: data.nodeRegion, mToken: data.nodeToken)
//                let passWord = data.nodeId + "/" + preParam.mUserId
//                self?.app.proxy.cocoaMqtt.initialize(defaultHost: data.mqttServer, clientID: data.nodeId, userNameStr: data.mqttUsername, passWordStr: passWord,port:data.mqttPort)
//
//            }else{
//                //todo:
//                self?._onPrepareListener(.NotReady,"\(msg)")
//            }
//
////            self?.initialize(defaultHost: "", clientID: "", userNameStr: "", passWordStr:"" )
//        }
        
    }
    
    
    func prepare(preParam: PrepareParam,prepareListener:@escaping(SdkStatus,String)->Void){
        log.i("---prepare--\(preParam.mAppId)")
        _onPrepareListener = prepareListener
//        app.proxy.cocoaMqtt.waitForPrepareListenerDesired(listenterDesired: onMqttListenerDesired)
//        activeNode(preParam)
        
    }

    func unprepare(){
        log.i("------unprepare------")
//        app.proxy.cocoaMqtt.disconnect()
    }
    
    func getUserNodeId()->String{
        
        return mLocalNode?.mNodeId ?? ""
        
    }
    
//    private func onMqttListenerDesired(state:MqttState,msg:String){
//
//        log.i("onMqttListenerDesired state : \(state.rawValue)")
//
//        switch state {
//        case .ConnectDone:
//            break
//        case .ConnectFail:
//            break
//        case .ScribeDone:
//            _onPrepareListener(.AllReady,msg)
//            break
//        case .ScribeFail:
//            break
//        case .ConnectionLost:
//            break
//        default:
//            break
//        }
//
//    }
}
