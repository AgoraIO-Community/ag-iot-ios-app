//FsmApp created by guzhihe@agora.io on 2022/07/15 14:11
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
        case initCall       
        case finiPush       
        case initMqtt       
        case FsmCall        
        case CallFailed     
        case finiCall       
        case logouted       
        case FsmMqtt        
        case allReady       
        case MqttFailed     
        case finiMqtt       
        case logout_watcher 
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
        case PUSH_ERROR     
        case MQTTIDLE       
        case LOGIN_FAIL     
        case LOGIN_SUCC     
        case PUSH_READY     
        case LOGOUT         
        case CALL_READY     
        case CALL_ERROR     
        case PUSHIDLE       
        case MQTT_READY     
        case MQTT_ERROR     
        case CALLIDLE       
        case LOGOUT_CONTINUE
        case INITPUSH_FAIL  
        case INITCALL       
        case NOTREADY       
        case INITMQTT_FAIL  
        case INITPUSH       
        case INITMQTT       
        case FINIPUSH       
        case FINIMQTT       
        case INITCALL_FAIL  
        case ALLREADY       
        case FINICALL       
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
        "initCall",
        "finiPush",
        "initMqtt",
        "FsmCall",
        "CallFailed",
        "finiCall",
        "logouted",
        "FsmMqtt",
        "allReady",
        "MqttFailed",
        "finiMqtt",
        "logout_watcher",
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
        "PUSH_ERROR",
        "MQTTIDLE",
        "LOGIN_FAIL",
        "LOGIN_SUCC",
        "PUSH_READY",
        "LOGOUT",
        "CALL_READY",
        "CALL_ERROR",
        "PUSHIDLE",
        "MQTT_READY",
        "MQTT_ERROR",
        "CALLIDLE",
        "LOGOUT_CONTINUE",
        "INITPUSH_FAIL",
        "INITCALL",
        "NOTREADY",
        "INITMQTT_FAIL",
        "INITPUSH",
        "INITMQTT",
        "FINIPUSH",
        "FINIMQTT",
        "INITCALL_FAIL",
        "ALLREADY",
        "FINICALL",
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
    var FsmApp_P8_initCall:[Node] = Fsm.None
    var FsmApp_P9_finiPush:[Node] = Fsm.None
    var FsmApp_P10_initMqtt:[Node] = Fsm.None
    var FsmApp_P11_FsmCall:[Node] = Fsm.None
    var FsmApp_P12_CallFailed:[Node] = Fsm.None
    var FsmApp_P13_finiCall:[Node] = Fsm.None
    var FsmApp_P14_logouted:[Node] = Fsm.None
    var FsmApp_P15_FsmMqtt:[Node] = Fsm.None
    var FsmApp_P16_allReady:[Node] = Fsm.None
    var FsmApp_P17_MqttFailed:[Node] = Fsm.None
    var FsmApp_P18_finiMqtt:[Node] = Fsm.None
    var FsmApp_P19_logout_watcher:[Node] = Fsm.None
    var FsmApp_P20_Running:[Node] = Fsm.None
    var FsmApp_P21_logouting:[Node] = Fsm.None


    var _listener : IFsmAppListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    override init(_ onPost:@escaping Fsm.PostFun){
        super.init(onPost)
        _FsmState = FsmState(onPost,self)
        _FsmPush = FsmPush(onPost,self)
        _FsmCall = FsmCall(onPost,self)
        _FsmMqtt = FsmMqtt(onPost,self)
        FsmApp_P0_FsmApp = [
            Node(Fsm.FLAG_RUN,Event.INIT.rawValue,State.Idle.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P1_Idle = [
            Node(Fsm.FLAG_RUN,Event.KICKOFF.rawValue,State.CfgReady.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.INIT_FAIL.rawValue,State.Idle.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P2_CfgReady = [
            Node(Fsm.FLAG_NONE,Event.LOGIN.rawValue,State.Logining.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.AUTOLOGIN.rawValue,State.Logining.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.MQTTIDLE.rawValue,State.CfgReady.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.NOTREADY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_NOTREADY(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P3_Logining = [
            Node(Fsm.FLAG_NONE,Event.LOGIN_FAIL.rawValue,State.CfgReady.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGIN_SUCC.rawValue,State.initPush.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P4_FsmState = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P5_initPush = [
            Node(Fsm.FLAG_NONE,Event.PUSH_ERROR.rawValue,State.PushFailed.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.PUSH_READY.rawValue,State.initCall.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiPush.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.INITPUSH.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmPush_INITPUSH(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P6_FsmPush = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P7_PushFailed = [
            Node(Fsm.FLAG_RUN,Event.NEXT.rawValue,State.initCall.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.INITPUSH_FAIL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_INITPUSH_FAIL(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P8_initCall = [
            Node(Fsm.FLAG_NONE,Event.CALL_READY.rawValue,State.initMqtt.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.CALL_ERROR.rawValue,State.CallFailed.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiCall.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.INITCALL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_INITCALL(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P9_finiPush = [
            Node(Fsm.FLAG_NONE,Event.PUSHIDLE.rawValue,State.logouted.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.logouted.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.FINIPUSH.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmPush_FINIPUSH(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P10_initMqtt = [
            Node(Fsm.FLAG_NONE,Event.MQTT_READY.rawValue,State.allReady.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.MQTT_ERROR.rawValue,State.MqttFailed.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiMqtt.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.INITMQTT.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmMqtt_INITMQTT(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P11_FsmCall = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P12_CallFailed = [
            Node(Fsm.FLAG_RUN,Event.NEXT.rawValue,State.initMqtt.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.INITCALL_FAIL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_INITCALL_FAIL(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P13_finiCall = [
            Node(Fsm.FLAG_NONE,Event.CALLIDLE.rawValue,State.finiPush.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiPush.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.FINICALL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_FINICALL(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P14_logouted = [
            Node(Fsm.FLAG_RUN,Event.LOGOUT_SUCC.rawValue,State.CfgReady.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.LOGOUT_DONE.rawValue,State.logout_watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_logout_watcher(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P15_FsmMqtt = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P16_allReady = [
            Node(Fsm.FLAG_RUN,Event.ALL_READY.rawValue,State.Running.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P17_MqttFailed = [
            Node(Fsm.FLAG_RUN,Event.NEXT.rawValue,State.allReady.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.INITMQTT_FAIL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_INITMQTT_FAIL(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P18_finiMqtt = [
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiCall.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.MQTTIDLE.rawValue,State.finiCall.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.FINIMQTT.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmMqtt_FINIMQTT(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P19_logout_watcher = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P20_Running = [
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.logouting.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.ALLREADY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmState_ALLREADY(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmApp_P21_logouting = [
            Node(Fsm.FLAG_NONE,Event.LOGOUT.rawValue,State.finiMqtt.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.LOGOUT_CONTINUE.rawValue,State.finiMqtt.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmApp_P0_FsmApp, FsmApp_P1_Idle, FsmApp_P2_CfgReady, FsmApp_P3_Logining,
            FsmApp_P4_FsmState, FsmApp_P5_initPush, FsmApp_P6_FsmPush, FsmApp_P7_PushFailed,
            FsmApp_P8_initCall, FsmApp_P9_finiPush, FsmApp_P10_initMqtt, FsmApp_P11_FsmCall,
            FsmApp_P12_CallFailed, FsmApp_P13_finiCall, FsmApp_P14_logouted, FsmApp_P15_FsmMqtt,
            FsmApp_P16_allReady, FsmApp_P17_MqttFailed, FsmApp_P18_finiMqtt, FsmApp_P19_logout_watcher,
            FsmApp_P20_Running, FsmApp_P21_logouting]

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
    private func do_FsmState_INITPUSH_FAIL(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.INITPUSH_FAIL.rawValue)}
    private func do_FsmCall_INITCALL(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.INITCALL.rawValue)}
    private func do_FsmState_NOTREADY(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.NOTREADY.rawValue)}
    private func do_FsmState_INITMQTT_FAIL(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.INITMQTT_FAIL.rawValue)}
    private func do_FsmPush_INITPUSH(_ e:Event)->Void{_FsmPush?.trans(FsmPush.Event.INITPUSH.rawValue)}
    private func do_FsmMqtt_INITMQTT(_ e:Event)->Void{_FsmMqtt?.trans(FsmMqtt.Event.INITMQTT.rawValue)}
    private func do_FsmPush_FINIPUSH(_ e:Event)->Void{_FsmPush?.trans(FsmPush.Event.FINIPUSH.rawValue)}
    private func do_FsmMqtt_FINIMQTT(_ e:Event)->Void{_FsmMqtt?.trans(FsmMqtt.Event.FINIMQTT.rawValue)}
    private func do_FsmState_INITCALL_FAIL(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.INITCALL_FAIL.rawValue)}
    private func do_FsmState_ALLREADY(_ e:Event)->Void{_FsmState?.trans(FsmState.Event.ALLREADY.rawValue)}
    private func do_FsmCall_FINICALL(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.FINICALL.rawValue)}
    //fsm
    //sub state get set
    func getFsmState()->FsmState{return _FsmState!}
    func getFsmPush()->FsmPush{return _FsmPush!}
    func getFsmCall()->FsmCall{return _FsmCall!}
    func getFsmMqtt()->FsmMqtt{return _FsmMqtt!}
    //sub state
    private var _FsmState:FsmState? = nil
    private var _FsmPush:FsmPush? = nil
    private var _FsmCall:FsmCall? = nil
    private var _FsmMqtt:FsmMqtt? = nil
};

