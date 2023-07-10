//
//  FsmApp.swift
//  demo
//
//  Created by ADMIN on 2022/1/29.
//

import Foundation

class AppListener : FsmApp.IListener{
    
    func on_logout_watcher(_ srcEvent: FsmApp.Event) {
        log.i("listener app.on_logout_watcher \(srcEvent)")
//        app.rule.trigger.logout_watcher()
    }
    
    var app:Application
    init(app:Application){
        self.app = app
    }
}

