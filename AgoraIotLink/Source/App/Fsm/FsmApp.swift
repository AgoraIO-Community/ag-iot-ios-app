//FsmApp created by guzhihe@agora.io on 2022/09/27 15:52
import Foundation
protocol IFsmAppListener{
     //srcEvent:LOGOUT_DONE
    func on_logout_watcher(_ srcEvent:FsmApp.Event)
 };
class FsmApp : Fsm {
    typealias IListener = IFsmAppListener
    enum State : Int{
        case FsmApp
        case Idle
        case CfgReady
        case Logining
        case FsmState
        case initPush
        case FsmPush
        case PushFailed
        case finiPush
        case logouted
        case logout_watcher
        case allReady
        case Running
        case logouting
        case SCount
    };

    enum Event : Int{
        case INIT
        case KICKOFF
        case NEXT
        case LOGOUT_SUCC
        case ALL_READY
        case INIT_FAIL
        case LOGIN
        case AUTOLOGIN
        case LOGOUT
        case LOGIN_FAIL
        case LOGIN_SUCC
        case LOGOUT_CONTINUE
        case PUSH_ERROR
        case PUSH_READY
        case PUSHIDLE
        case NOTREADY
        case INITPUSH
        case INITPUSH_FAIL
        case FINIPUSH
        case ALLREADY
        case LOGOUT_DONE
        case ECount
    };

    let s_State:[String] = [
        "FsmApp",
        "Idle",
        "CfgReady",
        "Logining",
        "FsmState",
        "initPush",
        "FsmPush",
        "PushFailed",
        "finiPush",
        "logouted",
        "logout_watcher",
        "allReady",
        "Running",
        "logouting",
        "*"
    ];

    let s_Event:[String] = [
        "INIT",
        "KICKOFF",
        "NEXT",
        "LOGOUT_SUCC",
        "ALL_READY",
        "INIT_FAIL",
        "LOGIN",
        "AUTOLOGIN",
        "LOGOUT",
        "LOGIN_FAIL",
        "LOGIN_SUCC",
        "LOGOUT_CONTINUE",
        "PUSH_ERROR",
        "PUSH_READY",
        "PUSHIDLE",
        "NOTREADY",
        "INITPUSH",
        "INITPUSH_FAIL",
        "FINIPUSH",
        "ALLREADY",
        "LOGOUT_DONE",
        "*"
    ];

    var FsmApp_P0_FsmApp:[Node] = Fsm.None
    var FsmApp_P1_Idle:[Node] = Fsm.None
    var FsmApp_P2_CfgReady:[Node] = Fsm.None
    var FsmApp_P3_Logining:[Node] = Fsm.None
    var FsmApp_P4_FsmState:[Node] = Fsm.None
    var FsmApp_P5_initPush:[Node] = Fsm.None
    var FsmApp_P6_FsmPush:[Node] = Fsm.None
    var FsmApp_P7_PushFailed:[Node] = Fsm.None
    var FsmApp_P9_finiPush:[Node] = Fsm.None
    var FsmApp_P14_logouted:[Node] = Fsm.None
    var FsmApp_P19_logout_watcher:[Node] = Fsm.None
    var FsmApp_P20_allReady:[Node] = Fsm.None
    var FsmApp_P23_Running:[Node] = Fsm.None
    var FsmApp_P24_logouting:[Node] = Fsm.None


    var _listener : IFsmAppListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    override init(_ onPost:@escaping Fsm.PostFun){
        super.init(onPost)
        _FsmState = FsmState(onPost,self)
        _FsmPush = FsmPush(onPost,self)
        FsmApp_P0_FsmApp = [
            Node(Fsm.FLAG_RUN,Event.INIT.rawValue,State.Idle.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P1_Idle = [
            Node(Fsm.FLAG_RUN,Event.KICKOFF.rawValue,State.CfgReady.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE,Event.INIT_FAIL.rawValue,State.Idle.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P2_CfgReady = [
            Node(Fsm.FLAG_NONE,Event.LOGIN.rawValue,State.Logining.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE,Event.AUTOLOGIN.rawValue,State.Logining.rawValue,nil,nil),
            Node(Fsm.FLAG_POST,Event.NOTREADY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_NOTREADY(Event(rawValue:e)!)},nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P3_Logining = [
            Node(Fsm.FLAG_NONE,Event.LOGIN_FAIL.rawValue,State.CfgReady.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE,Event.LOGIN_SUCC.rawValue,State.initPush.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P4_FsmState = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P5_initPush = [
            Node(Fsm.FLAG_NONE,Event.PUSH_ERROR.rawValue,State.PushFailed.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE,Event.PUSH_READY.rawValue,State.allReady.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiPush.rawValue,nil,nil),
            Node(Fsm.FLAG_POST,Event.INITPUSH.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmPush_INITPUSH(Event(rawValue:e)!)},nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P6_FsmPush = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P7_PushFailed = [
            Node(Fsm.FLAG_RUN,Event.NEXT.rawValue,State.allReady.rawValue,nil,nil),
            Node(Fsm.FLAG_POST,Event.INITPUSH_FAIL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_INITPUSH_FAIL(Event(rawValue:e)!)},nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P9_finiPush = [
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.logouted.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE,Event.PUSHIDLE.rawValue,State.logouted.rawValue,nil,nil),
            Node(Fsm.FLAG_POST,Event.FINIPUSH.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmPush_FINIPUSH(Event(rawValue:e)!)},nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P14_logouted = [
            Node(Fsm.FLAG_RUN,Event.LOGOUT_SUCC.rawValue,State.CfgReady.rawValue,nil,nil),
            Node(Fsm.FLAG_POST,Event.LOGOUT_DONE.rawValue,State.logout_watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_logout_watcher(Event(rawValue:e)!)}),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P19_logout_watcher = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P20_allReady = [
            Node(Fsm.FLAG_RUN,Event.ALL_READY.rawValue,State.Running.rawValue,nil,nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P23_Running = [
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.logouting.rawValue,nil,nil),
            Node(Fsm.FLAG_POST,Event.ALLREADY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_ALLREADY(Event(rawValue:e)!)},nil),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P24_logouting = [
            Node(Fsm.FLAG_NONE,Event.LOGOUT_CONTINUE.rawValue,State.finiPush.rawValue,nil,{(e:Int)->Void in }),
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiPush.rawValue,nil,{(e:Int)->Void in }),
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmApp_P0_FsmApp, FsmApp_P1_Idle, FsmApp_P2_CfgReady, FsmApp_P3_Logining,
            FsmApp_P4_FsmState, FsmApp_P5_initPush, FsmApp_P6_FsmPush, FsmApp_P7_PushFailed,
            FsmApp_P9_finiPush, FsmApp_P14_logouted, FsmApp_P19_logout_watcher,
            FsmApp_P20_allReady, FsmApp_P23_Running,
            FsmApp_P24_logouting]

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
    private func do_FsmState_NOTREADY(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.NOTREADY.rawValue)}
    private func do_FsmPush_INITPUSH(_ e:Event)->Void{_FsmPush?.trans(FsmPush.Event.INITPUSH.rawValue)}
    private func do_FsmState_INITPUSH_FAIL(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.INITPUSH_FAIL.rawValue)}
    private func do_FsmPush_FINIPUSH(_ e:Event)->Void{_FsmPush?.trans(FsmPush.Event.FINIPUSH.rawValue)}
    private func do_FsmState_ALLREADY(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.ALLREADY.rawValue)}
    //fsm
    //sub state get set
    func getFsmState()->FsmState{return _FsmState!}
    func getFsmPush()->FsmPush{return _FsmPush!}
    //sub state
    private var _FsmState:FsmState? = nil
    private var _FsmPush:FsmPush? = nil
};


