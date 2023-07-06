//
//  DoorBellManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/12.
//

import UIKit
import AgoraIotLink

class DoorBellManager: NSObject {
    
    public static let shared = DoorBellManager()
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}

    var volumeValue : Int = 10
    var members:Int = 0
    var isPlaying:Bool = false
    
    var mSessionId = "" //当前会话Id
    
    fileprivate override init() {
        super.init()
    }
    
    func previewStart(sessionId:String,previewListener: @escaping (_ sessionId:String,_ videoWidth:Int,_ videoHeight:Int) -> Void){
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.previewStart { sessionId, videoWidth, videoHeight in
            previewListener(sessionId,videoWidth,videoHeight)
        }
    }
    
    func previewStop(sessionId:String,result:@escaping(Bool,String)->Void){
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.previewStop { ec, msg in
            result(ec == ErrCode.XOK ? true : false , msg)
        }
    }

    func getDevSessionMgr(_ sessionId:String)->IDevPreviewMgr{
        return (sdk?.deviceSessionMgr.getDevPreviewMgr(sessionId: sessionId))!
    }
    
    //设置音量
    func setDeviceVolume(sessionId:String,volumeLevel: Int,_ cb:@escaping(Bool,String)->Void){
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.setPlaybackVolume(volumeLevel: volumeLevel, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
        })
    }
    
    //推本地音频到对端 mute: 是否禁止
    func muteLocalAudio(sessionId:String,mute: Bool,cb:@escaping(Bool,String)->Void){
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.muteLocalAudio(mute: mute, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("---msg---\(msg)")
        })
    }
    
    //拉取对端音频 mute: 是否禁止
    func mutePeerAudio(sessionId:String, mute: Bool,cb:@escaping(Bool,String)->Void){
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.mutePeerAudio(mute: mute, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //设置音效效果（通常是变声等音效）effectId: 音效Id
    func setAudioEffect(sessionId:String = "",effectId: AudioEffectId,cb:@escaping(Bool,String)->Void){
        //todo:
        let callkitMgr = getDevSessionMgr("")
        callkitMgr.setAudioEffect(effectId:effectId, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //开始录制当前通话（包括音视频流），仅在通话状态下才能调用
    func talkingRecordStart(outFilePath:String = "", sessionId:String = "",cb:@escaping(Bool,String)->Void){
        //todo:
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.recordingStart(outFilePath: outFilePath, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })

    }
    
    //停止录制当前通话（包括音视频流），仅在通话状态下才能调用
    func talkingRecordStop(sessionId:String = "",cb:@escaping(Bool,String)->Void){
        //todo:
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.recordingStop(result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //屏幕截屏 仅在通话状态下才能调用
    func capturePeerVideoFrame(sessionId:String = "", cb:@escaping(Bool,String,UIImage?)->Void){
        let callkitMgr = getDevSessionMgr(sessionId)
        callkitMgr.captureVideoFrame(result: { ec, msg, shotImage in
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
                
//        guard let devMgr = sdk?.deviceMgr else{
//            log.e("demo app manager not inited")
//            return
//        }
//        doorBell.sync(devMgr: devMgr, result: {ec,msg in
//            log.i("demo app sync result:\(msg)(\(ec))")
//            cb(ec == ErrCode.XOK ? true : false,msg)
//        })
    }
    
    
    func setDeviceProperty(_ dev:IotDevice,dict:Dictionary<String,Any>,cb:@escaping(Bool,String)->Void){
        log.i("------设置属性：\(dict)")
//        sdk?.deviceMgr.setDeviceProperty(deviceId: dev.deviceId, properties: dict, result: {
//            (ec,msg) in
//            log.i("demo app sync result:\(msg)(\(ec)))")
//            cb(ec == ErrCode.XOK ? true : false,msg)
//        })
        
    }
    
    func getDeviceProperty(_ dev:IotDevice,cb:@escaping(Bool,String,Dictionary<String, Any>?,Dictionary<String, Any>?)->Void){
        
//        sdk?.deviceMgr.getDeviceProperty(deviceId: dev.deviceId, result: { ecCode, msg, desiredDic,reportedDic in
//            if ecCode == 0 {
//                debugPrint("查询设备信息：\(msg)")
//                cb(true,msg,desiredDic,reportedDic)
//            }else{
//                debugPrint("查询设备信息：\(msg)")
////                AGToolHUD.showInfo(info: "\(msg)")
//            }
//        })
        
    }
    
    //接听来电
    func callAnswer(sessionId:String = "" ,cb:@escaping(Bool,String)->Void){
//         sdk?.callkitMgr.callAnswer(sessionId:sessionId, pubLocalAudio:true, result: {ec,msg in
//             self.sdk?.callkitMgr.muteLocalAudio(sessionId: sessionId, mute: true, result: { ec, msg in})
//            log.i("demo app callAnswer ret:\(msg)(\(ec))")
//            if(ec == ErrCode.XOK){
//                cb(ec == ErrCode.XOK ? true : false , msg)
//            }
//        })
        
        cb(true , "")
    }

    //挂断来电
    func hungUpAnswer( sessionId:String = "" ,cb:@escaping(Bool,String)->Void){
        var tempSessionId = sessionId
        if sessionId == ""{
            tempSessionId = mSessionId
        }else{
            mSessionId = sessionId
        }
        let ret = sdk?.deviceSessionMgr.disconnect(sessionId: tempSessionId)
        if ret == 0 {
            log.i("demo app callHangup ret:")
            debugPrint("挂断 ret:(\(String(describing: ret)))")
            DoorBellManager.shared.members = 0
            cb( true, "")
        }else{
            debugPrint("挂断 ret:(\(String(describing: ret)))")
        }

    }
    
    func unregister(account:String, _ cb:@escaping(Bool,String)->Void){
//        sdk?.accountMgr.unregister( result: { ec, msg in
//            cb(ec == ErrCode.XOK ? true : false, msg)
//        })
        //note:
        let accAndPwd = TDUserInforManager.shared.readKeyChainAccountAndPwd()
        ThirdAccountManager.reqUnRegister(account, accAndPwd.pwd) { ec, msg in
            cb(ec == ErrCode.XOK ? true : false, msg)
        }
    }
    
    func disConnectDevice(sessionId:String = "")->Void{
        let devSessionMgr = sdk?.deviceSessionMgr.disconnect(sessionId: sessionId)
    }
        
    //-------------------------------设备控制----------------------------------
    
    func getDevControlMgr(_ sessionId:String)->IDevControllerMgr{
        return (sdk?.deviceSessionMgr.getDevController(sessionId: sessionId))!
    }
                
    //云台命令 仅在通话状态下才能调用
    func sendCmdPtzCtrl(sessionId:String = "", cb:@escaping(Int,String)->Void){
        let controlMgr = getDevControlMgr(sessionId)
        controlMgr.sendCmdPtzCtrl(action: 0, direction: 1, speed: 1) { errCode, msg in
            print("sendCmdPtzCtrl---:\(errCode)")
            cb(errCode,msg as! String)
        }
        controlMgr.sendCmdPtzReset(cmdListener: cb)
        controlMgr.sendCmdPtzCtrl(cmdListener: cb)
    }
    
    
    func getDevMediaMgr(_ sessionId:String)->IDevMediaMgr{
        return (sdk?.deviceSessionMgr.getDevMediaMgr(sessionId: sessionId))!
    }
    
    //SD卡回看命令 仅在通话状态下才能调用
    func sendCmdSDCtrl(sessionId:String = "", cb:@escaping(Int,String)->Void){
        
        let mediaMgr = getDevMediaMgr(sessionId)
        
//        let param = QueryParam(mFileId: 0, mBeginTimestamp: 12, mEndTimestamp: 20, mPageIndex: 0, mPageSize: 10)
//        mediaMgr.queryMediaList(queryParam: param) { errCode, mediaList in
//            print("sendCmdSDCtrl---:\(errCode) mediaList:\(mediaList)")
//            cb(errCode,"success")
//        }
        
//        mediaMgr.deleteMediaList(deletingList: ["1","2","3"]) { errCode, undeletedList in
//            print("sendCmdSDCtrl---:\(errCode) mediaList:\(undeletedList)")
//            cb(errCode,"success")
//        }
        
//        mediaMgr.queryMediaCoverImage(imgUrl: "http://jd.com/image1.jpg") { errCode, result in
//            print("sendCmdSDCtrl---:\(errCode) mediaList:\(result)")
//            cb(errCode,"success")
//        }
        
         mediaMgr.play(globalStartTime: 0, playingCallListener: self)
        
//          mediaMgr.play(fileId: "1", startPos: 989898989, playSpeed: 1, playingCallListener: self)
        
//        mediaMgr.stop()
        
//          mediaMgr.setPlayingSpeed(speed: 2)
        
    }
    
    
   //-------------------------------设备控制----------------------------------
}

extension DoorBellManager:IPlayingCallbackListener{
    
    func onDevPlayingStateChanged(mediaUrl: String, newState: Int) {
        
    }
    
    func onDevMediaOpenDone(mediaUrl: String, errCode: Int) {
        
    }
    
    func onDevMediaSeekDone(mediaUrl: String, errCode: Int, targetPos: UInt64, seekedPos: UInt64) {
        
    }
    
    func onDevMediaPlayingDone(mediaUrl: String, duration: UInt64) {
        
    }
    
    func onDevPlayingError(mediaUrl: String, errCode: Int) {
        
    }
}
