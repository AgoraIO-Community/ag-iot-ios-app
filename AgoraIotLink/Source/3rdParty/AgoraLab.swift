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
    
    private var http:String
    init(http:String){
        self.http = http
    }

    func resetDevice(_ deviceId:String, _ appId:String,_ token:String, _ rsp:@escaping(Int,String)->Void){
        
        let header = Header()
        
        let nodePayload = AgoraLab.ResetDevice.Payload(deviceId: deviceId, appId: appId)
        let paramsDic = AgoraLab.ResetDevice.Req(header: header, payload: nodePayload)
        
        let headers : HTTPHeaders = ["Authorization":token]
        
        let url = http + api.resetDevice

        AF.request(url,method: .post,parameters: paramsDic,encoder: JSONParameterEncoder.default,headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of:ResetDevice.Rsp.self){(dataRsp:AFDataResponse<ResetDevice.Rsp>) in
            URLCache.shared.removeAllCachedResponses()
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.e("3rd resetPassword fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("3rd resetPassword \(url) , detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
            }
        }
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
    
    func reqUploadIcon(_ token:String,_ image:UIImage,_ traceId:String, _ rsp:@escaping(Int,String,String?)->Void){
        let url = http + api.uploadHeadIcon
        //let httpHeaders = HTTPHeaders([:])
        let headers : HTTPHeaders = ["Authorization":token]
        let imageData : Data = image.jpegData(compressionQuality: 0.5)!
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imageData, withName: "file", fileName: "icon.jpg", mimeType: "image/jpg")
            //multiPart.append("true".data(using: String.Encoding.utf8)!, withName: "noRenameFile")
            multiPart.append("icon".data(using: String.Encoding.utf8)!, withName: "fileDir")
            multiPart.append("icon.jpg".data(using: String.Encoding.utf8)!, withName: "fileName")
        }, to: url, method: .post, headers: headers).uploadProgress(queue: .main) { progress in
            
        }.responseDecodable(of:UploadImage.Rsp.self){(dataRsp:AFDataResponse<UploadImage.Rsp>) in
            switch dataRsp.result{
            case .success(let ret):
                if(ret.code != 0){
                    log.w("al reqUploadIcon rsp:'\(ret.msg)(\(ret.code))'")
                }
                if(ret.code == AgoraLab.tokenExpiredCode){
                    rsp(ErrCode.XERR_TOKEN_INVALID,ret.msg,nil)
                    return
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_INVALID_PARAM,"上传图片:\(ret.msg)(\(ret.code))",ret.data)
            case .failure(let error):
                log.e("al reqUploadIcon \(url) failed,detail:\(error) ")
                rsp(ErrCode.XERR_NETWORK,"network error",nil)
            }
        }
    }
    
    func reqCall(_ token:String, _ reqPayload:Call.Payload,_ traceId:String, _ rsp:@escaping (Int,String,Call.Rsp?)->Void){
        let header = Header(traceId: traceId)
        let req = Call.Req(header: header, payload: reqPayload)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.call
        log.i("Call：param： \(req) token:\(token)")
        AF.request(url,method: .post,parameters: req,encoder: JSONParameterEncoder.default,headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of:Call.Rsp.self){(dataRsp:AFDataResponse<Call.Rsp>) in
                switch dataRsp.result{
                case .success(let ret):
                    log.i("Call resonse: \(ret)")
                    if(ret.code != 0){
                        log.w("al reqCall rsp:'\(ret.msg)(\(ret.code))' from:\(url)")
                    }
                    if(ret.code == AgoraLab.tokenExpiredCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,ret.msg,nil)
                        return
                    }
                    var ec = ErrCode.XERR_API_RET_FAIL
                    if(ret.code == 100001){//对端忙
                        ec = ErrCode.XERR_CALLKIT_PEER_BUSY
                    }
                    if(ret.code == 100005){
                        ec = ErrCode.XERR_CALLKIT_LOCAL_BUSY
                    }
                    rsp(ret.code == 0 ? ErrCode.XOK : ec,"dial number recv:\(ret.msg)(\(ret.code))",ret)
                case .failure(let error):
                    log.e("call failure: \(url) failed,detail:\(error) ")
                    rsp(ErrCode.XERR_NETWORK,"dial number fail",nil)
                }
            }
    }

    func reqAnswer(_ token:String,_ reqPayload:Answer.Payload,_ traceId:String, _ rsp:@escaping (Int,String,Answer.Data?)->Void){
        let header = Header.init(traceId: traceId)
        let req = Answer.Req(header: header, payload: reqPayload)
        let act = reqPayload.answer == 0 ? "accept" : "hangup"
        let url = http + api.answer
        log.i("reqAnswer param: '\(act)' sessionId:\(reqPayload.sessionId) callee:\(reqPayload.calleeId) caller:\(reqPayload.callerId) header:\(header) token:\(token)")
        let headers : HTTPHeaders = ["Authorization":token]
        
        AF.request(url,method: .post,parameters: req,encoder: JSONParameterEncoder.default,headers: headers)
            .validate(statusCode: acceptableStatusCodes)
            .responseDecodable(of:Answer.Rsp.self){(dataRsp:AFDataResponse<Answer.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    log.i("reqAnswer response : \(value)")
                    if(value.code != 0){
                        log.w("reqAnswer '\(act)' fail \(value) msg:\(value.msg) code:(\(value.code)) from \(url)")
                    }
                    if(value.code == AgoraLab.tokenExpiredCode){
                        rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,nil)
                        return
                    }
                    let op = reqPayload.answer == 0 ? "answer :" : "hangup:"
                    let ret = value.success ? "succ" : "fail("+String(value.code)+")"
                    
                    rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,  op + ret, value.data)
                case .failure(let error):
                    log.e("reqAnswer response fail error  '\(act)' \(url) detail:\(error) ")
                    rsp(ErrCode.XERR_NETWORK,reqPayload.answer == 0 ? "answer fail" : "hangup fail",nil)
                }
            }
    }

    func reqAnswerSync(_ token:String,_ reqPayload:Answer.Payload,_ traceId:String, _ rsp:@escaping (Int,String,[String:Any]?)->Void){
        
        let act = reqPayload.answer == 0 ? "accept" : "hangup"
        
        let header = Header()
        let urlString = http + api.answer
        guard let url = URL(string: urlString) else { return  }

        let request = NSMutableURLRequest(url: url)
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(token)", forHTTPHeaderField: "Authorization")
        request.addValue("\(header.traceId)", forHTTPHeaderField: "traceId")
        request.addValue("\(header.timestamp)", forHTTPHeaderField: "timestamp")
  
        var jsonStr : String = ""
        let dict = ["sessionId": reqPayload.sessionId, "calleeId": reqPayload.calleeId, "localId": reqPayload.localId, "callerId": reqPayload.callerId, "answer": reqPayload.answer] as [String : Any]
        let paramsDic = ["payload":dict]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramsDic, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonStr = jsonString
                log.i("reqAnswer_jsonString:\(jsonString) ")
            }
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
        }
 
        request.httpMethod = "POST"
        request.httpBody = jsonStr.data(using: .utf8)

        let semaphore = DispatchSemaphore(value: 0)
        
        var resultData = [String:Any]()
        let httpTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in

            if error == nil {
                guard let jsonData:[String:Any] = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : Any] else{
                    log.i("reqAnswer--success,解析失败 ")
                    return
                }
                log.i("reqAnswer--success \(jsonData) ")
                resultData = jsonData
                sleep(UInt32(0.5))
                semaphore.signal()

            }else{
                log.e("al reqAnswer '\(act)' \(url) failed,detail:\(String(describing: error)) ")
                semaphore.signal()
            }
        }
        httpTask.resume()

        semaphore.wait()
        
        if let success = resultData["success"] as? Bool,let code = resultData["code"] as? Int,let msg = resultData["msg"] as? String{
            
            if(code != 0){
                log.w("al reqAnswer '\(act)' fail \(msg)(\(code)) from \(url)")
            }
            if(code == AgoraLab.tokenExpiredCode){
                rsp(ErrCode.XERR_TOKEN_INVALID,msg,nil)
                return
            }
            let op = reqPayload.answer == 0 ? "answer :" : "hangup:"
            let ret = success ? "succ" : "fail("+String(code)+")"
            
            log.i("reqAnswer--success 成功返回")
            rsp(code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,  op + ret, resultData["data"] as? [String:Any] )
            
        }else{
            rsp(ErrCode.XERR_NETWORK,reqPayload.answer == 0 ? "answer fail" : "hangup fail",nil)
        }
    }

//    func reqLogin(_ username:String,_ password:String,rsp:@escaping(Int,String,LoginRspData?)->Void){
//        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
//        let params = ["username":username,"password":password]
//        let url = api.http_dev + api.authLogin
//
//        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
//            .validate()
//            .responseDecodable(of:Login.Rsp.self){(dataRsp:AFDataResponse<Login.Rsp>) in
//                switch dataRsp.result{
//                case .success(let ret):
//                    self.handleRspLogin(ret,rsp)
//                case .failure(let error):
//                    log.e("al reqLogin \(url) fail for \(username), detail: \(error) ")
//                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
//                }
//            }
//    }
    
    func reqRegister(_ userName:String,_ rsp:@escaping(Int,String)->Void){
        let header:HTTPHeaders = ["Content-Type":"application/json;charset=utf-8"]
        let params = ["username":userName]
        let url = http + api.oauthRegister
        
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default,headers: header)
            .validate()
            .responseDecodable(of:Rsp.self){(dataRsp:AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let ret):
                    if(ret.code != 0){
                        log.w("al reqRegister fail \(ret.msg)(\(ret.code))")
                    }
                    rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,ret.msg)
                case .failure(let error):
                    log.e("al reqRegister \(url) fail for \(userName), detail: \(error) ")
                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                }
            }
    }
    
//    func reqGetToken(_ userName:String,_ password:String,_ scope:String,_ clientId:String,_ secretKey:String,_ rsp:@escaping(Int,String,AgoraLabToken?)->Void){
//        let params:Dictionary<String,String> = ["grant_type":"password", "username":userName,"password":password,"scope":scope,"client_id":clientId,"client_secret":secretKey]
//        let url = http + api.oauthResetToken
//        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default)
//            .validate()
//            .responseDecodable(of:RestToken.Rsp.self){(dataRsp:AFDataResponse<RestToken.Rsp>) in
//                switch dataRsp.result{
//                case .success(let ret):
//                    var token:AgoraLabToken? = nil
//                    if(ret.code != 0){
//                        log.e("al reqGetToken fail \(ret.msg)(\(ret.code))")
//                    }
//                    else if(ret.data == nil){
//                        log.e("al reqGetToken data is nil \(ret.msg)(\(ret.code))")
//                    }
//                    else{
//                        let data = ret.data!
//                        token = AgoraLabToken(tokenType: data.token_type,
//                                              accessToken: data.access_token,
//                                              refreshToken: data.refresh_token,
//                                              expireIn: data.expires_in,
//                                              scope: data.scope)
//                    }
//                    
//                    rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,token)
//                case .failure(let error):
//                    log.e("al reqGetToken \(url) fail for \(userName), detail: \(error) ")
//                    rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
//                }
//            }
//    }
    
    func reqLogout(_ rsp: @escaping (Int,String)->Void){
        rsp(ErrCode.XOK,"")
    }
    
    #if false
    func reqAlertDelete(_ token:String,_ index:UInt64,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.delete
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageRead.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertDelete \(req) return code \(value.code)")
                            }
                            if(value.code == AgoraLab.tokenInvalidCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertDelete \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqAlertBatchDelete(_ token:String,_ indexes:[UInt64],_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageBatchRead.Req(header,indexes)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.batchDelete
        log.i("al reqAlertBatchDelete \(indexes)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageBatchRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageBatchRead.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertBatchDelete rsp \(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenInvalidCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertBatchDelete \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqAlertRead(_ token:String,_ index:UInt64,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.singleRead
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageRead.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertRead rsp \(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenInvalidCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertRead \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqAlertBatchRead(_ token:String,_ indexes:[UInt64],_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageBatchRead.Req(header,indexes)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.batchRead
        log.i("al reqAlertBatchRead \(indexes)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageBatchRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageBatchRead.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertBatchRead rsp:\(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenInvalidCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertBatchRead \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
              }
    }
    
    func reqAlertById(_ token:String,_ alertMessageId:UInt64, _ rsp:@escaping (Int,String,IotAlarm?) -> Void){
        let header = Header()
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.getById
        log.i("al reqAlertById \(alertMessageId)")
        let req = AlertMessageGetById.Req(header,alertMessageId)
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageGetById.Rsp.self){(dataRsp:AFDataResponse<AlertMessageGetById.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        var alerts:IotAlarm? = nil
                        if(value.data != nil){
                            let item = value.data!
                            //for item in data.pageResults{
                                let alert:IotAlarm = IotAlarm(messageId: item.alertMessageId)
                                alert.createdDate = item.createdDate
                                alert.messageType = item.messageType
                                alert.status = item.status
                                alert.desc = item.description ?? ""
                                alert.fileUrl = item.fileUrl ?? ""
                                alert.productId = item.productId
                                alert.deviceId = item.deviceId
                                alert.deviceName = item.deviceName
                                alert.deleted = item.deleted
                                alert.createdBy = item.createdBy
                                alert.createdDate = item.createdDate
                                alert.changedBy = item.changedBy ?? 0
                                alert.changedDate = item.changedDate ?? 0
                                alerts = alert
                            //}
                        }
                        else{
                            log.e("al reqAlertById rsp no data found")
                        }
                        
                        if(value.code != 0){
                            log.w("al reqAlertById rsp \(value.msg)(\(value.code)) with \(String(describing: alerts)) alerts")
                        }
                        if(value.code == AgoraLab.tokenInvalidCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,alerts)
                    case .failure(let error):
                        log.e("al reqAlertById \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                    }
                  }
    }
    
    func reqAlertCount(_ token:String,_ tenantId:String?,_ productId:String?,_ deviceId:String?,messageType:Int?,_ status:Int?,_ createDateBegin:Date?,_ createDateEnd:Date? ,_ rsp:@escaping(Int,String,UInt)->Void){
        let header = Header()

        let payload:AlertCount.Payload = AlertCount.Payload(
        tenantId: tenantId,
        productId: productId,
        deviceId: deviceId,
        messageType: messageType,
        status: status,
        createdDateBegin: createDateBegin?.toString(),
        createdDateEnd: createDateEnd?.toString())
        
        let req = AlertCount.Req(header,payload)
        let url = http + api.getAlertCount
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqAlertCount \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertCount.Rsp.self){(dataRsp:AFDataResponse<AlertCount.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertCount rsp \(value.msg)(\(value.code)) with \(value.data) alerts")
                            }
                            if(value.code == AgoraLab.tokenInvalidCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,0)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,value.data)
                        case .failure(let error):
                            log.e("al reqAlertCount \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",0)
                        }
                    }
    }
    
    func reqAlert(_ token:String,_ tenantId:String, _ query:AlarmQueryParam,_ rsp:@escaping (Int,String,[IotAlarm]?) -> Void){
        let header = Header()
        let pageInfo = AlertMessageGetPage.PageInfo(query.currentPage,query.pageSize)
        var payload:AlertMessageGetPage.Payload? = nil
        
        if let dev = query.device{
            payload = AlertMessageGetPage.Payload(
            tenantId: tenantId,
            productId: String(dev.productId),
            deviceId: String(dev.deviceId),
            messageType: query.messageType,
            status: query.status,
            createdDateBegin: query.createdDateBegin?.toString(),
            createdDateEnd: query.createdDateEnd.toString())
        }
        else{
            payload = AlertMessageGetPage.Payload(
            tenantId: tenantId,
            productId: nil,
            deviceId: nil,
            messageType: query.messageType,
            status: query.status,
            createdDateBegin: query.createdDateBegin?.toString(),
            createdDateEnd: query.createdDateEnd.toString())
        }
        let req = AlertMessageGetPage.Req(header,payload!,pageInfo)
        let url = http + api.getPage
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqAlert \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageGetPage.Rsp.self){(dataRsp:AFDataResponse<AlertMessageGetPage.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            var alerts:[IotAlarm] = []
                            if(value.data != nil){
                                let data = value.data!
                                if let pageResults = data.pageResults{
                                    for item in pageResults{
                                        let alert:IotAlarm = IotAlarm(messageId: item.alertMessageId)
                                        alert.createdDate = item.createdDate
                                        alert.messageType = item.messageType
                                        alert.status = item.status
                                        alert.desc = item.description ?? ""
                                        alert.fileUrl = item.fileUrl ?? ""
                                        alert.productId = item.productId
                                        alert.deviceId = item.deviceId
                                        alert.deviceName = item.deviceName
                                        alert.deleted = item.deleted
                                        alert.createdBy = item.createdBy
                                        alert.createdDate = item.createdDate
                                        alert.changedBy = item.changedBy ?? 0
                                        alert.changedDate = item.changedDate ?? 0
                                        alerts.append(alert)
                                        log.v("alert item \(item)")
                                    }
                                }
                            }
                            else{
                                log.e("al reqAlert rsp no data found")
                            }
                            if(value.code != 0){
                                log.w("al reqAlert rsp \(value.msg)(\(value.code)) with \(alerts.count) alerts")
                            }
                            if(value.code == AgoraLab.tokenInvalidCode){
                                rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,alerts)
                        case .failure(let error):
                            log.e("al reqAlert \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    
    #else
    func reqAddAlert(_ token:String,_ tenantId:String,_ productId:String,_ deviceId:String,_ deviceName:String,_ description:String,_ rsp:@escaping(Int,String)->Void){
        let header = Header()
        let payload = AlertMessageAddV2.Payload(beginTime: header.timestamp, tenantId: tenantId, productId: productId, deviceId: deviceId, deviceName: deviceName, description: description, status: 0, messageType: 1)
        let req = AlertMessageAddV2.Req(header,payload)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.addV2
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageAddV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageAddV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.i("al reqAddAlert rsp \(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAddAlert \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    func reqAlertRead(_ token:String,_ index:UInt64,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageReadV2.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.singleReadV2
        log.v("al reqAlertRead \(index)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageReadV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageReadV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertRead rsp \(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertRead \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqAlertBatchRead(_ token:String,_ indexes:[UInt64],_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageBatchReadV2.Req(header,indexes)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.batchReadV2
        log.v("al reqAlertBatchRead \(indexes)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageBatchReadV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageBatchReadV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertBatchRead rsp:\(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertBatchRead \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
              }
    }
    
    func reqAlertCount(_ token:String,_ tenantId:String?,_ productId:String?,_ deviceId:String?,messageType:Int?,_ status:Int?,_ createDateBegin:Date?,_ createDateEnd:Date? ,_ rsp:@escaping(Int,String,UInt)->Void){
        let header = Header()

        let payload:AlertCountV2.Payload = AlertCountV2.Payload(
        tenantId: tenantId,
        productId: productId,
        deviceId: deviceId,
        messageType: messageType,
        status: status,
        createdDateBegin: createDateBegin?.toString(),
        createdDateEnd: createDateEnd?.toString())
        
        let req = AlertCountV2.Req(header,payload)
        let url = http + api.getAlertCountV2
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqAlertCount \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertCountV2.Rsp.self){(dataRsp:AFDataResponse<AlertCountV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertCount rsp \(value.msg)(\(value.code)) with \(value.data) alerts")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,0)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,value.data)
                        case .failure(let error):
                            log.e("al reqAlertCount \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",0)
                        }
                    }
    }
    
    func reqAlertById(_ token:String,_ alertMessageId:UInt64, _ rsp:@escaping (Int,String,IotAlarm?) -> Void){
        let header = Header()
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.getByIdV2
        log.v("al reqAlertById \(alertMessageId)")
        let req = AlertMessageGetById.Req(header,alertMessageId)
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageGetByIdV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageGetByIdV2.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        self.handleRspGetAlarmByIdV2(value, rsp)
                    case .failure(let error):
                        log.e("al reqAlertById \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                    }
                  }
    }
    
    func reqAlert(_ token:String,_ tenantId:String, _ query:AlarmQueryParam,_ rsp:@escaping (Int,String,[IotAlarm]?) -> Void){
        let header = Header()
        let pageInfo = AlertMessageGetPageV2.PageInfo(query.currentPage,query.pageSize)
        let payload = AlertMessageGetPageV2.Payload(
            tenantId: tenantId,
            productId: query.productId,
            deviceId: query.deviceId,
            messageType: query.messageType,
            status: query.status,
            createdDateBegin: query.createdDateBegin?.toString(),
            createdDateEnd: query.createdDateEnd?.toString())
            
        let req = AlertMessageGetPageV2.Req(header,payload,pageInfo)
        let url = http + api.getPageV2
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqAlert \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageGetPageV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageGetPageV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            self.handleRspGetAlarmPageV2(value,rsp)
                        case .failure(let error):
                            log.e("al reqAlert \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    
    func reqAlertDelete(_ token:String,_ index:UInt64,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.deleteV2
        log.v("al reqAlertDelete \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageDeleteV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageDeleteV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertDelete \(req) return code \(value.code)")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertDelete \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqAlertBatchDelete(_ token:String,_ indexes:[UInt64],_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageBatchRead.Req(header,indexes)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.batchDeleteV2
        log.v("al reqAlertBatchDelete \(indexes)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageBatchDeleteV2.Rsp.self){(dataRsp:AFDataResponse<AlertMessageBatchDeleteV2.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqAlertBatchDelete rsp \(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqAlertBatchDelete \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqAlertImageUrl(_ token:String,_ tenantId:String,_ alertImageId:String,_ rsp:@escaping(Int,String,String?)->Void){
        let header = Header()
        let req = AlertImageUrl.Req(header, alertImageId)
        let url = http + api.getImageUrl
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqAlertImageUrl \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertImageUrl.Rsp.self){(dataRsp:AFDataResponse<AlertImageUrl.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            self.handleRspGetImageUrl(value,rsp)
                        case .failure(let error):
                            log.e("al reqAlertImageUrl \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    
    func reqAlertVideoUrl(_ token:String,_ userId:String,_ deviceId:String,_ beginTime:UInt64,_ rsp:@escaping(Int,String,AlarmVideoInfo?)->Void){
        let header = Header()
        let payload = AlertVideoUrl.Payload(userId: userId, deviceId: deviceId, beginTime: beginTime)
        let req = AlertVideoUrl.Req(header, payload)
        let url = http + api.getVideoUrl
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqAlertVideoUrl \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertVideoUrl.Rsp.self){(dataRsp:AFDataResponse<AlertVideoUrl.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            self.handleRspGetVideoUrl(value,rsp)
                        case .failure(let error):
                            log.e("al reqAlertVideoUrl \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    #endif
    
    func reqSysAlertRead(_ token:String,_ index:UInt64,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.sysReadMsg
        log.v("al reqSysAlertRead \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
              .responseDecodable(of:AlertMessageRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageRead.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqSysAlertRead rsp \(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqSysAlertRead \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqSysAlertBatchRead(_ token:String,_ indexes:[UInt64],_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageBatchRead.Req(header,indexes)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.sysReadMsgBatch
        log.v("al reqSysAlertBatchRead \(indexes)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageBatchRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageBatchRead.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqSysAlertBatchRead rsp:\(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg)
                        case .failure(let error):
                            log.e("al reqSysAlertBatchRead \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                        }
                    }
    }
    
    func reqSysAlert(_ token:String,_ tenantId:String, _ query:SysAlarmQueryParam,_ rsp:@escaping (Int,String,[IotAlarm]?) -> Void){
        let header = Header()
        let pageInfo = SysAlertMessageGetPage.PageInfo(query.currentPage,query.pageSize)
        let payload = SysAlertMessageGetPage.Payload(
            tenantId: nil,
            productId: nil,
            deviceIds: query.deviceIds,
            messageType: query.messageType,
            status: query.status,
            createdDateBegin: query.createdDateBegin?.toString(),
            createdDateEnd: query.createdDateEnd.toString())
        
        let req = SysAlertMessageGetPage.Req(header,payload,pageInfo)
        let url = http + api.sysGetPage
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqSysAlert \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:SysAlertMessageGetPage.Rsp.self){(dataRsp:AFDataResponse<SysAlertMessageGetPage.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            var alerts:[IotAlarm] = []
                            if(value.data != nil){
                                let data = value.data!
                                if let pageResults = data.pageResults{
                                    for item in pageResults{
                                        let alert:IotAlarm = IotAlarm(messageId: item.systemMessageId)
                                        alert.createdDate = item.createdDate ?? 0
                                        alert.messageType = item.messageType
                                        alert.status = item.status
                                        alert.desc = item.description ?? ""
                                        alert.fileUrl = item.fileUrl ?? ""
                                        alert.productId = item.productId
                                        alert.deviceId = item.deviceId
                                        alert.deviceName = item.deviceName ?? ""
                                        alert.deleted = item.deleted
                                        alert.createdBy = item.createdBy
                                        alert.createdDate = item.createdDate ?? 0
                                        alert.changedBy = item.changedBy ?? 0
                                        alert.changedDate = item.changedDate ?? 0
                                        alerts.append(alert)
                                        log.i("alert item \(item)")
                                    }
                                }
                            }
                            else{
                                log.e("al reqSysAlert rsp no data found")
                            }
                            if(value.code != 0){
                                log.w("al reqSysAlert rsp \(value.msg)(\(value.code)) with \(alerts.count) alerts")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,nil)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,alerts)
                        case .failure(let error):
                            log.e("al reqSysAlert \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    
    func reqSysAlertById(_ token:String,_ alertMessageId:UInt64, _ rsp:@escaping (Int,String,IotAlarm?) -> Void){
        let header = Header()
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.sysGetById
        log.v("al reqSysAlertById \(alertMessageId)")
        let req = AlertMessageGetById.Req(header,alertMessageId)
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageGetById.Rsp.self){(dataRsp:AFDataResponse<AlertMessageGetById.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            var alerts:IotAlarm? = nil
                            if(value.data != nil){
                                let item = value.data!
                                //for item in data.pageResults{
                                    let alert:IotAlarm = IotAlarm(messageId: item.alertMessageId)
                                    alert.createdDate = item.createdDate
                                    alert.messageType = item.messageType
                                    alert.status = item.status
                                    alert.desc = item.description ?? ""
                                    alert.fileUrl = item.fileUrl ?? ""
                                    alert.productId = item.productId
                                    alert.deviceId = item.deviceId
                                    alert.deviceName = item.deviceName
                                    alert.deleted = item.deleted
                                    alert.createdBy = item.createdBy
                                    alert.createdDate = item.createdDate
                                    alert.changedBy = item.changedBy ?? 0
                                    alert.changedDate = item.changedDate ?? 0
                                    alerts = alert
                                //}
                            }
                            else{
                                log.e("al reqSysAlertById rsp no data found")
                            }
                            if(value.code != 0){
                                log.w("al reqSysAlertById rsp \(value.msg)(\(value.code)) with \(String(describing: alerts)) alerts")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,nil)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,alerts)
                        case .failure(let error):
                            log.e("al reqSysAlertById \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    
    func reqSysAlertCount(_ token:String,_ tenantId:String?,_ productId:String?,_ deviceId:[String]?,messageType:Int?,_ status:Int?,_ createDateBegin:Date?,_ createDateEnd:Date? ,_ rsp:@escaping(Int,String,UInt)->Void){
        let header = Header()

        let payload = SysAlertCount.Payload(
            tenantId: nil,
            productId: productId,
            deviceIds: deviceId,
            messageType: messageType,
            status: status,
            createdDateBegin: createDateBegin?.toString(),
            createdDateEnd: createDateEnd?.toString())
        
        let req = SysAlertCount.Req(header,payload)
        
        let headers : HTTPHeaders = ["Authorization":token]
        log.v("al reqSysAlertCount \(req)")
        let url = http + api.sysGetAlertCount
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:SysAlertCount.Rsp.self){(dataRsp:AFDataResponse<SysAlertCount.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqSysAlertCount rsp \(value.msg)(\(value.code)) with \(value.data) alerts")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,0)
                                return
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,value.data)
                        case .failure(let error):
                            log.e("al reqSysAlertCount \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",0)
                        }
                    }
    }
    
    func reqControlInfo(_ token:String,_ localVirtualNumber:String,_ peerVirtualNumber:String,_ rsp:@escaping(Int,String,RtmSession?)->Void){
        let header = Header()
        let payload = ControlInfo.Payload(localVirtualNumb : localVirtualNumber, peerVirtualNumb: peerVirtualNumber)
        let req = ControlInfo.Req(header:header,payload: payload)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.control
        log.v("al reqControlInfo localVirtualNumb:\(localVirtualNumber) peerVirtualNumb:\(peerVirtualNumber)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:ControlInfo.Rsp.self){(dataRsp:AFDataResponse<ControlInfo.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqControlInfo rsp:\(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,nil)
                                return
                            }
                            var sess:RtmSession? = nil
                            if let data = value.data {
                                sess = RtmSession()
                                //sess?.loginId = data.uid
                                sess?.token = data.rtmToken
                                sess?.peerVirtualNumber = peerVirtualNumber
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,sess)
                        case .failure(let error):
                            log.e("al reqControlInfo \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
    }
    
    func reqPlayerToekn(_ token:String,_ appId:String,_ channelName:String,_ rsp:@escaping(Int,String,PlayerSession?)->Void){
        let header = Header()
        let payload = RtcToken.Payload(appId: appId, channelName: channelName)
        let req = RtcToken.Req(header:header,payload: payload)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.rtcToken
        log.v("al reqRtcToekn appId:\(appId) channelName:\(channelName)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:RtcToken.Rsp.self){(dataRsp:AFDataResponse<RtcToken.Rsp>) in
                        switch dataRsp.result{
                        case .success(let value):
                            if(value.code != 0){
                                log.w("al reqRtcToekn rsp:\(value.msg)(\(value.code))")
                            }
                            if(value.code == AgoraLab.tokenExpiredCode){
                                rsp(ErrCode.XERR_TOKEN_INVALID,value.msg,nil)
                                return
                            }
                            var sess:PlayerSession? = nil
                            if let data = value.data {
                                sess = PlayerSession()
                                //sess?.loginId = data.uid
                                sess?.token = data.rtcToken
                                sess?.channelName = data.channelName
                                sess?.uid = data.uid
                            }
                            rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_API_RET_FAIL,value.msg,sess)
                        case .failure(let error):
                            log.e("al reqRtcToekn \(url) fail for \(req), detail: \(error) ")
                            rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error",nil)
                        }
                    }
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
