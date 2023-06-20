//
//  NotificationManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/5/7.
//

import Foundation

class NotificationManager : INotificationMgr{
    func getEid() -> String {
        return self.app.context.push.session.eid
    }
    
    
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
    
    func notifyEnabled() -> Bool {
        return app.context.push.session.pushEnabled == false ? false : true
    }
    
    func updateToken(_ deviceToken:Data){
        app.proxy.ntf.updateToken(deviceToken)
    }
    
//    func enableNotify(enable:Bool,result:@escaping(Int,String)->Void){
//        DispatchQueue.main.async {
//            let eid = self.app.context.push.session.eid
//            self.app.proxy.mqtt.publishEnableNotify(eid:eid,enable: enable,result: {ec,msg in
//                if(ec == ErrCode.XOK){
//                    self.app.context.push.session.pushEnabled = enable
//                }
//                self.asyncResult(ec,msg,result)
//            })
//        }
//    }

    func queryAll(result:@escaping(UNNotification,String)->Void){
        app.proxy.ntf.createQueryAllcompletion(queryAllcompletion: result)
    }

    func queryByDevice(productKey: String, deviceId: String,result:@escaping(Int,String)->Void){
        self.asyncResult(ErrCode.XERR_UNSUPPORTED,"unimplemented",result)
    }

    func delete(notificationIdList: [String],result:@escaping(Int,String)->Void){
        self.asyncResult(ErrCode.XERR_UNSUPPORTED,"unimplemented",result)
    }

    func mark(markFlag: Int, notificationIdList: [String],result:@escaping(Int,String)->Void){
        self.asyncResult(ErrCode.XERR_UNSUPPORTED,"unimplemented",result)
    }

    private var app:Application
    private var rule:RuleManager
    
    init(app:Application){
        self.app = app
        self.rule = app.rule
    }
}
