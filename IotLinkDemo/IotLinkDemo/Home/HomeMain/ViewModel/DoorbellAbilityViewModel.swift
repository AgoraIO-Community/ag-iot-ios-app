//
//  DoorbellAbilityViewModel.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit
import AgoraIotLink

//class DoorbellAbilityViewModel: NSObject {
extension DoorBellManager{
//    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
//    var members:Int = 0
//    var isPlaying:Bool = false
    
//    public static let shared = DoorbellAbilityViewModel()

    
    func registerConnectMgrListener(listener:IConnectionMgrListener){
        guard let callMgr = sdk?.connectionMgr else{
            log.i("sdk.callkitMgr not init")
            return
        }
        let ret = callMgr.registerListener(connectionMgrListener:listener )
    }
    
    func unRegisterConnectMgrListener(){
        guard let callMgr = sdk?.connectionMgr else{
            log.i("sdk.callkitMgr not init")
            return
        }
        let ret = callMgr.unregisterListener()
    }
    
    //连接设备
    func connectDevice(_ param:ConnectCreateParam)->IConnectionObj?{
        guard let callMgr = sdk?.connectionMgr else{
            log.i("sdk.callkitMgr not init")
            return nil
        }
        log.i("connectDevice :\(param)")
        let connectObj = callMgr.connectionCreate(connectParam: param)
        return connectObj

    }
    
    func registerConnectObjListener(connectObj : IConnectionObj?,listener:ICallbackListener){
        let ret = connectObj?.registerListener(callBackListener: listener)
    }
    
    func unRegisterConnectObjListener(connectObj : IConnectionObj?){
        let ret = connectObj?.unregisterListener()
    }
    
    //呼叫设备
//    func wakeupDevice(_ dev:MDeviceModel,_ cb:@escaping(Int,String,String)->Void,_ action:@escaping(String,ActionAck)->Void,_ memberState:@escaping(Int,String)->Void){
//        guard let callMgr = sdk?.callkitMgr else{
//            log.i("sdk.callkitMgr not init")
//            cb(-1,"","")
//            return
//        }
//
//        
//        let dailParam = DialParam(mPeerNodeId: dev.peerNodeId, mAttachMsg: "attachMsg", mPubLocalAudio: true)
//        callMgr.callDial(dialParam: dailParam,result:{
//            (ec,connectId,peerNodeId) in
//            cb(ec, connectId, peerNodeId)
//        },actionAck: {s,connectId,peerNodeId in
//            var msg = "未知的设备操作"
//            self.mconnectId = connectId
//            switch(s){
//                case .RemoteAnswer:msg = "设备接听"
//                case .RemoteHangup:msg = "设备挂断"
//                case .LocalHangup:msg = "本地挂断"
//                case .UnknownAction:msg = "未知行为"
//                case .RemoteVideoReady:msg = "首次收到设备视频"
//                case .CallIncoming:msg = "设备来电"
//                case .RemoteTimeout:msg = "对端超时"
//
//            }
//            log.i("呼叫事件:\(msg)")
//            if(s == .RemoteHangup){
//                self.members = 0
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
//            }
//            if(s == .RemoteAnswer){
//                self.members = self.members + 1
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
//            }
//            action(connectId,s)
//        },memberState:{s,a,connectId in
//            if(s == .Exist){self.members = 0}
//            if(s == .Enter){self.members = self.members + 1}
//            if(s == .Leave){self.members = self.members - 1}
//            log.i("demo app member count \(self.members):\(s.rawValue) \(a)")
//            memberState(self.members,connectId)
////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
//        })
//        
//
//    }
 
//    func startPlayback(channelName:String,result:@escaping(Int,String)->Void,stateChanged:@escaping(PlaybackStatus,String)->Void){
//        isPlaying = true
////        return iotsdk.deviceMgr.startPlayback(channelName: channelName, result: result, stateChanged: stateChanged)
//    }
    func setPlaybackView(peerView: UIView?) -> Int{
//        return iotsdk.deviceMgr.setPlaybackView(peerView: peerView)
        return 0
    }
    func isSdCardPlaying()->Bool{return isPlaying}
    func stopPlayback(){
        isPlaying = false
//        return iotsdk.deviceMgr.stopPlayback()
    }
    //挂断设备
    func hangupDevice(_ connectObj : IConnectionObj, _ cb:@escaping(Bool,String)->Void){
        log.i("demo app local req Hangup")
        guard let callMgr = sdk?.connectionMgr else{
            cb(false,"sdk 呼叫服务 未初始化")
            return
        }
        let ret = callMgr.connectionDestroy(connectObj: connectObj)
        cb(ret == ErrCode.XOK ? true : false,"")
        members = 0
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cLocalHangupNotify), object: nil, userInfo: nil)
        
        
    }
    
    //接听来电
//    func callAnswer2(cb:@escaping(Bool,String)->Void,
//                    actionAck:@escaping(ActionAck)->Void){
//        sdk?.callkitMgr.callAnswer(connectId: "", pubLocalAudio: true,result: {ec,msg in
//            log.i("demo app callAnswer ret:\(msg)(\(ec))")
//            if(ec == ErrCode.XOK){
//                cb(ec == ErrCode.XOK ? true : false , msg)
//            }
//        },
//        actionAck: {ack in
//            log.i("demo app callAnser ack:\(ack)")
//             if(ack == .RemoteHangup){
//                 self.members = 0
//                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
//             }
////             if(ack == .RemoteAnswer){
////                 self.members = self.members + 1
////                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
////             }
//            actionAck(ack)
//
//        },
//        memberState:{s,a in
//             if(s == .Exist){self.members = 0}
//             if(s == .Enter){self.members = self.members + a.count}
//             if(s == .Leave){self.members = self.members - a.count}
//             log.i("demo app member count \(self.members):\(s.rawValue) \(a)")
//             NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
//         })
//
//    }
    
    
    //-----------------------以上为获取网络数据部分----------------------------

    //MARK: 初始化设备属性设置数据
//    func loadDoorbellAbilityPropertyData(finished: @escaping ( _ modelArr:[DoorbellAbilityModel]?,_ isSuccess:Bool)->()){
//        
//        let jsonString = "{\"code\":200,\"msg\":\"获取成功\",\"dataList\":[{\"abilityName\":\"回放\",\"abilityIcon\":\"func1\",\"abilitySecectIcon\":\"func1\",\"abilityId\":10000},{\"abilityName\":\"相册\",\"abilityIcon\":\"func2\",\"abilitySecectIcon\":\"func2\",\"abilityId\":10002},{\"abilityName\":\"强拆报警\",\"abilityIcon\":\"func3\",\"abilitySecectIcon\":\"func3_on\",\"abilityId\":105},{\"abilityName\":\"红外夜视\",\"abilityIcon\":\"func4\",\"abilitySecectIcon\":\"func4_on\",\"abilityId\":101},{\"abilityName\":\"声音检测\",\"abilityIcon\":\"func5\",\"abilitySecectIcon\":\"func5_on\",\"abilityId\":115},{\"abilityName\":\"移动侦测\",\"abilityIcon\":\"func6\",\"abilitySecectIcon\":\"func6_on\",\"abilityId\":102},{\"abilityName\":\"PIR开关\",\"abilityIcon\":\"func7\",\"abilitySecectIcon\":\"func7_on\",\"abilityId\":103},{\"abilityName\":\"警笛\",\"abilityIcon\":\"func8\",\"abilitySecectIcon\":\"func8_on\",\"abilityId\":114}]}"
//        
//        let dict = getDictionaryFromJSONString(jsonString: String(describing: jsonString).removingPercentEncoding!)
//        
//        //debugPrint(dict)
//        
//        
//        guard let arr = dict["dataList"] as? [[String: Any]] else {
//            
//            finished(nil,false)
//            
//            return
//        }
//        var saveModelArr = [DoorbellAbilityModel]()
//        for dict in arr {
//            guard let model = DoorbellAbilityModel.deserialize(from: dict) else { continue }
//            saveModelArr.append(model)
//        }
//
//        finished(saveModelArr,true)
//        
//    }
    
    //MARK: 初始化头像设置数据
    func loadHeardImgPropertyData(finished: @escaping ( _ modelArr:[UserHeardImgModel]?,_ isSuccess:Bool)->()){
        
        let jsonString = "{\"code\":200,\"msg\":\"获取成功\",\"dataList\":[{\"heardName\":\"男孩\",\"heardIcon\":\"boy\"},{\"heardName\":\"女孩\",\"heardIcon\":\"girl\"},{\"heardName\":\"小狗\",\"heardIcon\":\"dog\"},{\"heardName\":\"小猫\",\"heardIcon\":\"cat\"}]}"
        
        let dict = getDictionaryFromJSONString(jsonString: String(describing: jsonString).removingPercentEncoding!)
        
        debugPrint(dict)
        
        
        guard let arr = dict["dataList"] as? [[String: Any]] else {
            
            finished(nil,false)
            
            return
        }
        var saveModelArr = [UserHeardImgModel]()
        for dict in arr {
            guard let model = UserHeardImgModel.deserialize(from: dict) else { continue }
            saveModelArr.append(model)
        }

        finished(saveModelArr,true)
        
    }

}