//
//  DeviceShareViewModel.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/6/1.
//

import UIKit
import AgoraIotLink

class DeviceShareViewModel: NSObject {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    //分享设备给其他人
    func shareDeviceTo(device:IotDevice,account:String,type:String,cb:@escaping(Bool,String,String?)->Void){
//        ThirdAccountManager.reqUseridByAccount(account) { ec, msg, uid in
//            if(ec != ErrCode.XOK){
//                log.e("demo reqUidByAccount fail \(msg)(\(ec))")
//                cb(ec == ErrCode.XOK ? true : false , msg,nil)
//                return
//            }
//            guard let uid = uid else{
//                log.e("demo reqUidByAccount uid is nil")
//                cb(false , msg,nil)
//                return
//            }
//            self.sdk?.deviceMgr.shareDeviceTo(deviceId:device.deviceId,userId:uid,type:type, result: { ec, msg in
//                if(ec != ErrCode.XOK){
//                    log.e("demo shareDeviceTo() fail for account:\(account),uid:\(uid)")
//                }
//                else{
//                    log.i("demo shareDeviceTo() \(msg)")
//                }
//                cb(ec == ErrCode.XOK ? true : false , msg,uid)
//            })
//        }
    }
    
    //分享设备给其他人，需对方接收
//    func sharePushDeviceTo(device:IotDevice,account:String,type:String,cb:@escaping(Bool,String)->Void){
//        Service.reqUidByAccount(account) { ec, msg, uid in
//            if(ec != ErrCode.XOK){
//                log.e("demo reqUidByAccount fail \(msg)(\(ec))")
//                return
//            }
//            guard let uid = uid else{
//                log.e("demo reqUidByAccount uid is nil")
//                return
//            }
//            self.sdk?.deviceMgr.sharePushAdd(deviceNumber:device.deviceNumber,email:uid,type:type, result: { ec, msg in
//                if(ec != ErrCode.XOK){
//                    log.e("demo sharePushDeviceTo() fail for account:\(account),uid:\(uid)")
//                }
//                else{
//                    log.i("demo sharePushDeviceTo() \(msg)")
//                }
//                cb(ec == ErrCode.XOK ? true : false , msg)
//            })
//        }
//    }
    
    //取消自己共享给别人的设备
    func cancelShare(device:IotDevice,cb:@escaping(Bool,String,[DeviceCancelable]?)->Void){
//        sdk?.deviceMgr.shareCancelable(deviceId:device.deviceId,result: { ec, msg,deviceCancelable in
//            if(ec != ErrCode.XOK){
//                log.e("demo cancelShare() fail for device:\(device.deviceId)")
//            }
//            else{
//                log.i("demo cancelShare() \(msg)")
//            }
//            cb(ec == ErrCode.XOK ? true : false , msg,deviceCancelable)
//        })
    }
    
    //设备所有者解除分享权限 同时发送消息给被分享者
    func removeMember(deviceId:String,userId:String,cb:@escaping(Bool,String)->Void){
//        sdk?.deviceMgr.shareRemoveMember(deviceId:deviceId,userId:userId,result: { ec, msg in
//            if(ec != ErrCode.XOK){
//                log.e("demo removeMember() fail for device:\(deviceId)")
//            }
//            else{
//                log.i("demo removeMember() \(msg)")
//            }
//            cb(ec == ErrCode.XOK ? true : false , msg)
//        })
    }
    
}
