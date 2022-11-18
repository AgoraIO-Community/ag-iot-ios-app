//
//  AlarmManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/14.
//

import Foundation

class AlarmManager : IAlarmMgr{
    
    private func asyncResult(_ ec:Int,_ msg:String,_ result:@escaping(Int,String)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1)
        }
    }
    
    private func asyncResultValue<T>(_ ec:Int,_ msg:String,_ data:T,_ result:@escaping(Int,String,T)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data)
        }
    }
    
    private func asyncResultData<T>(_ ec:Int,_ msg:String,_ data:T?,_ result:@escaping(Int,String,T?)->Void) {
        DispatchQueue.main.async {
            let filter = self.app.context.callbackFilter
            let ret = filter(ec,msg)
            result(ret.0,ret.1,data)
        }
    }
    
    func queryByParam(queryParam: QueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        DispatchQueue.main.async {
            let tenantId = self.app.context.gyiot.session.cert.thingName
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as [IotAlarm]?, result)
                return
            }
            self.app.proxy.al.reqAlert(agToken, tenantId, queryParam, {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func queryById(alertMessageId:UInt64, result:@escaping (Int,String,IotAlarm?) -> Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as IotAlarm?, result)
                return
            }
            self.app.proxy.al.reqAlertById(agToken,alertMessageId,{ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func queryByPage(queryParam: QueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        DispatchQueue.main.async {
            let tenantId = self.app.context.gyiot.session.cert.thingName
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as [IotAlarm]?, result)
                return
            }
            self.app.proxy.al.reqAlert(agToken,tenantId, queryParam, {ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func mark(alarmIdList: [UInt64],result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
                return
            }
            self.app.proxy.al.reqAlertBatchRead(agToken, alarmIdList, {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func addAlarm(device:IotDevice,desc:String,result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.accessToken
            let tenantId = self.app.context.gyiot.session.cert.thingName
            if(agToken == ""){
                self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
                return
            }
            self.app.proxy.al.reqAddAlert(agToken, tenantId, device.productId, device.deviceId, device.deviceName, desc, result)
        }
    }
        
    func delete(alarmIdList: [UInt64], result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
                return
            }
            self.app.proxy.al.reqAlertBatchDelete(agToken,alarmIdList,{ec,msg in self.asyncResult(ec, msg,result)})
        }
    }
    
    func queryCount(productId:String?,deviceId:String?,messageType:Int?,status:Int?,createDateBegin:Date?,createDateEnd:Date? ,result:@escaping(Int,String,UInt)->Void){
        DispatchQueue.main.async {
            let tenant = self.app.context.gyiot.session.cert.thingName
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResultValue(ErrCode.XERR_TOKEN_INVALID,"token invalid",0 as UInt,result)
                return
            }
            self.app.proxy.al.reqAlertCount(agToken, tenant, productId, deviceId, messageType: messageType, status, createDateBegin, createDateEnd, {ec,msg,al in self.asyncResultValue(ec, msg, al, result)})
        }
    }
    
    func queryAlarmImage(alertImageId:String,result:@escaping(Int,String,String?)->Void){
        DispatchQueue.main.async {
            let tenant = self.app.context.gyiot.session.cert.thingName
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResultValue(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil,result)
                return
            }
            self.app.proxy.al.reqAlertImageUrl(agToken, tenant, alertImageId) { ec, msg, url in
                self.asyncResultValue(ec, msg, url, result)
            }
        }
    }
    
    func queryAlarmVideoUrl(deviceId:String,tenantId:String, beginTime:UInt64,result:@escaping(Int,String,AlarmVideoInfo?)->Void){
        DispatchQueue.main.async {
            let tenant = self.app.context.gyiot.session.cert.thingName
            let agToken = self.app.context.aglab.session.accessToken
            let userId = tenantId
            if(agToken == ""){
                self.asyncResultValue(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil,result)
                return
            }
            self.app.proxy.al.reqAlertVideoUrl(agToken, userId, deviceId, beginTime) { ec, msg, info in
                self.asyncResultValue(ec, msg, info, result)
            }
        }
    }
    
    func querySysByParam(queryParam: SysQueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        var ids:[String] = [String]()
        if(queryParam.deviceIds.count == 0){
            //note:try to walkaround by restoring deviceIds,because sever can't acquire device id information
            if(self.app.context.devices.count == 0){
                log.w("current device is nil")
                self.asyncResultData(ErrCode.XOK,"no corespond device alert",[] as [IotAlarm],result)
                return
            }
            for item in app.context.devices{
                ids.append(item.deviceId)
            }
            queryParam.deviceIds = ids
        }
        DispatchQueue.main.async {
            let tenantId = self.app.context.gyiot.session.cert.thingName
            let agToken = self.app.context.aglab.session.accessToken
            
            if(agToken == ""){
                self.asyncResultData(ErrCode.XERR_TOKEN_INVALID,"token invalid",nil as [IotAlarm]?,result)
                return
            }
            self.app.proxy.al.reqSysAlert(agToken, tenantId, queryParam, {ec,msg,al in self.asyncResultData(ec,msg,al,result)})
        }
    }
    
    func querySysById(alertMessageId:UInt64, result:@escaping (Int,String,IotAlarm?) -> Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.accessToken
            if(self.app.context.devices.count == 0){
                self.asyncResultData(ErrCode.XERR_UNSUPPORTED,"no corespond device alert",nil as IotAlarm?,result)
                return
            }
            if(agToken == ""){
                self.asyncResultData(ErrCode.XERR_UNSUPPORTED,"no corespond device alert",nil as IotAlarm?,result)
                return
            }
            self.app.proxy.al.reqSysAlertById(agToken,alertMessageId,{ec,msg,al in self.asyncResultData(ec, msg, al, result)})
        }
    }
    
    func markSys(alarmIdList: [UInt64],result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.accessToken
            if(agToken == ""){
                self.asyncResult(ErrCode.XERR_TOKEN_INVALID,"token invalid",result)
                return
            }
            self.app.proxy.al.reqSysAlertBatchRead(agToken, alarmIdList, {ec,msg in self.asyncResult(ec, msg, result)})
        }
    }
    
    func querySysCount(productId:String?,deviceIds:[String],messageType:Int?,status:Int?,createDateBegin:Date?,createDateEnd:Date? ,result:@escaping(Int,String,UInt)->Void){
        let agToken = app.context.aglab.session.accessToken
        let tenant = app.context.gyiot.session.cert.thingName
        
        var ids:[String] = deviceIds
        if(deviceIds.count == 0){
            //note:try to walkaround by restoring deviceIds,because sever can't acquire device id information
            if(app.context.devices.count == 0){
                log.i("current devices count is 0")
                self.asyncResultValue(ErrCode.XOK,"no corespond device alert",0 as UInt,result)
                return
            }
            for item in app.context.devices{
                ids.append(item.deviceId)
            }
        }
        if(agToken == ""){
            self.asyncResultValue(ErrCode.XERR_TOKEN_INVALID,"token invalid",0 as UInt,result)
            return
        }
        DispatchQueue.main.async {
            self.app.proxy.al.reqSysAlertCount(agToken, tenant, productId, ids, messageType: messageType, status, createDateBegin, createDateEnd, {ec,msg,al in self.asyncResultValue(ec, msg, al, result)})
        }
    }
    
    private var app:Application
    
    init(app:Application){
        self.app = app
    }
}
