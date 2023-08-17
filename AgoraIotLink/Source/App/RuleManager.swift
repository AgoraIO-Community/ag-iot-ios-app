//
//  StateManager.swift
//  demo
//
//  Created by ADMIN on 2022/2/9.
//

import Foundation

class RuleManager{
    
    private var app:Application
    private var ctx:Context
    private var _fsmApp:FsmApp
    private var _fsmPlay:FsmPlay
    private var _trigger:TriggerListener
    private var _playback:PlayListener
    
    init(_ app:Application,_ onPost: @escaping Fsm.PostFun){
        self.app = app
        self.ctx = app.context
        _fsmApp = FsmApp(onPost)
        _fsmPlay = FsmPlay(onPost)
        _trigger = TriggerListener()
        _fsmApp.listener = AppListener(app: app)
        _playback = PlayListener(app:app)
        _fsmPlay.listener = _playback
//        _fsmApp.getFsmState().listener = app.status
        _fsmApp.getFsmPush().listener = PushListener(app:app)
        
    }
    
    var trigger:TriggerListener{get{return _trigger}}
    
    var playback : PlayListener{get{return _playback}}
    
    func start(queue:DispatchQueue){
        if(!Thread.current.isMainThread){
            DispatchQueue.main.async {
                self._fsmApp.start(queue: queue)
            }
        }
        else{
            _fsmApp.getFsmState().start(queue: queue)
            _fsmApp.getFsmPush().start(queue: queue)
            _fsmApp.start(queue:queue)
            _fsmPlay.start(queue: queue)
        }
    }
    
    private func transByMain(_ fsm:Fsm, _ evt:Int,_ act:@escaping ()->Void={},_ fail:@escaping ()->Void = {}){
        if(!Thread.current.isMainThread){
        //if(false){
            DispatchQueue.main.async {
                if(!fsm.trans(evt,act)){
                    fail()
                }
            }
        }
        else{
            if(!fsm.trans(evt,act)){
                fail()
            }
        }
    }

    func trans(_ evt:FsmApp.Event,_ act:@escaping ()->Void={},_ fail:@escaping ()->Void = {}){
        transByMain(self._fsmApp,evt.rawValue,act,fail)
    }

    func trans(_ evt:FsmPush.Event,_ act:@escaping ()->Void={},_ fail:@escaping ()->Void = {}){
        transByMain(self._fsmApp.getFsmPush(),evt.rawValue,act,fail)
    }
    
    func trans(_ evt:FsmPlay.Event,_ act:@escaping ()->Void={},_ faile:@escaping ()->Void = {}){
        transByMain(self._fsmPlay,evt.rawValue,act,faile)
    }
}
