//
//  DeviceManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/2/22.
//

import Foundation

class DeviceManager : IDeviceMgr{
    func sharePushDetail(id: String, result: @escaping (Int, String, ShareDetail?) -> Void) {
        let filter = self.app.context.callbackFilter
        let token = self.app.context.gran.session.granwin_token
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1,nil)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushDetail(token: token, id: id, rsp: {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func sharePushList(pageNo: Int, pageSize: Int, auditStatus: String, result: @escaping (Int, String, [ShareItem]?, PageTurn?) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1,nil,nil)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushList(token: token, pageNo: pageNo, pageSize: pageSize, auditStatus: auditStatus, rsp: {ec,msg,s,p in let ret = filter(ec,msg);result(ret.0,ret.1,s,p)})
        }
    }
    
    func shareDeviceTo(deviceNumber: String, account: String, type: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareToUser(token: token, deviceNumber: deviceNumber, email: account, type: type, rsp: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func shareDeviceAccept(deviceNickName: String, order: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareAccept(token: token, deviceName: deviceNickName, order: order, rsp: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func shareGetOwnDevices(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1,nil)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareOwnDevice(token: token, rsp: {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func shareWithMe(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1,nil)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareWithMe(token: token, rsp: {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func shareCancelable(deviceNumber: String, result: @escaping (Int, String, [DeviceCancelable]?) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1,nil)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareCancelable(token: token, deviceNumber: deviceNumber, rsp: {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func shareRemoveMember(deviceNumber: String, userId: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareRemove(token: token, deviceNumber: deviceNumber, userId: userId, rsp: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func sharePushAdd(deviceNumber: String, email: String, type: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushAdd(token: token, deviceNumber: deviceNumber, email: email, type: type, rsp: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func sharePushDel(id: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushDel(token: token, id: id, rsp: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func register(listener: IDeviceStateListener) {
        DispatchQueue.main.async {
            self.app.proxy.mqtt.setListener(listener: listener)
        }
    }
    
    func queryProductList(result:@escaping(Int,String,[ProductInfo])->Void){
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        let venderId = self.app.config.projectId
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1,[])
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.reqProductList(token,venderId, {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func renameDevice(device: IotDevice, newName: String, result:@escaping(Int,String)->Void) {
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.reqRenameDevice(token, String(device.deviceNumber), newName, {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    private func associateDeviceAndProduct(devs:[IotDevice],prds:[ProductInfo]){
        log.i("devMgr associateDeviceAndProduct(\(devs.count),\(prds.count))")
        for dev in devs {
            for prd in prds {
                if dev.productNumber == prd.number {
                    dev.productInfo = prd
                }
            }
            if(dev.productInfo == nil){
                log.e("devMgr can't pair device for \(dev.productNumber)")
            }
        }
    }
    
    private func doQueryAllDevice(result:@escaping(Int,String,[IotDevice])->Void){
        let token = self.app.context.gran.session.granwin_token
        if(token == ""){
            result(ErrCode.XERR_DEVMGR_QUEYR,"token 无效",[])
            return
        }
        let cbPrd = {
            (ec:Int,msg:String,prd:[ProductInfo]) in
            if(ec == ErrCode.XOK){
                self.app.context.products = prd
            }
            if(ec != ErrCode.XOK && self.app.context.devices != nil){
                result(ec,msg,[])
                return
            }
            
            guard let dev = self.app.context.devices else{
                log.i("devMgr devices info list has not recved,continue waiting ...")
                return
            }
            self.app.context.products = prd
            self.associateDeviceAndProduct(devs: dev, prds: prd)
            result(ec,msg,dev)
            self.app.context.products = nil
        }
        
        let cbDev = {
            (ec:Int,msg:String,dev:[IotDevice]) in
            self.app.context.devices = dev
            if(ec != ErrCode.XOK && self.app.context.products != nil){
                result(ec,msg,[])
                return
            }
            guard let prd = self.app.context.products else{
                self.app.proxy.gw.reqProductList(token,self.app.config.projectId,cbPrd)
                //log.i("products info list has not recved,continue waiting ...")
                log.i("devMgr products info list is nil,try to reqProductList ...")
                return
            }
            self.app.context.devices = dev
            self.associateDeviceAndProduct(devs: dev, prds: prd)
            result(ec,msg,dev)
            self.app.context.products = nil
        }
        
        self.app.context.devices = nil
        self.app.proxy.gw.reqAllDevice(token, cbDev)
    }
    
    func queryAllDevices(result:@escaping(Int,String,[IotDevice])->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            self.doQueryAllDevice(result: {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func addDevice(productId: String, deviceId: String,result:@escaping(Int,String)->Void){
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            //self.app.proxy.gw.reqBindDevice(token,productId,deviceId, {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
            let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未实现")
            result(ret.0,ret.1)
        }
    }

    func removeDevice(device:IotDevice,result:@escaping(Int,String)->Void){
        let token = self.app.context.gran.session.granwin_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
            result(ret.0,ret.1)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.reqUnbindDevice(token,device.deviceNumber,
            {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
//    func sendCommandToDevice(productKey: String?, deviceId: String?, command: String?,result:(Int,String)->Void){
//        log.w("devMgr not implemented")
//        let filter = self.app.context.callBackFilter
//        let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未支持")
//        result(ret.0,ret.1)
//    }
    
    func setDeviceProperty(device: IotDevice, properties: Dictionary<String, Any>, result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let sess = self.app.context.gran.session
            let filter = self.app.context.callbackFilter
            self.app.proxy.mqtt.setDeviceStatus(account: sess.account, productId: device.productId, things_name: device.deviceId, params: properties, result: {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func getDeviceProperty(device: IotDevice, result: @escaping (Int, String, Dictionary<String, Any>?) -> Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            self.app.proxy.mqtt.getDeviceStatus(things_name: device.deviceId,result:{ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    private var app:Application
    
    init(app:Application){
        self.app = app
    }
}
