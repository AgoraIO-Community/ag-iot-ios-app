//
//  AlarmManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/14.
//

import Foundation

class AlarmManager : IAlarmMgr{
    
    func queryByParam(queryParam: QueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        DispatchQueue.main.async {
            let tenantId = self.app.context.gran.session.cert.thingName
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,nil)
                return
            }
            self.app.proxy.al.reqAlert(agToken, tenantId, queryParam, {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func queryById(alertMessageId:UInt64, result:@escaping (Int,String,IotAlarm?) -> Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,nil)
                return
            }
            self.app.proxy.al.reqAlertById(agToken,alertMessageId,{ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func queryByPage(queryParam: QueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        DispatchQueue.main.async {
            let tenantId = self.app.context.gran.session.cert.thingName
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,nil)
                return
            }
            self.app.proxy.al.reqAlert(agToken,tenantId, queryParam, {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func mark(alarmIdList: [UInt64],result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1)
                return
            }
            self.app.proxy.al.reqAlertBatchRead(agToken, alarmIdList, {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
        
    func delete(alarmIdList: [UInt64], result: @escaping (Int, String) -> Void) {
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1)
                return
            }
            self.app.proxy.al.reqAlertBatchDelete(agToken,alarmIdList,{ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func queryCount(productId:String?,deviceId:String?,messageType:Int?,status:Int?,createDateBegin:Date?,createDateEnd:Date? ,result:@escaping(Int,String,UInt)->Void){
        DispatchQueue.main.async {
            let tenant = self.app.context.gran.session.cert.thingName
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,0)
                return
            }
            self.app.proxy.al.reqAlertCount(agToken, tenant, productId, deviceId, messageType: messageType, status, createDateBegin, createDateEnd, {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func querySysByParam(queryParam: SysQueryParam, result: @escaping (Int, String, [IotAlarm]?) -> Void) {
        var ids:[String] = [String]()
        let filter = self.app.context.callBackFilter
        if(queryParam.deviceIds.count == 0){
            //note:try to walkaround by restoring deviceIds,because sever can't acquire device id information
            if(app.context.devices == nil || self.app.context.devices?.count == 0){
                log.w("current device is nil")
                let ret = filter(ErrCode.XOK,"没有查询到对应设备的告警")
                result(ret.0,ret.1,[])
                return
            }
            for item in app.context.devices!{
                ids.append(item.deviceId)
            }
            queryParam.deviceIds = ids
        }
        DispatchQueue.main.async {
            let tenantId = self.app.context.gran.session.cert.thingName
            let agToken = self.app.context.aglab.session.token.acessToken
            
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,nil)
                return
            }
            self.app.proxy.al.reqSysAlert(agToken, tenantId, queryParam, {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func querySysById(alertMessageId:UInt64, result:@escaping (Int,String,IotAlarm?) -> Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(self.app.context.devices == nil || self.app.context.devices?.count == 0){
                let ret = filter(ErrCode.XERR_UNSUPPORTED,"没有查询到对应设备的告警")
                result(ret.0,ret.1,nil)
                return
            }
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,nil)
                return
            }
            self.app.proxy.al.reqSysAlertById(agToken,alertMessageId,{ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    func markSys(alarmIdList: [UInt64],result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let agToken = self.app.context.aglab.session.token.acessToken
            let filter = self.app.context.callBackFilter
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1)
                return
            }
            self.app.proxy.al.reqSysAlertBatchRead(agToken, alarmIdList, {ec,msg in let ret = filter(ec,msg);result(ret.0,ret.1)})
        }
    }
    
    func querySysCount(productId:String?,deviceIds:[String],messageType:Int?,status:Int?,createDateBegin:Date?,createDateEnd:Date? ,result:@escaping(Int,String,UInt)->Void){
        let agToken = app.context.aglab.session.token.acessToken
        let tenant = app.context.gran.session.cert.thingName
        let filter = self.app.context.callBackFilter
        
        var ids:[String] = deviceIds
        if(deviceIds.count == 0){
            //note:try to walkaround by restoring deviceIds,because sever can't acquire device id information
            if(app.context.devices == nil || self.app.context.devices?.count == 0){
                log.w("current device is nil")
                let ret = filter(ErrCode.XOK,"没有查询到对应设备的告警")
                result(ret.0,ret.1,0)
                return
            }
            for item in app.context.devices!{
                ids.append(item.deviceId)
            }
        }
        DispatchQueue.main.async {
            if(agToken == ""){
                let ret = filter(ErrCode.XERR_TOKEN_INVALID,"token 无效")
                result(ret.0,ret.1,0)
                return
            }
            self.app.proxy.al.reqSysAlertCount(agToken, tenant, productId, ids, messageType: messageType, status, createDateBegin, createDateEnd, {ec,msg,al in let ret = filter(ec,msg);result(ret.0,ret.1,al)})
        }
    }
    
    private var app:Application
    
    init(app:Application){
        self.app = app
    }
}
