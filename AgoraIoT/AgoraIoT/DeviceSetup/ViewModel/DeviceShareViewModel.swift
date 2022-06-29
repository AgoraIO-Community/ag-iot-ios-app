//
//  DeviceShareViewModel.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/6/1.
//

import UIKit
import AgoraIotSdk

class DeviceShareViewModel: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return gwsdk}}
    
    //分享设备给其他人
    func shareDeviceTo(device:IotDevice,account:String,type:String,cb:@escaping(Bool,String)->Void){
        sdk?.deviceMgr.shareDeviceTo(deviceNumber:device.deviceNumber,account:account,type:type, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //分享设备给其他人，需对方接收
    func sharePushDeviceTo(device:IotDevice,account:String,type:String,cb:@escaping(Bool,String)->Void){
        sdk?.deviceMgr.sharePushAdd(deviceNumber:device.deviceNumber,email:account,type:type, result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
    //取消自己共享给别人的设备
    func cancelShare(device:IotDevice,cb:@escaping(Bool,String,[DeviceCancelable]?)->Void){
        sdk?.deviceMgr.shareCancelable(deviceNumber:device.deviceNumber,result: { ec, msg,deviceCancelable in
            cb(ec == ErrCode.XOK ? true : false , msg,deviceCancelable)
            
            debugPrint("\(msg)")
        })
    }
    
    //设备所有者解除分享权限 同时发送消息给被分享者
    func removeMember(deviceId:String,userId:String,cb:@escaping(Bool,String)->Void){
        sdk?.deviceMgr.shareRemoveMember(deviceNumber:deviceId,userId:userId,result: { ec, msg in
            cb(ec == ErrCode.XOK ? true : false , msg)
            debugPrint("\(msg)")
        })
    }
    
}
