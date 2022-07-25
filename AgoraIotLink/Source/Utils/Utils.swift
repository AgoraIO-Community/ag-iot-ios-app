//
//  Utils.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/25.
//

import Foundation

enum TaskResult{
    case Succ
    case Fail
    case Abort
}
class TimeCallback<T>{
    public typealias GenericClosure<T> = (T) -> ()
    var _callback:GenericClosure<T>
    var _timer:Timer
    //var timer:Timer{get{return _timer}set{_timer = newValue}}
    var callback:GenericClosure<T>{get{return _callback}set{_callback = newValue}}
    
    public init(cb:@escaping GenericClosure<T>){
        _callback = cb
        _timer = Timer()
    }
    public func schedule(time:Double,timeout:@escaping()->Void){
        _timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false){tm in
            DispatchQueue.main.async {
                timeout()
            }
        }
    }
    public func invalidate(){
        DispatchQueue.main.async {
            if(self._timer.isValid){
                self._timer.invalidate()
            }
        }
    }
    public func invoke(args:T)->Void{
        //DispatchQueue.main.async {
            if(self._timer.isValid){
                self._timer.invalidate()
                self._callback(args)
            }
        //}
    }
}
