//
//  ConnectStateListener.swift
//  AgoraIotLink
//
//  Created by admin on 2024/3/14.
//

import UIKit
  
/*
 * @brief 与对端连通过程中产生的行为/事件
 */
@objc public enum ActionAck:Int{
    case connectFail                    //链接失败
    case RemoteHangup                   //对端挂断
    case RemoteVideoReady               //对端首帧出图
    case LocalHangup                    //本地挂断
    case LocalNetLost                    //本地网络连接丢失
    case UnknownAction                  //未知错误
}

/*
 * @brief 多人呼叫时成员状态变化种类
 */
@objc public enum MemberState : Int{
    case Exist                          //当前已有用户(除开自己)
    case Enter                          //其他新用户接入会话
    case Leave                          //其他用户退出会话
}

public class CallSession : NSObject{
    
    var token = ""
    var cname = ""
    var uid:UInt = 0
    var encryptMode: Int = 0
    var secretKey: String = ""
    
    
    var traceId:String = ""
    var lastSequenceId:Int = -1
    var version:UInt = 0
    
    var peerUid:UInt = 0                     //对端id
    var mPubLocalAudio: Bool = false        //设备端接听后是否立即推送本地音频流
    var mEncrypt: Bool = false              //是否开启内容加密
    
    var callType:ConnectType = .unknown     //通话类型
    var mConnectId = ""                     //链接Id
    var peerNodeId = ""                     //对端nodeId
    
    var transferId : UInt64 = 0             //当前数据传输Id
    
    var mVideoQuality:VideoQualityParam = VideoQualityParam()   //当前通话视频质量参数

    //------rtm信息------
    var mRtmUid: String = ""                //本地用户的 UserId
    var mRtmToken: String = ""              //要会话的 RTM Token
    
    var connectionObj : IConnectionObj?     //设备链接接口对象
    var connectionCmd : InnerCmdManager?    //设备链接信令对象
    
}

public class StreamSessionObj : NSObject{
    
    var streamId : StreamId = .UNICAST_STREAM_1
    var peerUid :  UInt = 1
    var timeStamp: TimeInterval = 0       //标记时间戳
    var mVideoPreviewing: Bool = false
    var mAudioPreviewing: Bool = false
    var mRecording: Bool = false
    
    init(streamId:StreamId,
          peerUid:UInt,
        timeStamp:TimeInterval
    ){
        self.streamId = streamId
        self.peerUid = peerUid
        self.timeStamp = timeStamp
    }
    
}

class ConnectStateListener: NSObject {
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var app  = IotLibrary.shared
    var rtc  = IotLibrary.shared.proxy.rtc
    private var  callRcbTime : TimeCallback<(Int,String)>? = nil
    private var  callReqTime : TimeCallback<(Int,String)>? = nil
    var callMachine : CallStateMachine?
    var talkingEngine : AgoraTalkingEngine?
    
    var callSession : CallSession?
    
    private var members:Int = 0
    private var tryCount:Int = 1
    
    var timerTimeout: Timer?
    let commandTimeOut   : TimeInterval = 5*1000  //命令超时时间 ms
    let commandCheckTime : TimeInterval = 3       //命令检测时间 s
    
    var callBackListener:ICallbackListener? = nil
    typealias callActionAck = (ConnectCallback,_ connectObj:IConnectionObj?, _ errCode:Int)->Void
    typealias callInterActionAck = (ActionAck,_ sessionId:String,_ peerNodeId:String)->Void
    typealias hangUpRetAck = (Bool,String)->Void
    
    private var callAct:callActionAck = {ack,connectObj,errCode in log.w("callAct callActionAck not inited")}
    private var hangUpRet :hangUpRetAck = {a,c in log.w("hangUpRetAck not inited")}
    var innerCallAct:callInterActionAck = {ack,sessionId,peerNodeId in log.w("innerCallAct callActionAck not inited")}
    
    
    init(connectionParam: ConnectCreateParam,connectionCallback: @escaping (ConnectCallback,_ connectObj:IConnectionObj?, _ errCode:Int)->Void) {
        super.init()
        
        callAct = connectionCallback
        startCall(connectionParam)
        connectRequest(connectionParam)
    }
    
    func startCall(_ dialParam: ConnectCreateParam){
        let callM = CallStateMachine()
        callMachine = callM
        callMachine?.delegate = self
        callMachine?.handleEvent(.startCall)
        
        callSession = CallSession()
        callSession?.callType = .active
        callSession?.peerNodeId = dialParam.mPeerNodeId
        callSession?.mEncrypt = dialParam.mEncrypt
    }
    
    func callRequest(_ suc:Bool){
        if suc == true{
            callMachine?.handleEvent(.localJoining)
        }else{
            self.callAct(.onConnectDone,self.callSession?.connectionObj, ErrCode.XERR_CALLKIT_DIAL)
            callMachine?.handleEvent(.endCall)
        }
    }
    
    func handelNetLost(){
        
        if callMachine?.currentState != .connected{
            self.callAct(.onConnectDone,self.callSession?.connectionObj, ErrCode.XERR_NETWORK)
            callMachine?.handleEvent(.endCall)
            self.innerCallAct(.connectFail,self.callSession?.mConnectId ?? "",self.callSession?.peerNodeId ?? "")
        }else{
            self.innerCallAct(.LocalNetLost,self.callSession?.mConnectId ?? "",self.callSession?.peerNodeId ?? "")
        }
    }
    
    func hangUp(_ ack:ActionAck,hangUpResult: @escaping (Bool,String) -> Void){
        
        hangUpRet = hangUpResult
        do_LEAVEANDDESTROY()
        let errCode = ack == .LocalNetLost ? ErrCode.XERR_NETWORK : ErrCode.XOK
        callAct(.onDisconnected,self.callSession?.connectionObj, errCode)
        endTime()
        stopTimerOut()
        callMachine?.handleEvent(.endCall)
        destory()

    }
    
    func registerCallBackListener(callBackListener: ICallbackListener){
        self.callBackListener = callBackListener
    }
    
    func unregisterCallBackListener(){
        callBackListener = nil
    }
    
    func endTime(){
        self.callRcbTime?.invoke(args: (ErrCode.XOK,"stop call"))
    }
    
    deinit {
        log.i("ConnectStateListener 销毁了")
    }

}

extension ConnectStateListener {
    
    func updateCallSession(_ sess : CallSession){
        callSession?.token = sess.token
        callSession?.cname = sess.cname
        callSession?.uid   = sess.uid
        callSession?.traceId = sess.traceId
        callSession?.peerUid = 1
        callSession?.callType = sess.callType
        callSession?.mRtmUid = app.config.mLocalNodeId
        callSession?.mRtmToken = sess.token
        callSession?.encryptMode = sess.encryptMode
        callSession?.secretKey = sess.secretKey
    }
    
    func updateCallSessionVideoQuality(_ videoQuality : VideoQualityParam){
        callSession?.mVideoQuality = videoQuality
    }
}

extension ConnectStateListener : CallStateMachineListener{
    
    func do_CREATEANDENTER() {
        
        let uid = callSession?.uid ?? 0
        let name = callSession?.cname ?? ""
        let token = callSession?.token ?? ""
        let peerId = callSession?.peerUid ?? 0
        let encryptMode = callSession?.encryptMode ?? 7
        let secretKey = callSession?.secretKey ?? ""
        let mEncrypt = callSession?.mEncrypt ?? false

        let setting = app.context.call.setting
        log.i("listener rtc.createAndEnter(uid:\(uid) channel:\(name))")
        var rtcSetting = RtcSetting()
        rtcSetting.dimension = setting.dimension
        rtcSetting.frameRate = setting.frameRate
        rtcSetting.bitRate = setting.bitRate
        rtcSetting.orientationMode = setting.orientationMode
        rtcSetting.renderMode = setting.renderMode
        rtcSetting.audioType = setting.audioType
        rtcSetting.audioSampleRate = setting.audioSampleRate

        rtcSetting.logFilePath = setting.logFilePath
        rtcSetting.publishAudio = setting.publishAudio
        rtcSetting.publishVideo = setting.publishVideo
        rtcSetting.subscribeAudio = setting.subscribeAudio
        rtcSetting.subscribeVideo = setting.subscribeVideo

        callRcbTime = TimeCallback<(Int,String)>(cb: { (state, msg) in
            log.i("callRcbTime :\(msg)")
        })
        
        let channelInfor = ChannelInfo()
        channelInfor.appId = app.config.masterAppId
        channelInfor.uid = uid
        channelInfor.cName = name
        channelInfor.token = token
        channelInfor.peerUid = peerId
        channelInfor.encryptMode = encryptMode
        channelInfor.secretKey = secretKey
        channelInfor.mEncrypt = mEncrypt
        
        talkingEngine = AgoraTalkingEngine.init(setting: rtcSetting, channelInfo: channelInfor, cb: {[weak self] ret,msg in
            if(ret == .Fail){
                log.e("listener rtc.createAndEnter failed:\(msg)")
                self?.callMachine?.handleEvent(.endCall)
                self?.innerCallAct(.RemoteHangup,self?.callSession?.mConnectId ?? "",self?.callSession?.peerNodeId ?? "")
            }
            else if(ret == .Succ){
                log.i("call reqCall CallForward")
                self?.timeOutTimer()
                self?.callMachine?.handleEvent(.localJoinSuc)
                self?.callRcbTime?.schedule(time:self?.app.config.calloutTimeOut ?? 15,timeout: {
                    log.i("call reqCall ring remote timeout")
                    self?.callMachine?.handleEvent(.endCall)
                    self?.innerCallAct(.RemoteHangup,self?.callSession?.mConnectId ?? "",self?.callSession?.peerNodeId ?? "")
                })

            }
            else {//Abort
                log.i("listener rtc.createAndEnter aborted:\(msg)")
            }
        }, peerAction: {[weak self] act,uid,exData in
            if(act == .Enter){
                log.i("listener Enter uid:\(uid)")
                if(self?.callSession?.peerUid == uid){
                    self?.handelPeerOnlineAction()
                }
            }
            else if(act == .Leave){
                log.i("listener Leave uid:\(uid)")
                if(self?.callSession?.peerUid == uid){
//                    self?.callAct(.onDisconnected,self?.callSession?.connectionObj,ErrCode.XOK)
                    self?.innerCallAct(.RemoteHangup,self?.callSession?.mConnectId ?? "",self?.callSession?.peerNodeId ?? "")

                }
            }
            else if(act == .Lost){
                log.i("listener rtc net Lost")
                self?.handelNetLost()
            }
            else if(act == .VideoReady){
                log.i("listener VideoReady uid:\(uid)")
                let streamId = StreamIdToUIdMap.getStreamId(baseUid: self?.callSession?.uid  ?? 1, uId: uid)
                self?.callBackListener?.onStreamFirstFrame(connectObj: self?.callSession?.connectionObj, subStreamId: StreamId(rawValue: streamId)!, videoWidth: exData?.width ?? 0, videoHeight: exData?.height ?? 0)
            }
        }, memberState: {[weak self]s,a in
            if(s == .Enter){
                log.i("listener memberState Enter uid:\(a[0])")
                self?.members +=  1
    
            }else if(s == .Leave){
                log.i("listener memberState Leave:\(a[0])")
                self?.members -= 1
                
            }else if(s == .Exist){
                self?.members = 0
            }
            else{
                log.i("listener memberState aborted:\(s)")
            }
        })
        
        talkingEngine?.waitForTokenWillExpire { [weak self] in
            //监听到token即将过期
            self?.renewTotalToken()
        }
        
        talkingEngine?.registerRdtDataListern(rdtListen: { [weak self] peerUid, receiveData,errCode in
            if errCode !=  ErrCode.XOK{
                self?.talkingEngine?.setRdtTransferState(.ideal)
                self?.callBackListener?.onFileTransError(connectObj: self?.callSession?.connectionObj, errCode: ErrCode.XERR_NETWORK)
            }else{
                self?.handelRdtReceiveData(receiveData)
            }
        })
        
        talkingEngine?.registeronRenderVideoFrameListern(renderDatalistern: { [weak self] videoFrame, uid in
            
            let streamId = StreamIdToUIdMap.getStreamId(baseUid: self?.callSession?.uid  ?? 1, uId: uid)
            if(videoFrame.type == 12){//CVPixelBufferRef
                if let buffer = videoFrame.pixelBuffer{
                    self?.callBackListener?.onStreamVideoFrame(connectObj: self?.callSession?.connectionObj, subStreamId: StreamId(rawValue: streamId)!, pixelBuffer: buffer, videoWidth: Int(videoFrame.width), videoHeight: Int(videoFrame.height))
                }else{
                    log.e("rtc capture pixelBuffer is nil")
                }
            }
        })
    }
    
    func handelRdtReceiveData(_ receiveData:Data){
        let pktType = RdtPktMgr.getPktType(receiveData)
        switch pktType {
        case .pktStart:
            callBackListener?.onFileTransRecvStart(connectObj: callSession?.connectionObj, startDescrption: receiveData)
        case .pktContentData:
            callBackListener?.onFileTransRecvData(connectObj: callSession?.connectionObj, recvedData: receiveData)
        case .pktEnd:
            guard let isTransferEnd = RdtPktMgr.getPktEof(receiveData) else {
                log.e("handelRdtReceiveData: getPktEof ret is nil")
                return
            }
            if isTransferEnd == true{
                talkingEngine?.setRdtTransferState(.ideal)
            }
            callBackListener?.onFileTransRecvDone(connectObj: callSession?.connectionObj, transferEnd: isTransferEnd, doneDescrption: receiveData)
        case nil:
            break
        }
    }
    
    func renewTotalToken(){
        log.i("renewTotalToken: listener TokenWillExpire peerNodeId:\(String(describing: callSession?.peerNodeId))")
        let connectParam = ConnectCreateParam(mPeerNodeId: callSession?.peerNodeId ?? "",mEncrypt: callSession?.mEncrypt ?? false, mAttachMsg: "")
        connectRequest(connectParam)
    }
    
    func do_LEAVEANDDESTROY() {
        log.i("listener rtc.on_destroy talkingEngine:\(String(describing: talkingEngine == nil ? nil:"talkingEngine already"))")
        talkingEngine?.leaveChannel(cb: { [weak self] succ in
            if(!succ){
                log.e("listener rtc.leaveAndDestroy failed")
            }
            self?.hangUpRet(succ, "leaveAndDestroy ret")
        })
        //todo:待最后一个连接退出频道再销毁
//        talkingEngine?.destroy()
        talkingEngine = nil
        
    }
    
    func renewRtcToken() {
        let token = callSession?.token ?? ""
        talkingEngine?.renewToken(token)
    }
    
    //处理对端上线回调
    func handelPeerOnlineAction(){
        guard callMachine?.currentState != .connected  else { return }
        endTime()
        callMachine?.handleEvent(.peerOnline)
        callAct(.onConnectDone,self.callSession?.connectionObj,ErrCode.XOK)
    }
    
    func destory(){
        callMachine?.delegate = nil
        callMachine = nil
    }
  
}

extension ConnectStateListener{//rtm
    
    func creatAndEnterRtm(){
        
        let rtm = app.proxy.rtm
        //初始化其他
        let setting = app.context.rtm.setting
        let succ = rtm.create(setting)
        if succ != true{
            log.e("creatAndEnterRtm: succ:\(succ)")
            return
        }
        enterRtm()

    }
    
    func enterRtm(){
        
        let rtm = app.proxy.rtm
        let rtmSession = RtmSession()
        rtmSession.token = callSession?.mRtmToken ?? ""
        rtmSession.peerVirtualNumber = callSession?.peerNodeId ?? ""
        rtmSession.localNodeId = app.config.mLocalNodeId
        
        let uid = callSession?.mRtmUid ?? ""
        rtm.enter(rtmSession, "\(uid)") { [weak self] ret, msg in
            if ret != ErrCode.XOK{
                //登陆失败，重新登陆
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
                    log.i("enterRtm: enterRtm login try again")
                    self?.enterRtm() // 调用自身以重新登录
                }
            }
        }
    }
    
    func handelRtmAlready(){
        
        guard callMachine?.currentState != .connected  else { return }
       // callSession?.connectionCmd?.sendCmdCreatConnect( cmdListener: { code, msg in })
        
    }
    
    
    func renewRtmToken(){
        let token = callSession?.mRtmToken ?? ""
        let peerNodeId = callSession?.peerNodeId ?? ""
        log.i("renewRtmToken:peerNodeId：\(peerNodeId)")
        //rtm 更新token
        let rtm = app.proxy.rtm
        //rtm 更新token，可能重新连接不同的设备，peerNodeId也需要传入进行更行
        rtm.renewToken(token,peerNodeId)
    }

}

extension ConnectStateListener{
    
    func initRtm(){//初始化Rtm

        let rtm = app.proxy.rtm
        
        if rtm.getRtmState() == .IDLED {
            creatAndEnterRtm()
        }else if rtm.getRtmState() == .ENTERED {
            log.i("initRtm: renewRtmToken rtmstate:\(rtm.getRtmState().rawValue)")
            renewRtmToken()
        }
   
    }
    
    func callRequestSuc(){
        
        callRequest(true)
        initRtm()
    }
    
    func callRequestFail(){//呼叫失败时清除呼叫对象
        
        self.callRequest(false)
        self.innerCallAct(.connectFail,self.callSession?.mConnectId ?? "",self.callSession?.peerNodeId ?? "")
    }
    
    func connectRequest(_ connectParam: ConnectCreateParam,retryCount: Int = 3){
        
        guard retryCount > 0 else {
            callRequestFail()
            return
        }
        
        let cbRequest = { [weak self] (code:Int, msg:String, rsp:AgoraLab.ConnectCreat.Rsp?) in
            log.i("---connect result--- code:\(code)")
            if code == ErrCode.XOK{
                guard let rsp = rsp else{
                    log.e("connectRequest ret XOK, but rsp is nil")
                    self?.callRequestFail()
                    return
                }
                guard let data = rsp.data else{
                    log.e("connectRequest ret data is nil for \(rsp.msg) (\(rsp.code))")
                    self?.callRequestFail()
                    return
                }
                log.i("---connectResult--- uid:\(data.uid) cname:\(data.cname) encryptMode:\(String(describing: data.encryptMode)) secretKey:\(String(describing: data.secretKey)) traceId:\(rsp.traceId)")
                self?.handelConnectResult(traceId:rsp.traceId,resultData: data)
                
                
            }else{
                log.e("connectRequest reTry fail  count:\(retryCount - 1) perrNodeId:\(connectParam.mPeerNodeId)")
                self?.connectRequest(connectParam, retryCount: retryCount - 1)
            }

        }
        
        let traceId:Int = String.dateTimeRounded()
        app.proxy.al.creatConnect("\(traceId)", connectParam.mPeerNodeId, connectParam.mEncrypt, cbRequest)
        
    }
    
    func handelConnectResult(traceId:String, resultData: AgoraLab.ConnectCreat.Data){
        
        let sess = CallSession()
        sess.token = resultData.token
        sess.uid = resultData.uid
        sess.cname = resultData.cname
        var encryptModeValue = app.config.encryptMode
        if let encryptMode = resultData.encryptMode,encryptMode != 0 {
            encryptModeValue = encryptMode
        }
        sess.encryptMode = encryptModeValue
        sess.secretKey = resultData.secretKey ?? app.config.encryptSecretKey
        sess.traceId = traceId
        updateCallSession(sess)
        
        if callMachine?.currentState != .connected{
            callRequestSuc()
        }else{
            renewRtcToken()
            renewRtmToken()
        }
    }
    
}


//首帧获取超时检测
extension ConnectStateListener{
    
    func  timeOutTimer(){
        timerTimeout = Timer()
        startTimeOut()
    }
    
    func startTimeOut() {
        timerTimeout = Timer.scheduledTimer(timeInterval: commandCheckTime, target: self, selector: #selector(handelTimeOut), userInfo: nil, repeats: true)
    }
    
    @objc func handelTimeOut() {
        // 在这里实现发送消息的逻辑
        handelPreviewTimeout()
        
    }
    
    func handelPreviewTimeout(){
        
        for (_,obj) in talkingEngine!.streamSessionObjs{
            guard obj.timeStamp != 0 else { continue }
            let timeSpace = String.dateTimeSpaceMillion(obj.timeStamp)
            if  timeSpace > commandTimeOut{
                log.i("handelPreviewTimeout: streamId:\(obj.streamId) obj.timeStamp:\(obj.timeStamp)")
                obj.timeStamp = 0
                obj.mVideoPreviewing = false
                callBackListener?.onStreamError(connectObj: callSession?.connectionObj, subStreamId: obj.streamId, errCode: ErrCode.XERR_TIMEOUT)
            }
        }
    }
    
    func stopTimerOut() {
        log.i("RtcEngine timer is nil")
        timerTimeout?.invalidate()
        timerTimeout = nil
    }
    
}
