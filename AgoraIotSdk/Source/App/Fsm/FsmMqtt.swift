//FsmMqtt created by guzhihe@agora.io on 2022/06/23 17:05
import Foundation
protocol IFsmMqttListener{
    //srcState:Connected
    func do_SUBMIT(_ srcState:FsmMqtt.State)
     //srcState:idle
    func do_INITMQTT(_ srcState:FsmMqtt.State)
     //srcState:Disconnected,ConnectionError
    func do_CONN(_ srcState:FsmMqtt.State)
     //srcEvent:FINIMQTT
    func on_disconnect(_ srcEvent:FsmMqtt.Event)
 };
class FsmMqtt : Fsm {
    typealias IListener = IFsmMqttListener
    enum State : Int{
        case FsmMqtt        
        case idle           
        case Disconnected   
        case Connecting     
        case disconnect     
        case Connected      
        case ConnectionRefused
        case ConnectionError
        case ConnFail       
        case disconnecting  
        case Submitting     
        case Submitted      
        case Running        
        case SCount         
    };

    enum Event : Int{
        case IDLE           
        case DISCONN        
        case SUBMIT         
        case RESET          
        case DISCONNECTED   
        case RUN            
        case INITMQTT       
        case CONN           
        case FINIMQTT       
        case CONN_SUCC      
        case CONN_REFUSE    
        case CONN_ERR       
        case CONN_FAIL      
        case SUBMIT_SUCC    
        case SUBMIT_FAIL    
        case MQTT_ERROR     
        case MQTTIDLE       
        case MQTT_READY     
        case ECount         
    };

    let s_State:[String] = [
        "FsmMqtt",
        "idle",
        "Disconnected",
        "Connecting",
        "disconnect",
        "Connected",
        "ConnectionRefused",
        "ConnectionError",
        "ConnFail",
        "disconnecting",
        "Submitting",
        "Submitted",
        "Running",
        "*"
    ];

    let s_Event:[String] = [
        "IDLE",
        "DISCONN",
        "SUBMIT",
        "RESET",
        "DISCONNECTED",
        "RUN",
        "INITMQTT",
        "CONN",
        "FINIMQTT",
        "CONN_SUCC",
        "CONN_REFUSE",
        "CONN_ERR",
        "CONN_FAIL",
        "SUBMIT_SUCC",
        "SUBMIT_FAIL",
        "MQTT_ERROR",
        "MQTTIDLE",
        "MQTT_READY",
        "*"
    ];

    var FsmMqtt_P0_FsmMqtt:[Node] = Fsm.None
    var FsmMqtt_P1_idle:[Node] = Fsm.None
    var FsmMqtt_P2_Disconnected:[Node] = Fsm.None
    var FsmMqtt_P3_Connecting:[Node] = Fsm.None
    var FsmMqtt_P4_disconnect:[Node] = Fsm.None
    var FsmMqtt_P5_Connected:[Node] = Fsm.None
    var FsmMqtt_P6_ConnectionRefused:[Node] = Fsm.None
    var FsmMqtt_P7_ConnectionError:[Node] = Fsm.None
    var FsmMqtt_P8_ConnFail:[Node] = Fsm.None
    var FsmMqtt_P9_disconnecting:[Node] = Fsm.None
    var FsmMqtt_P10_Submitting:[Node] = Fsm.None
    var FsmMqtt_P11_Submitted:[Node] = Fsm.None
    var FsmMqtt_P12_Running:[Node] = Fsm.None


    var _listener : IFsmMqttListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    init(_ onPost:@escaping Fsm.PostFun,_ _FsmApp:FsmApp){
        super.init(onPost)
        self._FsmApp = _FsmApp
        FsmMqtt_P0_FsmMqtt = [
            Node(Fsm.FLAG_RUN,Event.IDLE.rawValue,State.idle.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P1_idle = [
            Node(Fsm.FLAG_NONE,Event.INITMQTT.rawValue,State.Disconnected.rawValue,{(s:Int)->Void in self._listener?.do_INITMQTT(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P2_Disconnected = [
            Node(Fsm.FLAG_NONE,Event.CONN.rawValue,State.Connecting.rawValue,{(s:Int)->Void in self._listener?.do_CONN(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.FINIMQTT.rawValue,State.disconnect.rawValue,nil,{(e:Int)->Void in self._listener?.on_disconnect(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P3_Connecting = [
            Node(Fsm.FLAG_NONE,Event.CONN_SUCC.rawValue,State.Connected.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.CONN_REFUSE.rawValue,State.ConnectionRefused.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.CONN_ERR.rawValue,State.ConnectionError.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.CONN_FAIL.rawValue,State.ConnFail.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.FINIMQTT.rawValue,State.disconnect.rawValue,nil,{(e:Int)->Void in self._listener?.on_disconnect(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P4_disconnect = [
            Node(Fsm.FLAG_RUN,Event.DISCONN.rawValue,State.disconnecting.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P5_Connected = [
            Node(Fsm.FLAG_RUN,Event.SUBMIT.rawValue,State.Submitting.rawValue,{(s:Int)->Void in self._listener?.do_SUBMIT(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P6_ConnectionRefused = [
            Node(Fsm.FLAG_RUN,Event.RESET.rawValue,State.Disconnected.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P7_ConnectionError = [
            Node(Fsm.FLAG_NONE,Event.CONN.rawValue,State.Connecting.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.CONN_ERR.rawValue,State.ConnectionError.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P8_ConnFail = [
            Node(Fsm.FLAG_RUN,Event.RESET.rawValue,State.Disconnected.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.MQTT_ERROR.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmApp_MQTT_ERROR(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P9_disconnecting = [
            Node(Fsm.FLAG_RUN,Event.DISCONNECTED.rawValue,State.idle.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.MQTTIDLE.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmApp_MQTTIDLE(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P10_Submitting = [
            Node(Fsm.FLAG_NONE,Event.SUBMIT_SUCC.rawValue,State.Submitted.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.SUBMIT_FAIL.rawValue,State.Submitted.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.FINIMQTT.rawValue,State.disconnect.rawValue,nil,{(e:Int)->Void in self._listener?.on_disconnect(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P11_Submitted = [
            Node(Fsm.FLAG_RUN,Event.RUN.rawValue,State.Running.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.MQTT_READY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmApp_MQTT_READY(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmMqtt_P12_Running = [
            Node(Fsm.FLAG_NONE,Event.FINIMQTT.rawValue,State.disconnect.rawValue,nil,{(e:Int)->Void in self._listener?.on_disconnect(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmMqtt_P0_FsmMqtt, FsmMqtt_P1_idle, FsmMqtt_P2_Disconnected, FsmMqtt_P3_Connecting,
            FsmMqtt_P4_disconnect, FsmMqtt_P5_Connected, FsmMqtt_P6_ConnectionRefused, FsmMqtt_P7_ConnectionError,
            FsmMqtt_P8_ConnFail, FsmMqtt_P9_disconnecting, FsmMqtt_P10_Submitting, FsmMqtt_P11_Submitted,
            FsmMqtt_P12_Running]

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
    private func do_FsmApp_MQTT_ERROR(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.MQTT_ERROR.rawValue)}
    private func do_FsmApp_MQTTIDLE(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.MQTTIDLE.rawValue)}
    private func do_FsmApp_MQTT_READY(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.MQTT_READY.rawValue)}
    //fsm
    private var _FsmApp:Fsm? = nil
};

