//
//  DeviceManager.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/26.
//

import Foundation
import AgoraIotLink

class DeviceManager {
    
    static let shared = DeviceManager()
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}

    private (set) var devices:[IotDevice]?
    
    var deviceIds:[String]? {
        get{
            guard let devs = devices else {
                return nil
            }
            var ids = [String]()
            for dev in devs {
                ids.append(dev.deviceId)
            }
            return ids
        }
    }
    
    func displayPropertyList(){
        guard let devMgr = sdk?.deviceMgr else{
            log.e("sdk 设备服务 未初始化")
            return
        }
        let param = ProductQueryParam()
        devMgr.queryProductList(query: param) { ec, msg, prods in
            for prd in prods{
                devMgr.getPropertyDescription(deviceId:"",productNumber: prd.number) { ec, msg, props in
                    if(ec == ErrCode.XOK){
                        for prop in props{
                            log.i("demo dp for \(prd.number)")
                            log.i("        pointName: \(prop.pointName)")
                            log.i("        pointName: \(prop.pointName)")
                            log.i("         maxValue: \(prop.maxValue)")
                            log.i("           remark: \(prop.remark)")
                            log.i("         markName: \(prop.markName)")
                            log.i("           status: \(prop.status)")
                        }
                    }
                }
            }
        }
    }
    
    /// 获取最新设备列表
    /// - Parameter cb: 回调
    func updateDevicesList(_ cb:@escaping (Bool,String,[IotDevice]?)->Void){
        guard let devMgr = sdk?.deviceMgr else{
            cb(false,"sdk 设备服务 未初始化",nil)
            return
        }
        devMgr.queryAllDevices(result: {ec,msg,devs in
            self.devices = devs
            cb(ec == ErrCode.XOK ? true : false,msg,devs)
        })
        
        
    }
    
    /// 通过id获取设备信息
    /// - Parameters:
    ///   - deviceId: id
    ///   - forceUpdate: 强制更新devices列表
    ///   - result: 结果回调
    func queryDeviceWithId(_ deviceId: String, forceUpdate: Bool = false, result: @escaping (Bool,String,IotDevice?)->Void) {
        if self.devices == nil || forceUpdate {
            updateDevicesList { [weak self] ec, msg, devs in
                if ec == false {
                    result(ec,msg,nil)
                    return
                }
                self?.devices = devs
                result(true,"",self?.deviceWithId(deviceId))
            }
            return
        }
        result(true,"",deviceWithId(deviceId))
    }
        
    func renameDevice(device: IotDevice, newName: String, result:@escaping(Int,String)->Void) {
        sdk?.deviceMgr.renameDevice(deviceId: device.deviceId, newName: newName, result: result)
    }
    
    // 查询分享给自己的设备
    func qureyShareWithMe(result: @escaping([DeviceShare]?)->Void) {
        sdk?.deviceMgr.shareWithMe(result: { ec, msg, share in
            if ec == ErrCode.XOK {
                result(share)
            }
        })
    }
    
    // 查询是否有未读的分享
//    func qureySharePushList(result: @escaping([ShareItem]?)->Void){
//        sdk?.deviceMgr.sharePushList(pageNo: 0, pageSize: 10, auditStatus: "f", result: { ec, msg, items, _ in
//            if ec == ErrCode.XOK {
//                result(items)
//            }
//        })
//    }
    
//    func acceptDevice(_ name:String,order:String, result:@escaping((Int, String)->Void)){
//        sdk?.deviceMgr.shareDeviceAccept(deviceNickName: name, order: order, result: result)
//    }
    
//    func refuseDevice(id: String, result: @escaping (Int, String) -> Void){
//        sdk?.deviceMgr.sharePushDel(id: id, result: result)
//    }

    func removeDevice(_ device: IotDevice,result:@escaping(Int,String)->Void) {
        sdk?.deviceMgr.removeDevice(deviceId: device.deviceId, result:result)
    }
    private func deviceWithId(_ id: String) -> IotDevice? {
        for device in self.devices! {
            if device.deviceId == id {
                return device
            }
        }
        return nil
    }
}
