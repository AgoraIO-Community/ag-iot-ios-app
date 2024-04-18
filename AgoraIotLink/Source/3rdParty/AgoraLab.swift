//
//  AgoraLab.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/14.
//

import Foundation
import CoreAudio
import Alamofire

extension Date{
    public func toString()->String{
        return String.init(format: "%d-%02d-%02d %02d:%02d:%02d", self.year,self.month,self.day,self.hour,self.minute,self.second)
    }
}

class AgoraLab {
    
    // http过滤状态码
    let acceptableStatusCodes = Array(200..<300) + [401, 404]
    
    private let httpPre = "http://api.sd-rtn.com/cn" //"http://api-test-huzhou1.agora.io/"
    private let httpEnd = "/iot/link"
    
    private var http:String
    init(cRegion:Int){
        let region = RegionToStringMap.getRegionString(cRegion)
        self.http = httpPre + region + httpEnd
    }
    
    func publicKeySet(_ userId:String, _ publicKey:String,_ token:String, _ rsp:@escaping(Int,String)->Void){
        
        let header = Header()
        
        let nodePayload = AgoraLab.PublicKeySet.Payload(userId: userId, publicKey:publicKey )
        let paramsDic = AgoraLab.PublicKeySet.Req(header: header, payload: nodePayload)
        
        let headers : HTTPHeaders = ["Authorization":token]
        
        let url = http + api.publicKeySet
        log.i("publicKeySet：url: \(url) param:\(paramsDic)")

        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of:PublicKeySet.Rsp.self){(dataRsp:AFDataResponse<PublicKeySet.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e(" publicKeySet fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e(" publicKeySet \(url) , detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
    }
    
    //配置请求头的通用参数
    func configCommonHeader()->HTTPHeaders {
        
        let headers:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8","traceId":"123456789","Authorization":"Basic " + getAuthorizationText()]
        
        return headers
    }
    
    //获取Authorization Base64编码
    func getAuthorizationText()-> String {
        
        let plainCredentials = Config.customerKey + ":" + Config.customerSecret
        let authData = plainCredentials.data(using: .utf8)
        
        guard let base64Credentials = authData?.base64EncodedString(options: .endLineWithLineFeed) else {
            print("转base64失败")
            return ""
        }
        UserDefaults.standard.set(base64Credentials, forKey: Config.kAuthorizationBase64Key)
        UserDefaults.standard.synchronize()
    
        return base64Credentials
        
    }
    
    func nodeActivate(_ traceId:String, _ userId:String,_ masterAppId:String,_ pusherId:String, _ rsp:@escaping(Int,String,ActivateNode.Rsp?)->Void){

        let header = self.configCommonHeader()
        print("header------\(header)")
        
        let nodePayload = AgoraLab.ActivateNode.Payload(clientType: "2", userId: userId, masterAppId: masterAppId, pusherId: pusherId)
        let paramsDic = AgoraLab.ActivateNode.Req(payload: nodePayload)
        
        //https://iot-api-gateway.sh.agoralab.co/api  "https://api.sd-rtn.com/agoralink/cn/api"
        let url = http + api.nodeActivate
        log.i("al reqCall \(url)")

        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:ActivateNode.Rsp.self){(dataRsp:AFDataResponse<ActivateNode.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd nodeActivate fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret)
            case .failure(let error):
                log.e("3rd nodeActivate \(url) , detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
            }
        }
    }
    func creatConnect(_ traceId:String, _ peerNodeId:String, _ rsp:@escaping(Int,String,ConnectCreat.Rsp?)->Void){
        
        let app = IotLibrary.shared
        let appId = app.config.masterAppId
        let nodeToken = app.config.mAuthToken
        let localNodeId = app.config.mLocalNodeId
    
        let header = self.configCommonHeader()
        let paramsDic = AgoraLab.ConnectCreat.Req(nodeToken: nodeToken, localNodeId: localNodeId, peerNodeId: peerNodeId, appId: appId)
        
        let url = http + api.connectCreat
        log.i("al connect url:\(url) header:\(header) paramsDic:\(paramsDic)")
        sessionManager.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:ConnectCreat.Rsp.self){[weak self] (dataRsp:AFDataResponse<ConnectCreat.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("creatConnect fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,ret)
            case .failure(let error):
                let errCode = self?.getErrorCode(from:error)
                log.e("creatConnect \(url) , errCode: \(String(describing: errCode))   detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
            }
        }
    }
    
    lazy var sessionManager: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5 // 设置超时时间为5秒
        return Alamofire.Session(configuration: configuration)
    }()
    
    func getErrorCode(from error: Error) -> Int? {
        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let sessionError):
                if let nsError = sessionError as NSError?, nsError.domain == NSURLErrorDomain {
                    return nsError.code
                }
            default:
                break
            }
        }
        return nil
    }

}



/* test code
 
 .responseString(completionHandler: {(response) in
 switch response.result{
 case .success(let value):
     log.e(value)
     _ = JSON(value)
     //cb(ErrCode.XERR_ALARM_NOT_FOUND,value,nil)
 case .failure(let error):
     log.e("http request detail: \(error) ")
     //cb(ErrCode.XERR_ACCOUNT_REGISTER,"")
 }
})
 
 */

//var jsonString:String = ""
//var jsonData:Data = Data()
//do{
//    jsonData = try JSONEncoder().encode(req)
//    jsonString = String(data: jsonData, encoding: .utf8)!
//}
//catch{
//    print(error)
//}
//var request = URLRequest(url: URL(string: url)!)
//request.httpMethod = HTTPMethod.post.rawValue
//request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//request.httpBody = jsonData
//request.headers = headers
//AF.request(request)
