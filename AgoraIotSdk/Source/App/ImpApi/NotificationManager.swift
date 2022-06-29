//
//  NotificationManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/5/7.
//

import Foundation

class NotificationManager : INotificationMgr{
    func notifyEnabled() -> Bool {
        return app.context.push.session.pushEnabled == false ? false : true
    }
    
    func updateToken(_ deviceToken:Data){
        app.proxy.ntf.updateToken(deviceToken)
    }
    
    func enableNotify(enable:Bool,result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let eid = self.app.context.push.session.eid
            self.app.proxy.mqtt.publishEnableNotify(eid:eid,enable: enable,result: {ec,msg in
                if(ec == ErrCode.XOK){
                    self.app.context.push.session.pushEnabled = enable
                }
                let filter = self.app.context.callBackFilter
                let ret = filter(ec,msg);result(ret.0,ret.1)
                result(ret.0,ret.1)
            })
        }
    }

    func queryAll(result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let filter = self.app.context.callBackFilter
            let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未实现");result(ret.0,ret.1)
            result(ret.0,ret.1)
        }
    }

    func queryByDevice(productKey: String, deviceId: String,result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let filter = self.app.context.callBackFilter
            let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未实现");result(ret.0,ret.1)
            result(ret.0,ret.1)
        }
    }

    func delete(notificationIdList: [String],result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let filter = self.app.context.callBackFilter
            let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未实现");result(ret.0,ret.1)
            result(ret.0,ret.1)
        }
    }

    func mark(markFlag: Int, notificationIdList: [String],result:@escaping(Int,String)->Void){
        DispatchQueue.main.async {
            let filter = self.app.context.callBackFilter
            let ret = filter(ErrCode.XERR_UNSUPPORTED,"暂未实现");result(ret.0,ret.1)
            result(ret.0,ret.1)
        }
    }

    private var app:Application
    private var rule:RuleManager
    
    init(app:Application){
        self.app = app
        self.rule = app.rule
    }
}
