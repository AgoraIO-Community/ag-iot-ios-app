//
//  Fsm.swift
//  demo
//
//  Created by ADMIN on 2022/1/28.
//

//let log = Logger.shared

import Foundation

internal class Node{
    init(_ flag:Int,_ e:Int,_ s:Int,_ one:((Int)->Void)?,_ dos:((Int)->Void)?){
        F = flag
        self.e = e
        self.s = s
        self.oe = one
        self.ds = dos
    }
    
    let F:Int
    let e:Int
    let s:Int
    var oe:((Int)->Void)?
    var ds:((Int)->Void)?
}

protocol IFsm{
    var count:Int{get}
    var graph:[[Node]]{get}
    var events:[String]{get}
    var states:[String]{get}
}

class Fsm: IFsm{
    var q:DispatchQueue
    var t:Thread
    
    init(_ onPost: @escaping Fsm.PostFun) {
        self.p = onPost
        self.t = Thread.current
        self.q = DispatchQueue.main
    }
    
    var count:Int{get{return 0}}
    
    var graph:[[Node]]{get{return Fsm.Nones}}
    
    static let None = [Node(0,0,0,nil,nil)]
    static let Nones = [[Node]]()
    
    static let FLAG_NONE = 0x0
    static let FLAG_RUN = 0x01
    static let FLAG_POST = 0x02
    static let FLAG_GOON = 0x04
    static let FLAG_FSM = 0x08
    
    typealias ActFun = ()->Void
    typealias PostFun = (@escaping ActFun)->Void
    
    var state:Int = 0
    var p:PostFun? = {(act: ActFun) in}
    
    private func _s(){
        let dia = graph
        let pairs:[Node] = dia[state]
        
        for i in 0..<pairs.count {
            if(0 != (pairs[i].F & 1)){
                trans(pairs[i].e)
                break
            }
        }
    }
    
    func start(queue:DispatchQueue){
        self.q = queue
        if(queue != OperationQueue.current?.underlyingQueue){
            queue.async {
                self.t = Thread.current
                self._s()
            }
        }
        else{
            self.t = Thread.current
            _s()
        }
    }
    
    func invoke(_ pe:Int,_ pa:Node,_ a:@escaping()->Void = {}){
        let lambda = {
            let e = pa.e
            log.i("Fsm<<  \(self.states[0]): \(self.states[pe])(\(pe)) \((pa.F & 2) != 0 ? "- -" : "---") \(self.events[e])(\(e)) \((pa.F & 2) != 0 ? "- ->":"--->") \(self.states[pa.s])(\(pa.s))")
            a()
            pa.oe?(pe)
            pa.ds?(e)
        }
        if(p != nil && (pa.F & 2) != 0){
            p?(lambda)
        }
        else{
            lambda()
        }
    }
    
    func trans(_ e:Int,_ a:@escaping ()->Void = {},_ f:@escaping ()->Void){
        if(Thread.current != self.t){
            q.async {
                if(!self.trans(e,a)){
                    f()
                }
            }
        }
        else{
            if(!trans(e,a)){
                f()
            }
        }
    }

    @discardableResult
    func trans(_ evt:Int,_ action:@escaping()->Void = {})->Bool{
        let cnt = count
        let dia = graph
        var tr = false
        var go = false
        var by = false
        var cs = state
        var fd = false
        var cg = false
        var e = evt
        var act = action
        while(true){
            fd = false
            if(cs == dia.count){
                log.e("\(states[0]): at the end \(cs),\(states[state])(\(state))")
                return false
            }
            let pairs = dia[cs]
            let cure = e
            let prev = cs
            var i = 0
            while(pairs[i].e != cnt){
                let pair = pairs[i]
                i += 1
                if(!fd){
                    if((pair.F & 4) != 0){
                        if(cure != pair.e){continue}
                        go = true
                        tr = true
                        fd = true
                        
                        state = pair.s
                        cs = state
                        invoke(prev,pair,act)
                        act = {}
                        continue
                    }
                    else if(pair.e == e && !go && !tr){
                        tr = true
                        fd = true
                        
                        by = true
                        state = pair.s
                        cs = state
                        invoke(prev,pair,act)
                        act = {}
                        continue
                    }
                    else if(0 != (pair.F & 1)){
                        tr = true
                        fd = true
                        
                        e = pair.e
                        state = pair.s
                        cs = state
                        invoke(prev, pair,act)
                        act = {}
                        continue
                    }
                }
                if(cg && ((pair.F & 2) != 0)){
                    tr = true
                    invoke(prev, pair)
                }
            }
            
            if(!fd){
                break
            }
            else{
                cg = true
            }
            by = false
        }
        by = false
        if(!tr){
            log.w("Fsm<<  \(states[0]): \(states[state])(\(state)) -x- \(events[e])(\(e)) -x-> ???")
        }
        return tr
    }
    
    var events:[String]{
        return [""]
    }
    
    var states:[String]{
        return [""]
    }
}

