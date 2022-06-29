//FsmPush created by guzhihe@agora.io on 2022/06/23 17:05
import Foundation
protocol IFsmPushListener{
    //srcState:initSucc
    func do_LOGIN(_ srcState:FsmPush.State)
     //srcEvent:INITPUSH
    func on_initialize(_ srcEvent:FsmPush.Event)
     //srcEvent:FINIPUSH
    func on_destroy(_ srcEvent:FsmPush.Event)
 };
class FsmPush : Fsm {
    typealias IListener = IFsmPushListener
    enum State : Int{
        case FsmPush        
        case idle           
        case initialize     
        case initSucc       
        case initFail       
        case logining       
        case ntfReady       
        case loginFail      
        case destroy        
        case push_finalizing
        case SCount         
    };

    enum Event : Int{
        case IDLE           
        case LOGIN          
        case INITPUSHFAIL   
        case FINIPUSH_SUCC  
        case INITPUSH       
        case INITSUCC       
        case INITFAIL       
        case LOGINSUCC      
        case LOGINFAIL      
        case FINIPUSH       
        case DESTROYED      
        case PUSH_READY     
        case PUSH_ERROR     
        case PUSHIDLE       
        case ECount         
    };

    let s_State:[String] = [
        "FsmPush",
        "idle",
        "initialize",
        "initSucc",
        "initFail",
        "logining",
        "ntfReady",
        "loginFail",
        "destroy",
        "push_finalizing",
        "*"
    ];

    let s_Event:[String] = [
        "IDLE",
        "LOGIN",
        "INITPUSHFAIL",
        "FINIPUSH_SUCC",
        "INITPUSH",
        "INITSUCC",
        "INITFAIL",
        "LOGINSUCC",
        "LOGINFAIL",
        "FINIPUSH",
        "DESTROYED",
        "PUSH_READY",
        "PUSH_ERROR",
        "PUSHIDLE",
        "*"
    ];

    var FsmPush_P0_FsmPush:[Node] = Fsm.None
    var FsmPush_P1_idle:[Node] = Fsm.None
    var FsmPush_P2_initialize:[Node] = Fsm.None
    var FsmPush_P3_initSucc:[Node] = Fsm.None
    var FsmPush_P4_initFail:[Node] = Fsm.None
    var FsmPush_P5_logining:[Node] = Fsm.None
    var FsmPush_P6_ntfReady:[Node] = Fsm.None
    var FsmPush_P7_loginFail:[Node] = Fsm.None
    var FsmPush_P8_destroy:[Node] = Fsm.None
    var FsmPush_P9_push_finalizing:[Node] = Fsm.None


    var _listener : IFsmPushListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    init(_ onPost:@escaping Fsm.PostFun,_ _FsmApp:FsmApp){
        super.init(onPost)
        self._FsmApp = _FsmApp
        FsmPush_P0_FsmPush = [
            Node(Fsm.FLAG_RUN,Event.IDLE.rawValue,State.idle.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P1_idle = [
            Node(Fsm.FLAG_NONE,Event.INITPUSH.rawValue,State.initialize.rawValue,nil,{(e:Int)->Void in self._listener?.on_initialize(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P2_initialize = [
            Node(Fsm.FLAG_NONE,Event.INITSUCC.rawValue,State.initSucc.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.INITFAIL.rawValue,State.initFail.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P3_initSucc = [
            Node(Fsm.FLAG_RUN,Event.LOGIN.rawValue,State.logining.rawValue,{(s:Int)->Void in self._listener?.do_LOGIN(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P4_initFail = [
            Node(Fsm.FLAG_RUN,Event.INITPUSHFAIL.rawValue,State.initSucc.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P5_logining = [
            Node(Fsm.FLAG_NONE,Event.LOGINSUCC.rawValue,State.ntfReady.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGINFAIL.rawValue,State.loginFail.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P6_ntfReady = [
            Node(Fsm.FLAG_NONE,Event.FINIPUSH.rawValue,State.destroy.rawValue,nil,{(e:Int)->Void in self._listener?.on_destroy(Event(rawValue:e)!)}),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.PUSH_READY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmApp_PUSH_READY(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P7_loginFail = [
            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.PUSH_ERROR.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmApp_PUSH_ERROR(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P8_destroy = [
            Node(Fsm.FLAG_NONE,Event.DESTROYED.rawValue,State.push_finalizing.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPush_P9_push_finalizing = [
            Node(Fsm.FLAG_RUN,Event.FINIPUSH_SUCC.rawValue,State.idle.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.PUSHIDLE.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmApp_PUSHIDLE(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmPush_P0_FsmPush, FsmPush_P1_idle, FsmPush_P2_initialize, FsmPush_P3_initSucc,
            FsmPush_P4_initFail, FsmPush_P5_logining, FsmPush_P6_ntfReady, FsmPush_P7_loginFail,
            FsmPush_P8_destroy, FsmPush_P9_push_finalizing]

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
    private func do_FsmApp_PUSH_READY(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.PUSH_READY.rawValue)}
    private func do_FsmApp_PUSH_ERROR(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.PUSH_ERROR.rawValue)}
    private func do_FsmApp_PUSHIDLE(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.PUSHIDLE.rawValue)}
    //fsm
    private var _FsmApp:Fsm? = nil
};

