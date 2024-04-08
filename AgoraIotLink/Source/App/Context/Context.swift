//
//  Ctx.swift
//  demo
//
//  Created by ADMIN on 2022/1/28.
//

import Foundation
import AgoraRtcKit

class RtcSession{
    class Pairing{
        var uid:UInt = 0
        var view:UIView? = nil
    }
    
    struct VideoView {
        let uid:UInt
        var view:UIView? = nil
    }
    var pairing:Pairing = Pairing()
    //var paired = [UInt:VideoView]()
}

class PlayerSetting{
    var dimension = AgoraVideoDimension640x360
    var frameRate = AgoraVideoFrameRate.fps15
    var bitRate = AgoraVideoBitrateStandard
    var orientationMode:AgoraVideoOutputOrientationMode = .adaptative
    var renderMode:AgoraVideoRenderMode = .fit
    var audioType = "G722" //G722，G711
    var audioSampleRate = "16000"; //16000,8000
    
    var logFilePath = ""
    var publishAudio = false ///< 通话时是否推流本地音频
    var publishVideo = false ///< 通话时是否推流本地视频
    var subscribeAudio = true ///< 通话时是否订阅对端音频
    var subscribeVideo = true ///< 通话时是否订阅对端视频
}

class RtmSetting{
    var appId:String = ""
}

class RtmSession{
    var token:String = ""
    var localNodeId:String = ""
    var peerVirtualNumber:String = ""
    func reset(){
        self.token = ""
        self.localNodeId = ""
        self.peerVirtualNumber = ""
    }
}

class PlayerSession{
    var token:String = ""
    var channelName:String = ""
    var uid:UInt = 0
}

class PushNtfSetting{
    var name:String = "ios"
    var password:String = "ios123456"
}
class PushNtfSession{
    var eid:String = ""
    var pushEnabled:Bool? = nil //nil equals true
}
class PushNtfContext{
    private var _setting:PushNtfSetting = PushNtfSetting()
    private var _session:PushNtfSession = PushNtfSession()
    var setting:PushNtfSetting{get{return _setting}}
    var session:PushNtfSession{get{return _session}}
}

class CallKitSession{
    var token = ""
//    var uid = ""
    var cname = ""
    
    var appId = ""
    var traceId = ""
    var sessionId = ""
    var channelName = ""
    var uid:UInt = 0
    var peerId:UInt = 0
    var rtcToken = ""
    var callee = ""
    var caller = ""
    var cloudRecordStatus:Int = 0
    var deviceAlias:String = ""
    //var peerAccount = CallKitAccount()
    private var _rtc:RtcSession = RtcSession()
    var rtc:RtcSession{get{return _rtc}}
    
    func reset(){
        
        token = ""
//      uid = ""
        cname = ""
        
        appId = ""
        sessionId = ""
        channelName = ""
        uid = 0
        peerId = 0
        rtcToken = ""
        callee = ""
        caller = ""
        cloudRecordStatus = 0
        deviceAlias = ""
        rtc.pairing.uid = 0
        rtc.pairing.view = nil
    }
}

struct CallKitSetting{
    var dimension = AgoraVideoDimension640x360
    var frameRate = AgoraVideoFrameRate.fps15
    var bitRate = AgoraVideoBitrateStandard
    var orientationMode:AgoraVideoOutputOrientationMode = .adaptative
    var renderMode:AgoraVideoRenderMode = .fit
    var audioType = "G722" //G722，G711A,G711U
    var audioSampleRate = "16000"; //16000,8000
    
    var logFilePath = ""
    var publishAudio = false ///< 通话时是否推流本地音频
    var publishVideo = false ///< 通话时是否推流本地视频
    var subscribeAudio = false ///< 通话时是否订阅对端音频
    var subscribeVideo = false ///< 通话时是否订阅对端视频
}

struct PlayerContext{
    private var _setting = PlayerSetting()
    var setting:PlayerSetting{get{return _setting}}
}

struct CallKitContext{
    private var _setting = CallKitSetting()
    var setting:CallKitSetting{get{return _setting} set{_setting = newValue}}
}

struct RtmKitContext{
    private var _session = RtmSession()
    private var _setting = RtmSetting()
    
    var setting:RtmSetting{get{return _setting} set{_setting = newValue}}
    var session:RtmSession{get{return _session} set{_session = newValue}}
}

public class IotMqttSession{
    public enum Status{
        case Unknown
        case Inited
        case Connecting
        case Connected
        case Disconnected
        case ConnectionRefused
        case ConnectionError
        case ProtocolError
        case InitError
    }
    var status:Status = .Unknown
}

class IotMqttContext{
    private var _session = IotMqttSession()
    var session:IotMqttSession{get{return _session} set{_session = newValue}}
}


class Context{
    private var _virtualNumber:String = ""
    private var _account:String = ""
    private var _push:PushNtfContext = PushNtfContext()
    private var _call:CallKitContext = CallKitContext()
    private var _player:PlayerContext = PlayerContext()
    private var _rtm:RtmKitContext = RtmKitContext();
    
    private var _callBackFilter:(Int,String)->(Int,String) = {ec,msg in return (ec,msg)}
    
    var push:PushNtfContext{get{return _push}}
    var call:CallKitContext{get{return _call}set{_call = newValue}}
    var player:PlayerContext{get{return _player}}
    var rtm:RtmKitContext{get{return _rtm}set{_rtm = newValue}}
    var account:String{get{return _account}set{_account = newValue}}
    var virtualNumber:String{get{return _virtualNumber}set{_virtualNumber = newValue}}
    var callbackFilter:(Int,String)->(Int,String){get{return _callBackFilter}set{_callBackFilter = newValue}}
}
