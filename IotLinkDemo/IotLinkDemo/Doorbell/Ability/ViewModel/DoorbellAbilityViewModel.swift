//
//  DoorbellAbilityViewModel.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit
import AgoraIotLink

class DoorbellAbilityViewModel: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    var members:Int = 0
    //呼叫设备
    func wakeupDevice(_ dev:IotDevice,_ cb:@escaping(Bool,String)->Void,_ action:@escaping(ActionAck)->Void){
        guard let callMgr = sdk?.callkitMgr else{
            cb(false,"sdk 呼叫服务 未初始化")
            return
        }
        callMgr.callDial(device:dev,attachMsg: "",result:{
            (ec,msg) in
            cb(ec == ErrCode.XOK ? true : false , msg)
        },actionAck: {s in
            var msg = "未知的设备操作"
            switch(s){
                case .AcceptFail:msg="接听失败"
                case .RemoteAnswer:msg = "设备接听"
                case .RemoteHangup:msg = "设备挂断"
                case .RemoteBusy:msg = "设备忙碌"
                case .LocalAnswer:msg = "本地接听"
                case .LocalHangup:msg = "本地挂断"
                case .UnknownAction:msg = "未知行为"
                case .RemoteVideoReady:msg = "首次收到设备视频"
                case .RemoteAudioReady:msg = "首次收到设备音频"
                case .CallForward:msg = "呼叫中"
                case .CallIncoming:msg = "设备来电"
                case .CallOutgoing:msg = "本地拨通"
                case .LocalTimeout:msg = "呼叫超时"
                case .StateInited:msg = "初始化呼叫状态"
                case .RemoteTimeout:msg = "对端超时"
                case .RecordEnd:msg = "云录停止"
                
            }
            log.i("呼叫事件:\(msg)")
            if(s == .RemoteHangup){
//                self._status.trans(FsmView.Event.BACK)
                self.members = 0
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
            }
            if(s == .RemoteAnswer){
                self.members = self.members + 1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
            }
            action(s)
        },memberState:{s,a in
            log.i("demo app member:\(a) \(s.rawValue)")
            if(s == .Enter){self.members = self.members + 1}
            if(s == .Leave){self.members = self.members - 1}
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
        })
        
        //sdk?.callkitMgr.mutePeerVideo(mute: false, result: { state, msg in

//        })
    }
 
    //挂断设备
    func hangupDevice(_ cb:@escaping(Bool,String)->Void){
        log.i("demo app local req Hangup")
        guard let callMgr = sdk?.callkitMgr else{
            cb(false,"sdk 呼叫服务 未初始化")
            return
        }
        members = 0
        iotsdk.callkitMgr.callHangup(result: { ec, msg in
            log.i("demo app call Hangup result:\(msg)(\(ec))")
            cb(ec == ErrCode.XOK ? true : false,msg)
        })
    }
    
    //接听来电
    func callAnswer(cb:@escaping(Bool,String)->Void,
                    actionAck:@escaping(ActionAck)->Void){
         sdk?.callkitMgr.callAnswer(result: {ec,msg in
            log.i("demo app callAnswer ret:\(msg)(\(ec))")
            if(ec == ErrCode.XOK){
                cb(ec == ErrCode.XOK ? true : false , msg)
            }
        },
        actionAck: {ack in
            
            log.i("demo app callAnser ack:\(ack)")
             if(ack == .RemoteHangup){
 //                self._status.trans(FsmView.Event.BACK)
                 self.members = 0
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
             }
             if(ack == .RemoteAnswer){
                 self.members = self.members + 1
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
             }
            actionAck(ack)
            
        },
        memberState:{s,a in
             log.i("demo app member:\(a) \(s.rawValue)")
             if(s == .Enter){self.members = self.members + a.count}
             if(s == .Leave){self.members = self.members - a.count}
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: cMemberStateUpdated), object: nil, userInfo: ["members":self.members])
         })
        
    }
    
    
    //-----------------------以上为获取网络数据部分----------------------------

    //MARK: 初始化设备属性设置数据
    func loadDoorbellAbilityPropertyData(finished: @escaping ( _ modelArr:[DoorbellAbilityModel]?,_ isSuccess:Bool)->()){
        
        let jsonString = "{\"code\":200,\"msg\":\"获取成功\",\"dataList\":[{\"abilityName\":\"回放\",\"abilityIcon\":\"func1\",\"abilitySecectIcon\":\"func1\",\"abilityId\":10000},{\"abilityName\":\"相册\",\"abilityIcon\":\"func2\",\"abilitySecectIcon\":\"func2\",\"abilityId\":10002},{\"abilityName\":\"强拆报警\",\"abilityIcon\":\"func3\",\"abilitySecectIcon\":\"func3_on\",\"abilityId\":105},{\"abilityName\":\"红外夜视\",\"abilityIcon\":\"func4\",\"abilitySecectIcon\":\"func4_on\",\"abilityId\":101},{\"abilityName\":\"声音检测\",\"abilityIcon\":\"func5\",\"abilitySecectIcon\":\"func5_on\",\"abilityId\":115},{\"abilityName\":\"移动侦测\",\"abilityIcon\":\"func6\",\"abilitySecectIcon\":\"func6_on\",\"abilityId\":102},{\"abilityName\":\"PIR开关\",\"abilityIcon\":\"func7\",\"abilitySecectIcon\":\"func7_on\",\"abilityId\":103},{\"abilityName\":\"警笛\",\"abilityIcon\":\"func8\",\"abilitySecectIcon\":\"func8_on\",\"abilityId\":114}]}"
        
        let dict = getDictionaryFromJSONString(jsonString: String(describing: jsonString).removingPercentEncoding!)
        
        //debugPrint(dict)
        
        
        guard let arr = dict["dataList"] as? [[String: Any]] else {
            
            finished(nil,false)
            
            return
        }
        var saveModelArr = [DoorbellAbilityModel]()
        for dict in arr {
            guard let model = DoorbellAbilityModel.deserialize(from: dict) else { continue }
            saveModelArr.append(model)
        }

        finished(saveModelArr,true)
        
    }
    
    //MARK: 初始化变声属性设置数据
    func loadSoundChangePropertyData(finished: @escaping ( _ modelArr:[DoorbellChangeSoundModel]?,_ isSuccess:Bool)->()){
        
        let jsonString = "{\"code\":200,\"msg\":\"获取成功\",\"dataList\":[{\"soundName\":\"原生\",\"soundIcon\":\"voice1\",\"soundId\":101},{\"soundName\":\"大叔\",\"soundIcon\":\"voice2\",\"soundId\":102},{\"soundName\":\"萝莉\",\"soundIcon\":\"voice3\",\"soundId\":103},{\"soundName\":\"少年\",\"soundIcon\":\"voice4\",\"soundId\":104}]}"
        
        let dict = getDictionaryFromJSONString(jsonString: String(describing: jsonString).removingPercentEncoding!)
        
        debugPrint(dict)
        
        
        guard let arr = dict["dataList"] as? [[String: Any]] else {
            
            finished(nil,false)
            
            return
        }
        var saveModelArr = [DoorbellChangeSoundModel]()
        for dict in arr {
            guard let model = DoorbellChangeSoundModel.deserialize(from: dict) else { continue }
            saveModelArr.append(model)
        }

        finished(saveModelArr,true)
        
    }
    
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
