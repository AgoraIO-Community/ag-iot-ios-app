//FsmRtc created by guzhihe@agora.io on 2022/06/23 17:05
import Foundation
protocol IFsmRtcListener{
    //srcState:stopAll
    func do_LEAVEANDDESTROY(_ srcState:FsmRtc.State)
     //srcState:ready
    func do_CREATEANDENTER(_ srcState:FsmRtc.State)
 };
class FsmRtc : Fsm {
    typealias IListener = IFsmRtcListener
    enum State : Int{
        case FsmRtc         
        case ready          
        case createAndEntering
        case ntfEnteredSucc 
        case stopAll        
        case enter_failed   
        case entered        
        case leaveAndDestroying
        case ntfRemoteJoin  
        case talking        
        case ntfRemoteLeft  
        case videoReady     
        case SCount         
    };

    enum Event : Int{
        case INITRTC        
        case LOCAL_READY    
        case LEAVEANDDESTROY
        case ENTER_FAIL     
        case PEER_JOIN      
        case VIDEOREADY     
        case CREATEANDENTER 
        case RESETRTC       
        case ENTER_SUCC     
        case DESTROY_SUCC   
        case DESTROY_FAIL   
        case PEER_LEFT      
        case LOCAL_JOIN_SUCC
        case LOCAL_JOIN_FAIL
        case REMOTE_JOIN    
        case REMOTE_LEFT    
        case REMOTE_VIDEOREADY
        case ECount         
    };

    let s_State:[String] = [
        "FsmRtc",
        "ready",
        "createAndEntering",
        "ntfEnteredSucc",
        "stopAll",
        "enter_failed",
        "entered",
        "leaveAndDestroying",
        "ntfRemoteJoin",
        "talking",
        "ntfRemoteLeft",
        "videoReady",
        "*"
    ];

    let s_Event:[String] = [
        "INITRTC",
        "LOCAL_READY",
        "LEAVEANDDESTROY",
        "ENTER_FAIL",
        "PEER_JOIN",
        "VIDEOREADY",
        "CREATEANDENTER",
        "RESETRTC",
        "ENTER_SUCC",
        "DESTROY_SUCC",
        "DESTROY_FAIL",
        "PEER_LEFT",
        "LOCAL_JOIN_SUCC",
        "LOCAL_JOIN_FAIL",
        "REMOTE_JOIN",
        "REMOTE_LEFT",
        "REMOTE_VIDEOREADY",
        "*"
    ];

    var FsmRtc_P0_FsmRtc:[Node] = Fsm.None
    var FsmRtc_P1_ready:[Node] = Fsm.None
    var FsmRtc_P2_createAndEntering:[Node] = Fsm.None
    var FsmRtc_P3_ntfEnteredSucc:[Node] = Fsm.None
    var FsmRtc_P4_stopAll:[Node] = Fsm.None
    var FsmRtc_P5_enter_failed:[Node] = Fsm.None
    var FsmRtc_P6_entered:[Node] = Fsm.None
    var FsmRtc_P7_leaveAndDestroying:[Node] = Fsm.None
    var FsmRtc_P8_ntfRemoteJoin:[Node] = Fsm.None
    var FsmRtc_P9_talking:[Node] = Fsm.None
    var FsmRtc_P10_ntfRemoteLeft:[Node] = Fsm.None
    var FsmRtc_P11_videoReady:[Node] = Fsm.None


    var _listener : IFsmRtcListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    init(_ onPost:@escaping Fsm.PostFun,_ _FsmCall:FsmCall){
        super.init(onPost)
        self._FsmCall = _FsmCall
        FsmRtc_P0_FsmRtc = [
            Node(Fsm.FLAG_RUN,Event.INITRTC.rawValue,State.ready.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P1_ready = [
            Node(Fsm.FLAG_NONE,Event.CREATEANDENTER.rawValue,State.createAndEntering.rawValue,{(s:Int)->Void in self._listener?.do_CREATEANDENTER(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.ready.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P2_createAndEntering = [
            Node(Fsm.FLAG_NONE,Event.ENTER_SUCC.rawValue,State.ntfEnteredSucc.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.ENTER_FAIL.rawValue,State.enter_failed.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P3_ntfEnteredSucc = [
            Node(Fsm.FLAG_RUN,Event.LOCAL_READY.rawValue,State.entered.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.LOCAL_JOIN_SUCC.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_LOCAL_JOIN_SUCC(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P4_stopAll = [
            Node(Fsm.FLAG_RUN,Event.LEAVEANDDESTROY.rawValue,State.leaveAndDestroying.rawValue,{(s:Int)->Void in self._listener?.do_LEAVEANDDESTROY(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P5_enter_failed = [
            Node(Fsm.FLAG_RUN,Event.ENTER_FAIL.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.LOCAL_JOIN_FAIL.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_LOCAL_JOIN_FAIL(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P6_entered = [
            Node(Fsm.FLAG_NONE,Event.PEER_JOIN.rawValue,State.ntfRemoteJoin.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P7_leaveAndDestroying = [
            Node(Fsm.FLAG_NONE,Event.DESTROY_SUCC.rawValue,State.ready.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.DESTROY_FAIL.rawValue,State.ready.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P8_ntfRemoteJoin = [
            Node(Fsm.FLAG_RUN,Event.PEER_JOIN.rawValue,State.talking.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.REMOTE_JOIN.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_REMOTE_JOIN(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P9_talking = [
            Node(Fsm.FLAG_NONE,Event.PEER_LEFT.rawValue,State.ntfRemoteLeft.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.VIDEOREADY.rawValue,State.videoReady.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P10_ntfRemoteLeft = [
            Node(Fsm.FLAG_RUN,Event.LOCAL_READY.rawValue,State.entered.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.REMOTE_LEFT.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_REMOTE_LEFT(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmRtc_P11_videoReady = [
            Node(Fsm.FLAG_RUN,Event.VIDEOREADY.rawValue,State.talking.rawValue,nil,nil),            Node(Fsm.FLAG_POST|Fsm.FLAG_FSM,Event.REMOTE_VIDEOREADY.rawValue,State.SCount.rawValue,{(e:Int)->Void in self.do_FsmCall_REMOTE_VIDEOREADY(Event(rawValue:e)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmRtc_P0_FsmRtc, FsmRtc_P1_ready, FsmRtc_P2_createAndEntering, FsmRtc_P3_ntfEnteredSucc,
            FsmRtc_P4_stopAll, FsmRtc_P5_enter_failed, FsmRtc_P6_entered, FsmRtc_P7_leaveAndDestroying,
            FsmRtc_P8_ntfRemoteJoin, FsmRtc_P9_talking, FsmRtc_P10_ntfRemoteLeft, FsmRtc_P11_videoReady]

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
    private func do_FsmCall_LOCAL_JOIN_SUCC(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.LOCAL_JOIN_SUCC.rawValue)}
    private func do_FsmCall_LOCAL_JOIN_FAIL(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.LOCAL_JOIN_FAIL.rawValue)}
    private func do_FsmCall_REMOTE_JOIN(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.REMOTE_JOIN.rawValue)}
    private func do_FsmCall_REMOTE_LEFT(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.REMOTE_LEFT.rawValue)}
    private func do_FsmCall_REMOTE_VIDEOREADY(_ e:Event)->Void{_FsmCall?.trans(FsmCall.Event.REMOTE_VIDEOREADY.rawValue)}
    //fsm
    private var _FsmCall:Fsm? = nil
};

