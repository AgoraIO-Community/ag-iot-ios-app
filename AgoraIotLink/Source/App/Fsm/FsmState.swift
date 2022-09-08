//FsmState created by guzhihe@agora.io on 2022/08/16 16:34
import Foundation
protocol IFsmStateListener{
    //srcState:idle
    func do_INITRTM_FAIL(_ srcState:FsmState.State)
     //srcState:idle
    func do_INITPUSH_FAIL(_ srcState:FsmState.State)
     //srcState:idle
    func do_INITCALL_FAIL(_ srcState:FsmState.State)
     //srcState:idle
    func do_INITMQTT_FAIL(_ srcState:FsmState.State)
     //srcState:idle
    func do_NOTREADY(_ srcState:FsmState.State)
     //srcState:idle
    func do_ALLREADY(_ srcState:FsmState.State)
 };
class FsmState : Fsm {
    typealias IListener = IFsmStateListener
    enum State : Int{
        case FsmState       
        case idle           
        case SCount         
    };

    enum Event : Int{
        case INIT           
        case INITRTM_FAIL   
        case INITPUSH_FAIL  
        case INITCALL_FAIL  
        case INITMQTT_FAIL  
        case NOTREADY       
        case ALLREADY       
        case ECount         
    };

    let s_State:[String] = [
        "FsmState",
        "idle",
        "*"
    ];

    let s_Event:[String] = [
        "INIT",
        "INITRTM_FAIL",
        "INITPUSH_FAIL",
        "INITCALL_FAIL",
        "INITMQTT_FAIL",
        "NOTREADY",
        "ALLREADY",
        "*"
    ];

    var FsmState_P0_FsmState:[Node] = Fsm.None
    var FsmState_P1_idle:[Node] = Fsm.None


    var _listener : IFsmStateListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    init(_ onPost:@escaping Fsm.PostFun,_ _FsmApp:FsmApp){
        super.init(onPost)
        FsmState_P0_FsmState = [
            Node(Fsm.FLAG_RUN,Event.INIT.rawValue,State.idle.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmState_P1_idle = [
            Node(Fsm.FLAG_NONE,Event.INITRTM_FAIL.rawValue,State.idle.rawValue,{(s:Int)->Void in self._listener?.do_INITRTM_FAIL(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.INITPUSH_FAIL.rawValue,State.idle.rawValue,{(s:Int)->Void in self._listener?.do_INITPUSH_FAIL(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.INITCALL_FAIL.rawValue,State.idle.rawValue,{(s:Int)->Void in self._listener?.do_INITCALL_FAIL(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.INITMQTT_FAIL.rawValue,State.idle.rawValue,{(s:Int)->Void in self._listener?.do_INITMQTT_FAIL(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.NOTREADY.rawValue,State.idle.rawValue,{(s:Int)->Void in self._listener?.do_NOTREADY(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.ALLREADY.rawValue,State.idle.rawValue,{(s:Int)->Void in self._listener?.do_ALLREADY(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmState_P0_FsmState, FsmState_P1_idle]

    }
    //override
    override var events:[String]{get{return s_Event}}
    override var states:[String]{get{return s_State}}
    override var graph:[[Node]]{get{return _diagram}}
    override var count:Int{get{return Event.ECount.rawValue}}
    @discardableResult
    func trans(_ event:Event,_ act:@escaping()->Void={})->Bool{
        return super.trans(event.rawValue,act)
    }
    //trans
    //fsm
};

