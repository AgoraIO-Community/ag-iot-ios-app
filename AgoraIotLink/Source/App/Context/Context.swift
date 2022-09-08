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

class RtmSetting{
    var appId:String = ""
}

class RtmSession{
    var token:String = ""
    //var loginId:String = ""
    var peerVirtualNumber:String = ""
    func reset(){
        self.token = ""
        //self.loginId = ""
        self.peerVirtualNumber = ""
    }
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

class IotLinkSetting{
    
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

class CallKitSession{
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
    }
}

struct CallKitSetting{
    private var _rtc:RtcSetting = RtcSetting()
    var rtc:RtcSetting{get{return _rtc}}
}

struct AgoraLabSetting{
    
}

struct LsToken {
    let access_token:String
    let token_type : String
    let expires_in : UInt64
    let scope : String
}
struct Pool {
    let identifier : String
    let identityId : String
    let identityPoolId : String
    let token : String
}
struct Proof {
    let accessKeyId : String
    let secretKey : String
    let sessionToken : String
    let sessionExpiration : UInt64
}

struct GyToken {
    let endpoint:String
    let pool : Pool
    let expiration : UInt64
    let iotlink_token : String
    let proof : Proof?
    let region : String
    let account : String
}

class AgoraLabToken{
    var tokenType:String
    var accessToken:String
    var refreshToken:String
    var expireIn:UInt
    var scope:String
    init(tokenType:String,accessToken:String,refreshToken:String,expireIn:UInt,scope:String){
        self.tokenType = tokenType
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expireIn = expireIn
        self.scope = scope
    }
}

struct LoginRspData{
    let agToken:AgoraLabToken
    let gyToken:IotLinkSession
}

struct AgoraLabSession{
    var scope = "read"
    var clientId = "9598156a7d15428f83f828a70f40aad5"
    var secretKey = "MRbRz1kGau9BZE0gWRh9YMZSYc1Ue06v"
    var password = "111111"
    var userNamew = ""
    var grantType = "password"
    
    var token = AgoraLabToken(tokenType: "", accessToken: "", refreshToken: "", expireIn: 0, scope: "")
    
    func reset(){
        token.tokenType = ""
        token.accessToken = ""
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

struct RtmKitContext{
    private var _session = RtmSession()
    private var _setting = RtmSetting()
    
    var setting:RtmSetting{get{return _setting} set{_setting = newValue}}
    var session:RtmSession{get{return _session} set{_session = newValue}}
}

class IotLinkSession{
    var iotlink_token:String = ""
    var expiration : UInt64 = 0
    var endPoint:String = ""
    var region:String = ""
    var account:String = ""
    
    var proof_sessionToken:String = ""
    var proof_secretKey:String = ""
    var proof_accessKeyId:String = ""
    var proof_sessionExpiration:UInt64 = 0
    
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
    init(){}
    init(granwin_token:String,expiration:UInt64,endPoint:String,region:String,account:String,
         proof_sessionToken:String,proof_secretKey:String,proof_accessKeyId:String,proof_sessionExpiration:UInt64,
         pool_token:String,pool_identityId:String,pool_identityPoolId:String,pool_identifier:String){
        self.iotlink_token = granwin_token
        self.expiration = expiration
        self.endPoint = endPoint
        self.region = region
        
        self.proof_sessionToken = proof_sessionToken
        self.proof_secretKey = proof_secretKey
        self.proof_accessKeyId = proof_accessKeyId
        self.proof_sessionExpiration = proof_sessionExpiration
        
        self.pool_token = pool_token
        self.pool_identityId = pool_identityId
        self.pool_identityPoolId = pool_identityPoolId
        self.pool_identifier = pool_identifier
    }
    func reset(){
        iotlink_token = ""
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

class IotLinkContext{
    private var _setting = IotLinkSetting()
    private var _session = IotLinkSession()
    var setting:IotLinkSetting{get{return _setting}}
    var session:IotLinkSession{get{return _session} set{_session = newValue}}
}

class Context{
    //private var _account:String = ""
    private var _virtualNumber:String = ""
    private var _push:PushNtfContext = PushNtfContext()
    private var _call:CallKitContext = CallKitContext()
    private var _rtm:RtmKitContext = RtmKitContext();
    private var _gran:IotLinkContext = IotLinkContext()
    private var _aglab:AgoraLabContext = AgoraLabContext()
    private var _devices:[IotDevice]? = nil
    private var _products:[ProductInfo]? = nil
    
    private var _callBackFilter:(Int,String)->(Int,String) = {ec,msg in return (ec,msg)}
    
    var push:PushNtfContext{get{return _push}}
    var gyiot:IotLinkContext{get{return _gran}}
    var aglab:AgoraLabContext{get{return _aglab}set{_aglab = newValue}}
    var call:CallKitContext{get{return _call}set{_call = newValue}}
    var rtm:RtmKitContext{get{return _rtm}set{_rtm = newValue}}
    var devices:[IotDevice]?{get{return _devices}set{_devices = newValue}}
    var products:[ProductInfo]?{get{return _products}set{_products = newValue}}
    //var account:String{get{return _account}set{_account = newValue}}
    var virtualNumber:String{get{return _virtualNumber}set{_virtualNumber = newValue}}
    var callbackFilter:(Int,String)->(Int,String){get{return _callBackFilter}set{_callBackFilter = newValue}}
}
