//
//  DeviceManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/2/22.
//

import Foundation

class DeviceManager : IDeviceMgr{

    private func asyncResult(_ ec:Int,_ msg:String,_ result:@escaping(Int,String)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1)
        }
    }
    
    private func asyncResultData<T>(_ ec:Int,_ msg:String,_ data:T,_ result:@escaping(Int,String,T)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data)
        }
    }
    
    private func asyncResultData2<T,D>(_ ec:Int,_ msg:String,_ data1:T,_ data2:D,_ result:@escaping(Int,String,T,D)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data1,data2)
        }
    }
    
    private func asyncResultData2<T,U>(_ ec:Int,_ msg:String,_ data:T?,_ data2:U?,_ result:@escaping(Int,String,T?,U?)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data,data2)
        }
    }
    
    func sharePushDetail(id: String, result: @escaping (Int, String, ShareDetail?) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            let detail:ShareDetail? = nil
            self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",detail,result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushDetail(token: token, id: id, rsp: {ec,msg,al in self.asyncResultData(ec,msg,al,result)})
        }
    }
    
    func sharePushList(pageNo: Int, pageSize: Int, auditStatus: String, result: @escaping (Int, String, [ShareItem]?, PageTurn?) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            let si:[ShareItem]? = nil
            let pt:PageTurn? = nil
            self.asyncResultData2(ErrCode.XERR_TOKEN_INVALID,"token invalid",si,pt,result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushList(token: token, pageNo: pageNo, pageSize: pageSize, auditStatus: auditStatus, rsp: {ec,msg,s,p in self.asyncResultData2(ec, msg, s, p, result)})
        }
    }
    
    func shareDeviceTo(deviceId: String, userId: String, type: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareToUser(token: token, deviceId: deviceId, userId: userId, type: type, rsp: {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func shareDeviceAccept(deviceNickName: String, order: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareAccept(token: token, deviceName: deviceNickName, order: order, rsp: {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func shareGetOwnDevices(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as [DeviceShare]?,result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareOwnDevice(token: token, rsp: {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func shareWithMe(result: @escaping (Int, String, [DeviceShare]?) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as [DeviceShare]?,result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareWithMe(token: token, rsp: {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func shareCancelable(deviceId: String, result: @escaping (Int, String, [DeviceCancelable]?) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as [DeviceCancelable]?,result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareCancelable(token: token, deviceId: deviceId, rsp: {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func shareRemoveMember(deviceId: String, userId: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.shareRemove(token: token, deviceId: deviceId, userId: userId, rsp: {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func sharePushAdd(deviceNumber: String, email: String, type: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushAdd(token: token, deviceNumber: deviceNumber, email: email, type: type, rsp: {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func sharePushDel(id: String, result: @escaping (Int, String) -> Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.sharePushDel(token: token, id: id, rsp: {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
//    func register(listener: IDeviceStateListener) {
//        DispatchQueue.main.async {
//            self.app.proxy.mqtt.setListener(listener: listener)
//            //self.app.proxy.rtm.setOnDataArrived(onDataArrived: onDataArrived)
//        }
//    }
    
    func queryProductList(query:ProductQueryParam, result:@escaping(Int,String,[ProductInfo])->Void){
        let token = self.app.context.gyiot.session.iotlink_token
        let venderId = self.app.config.projectId
        if(token == ""){
            let pi:[ProductInfo] = []
            self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",pi,result)
            return
        }
        DispatchQueue.main.async {
            query.blurry = venderId
            self.app.proxy.gw.reqProductList(token,query, {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func renameDevice(deviceId: String, newName: String, result:@escaping(Int,String)->Void) {
        let token = self.app.context.gyiot.session.iotlink_token
        let filter = self.app.context.callbackFilter
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.reqRenameDevice(token, deviceId, newName, {ec,msg in self.asyncResult(ec, msg, result)})
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
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            result(ErrCode.XERR_DEVMGR_QUEYR,"token invalid",[])
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
            
            let dev = self.app.context.devices
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
                let query = ProductQueryParam()
                query.blurry = self.app.config.projectId
                self.app.proxy.gw.reqProductList(token,query,cbPrd)
                //log.i("products info list has not recved,continue waiting ...")
                log.i("devMgr products info list is nil,try to reqProductList ...")
                return
            }
            self.app.context.devices = dev
            self.associateDeviceAndProduct(devs: dev, prds: prd)
            result(ec,msg,dev)
            self.app.context.products = nil
        }
        
        self.app.context.devices = []
        self.app.proxy.gw.reqAllDevice(token, cbDev)
    }
    
    func queryAllDevices(result:@escaping(Int,String,[IotDevice])->Void) {
        DispatchQueue.main.async {
            self.doQueryAllDevice(result: {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func addDevice(productId: String, deviceId: String,result:@escaping(Int,String)->Void){
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            //self.app.proxy.gw.reqBindDevice(token,productId,deviceId, {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
            self.asyncResult(ErrCode.XERR_UNSUPPORTED,"unimplemented",result)
        }
    }

    func removeDevice(deviceId:String,result:@escaping(Int,String)->Void){
        let token = self.app.context.gyiot.session.iotlink_token
        if(token == ""){
            self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.gw.reqUnbindDevice(token,deviceId,{ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
//    func sendCommandToDevice(productKey: String?, deviceId: String?, command: String?,result:(Int,String)->Void){
//        log.w("devMgr not implemented")
//        let filter = self.app.context.callBackFilter
//        let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未支持")
//        result(ret.0,ret.1)
//    }
    func getPropertyDescription(deviceId:String,productNumber:String,result: @escaping (Int, String, [Property]) -> Void) {
        if(deviceId != "" && productNumber != ""){
            log.e("deviceId and productNumber can't be both empty")
            self.asyncResultData(ErrCode.XERR_INVALID_PARAM, "param error", [], result)
            return
        }
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqProperty(token,deviceId, productNumber, {ec,msg,p in self.asyncResultData(ec, msg, p, result)})
            }
     }
    
//    func setDeviceProperty(deviceId: String, properties: Dictionary<String, Any>, result: @escaping (Int, String) -> Void) {
//        DispatchQueue.main.async {
//            self.app.proxy.mqtt.setDeviceStatus(account: self.app.context.gyiot.session.account, things_name: deviceId, params: properties, result: {ec,msg in self.asyncResult(ec, msg, result)})
//        }
//    }
    
//    func getDeviceProperty(deviceId:String, result: @escaping (Int, String, Dictionary<String, Any>?,Dictionary<String, Any>?) -> Void) {
//        DispatchQueue.main.async {
//            self.app.proxy.mqtt.getDeviceStatus(things_name: deviceId,result:{ec,msg,d1,d2 in self.asyncResultData2(ec, msg,d1,d2, result)})
//        }
//    }
    
    func otaGetInfo(deviceId:String, result: @escaping (Int, String, FirmwareInfo?) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqOtaInfo(token,deviceId,{ec,msg,info in self.asyncResultData(ec, msg, info, result)})
        }
    }
    
    func otaUpgrade(upgradeId: String,result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqOtaUpdate(token,upgradeId,2, {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func otaQuery(upgradeId: String, result: @escaping (Int, String, FirmwareStatus?) -> Void) {
        DispatchQueue.main.async {
            let token = self.app.context.gyiot.session.iotlink_token
            self.app.proxy.gw.reqOtaStatus(token,upgradeId, {ec,msg,s in self.asyncResultData(ec, msg, s,result)})
        }
    }
    
    func sendMessageBegin(deviceId: String,result:@escaping(Int,String)->Void,statusUpdated:@escaping(MessageChannelStatus,String,Data?)->Void) {
        DispatchQueue.main.async {
            //todo:remove rtm shadow update below
//            let dictRtm:[String:Any] = ["appId":self.app.config.appId]
//            let reportedRtm:[String:Any] = ["reported":dictRtm]
//            let stateJsonRtm:[String:Any] = ["state":reportedRtm]
//            let strRtm = JSON(stateJsonRtm)
//            let jsonStrRtm = strRtm.rawString([.castNilToNSNull:true])
//            
//            var topicRtmUpdate = "$aws/things/" + device.deviceId + "/shadow/name/rtm/update"
//            self.app.proxy.mqtt.publish(data: jsonStrRtm!, topic: topicRtmUpdate, qos: .messageDeliveryAttemptedAtLeastOnce)
//            
//            topicRtmUpdate = "$aws/things/" + self.app.context.virtualNumber + "/shadow/name/rtm/update"
//            self.app.proxy.mqtt.publish(data: jsonStrRtm!, topic: topicRtmUpdate, qos: .messageDeliveryAttemptedAtLeastOnce)

            let agToken = self.app.context.aglab.session.accessToken
            let local = self.app.context.virtualNumber
            let peer = deviceId

//            self.app.proxy.al.reqControlInfo(agToken, local, peer) { ec, msg, sess in
//                if(ErrCode.XOK == ec){
//                    guard let sess = sess else{
//                        log.e("rtm sess is nil")
//                        self.asyncResult(ErrCode.XERR_UNKNOWN,msg,result)
//                        return
//                    }
//                    self.app.context.rtm.session.token = sess.token
//                    self.app.context.rtm.session.peerVirtualNumber = peer
//                    let uid = self.app.context.virtualNumber
//                    self.app.proxy.rtm.enter(self.app.context.rtm.session,uid,statusUpdated) { tr, msg in
//                        if(tr != .Succ){
//                            log.e("rtm enter not succ,reset session")
//                            self.app.context.rtm.session.reset()
//                        }
//                        self.asyncResult(tr == .Succ ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,msg,result)
//                    }
//                }
//                else{
//                    self.asyncResult(ec,msg,result)
//                }
//            }
        }
    }
    
    func sendMessageEnd() {
//        self.app.proxy.rtm.leave { succ in
//            if(!succ){
//                log.w("rtm leave fail")
//            }
//        }
    }
    
    func sendMessage(data: Data, description: String, result: @escaping (Int, String) -> Void) {
//        DispatchQueue.main.async {
//            let peerVirtualNumber = self.app.context.rtm.session.peerVirtualNumber
//            self.app.proxy.rtm.sendRawMessage(toPeer: peerVirtualNumber, data: data, description: description, cb: {ec,msg in self.asyncResult(ec,msg,result)})
//        }
    }
    
    private func doStartPlayback(channelName: String, result: @escaping (Int, String) -> Void,stateChanged:@escaping(PlaybackStatus,String)->Void){
        //todo:
//        let appId = self.app.config.appId
//        let agToken = self.app.context.aglab.session.accessToken
//        app.proxy.al.reqPlayerToekn(agToken, appId, channelName) { ec, msg, sess in
//            if(ec != ErrCode.XOK){
//                result(ec,msg)
//                return
//            }
//            guard let sess = sess else{
//                result(ErrCode.XERR_INVALID_PARAM,"param error")
//                return
//            }
//            self.app.rule.trans(FsmPlay.Event.STARTPLAY,
//                                {self.app.rule.playback.start(channelName: sess.channelName,token: sess.token, uid: sess.uid, result: result, stateChanged: stateChanged)},
//                                {self.asyncResult(ErrCode.XERR_BAD_STATE,"state error",result)})
//
//        }
    }
    
    func startPlayback(channelName: String, result: @escaping (Int, String) -> Void,stateChanged:@escaping(PlaybackStatus,String)->Void){
        DispatchQueue.main.async {
            self.doStartPlayback(channelName: channelName, result: result, stateChanged: stateChanged)
        }
    }
    
    func setPlaybackView(peerView: UIView?) -> Int {
        //todo:
//        return self.app.rule.playback.setPlaybackView(peerView: peerView)
        return 0
    }
    
    func stopPlayback() {
        //todo:
//        self.app.rule.trans(FsmPlay.Event.RESETRTC,
//                            {self.app.rule.playback.stop()})
    }
    
    private var app:Application
    
    init(app:Application){
        self.app = app
    }
}
