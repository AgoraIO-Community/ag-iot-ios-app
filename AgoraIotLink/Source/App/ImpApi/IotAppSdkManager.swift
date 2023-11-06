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
    private var rule:RuleManager
    
    private var _onPrepareListener:(Int,String)->Void = {s,msg in log.w("mqtt _onActionAck not inited")}
    
    var mLocalNode:LocalNode?
    
    init(app:Application){
        self.app = app
        self.rule = app.rule
    }
    
    func activeNode(_ preParam: LoginParam){
        
        app.config.userId = preParam.mUserId
        let mAppId = app.config.masterAppId
        let traceId:Int = String.dateTimeRounded()
        
        app.status.do_Preparing(.none)
        app.proxy.al.nodeActivate("\(traceId)", preParam.mUserId, mAppId, "") {[weak self] code, msg, rsp in
            log.i("---activeNode--\(code)")
            if code == ErrCode.XOK{
                guard let rsp = rsp else{
                    log.e("nodeActivate ret XOK, but rsp is nil")
                    self?._onPrepareListener(ErrCode.XERR_HTTP_NO_RESPONSE,msg)
                    self?.app.status.do_Initialized(.prepareFail)
                    return
                }
                guard let data = rsp.data else{
                    self?._onPrepareListener(ErrCode.XERR_HTTP_RESP_DATA,msg)
                    self?.app.status.do_Initialized(.prepareFail)
                    log.e("nodeActivate ret data is nil for \(rsp.msg) (\(rsp.code))")
                    return
                }
                log.i("---activeNode---data:\(data)")
                self?.mLocalNode = LocalNode(mUserId: preParam.mUserId, mNodeId: data.nodeId, mRegion: data.nodeRegion, mToken: data.nodeToken)
                let passWord = data.nodeId + "/" + preParam.mUserId + "/" + data.mqttSalt
                self?.app.proxy.cocoaMqtt.initialize(defaultHost: data.mqttServer, clientID: data.nodeId, userNameStr: data.mqttUsername, passWordStr: passWord,port:data.mqttPort)
                
            }else{
                self?._onPrepareListener(ErrCode.XERR_HTTP_RESP_CODE,"\(msg)")
                self?.app.status.do_Initialized(.prepareFail)
            }

        }
        
    }
    
    
    func prepare(loginParam: LoginParam,prepareListener:@escaping(Int,String)->Void)-> Int{
        
        if app.sdkState != .initialized{
            log.i("---:\(app.sdkState.rawValue)")
            return ErrCode.XERR_BAD_STATE
        }
        log.i("---prepare--\(loginParam.mUserId)")
        _onPrepareListener = prepareListener
        app.proxy.cocoaMqtt.waitForPrepareListenerDesired(listenterDesired: onMqttListenerDesired)
        activeNode(loginParam)
        
        return ErrCode.XOK
    }

    func logout() -> Int{
        log.i("------unprepare------")
        if app.sdkState == .running || app.sdkState == .reconnecting || app.sdkState == .loginOnGoing{
            app.proxy.cocoaMqtt.disconnect()
            app.status.do_Initialized(.none)
            return ErrCode.XOK
        }else{
            log.i("------unprepare---XERR_BAD_STATE---\(app.sdkState)")
            return ErrCode.XERR_BAD_STATE
        }
    }
    
    func getUserId()->String{
        
        return mLocalNode?.mUserId ?? ""
        
    }
    
    func getUserNodeId()->String{
        
        return mLocalNode?.mNodeId ?? ""
        
    }
    
    private func onMqttListenerDesired(state:MqttState,errCode:Int,msg:String){

        log.i("onMqttListenerDesired state : \(state.rawValue)")
        
        switch state {
        case .ConnectDone:
            break
        case .ConnectFail:
            _onPrepareListener(errCode,msg)
            _onPrepareListener = {s,msg in log.i("runing already")}
            break
        case .ScribeDone:
            _onPrepareListener(errCode,msg)
            _onPrepareListener = {s,msg in log.i("runing already")}
            break
        case .ScribeFail:
            break
        case .ConnectionLost:
            //todo:
//            _onPrepareListener(.Reconnecting,msg)
            break
        default:
            break
        }

    }
}
