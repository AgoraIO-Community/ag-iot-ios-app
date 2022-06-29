//
//  DoorBellManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/12.
//

import UIKit
import AgoraIotSdk

class DoorBellManager: NSObject {

    public static let shared = DoorBellManager()
    
    var sdk:IAgoraIotAppSdk?{get{return gwsdk}}

    var volumeValue : Int = 10
    
    fileprivate override init() {
        super.init()
    }
    

    //设置音量
    func setDeviceVolume(volumeLevel: Int,_ cb:@escaping(Bool,String)->Void){
        sdk?.callkitMgr.setVolume(volumeLevel: volumeLevel, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
        })
    }
    
    //推本地音频到对端 mute: 是否禁止
    func muteLocalAudio(mute: Bool,cb:@escaping(Bool,String)->Void){
        sdk?.callkitMgr.muteLocaAudio(mute: mute, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("---msg---\(msg)")
        })
    }
    
    //拉取对端音频 mute: 是否禁止
    func mutePeerAudio(mute: Bool,cb:@escaping(Bool,String)->Void){
        sdk?.callkitMgr.mutePeerAudio(mute: mute, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //设置音效效果（通常是变声等音效）effectId: 音效Id
    func setAudioEffect(effectId: AudioEffectId,cb:@escaping(Bool,String)->Void){
        sdk?.callkitMgr.setAudioEffect(effectId:effectId, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //开始录制当前通话（包括音视频流），仅在通话状态下才能调用
    func talkingRecordStart(cb:@escaping(Bool,String)->Void){
        
        sdk?.callkitMgr.talkingRecordStart(result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })

    }
    
    //停止录制当前通话（包括音视频流），仅在通话状态下才能调用
    func talkingRecordStop(cb:@escaping(Bool,String)->Void){
        sdk?.callkitMgr.talkingRecordStop(result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //屏幕截屏 仅在通话状态下才能调用
    func capturePeerVideoFrame(cb:@escaping(Bool,String,UIImage?)->Void){
        sdk?.callkitMgr.capturePeerVideoFrame(result: { ec, msg, shotImage in
            cb(ec == ErrCode.XOK ? true : false , msg,shotImage)
            debugPrint("\(msg)")
        })
    }
    
    //设置设备属性
    func setSynDevicecProperty(_ dev:IotDevice,pointId:Int,value: Int, _ cb:@escaping(Bool,String)->Void){
        
        let doorBell = dev.toDoorBell()
        switch pointId {
        case 101:
            doorBell.nightView = value
            break
        case 102:
            let valueB : Bool = value == 1 ? true:false
            doorBell.motionAlarm = valueB
            break
        case 103:
            doorBell.pirSwitch = value
            break
        case 105:
            let valueB : Bool = value == 1 ? true:false
            doorBell.forceAlarm = valueB
            break
        default:
            break
        }
                
        guard let devMgr = sdk?.deviceMgr else{
            log.e("demo app manager not inited")
            return
        }
        doorBell.sync(devMgr: devMgr, result: {ec,msg in
            log.i("demo app sync result:\(msg)(\(ec))")
            cb(ec == ErrCode.XOK ? true : false,msg)
        })
    }
    
    
    func setDeviceProperty(_ dev:IotDevice,dict:Dictionary<String,Any>,cb:@escaping(Bool,String)->Void){
        log.i("------设置属性：\(dict)")
        sdk?.deviceMgr.setDeviceProperty(device: dev, properties: dict, result: {
            (ec,msg) in
            log.i("demo app sync result:\(msg)(\(ec)))")
            cb(ec == ErrCode.XOK ? true : false,msg)
        })
        
    }
    
    func getDeviceProperty(_ dev:IotDevice,cb:@escaping(Bool,String,Dictionary<String, Any>?)->Void){
        
        sdk?.deviceMgr.getDeviceProperty(device: dev, result: { ecCode, msg, resultDic in
            if ecCode == 0 {
                debugPrint("查询设备信息：\(msg)")
                cb(true,msg,resultDic)
            }else{
                debugPrint("查询设备信息：\(msg)")
//                AGToolHUD.showInfo(info: "\(msg)")
            }
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
        },actionAck: {ack in
            
            log.i("demo app callAnser ack:\(ack)")
            if(ack == .RemoteHangup){
            }
            actionAck(ack)
            
        })
        
    }

    //挂断来电
    func hungUpAnswer(cb:@escaping(Bool,String)->Void){
        
        sdk?.callkitMgr.callHangup(result: {ec,msg in
            log.i("demo app callHangup ret:\(msg)(\(ec))")
            cb(ec == ErrCode.XOK ? true : false , msg)
        })
    }
    
    func unregister(account:String, _ cb:@escaping(Bool,String)->Void){
        sdk?.accountMgr.unregister( result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false, msg)
        })
    }
    
}
