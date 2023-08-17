//
//  FsmApp.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

class AppListener : FsmApp.IListener{
    func on_initRtm(_ srcEvent: FsmApp.Event) {
////        let session = app.context.rtm.session
//        let setting = app.context.rtm.setting
//
////        let agToken = app.context.aglab.session.token.acessToken
////        let localVNumber = self.app.context.virtualNumber
//        let succ = app.proxy.rtm.create(setting)
//        self.app.rule.trans(succ ? FsmApp.Event.RTM_READY : FsmApp.Event.RTM_ERROR)
    }
    
    func on_finiRtm(_ srcEvent: FsmApp.Event) {
//        app.proxy.rtm.destroy();
//        self.app.rule.trans(FsmApp.Event.RTMIDLE)
    }
    
    func on_logout_watcher(_ srcEvent: FsmApp.Event) {
        log.i("listener app.on_logout_watcher \(srcEvent)")
        app.rule.trigger.logout_watcher()
    }
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}

