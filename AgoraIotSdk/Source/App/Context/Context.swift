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
    
    class VideoView {
        var uid:UInt = 0
        var view:AgoraRtcVideoCanvas? = nil
    }
    var pairing:Pairing = Pairing()
    var paired = [UInt:VideoView]()
}

class RtcSetting{
    var uid:UInt = 0
    var channel:String = ""
    var info:String? = nil
    var dimension = AgoraVideoDimension640x360
    var frameRate = AgoraVideoFrameRate.fps15
    var bitRate = AgoraVideoBitrateStandard
    var orientationMode:AgoraVideoOutputOrientationMode = .adaptative
    var renderMode:AgoraVideoRenderMode = .fit
    var audioType = "G722" //G722，G711
    var audioSampleRate = "16000"; //16000,8000
    
    var logFilePath : String? = nil
    var publishAudio = true ///< 通话时是否推流本地音频
    var publishVideo = false ///< 通话时是否推流本地视频
    var subscribeAudio = true ///< 通话时是否订阅对端音频
    var subscribeVideo = true ///< 通话时是否订阅对端视频
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

class GranWinSetting{
    
}

//CallKitAcccount
//struct CallKitAccount{
//    //static let ACCOUNT_TYPE_DEV = 1
//    //static let ACCOUNT_TYPE_USER = 2
//
//    //var accountName:String = ""
//    //var accountType:Int = ACCOUNT_TYPE_USER
//    //var accountValid:Bool = true
//    //var password:String = ""
//    //var code:String = ""
//    //var uid:UInt? = 0   //agora uid
//    //var online:Bool = false
//}

struct CallKitSession{
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
}

struct CallKitSetting{
    private var _rtc:RtcSetting = RtcSetting()
    var rtc:RtcSetting{get{return _rtc}}
}

struct AgoraLabSetting{
    
}

class AgoraLabToken{
    var tokenType = ""
    var acessToken = ""
    var refreshToken = ""
    var expireIn:UInt = 0
    var scope = ""
}

struct AgoraLabSession{
    var scope = "read"
    var clientId = "9598156a7d15428f83f828a70f40aad5"
    var secretKey = "MRbRz1kGau9BZE0gWRh9YMZSYc1Ue06v"
    var password = "111111"
    var userName = ""
    var grantType = "password"
    
    var token = AgoraLabToken()
    
    func reset(){
        token.tokenType = ""
        token.acessToken = ""
        token.expireIn = 0
        token.refreshToken = ""
        token.scope = ""
    }
}

struct AgoraLabContext{
    private var _session = AgoraLabSession()
    private var _setting = AgoraLabSetting()
    
    var setting:AgoraLabSetting{get{return _setting}set{_setting = newValue}}
    var session:AgoraLabSession{get{return _session}set{_session = newValue}}
}

struct CallKitContext{
    private var _session = CallKitSession()
    private var _setting = CallKitSetting()
    
    var setting:CallKitSetting{get{return _setting} set{_setting = newValue}}
    var session:CallKitSession{get{return _session} set{_session = newValue}}
}

class GranWinSession{
    var account:String = ""
    var granwin_token:String = ""  //granwinToken
    
    var proof_sessionToken:String = ""
    var proof_secretKey:String = ""
    var endPoint:String = ""
    var region:String = ""
    
    var pool_token:String = ""
    var pool_identityId:String = ""
    var pool_identityPoolId:String = ""
    var pool_identifier = ""

    struct Cert{
        var privateKey:String = ""
        var certificatePem:String = ""
        var certificateArn:String = ""
        var regionId:String = ""
        var domain:String = ""
        var thingName:String = ""
        var region:String = ""
        var deviceId:UInt64 = 0
    }
    var cert:Cert = Cert()
    func reset(){
        account = ""
        granwin_token = ""
        proof_sessionToken = ""
        proof_secretKey = ""
    }
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

class GranWinContext{
    private var _setting = GranWinSetting()
    private var _session = GranWinSession()
    var setting:GranWinSetting{get{return _setting}}
    var session:GranWinSession{get{return _session} set{_session = newValue}}
}

class Context{
    private var _account:String = ""
    private var _push:PushNtfContext = PushNtfContext()
    private var _call:CallKitContext = CallKitContext()
    private var _gran:GranWinContext = GranWinContext()
    private var _aglab:AgoraLabContext = AgoraLabContext()
    private var _devices:[IotDevice]? = nil
    private var _products:[ProductInfo]? = nil
    
    private var _callBackFilter:(Int,String)->(Int,String) = {ec,msg in return (ec,msg)}
    
    var push:PushNtfContext{get{return _push}}
    var gran:GranWinContext{get{return _gran}}
    var aglab:AgoraLabContext{get{return _aglab}set{_aglab = newValue}}
    var call:CallKitContext{get{return _call}set{_call = newValue}}
    var devices:[IotDevice]?{get{return _devices}set{_devices = newValue}}
    var products:[ProductInfo]?{get{return _products}set{_products = newValue}}
    var account:String{get{return _account}set{_account = newValue}}
    var callbackFilter:(Int,String)->(Int,String){get{return _callBackFilter}set{_callBackFilter = newValue}}
}
