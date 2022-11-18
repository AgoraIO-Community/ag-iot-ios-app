//FsmCall created by guzhihe@agora.io on 2022/09/27 15:52
import Foundation
protocol IFsmCallListener{
    //srcState:local_viewing,accepting,waiting,remote_answered
    func do_REMOTE_JOIN(_ srcState:FsmCall.State)
     //srcEvent:LOCAL_JOIN_FAIL,REMOTE_LEFT,NTF_HANGUP,REMOTE_ANSWER,REMOTE_RINGING,LOCAL_ERROR
    func on_callHangup(_ srcEvent:FsmCall.Event)
     //srcEvent:RESETCALL
    func on_reset_call(_ srcEvent:FsmCall.Event)
     //srcEvent:
    func on_local_join_watcher(_ srcEvent:FsmCall.Event)
     //srcEvent:VIDEOREADY,LOCAL_ACCEPT_ERROR,INCOMING_HANGUP
    func on_incoming_state_watcher(_ srcEvent:FsmCall.Event)
     //srcEvent:NTF_REMOTE_HANGUP
    func on_remote_state_watcher(_ srcEvent:FsmCall.Event)
 };
class FsmCall : Fsm {
    typealias IListener = IFsmCallListener
    enum State : Int{
        case FsmCall        
        case idle           
        case local_ready    
        case callkit_ready  
        case query_agoraLab 
        case remote_incoming
        case exited         
        case FsmRtc         
        case callHangup     
        case reset_call     
        case wait_mqtt_ntf  
        case local_joining  
        case hanging_up0    
        case ntf_join_fail  
        case hanging_up     
        case local_viewing  
        case incoming_hangup
        case incoming_local_error
        case local_join_succ
        case remote_answer_first
        case re_wait_mqtt   
        case local_join_watcher
        case accepting      
        case remoteVReady2  
        case incoming_state_watcher
        case waiting        
        case local_join_succ_second
        case remote_hangingup
        case talking        
        case remote_answered
        case remote_state_watcher
        case remote_dropped 
        case remoteVReady1  
        case SCount         
    };

    enum Event : Int{
        case IDLE           
        case LOCAL_JOIN_FAIL
        case NTF            
        case LOCAL_READY    
        case LOCAL_JOIN_SUCC
        case REMOTE_LEFT    
        case INCOMING_HANGUP_DONE
        case NTF_HANGUP     
        case REMOTE_HANGUP_DONE
        case INITCALL       
        case CALL           
        case INCOME         
        case FINICALL       
        case REMOTE_ANSWER  
        case REMOTE_RINGING 
        case ACK_INVALID    
        case ACK_SUCC       
        case LOCAL_HANGUP   
        case REMOTE_TIMEOUT 
        case REMOTE_HANGUP  
        case STATUS_ERROR   
        case MQTT_ACK_ERROR 
        case LOCAL_JOIN_TIMEOUT
        case LOCAL_HANGUP_SUCC
        case LOCAL_HANGUP_FAIL
        case LOCAL_ACCEPT   
        case REMOTE_VIDEOREADY
        case REMOTE_JOIN    
        case LOCAL_ERROR    
        case RESETCALL      
        case NTF_REMOTE_HANGUP
        case VIDEOREADY     
        case CALLIDLE       
        case LOCAL_ACCEPT_ERROR
        case CREATEANDENTER 
        case RESETRTC       
        case INCOMING_HANGUP
        case CALL_READY     
        case ECount         
    };

    let s_State:[String] = [
        "FsmCall",
        "idle",
        "local_ready",
        "callkit_ready",
        "query_agoraLab",
        "remote_incoming",
        "exited",
        "FsmRtc",
        "callHangup",
        "reset_call",
        "wait_mqtt_ntf",
        "local_joining",
        "hanging_up0",
        "ntf_join_fail",
        "hanging_up",
        "local_viewing",
        "incoming_hangup",
        "incoming_local_error",
        "local_join_succ",
        "remote_answer_first",
        "re_wait_mqtt",
        "local_join_watcher",
        "accepting",
        "remoteVReady2",
        "incoming_state_watcher",
        "waiting",
        "local_join_succ_second",
        "remote_hangingup",
        "talking",
        "remote_answered",
        "remote_state_watcher",
        "remote_dropped",
        "remoteVReady1",
        "*"
    ];

    let s_Event:[String] = [
        "IDLE",
        "LOCAL_JOIN_FAIL",
        "NTF",
        "LOCAL_READY",
        "LOCAL_JOIN_SUCC",
        "REMOTE_LEFT",
        "INCOMING_HANGUP_DONE",
        "NTF_HANGUP",
        "REMOTE_HANGUP_DONE",
        "INITCALL",
        "CALL",
        "INCOME",
        "FINICALL",
        "REMOTE_ANSWER",
        "REMOTE_RINGING",
        "ACK_INVALID",
        "ACK_SUCC",
        "LOCAL_HANGUP",
        "REMOTE_TIMEOUT",
        "REMOTE_HANGUP",
        "STATUS_ERROR",
        "MQTT_ACK_ERROR",
        "LOCAL_JOIN_TIMEOUT",
        "LOCAL_HANGUP_SUCC",
        "LOCAL_HANGUP_FAIL",
        "LOCAL_ACCEPT",
        "REMOTE_VIDEOREADY",
        "REMOTE_JOIN",
        "LOCAL_ERROR",
        "RESETCALL",
        "NTF_REMOTE_HANGUP",
        "VIDEOREADY",
        "CALLIDLE",
        "LOCAL_ACCEPT_ERROR",
        "CREATEANDENTER",
        "RESETRTC",
        "INCOMING_HANGUP",
        "CALL_READY",
        "*"
    ];

    var FsmCall_P0_FsmCall:[Node] = Fsm.None
    var FsmCall_P1_idle:[Node] = Fsm.None
    var FsmCall_P2_local_ready:[Node] = Fsm.None
    var FsmCall_P3_callkit_ready:[Node] = Fsm.None
    var FsmCall_P4_query_agoraLab:[Node] = Fsm.None
    var FsmCall_P5_remote_incoming:[Node] = Fsm.None
    var FsmCall_P6_exited:[Node] = Fsm.None
    var FsmCall_P7_FsmRtc:[Node] = Fsm.None
    var FsmCall_P8_callHangup:[Node] = Fsm.None
    var FsmCall_P9_reset_call:[Node] = Fsm.None
    var FsmCall_P10_wait_mqtt_ntf:[Node] = Fsm.None
    var FsmCall_P11_local_joining:[Node] = Fsm.None
    var FsmCall_P12_hanging_up0:[Node] = Fsm.None
    var FsmCall_P13_ntf_join_fail:[Node] = Fsm.None
    var FsmCall_P14_hanging_up:[Node] = Fsm.None
    var FsmCall_P15_local_viewing:[Node] = Fsm.None
    var FsmCall_P16_incoming_hangup:[Node] = Fsm.None
    var FsmCall_P17_incoming_local_error:[Node] = Fsm.None
    var FsmCall_P18_local_join_succ:[Node] = Fsm.None
    var FsmCall_P19_remote_answer_first:[Node] = Fsm.None
    var FsmCall_P20_re_wait_mqtt:[Node] = Fsm.None
    var FsmCall_P21_local_join_watcher:[Node] = Fsm.None
    var FsmCall_P22_accepting:[Node] = Fsm.None
    var FsmCall_P23_remoteVReady2:[Node] = Fsm.None
    var FsmCall_P24_incoming_state_watcher:[Node] = Fsm.None
    var FsmCall_P25_waiting:[Node] = Fsm.None
    var FsmCall_P26_local_join_succ_second:[Node] = Fsm.None
    var FsmCall_P27_remote_hangingup:[Node] = Fsm.None
    var FsmCall_P28_talking:[Node] = Fsm.None
    var FsmCall_P29_remote_answered:[Node] = Fsm.None
    var FsmCall_P30_remote_state_watcher:[Node] = Fsm.None
    var FsmCall_P31_remote_dropped:[Node] = Fsm.None
    var FsmCall_P32_remoteVReady1:[Node] = Fsm.None


    var _listener : IFsmCallListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    init(_ onPost:@escaping Fsm.PostFun,_ _FsmApp:FsmApp){
        super.init(onPost)
        _FsmRtc = FsmRtc(onPost,self)
        self._FsmApp = _FsmApp
        FsmCall_P0_FsmCall = [
            Node(Fsm.FLAG_RUN,Event.IDLE.rawValue,State.idle.rawValue,nil,nil),
        FsmCall_P1_idle = [
            Node(Fsm.FLAG_NONE,Event.INITCALL.rawValue,State.local_ready.rawValue,nil,nil),
        FsmCall_P2_local_ready = [
            Node(Fsm.FLAG_RUN,Event.LOCAL_READY.rawValue,State.callkit_ready.rawValue,nil,nil),
        FsmCall_P3_callkit_ready = [
            Node(Fsm.FLAG_NONE,Event.CALL.rawValue,State.query_agoraLab.rawValue,nil,nil),
        FsmCall_P4_query_agoraLab = [
            Node(Fsm.FLAG_NONE,Event.ACK_INVALID.rawValue,State.callkit_ready.rawValue,nil,nil),
        FsmCall_P5_remote_incoming = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_HANGUP.rawValue,State.hanging_up.rawValue,nil,nil),
        FsmCall_P6_exited = [
            Node(Fsm.FLAG_RUN,Event.IDLE.rawValue,State.idle.rawValue,nil,nil),
        FsmCall_P7_FsmRtc = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmCall_P8_callHangup = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_HANGUP.rawValue,State.hanging_up.rawValue,nil,nil),
        FsmCall_P9_reset_call = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmCall_P10_wait_mqtt_ntf = [
            Node(Fsm.FLAG_NONE,Event.REMOTE_RINGING.rawValue,State.local_joining.rawValue,nil,nil),
        FsmCall_P11_local_joining = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_JOIN_SUCC.rawValue,State.local_join_succ.rawValue,nil,nil),
        FsmCall_P12_hanging_up0 = [
            Node(Fsm.FLAG_NONE,Event.ACK_INVALID.rawValue,State.callkit_ready.rawValue,nil,nil),
        FsmCall_P13_ntf_join_fail = [
            Node(Fsm.FLAG_RUN,Event.NTF_HANGUP.rawValue,State.callHangup.rawValue,nil,{(e:Int)->Void in self._listener?.on_callHangup(Event(rawValue:e)!)}),
        FsmCall_P14_hanging_up = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_HANGUP_SUCC.rawValue,State.callkit_ready.rawValue,nil,nil),
        FsmCall_P15_local_viewing = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_ACCEPT.rawValue,State.accepting.rawValue,nil,nil),
        FsmCall_P16_incoming_hangup = [
            Node(Fsm.FLAG_RUN,Event.INCOMING_HANGUP_DONE.rawValue,State.callkit_ready.rawValue,nil,nil),
        FsmCall_P17_incoming_local_error = [
            Node(Fsm.FLAG_RUN,Event.LOCAL_JOIN_FAIL.rawValue,State.callHangup.rawValue,nil,{(e:Int)->Void in self._listener?.on_callHangup(Event(rawValue:e)!)}),
        FsmCall_P18_local_join_succ = [
            Node(Fsm.FLAG_RUN,Event.LOCAL_JOIN_SUCC.rawValue,State.waiting.rawValue,nil,nil),
        FsmCall_P19_remote_answer_first = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_JOIN_SUCC.rawValue,State.local_join_succ_second.rawValue,nil,nil),
        FsmCall_P20_re_wait_mqtt = [
            Node(Fsm.FLAG_NONE,Event.ACK_SUCC.rawValue,State.wait_mqtt_ntf.rawValue,nil,nil),
        FsmCall_P21_local_join_watcher = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmCall_P22_accepting = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_HANGUP.rawValue,State.hanging_up.rawValue,nil,nil),
        FsmCall_P23_remoteVReady2 = [
            Node(Fsm.FLAG_RUN,Event.NTF.rawValue,State.local_viewing.rawValue,nil,nil),
        FsmCall_P24_incoming_state_watcher = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmCall_P25_waiting = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_ERROR.rawValue,State.callHangup.rawValue,nil,{(e:Int)->Void in self._listener?.on_callHangup(Event(rawValue:e)!)}),
        FsmCall_P26_local_join_succ_second = [
            Node(Fsm.FLAG_RUN,Event.LOCAL_JOIN_SUCC.rawValue,State.remote_answered.rawValue,nil,nil),
        FsmCall_P27_remote_hangingup = [
            Node(Fsm.FLAG_RUN,Event.REMOTE_HANGUP_DONE.rawValue,State.callkit_ready.rawValue,nil,nil),
        FsmCall_P28_talking = [
            Node(Fsm.FLAG_NONE,Event.LOCAL_HANGUP.rawValue,State.hanging_up.rawValue,nil,nil),
        FsmCall_P29_remote_answered = [
            Node(Fsm.FLAG_NONE,Event.REMOTE_JOIN.rawValue,State.talking.rawValue,{(s:Int)->Void in self._listener?.do_REMOTE_JOIN(State(rawValue:s)!)},nil),
        FsmCall_P30_remote_state_watcher = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmCall_P31_remote_dropped = [
            Node(Fsm.FLAG_RUN,Event.REMOTE_LEFT.rawValue,State.callHangup.rawValue,nil,{(e:Int)->Void in self._listener?.on_callHangup(Event(rawValue:e)!)}),
        FsmCall_P32_remoteVReady1 = [
            Node(Fsm.FLAG_RUN,Event.NTF.rawValue,State.talking.rawValue,nil,nil),

        _diagram = [
            FsmCall_P0_FsmCall, FsmCall_P1_idle, FsmCall_P2_local_ready, FsmCall_P3_callkit_ready,
            FsmCall_P4_query_agoraLab, FsmCall_P5_remote_incoming, FsmCall_P6_exited, FsmCall_P7_FsmRtc,
            FsmCall_P8_callHangup, FsmCall_P9_reset_call, FsmCall_P10_wait_mqtt_ntf, FsmCall_P11_local_joining,
            FsmCall_P12_hanging_up0, FsmCall_P13_ntf_join_fail, FsmCall_P14_hanging_up, FsmCall_P15_local_viewing,
            FsmCall_P16_incoming_hangup, FsmCall_P17_incoming_local_error, FsmCall_P18_local_join_succ, FsmCall_P19_remote_answer_first,
            FsmCall_P20_re_wait_mqtt, FsmCall_P21_local_join_watcher, FsmCall_P22_accepting, FsmCall_P23_remoteVReady2,
            FsmCall_P24_incoming_state_watcher, FsmCall_P25_waiting, FsmCall_P26_local_join_succ_second, FsmCall_P27_remote_hangingup,
            FsmCall_P28_talking, FsmCall_P29_remote_answered, FsmCall_P30_remote_state_watcher, FsmCall_P31_remote_dropped,
            FsmCall_P32_remoteVReady1]

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
    private func do_FsmApp_CALLIDLE(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.CALLIDLE.rawValue)}
    private func do_FsmRtc_CREATEANDENTER(_ e:Event)->Void{_FsmRtc?.trans(FsmRtc.Event.CREATEANDENTER.rawValue)}
    private func do_FsmRtc_RESETRTC(_ e:Event)->Void{_FsmRtc?.trans(FsmRtc.Event.RESETRTC.rawValue)}
    private func do_FsmApp_CALL_READY(_ e:Event)->Void{_FsmApp?.trans(FsmApp.Event.CALL_READY.rawValue)}
    //fsm
    private var _FsmApp:Fsm? = nil
    //sub state get set
    func getFsmRtc()->FsmRtc{return _FsmRtc!}
    //sub state
    private var _FsmRtc:FsmRtc? = nil
};
