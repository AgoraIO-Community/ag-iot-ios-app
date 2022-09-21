//FsmPlay created by guzhihe@agora.io on 2022/09/15 15:54
import Foundation
protocol IFsmPlayListener{
    //srcState:startSession
    func do_CREATEANDENTER(_ srcState:FsmPlay.State)
     //srcState:stopAll
    func do_LEAVEANDDESTROY(_ srcState:FsmPlay.State)
     //srcEvent:STARTPLAY
    func on_startSession(_ srcEvent:FsmPlay.Event)
     //srcEvent:LOCAL_JOIN_SUCC,LOCAL_JOIN_FAIL,REMOTE_JOIN,REMOTE_LEFT,REMOTE_VIDEOREADY
    func on_watcher(_ srcEvent:FsmPlay.Event)
     //srcEvent:DESTROY_SUCC,DESTROY_FAIL
    func on_stopSession(_ srcEvent:FsmPlay.Event)
 };
class FsmPlay : Fsm {
    typealias IListener = IFsmPlayListener
    enum State : Int{
        case FsmPlay        
        case ready          
        case startSession   
        case createAndEntering
        case ntfEnteredSucc 
        case stopAll        
        case ntfEnterFailed 
        case entered        
        case watcher        
        case leaveAndDestroying
        case ntfRemoteJoin  
        case stopSession    
        case playing        
        case ntfRemoteLeft  
        case videoReady     
        case SCount         
    };

    enum Event : Int{
        case READY          
        case CREATEANDENTER 
        case ENTER_SUCC     
        case LEAVEANDDESTROY
        case ENTER_FAIL     
        case PEER_JOIN      
        case PEER_LEFT      
        case VIDEOREADY     
        case STARTPLAY      
        case RESETRTC       
        case DESTROY_SUCC   
        case DESTROY_FAIL   
        case LOCAL_JOIN_SUCC
        case LOCAL_JOIN_FAIL
        case REMOTE_JOIN    
        case REMOTE_LEFT    
        case REMOTE_VIDEOREADY
        case ECount         
    };

    let s_State:[String] = [
        "FsmPlay",
        "ready",
        "startSession",
        "createAndEntering",
        "ntfEnteredSucc",
        "stopAll",
        "ntfEnterFailed",
        "entered",
        "watcher",
        "leaveAndDestroying",
        "ntfRemoteJoin",
        "stopSession",
        "playing",
        "ntfRemoteLeft",
        "videoReady",
        "*"
    ];

    let s_Event:[String] = [
        "READY",
        "CREATEANDENTER",
        "ENTER_SUCC",
        "LEAVEANDDESTROY",
        "ENTER_FAIL",
        "PEER_JOIN",
        "PEER_LEFT",
        "VIDEOREADY",
        "STARTPLAY",
        "RESETRTC",
        "DESTROY_SUCC",
        "DESTROY_FAIL",
        "LOCAL_JOIN_SUCC",
        "LOCAL_JOIN_FAIL",
        "REMOTE_JOIN",
        "REMOTE_LEFT",
        "REMOTE_VIDEOREADY",
        "*"
    ];

    var FsmPlay_P0_FsmPlay:[Node] = Fsm.None
    var FsmPlay_P1_ready:[Node] = Fsm.None
    var FsmPlay_P2_startSession:[Node] = Fsm.None
    var FsmPlay_P3_createAndEntering:[Node] = Fsm.None
    var FsmPlay_P4_ntfEnteredSucc:[Node] = Fsm.None
    var FsmPlay_P5_stopAll:[Node] = Fsm.None
    var FsmPlay_P6_ntfEnterFailed:[Node] = Fsm.None
    var FsmPlay_P7_entered:[Node] = Fsm.None
    var FsmPlay_P8_watcher:[Node] = Fsm.None
    var FsmPlay_P9_leaveAndDestroying:[Node] = Fsm.None
    var FsmPlay_P10_ntfRemoteJoin:[Node] = Fsm.None
    var FsmPlay_P11_stopSession:[Node] = Fsm.None
    var FsmPlay_P12_playing:[Node] = Fsm.None
    var FsmPlay_P13_ntfRemoteLeft:[Node] = Fsm.None
    var FsmPlay_P14_videoReady:[Node] = Fsm.None


    var _listener : IFsmPlayListener? = nil
    var _diagram : [[Node]] = Fsm.Nones

    var listener:IListener?{set{_listener = newValue}get{return _listener}}


    override init(_ onPost:@escaping Fsm.PostFun){
        super.init(onPost)
        FsmPlay_P0_FsmPlay = [
            Node(Fsm.FLAG_RUN,Event.READY.rawValue,State.ready.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P1_ready = [
            Node(Fsm.FLAG_NONE,Event.STARTPLAY.rawValue,State.startSession.rawValue,nil,{(e:Int)->Void in self._listener?.on_startSession(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P2_startSession = [
            Node(Fsm.FLAG_RUN,Event.CREATEANDENTER.rawValue,State.createAndEntering.rawValue,{(s:Int)->Void in self._listener?.do_CREATEANDENTER(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P3_createAndEntering = [
            Node(Fsm.FLAG_NONE,Event.ENTER_SUCC.rawValue,State.ntfEnteredSucc.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.ENTER_FAIL.rawValue,State.ntfEnterFailed.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P4_ntfEnteredSucc = [
            Node(Fsm.FLAG_RUN,Event.ENTER_SUCC.rawValue,State.entered.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.LOCAL_JOIN_SUCC.rawValue,State.watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_watcher(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P5_stopAll = [
            Node(Fsm.FLAG_RUN,Event.LEAVEANDDESTROY.rawValue,State.leaveAndDestroying.rawValue,{(s:Int)->Void in self._listener?.do_LEAVEANDDESTROY(State(rawValue:s)!)},nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P6_ntfEnterFailed = [
            Node(Fsm.FLAG_RUN,Event.ENTER_FAIL.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.LOCAL_JOIN_FAIL.rawValue,State.watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_watcher(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P7_entered = [
            Node(Fsm.FLAG_NONE,Event.PEER_JOIN.rawValue,State.ntfRemoteJoin.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P8_watcher = [
            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P9_leaveAndDestroying = [
            Node(Fsm.FLAG_NONE,Event.DESTROY_SUCC.rawValue,State.stopSession.rawValue,nil,{(e:Int)->Void in self._listener?.on_stopSession(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE,Event.DESTROY_FAIL.rawValue,State.stopSession.rawValue,nil,{(e:Int)->Void in self._listener?.on_stopSession(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P10_ntfRemoteJoin = [
            Node(Fsm.FLAG_RUN,Event.PEER_JOIN.rawValue,State.playing.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.REMOTE_JOIN.rawValue,State.watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_watcher(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P11_stopSession = [
            Node(Fsm.FLAG_RUN,Event.READY.rawValue,State.ready.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P12_playing = [
            Node(Fsm.FLAG_NONE,Event.PEER_LEFT.rawValue,State.ntfRemoteLeft.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.RESETRTC.rawValue,State.stopAll.rawValue,nil,nil),            Node(Fsm.FLAG_NONE,Event.VIDEOREADY.rawValue,State.videoReady.rawValue,nil,nil),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P13_ntfRemoteLeft = [
            Node(Fsm.FLAG_RUN,Event.PEER_LEFT.rawValue,State.entered.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.REMOTE_LEFT.rawValue,State.watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_watcher(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]
        FsmPlay_P14_videoReady = [
            Node(Fsm.FLAG_RUN,Event.VIDEOREADY.rawValue,State.playing.rawValue,nil,nil),            Node(Fsm.FLAG_POST,Event.REMOTE_VIDEOREADY.rawValue,State.watcher.rawValue,nil,{(e:Int)->Void in self._listener?.on_watcher(Event(rawValue:e)!)}),            Node(Fsm.FLAG_NONE, Event.ECount.rawValue,State.SCount.rawValue,nil,nil)]

        _diagram = [
            FsmPlay_P0_FsmPlay, FsmPlay_P1_ready, FsmPlay_P2_startSession, FsmPlay_P3_createAndEntering,
            FsmPlay_P4_ntfEnteredSucc, FsmPlay_P5_stopAll, FsmPlay_P6_ntfEnterFailed, FsmPlay_P7_entered,
            FsmPlay_P8_watcher, FsmPlay_P9_leaveAndDestroying, FsmPlay_P10_ntfRemoteJoin, FsmPlay_P11_stopSession,
            FsmPlay_P12_playing, FsmPlay_P13_ntfRemoteLeft, FsmPlay_P14_videoReady]

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

