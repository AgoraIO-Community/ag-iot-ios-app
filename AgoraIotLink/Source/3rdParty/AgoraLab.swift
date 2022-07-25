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
    private var http:String
    init(http:String){
        self.http = http
    }
//    public func reqRegisterUser(_ username: String,_ password:String, _ appId: String,_ rsp: @escaping (Int,String,UInt?)->Void){
//        let headers : HTTPHeaders = ["Authorization":arg.Authorization]
//        let params : Dictionary = ["customerAccountId":username,"appId":appId]
//        AF.request(url.register,method: .post,parameters: params, headers: headers)
//            .validate()
////            .responseDecodable(of:Register.Rsp.self){(dataRsp:AFDataResponse<Register.Rsp>) in
////                switch dataRsp.result{
////                case .success(let value):
////                    if(value.code != 200){
////                        log.e("al reqRegisterUser return \(value.message)(\(value.code)) for \(params)")
////                    }
////                    rsp(value.code == 200 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_REGISTER,value.message,value.data?.agoraUid)
////                case .failure(let error):
////                    log.e("al reqRegisterUser \(url.register) fail for \(username) appId \(appId), detail: \(error) ")
////                    rsp(ErrCode.XERR_ACCOUNT_REGISTER,error.errorDescription ?? "网络请求失败",nil)
////                }
////            }
//            .responseString(completionHandler: {(response) in
//            switch response.result{
//            case .success(let value):
//                log.e(value)
//                _ = JSON(value)
//                //cb(ErrCode.XERR_ALARM_NOT_FOUND,value,nil)
//            case .failure(let error):
//                log.e("http request detail: \(error) ")
//                //cb(ErrCode.XERR_ACCOUNT_REGISTER,"")
//            }
//           })
//    }
    
//    public func reqRegisterDevice(_ deviceId:String,_ appId:String,_ rsp:@escaping (Int,String,UInt?)->Void){
//        let headers : HTTPHeaders = ["Authorization":arg.Authorization]
//        let params:Dictionary<String,String> = ["deviceId":deviceId,"appId":appId]
//        AF.request(url.register,method: .post,parameters: params, encoder: JSONParameterEncoder.default,headers: headers)
//            .validate()
//            .responseDecodable(of:Register.Rsp.self){(dataRsp:AFDataResponse<Register.Rsp>) in
//                switch dataRsp.result{
//                case .success(let value):
//                    if(value.code != 200){
//                        log.e("al reqRegisterDevice return code \(value.code)")
//                    }
//                    rsp(value.code == 200 ? ErrCode.XOK : ErrCode.XERR_ACCOUNT_REGISTER,value.message,value.data?.agoraUid)
//                case .failure(let error):
//                    log.e("al reqRegisterDevice \(url.register) fail for \(deviceId) appId \(appId), detail: \(error) ")
//                    rsp(ErrCode.XERR_ACCOUNT_REGISTER,error.errorDescription ?? "网络请求失败",nil)
//                }
//            }
//    }
    func reqUploadIcon(_ token:String,_ image:UIImage,_ traceId:String, _ rsp:@escaping(Int,String,String?)->Void){
        let url = http + api.uploadHeadIcon
        let httpHeaders = HTTPHeaders([:])
        let imageData : Data = image.jpegData(compressionQuality: 0.5)!
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imageData, withName: "file", fileName: "icon.jpg", mimeType: "image/jpg")
            //multiPart.append("true".data(using: String.Encoding.utf8)!, withName: "noRenameFile")
            multiPart.append("icon".data(using: String.Encoding.utf8)!, withName: "fileDir")
            multiPart.append("icon.jpg".data(using: String.Encoding.utf8)!, withName: "fileName")
        }, to: url, method: .post, headers: httpHeaders).uploadProgress(queue: .main) { progress in
            
        }.responseDecodable(of:UploadImage.Rsp.self){(dataRsp:AFDataResponse<UploadImage.Rsp>) in
            switch dataRsp.result{
            case .success(let ret):
                log.i("al reqUploadIcon rsp:'\(ret.msg)(\(ret.code))'")
                if(ret.code == AgoraLab.tokenExpiredCode){
                    rsp(ErrCode.XERR_TOKEN_EXPIRED,ret.msg,nil)
                    return
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_INVALID_PARAM,"上传图片:\(ret.msg)(\(ret.code))",ret.data)
            case .failure(let error):
                log.e("al reqUploadIcon \(url) failed,detail:\(error) ")
                rsp(ErrCode.XERR_NETWORK,"网络错误",nil)
            }
        }
    }
    
    func reqCall(_ token:String, _ reqPayload:Call.Payload,_ traceId:String, _ rsp:@escaping (Int,String,Call.Rsp?)->Void){
        let header = Header(traceId: traceId)
        let req = Call.Req(header: header, payload: reqPayload)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.call
        log.i("al reqCall \(req)")
        AF.request(url,method: .post,parameters: req,encoder: JSONParameterEncoder.default,headers: headers)
            .validate()
            .responseDecodable(of:Call.Rsp.self){(dataRsp:AFDataResponse<Call.Rsp>) in
                switch dataRsp.result{
                case .success(let ret):
                    log.i("al reqCall rsp:'\(ret.msg)(\(ret.code))'")
                    if(ret.code == AgoraLab.tokenExpiredCode){
                        rsp(ErrCode.XERR_TOKEN_EXPIRED,ret.msg,nil)
                        return
                    }
                    var ec = ErrCode.XERR_CALLKIT_DIAL
                    if(ret.code == 100001){
                        ec = ErrCode.XERR_CALLKIT_PEER_BUSY
                    }
                    rsp(ret.code == 0 ? ErrCode.XOK : ec,"拨打电话收到响应:\(ret.msg)(\(ret.code))",ret)
                case .failure(let error):
                    log.e("al reqCall \(url) failed,detail:\(error) ")
                    rsp(ErrCode.XERR_NETWORK,"拨打电话操作失败",nil)
                }
            }
    }

    func reqAnswer(_ token:String,_ reqPayload:Answer.Payload,_ traceId:String, _ rsp:@escaping (Int,String,Answer.Data?)->Void){
        let header = Header()
        let req = Answer.Req(header: header, payload: reqPayload)
        let act = reqPayload.answer == 0 ? "accept" : "hangup"
        let url = http + api.answer
        log.i("al reqAnswer '\(act)' by local:\(reqPayload.localId) with: callee:\(reqPayload.calleeId) by caller:\(reqPayload.callerId) sess:\(reqPayload.sessionId)")
        let headers : HTTPHeaders = ["Authorization":token]
        AF.request(url,method: .post,parameters: req,encoder: JSONParameterEncoder.default,headers: headers)
            .validate()
            .responseDecodable(of:Answer.Rsp.self){(dataRsp:AFDataResponse<Answer.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    log.i("al reqAnswer '\(act)' rsp: '\(value.success)(\(value.code))'")
                    if(value.code == AgoraLab.tokenExpiredCode){
                        rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                        return
                    }
                    let op = reqPayload.answer == 0 ? "接听电话操作:" : "挂断电话操作:"
                    let ret = value.success ? "成功" : "失败("+String(value.code)+")"
                    if(!value.success){
                        log.e("al reqAnswer fail \(value.msg)(\(value.code))")
                    }
                    rsp(value.success ? ErrCode.XOK : ErrCode.XERR_CALLKIT_ANSWER,  op + ret, value.data)
                case .failure(let error):
                    log.e("al reqAnswer \(url) failed,detail:\(error) ")
                    rsp(ErrCode.XERR_NETWORK,reqPayload.answer == 0 ? "接听电话操作失败" : "挂断电话失败",nil)
                }
            }
    }
    
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
                    log.e("al reqRegister fail \(ret.msg)(\(ret.code))")
                }
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg)
            case .failure(let error):
                log.e("al reqRegister \(url) fail for \(userName), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
            }
           }
    }
    
    func reqGetToken(_ userName:String,_ password:String,_ scope:String,_ clientId:String,_ secretKey:String,_ rsp:@escaping(Int,String,AgoraLabToken?)->Void){
        let params:Dictionary<String,String> = ["grant_type":"password", "username":userName,"password":password,"scope":scope,"client_id":clientId,"client_secret":secretKey]

        let url = http + api.oauthResetToken
        
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of:RestToken.Rsp.self){(dataRsp:AFDataResponse<RestToken.Rsp>) in
            switch dataRsp.result{
            case .success(let ret):
                var token:AgoraLabToken? = nil
                if(ret.code != 0){
                    log.e("al reqGetToken fail \(ret.msg)(\(ret.code))")
                }
                else if(ret.data == nil){
                    log.e("al reqGetToken data is nil \(ret.msg)(\(ret.code))")
                }
                else{
                    let data = ret.data!
                    token = AgoraLabToken()
                    token?.acessToken = data.access_token
                    token?.expireIn = data.expires_in
                    token?.refreshToken = data.refresh_token
                    token?.tokenType = data.token_type
                    token?.scope = data.scope
                }
                
                rsp(ret.code == 0 ? ErrCode.XOK : ErrCode.XERR_UNKNOWN,ret.msg,token)
            case .failure(let error):
                log.e("al reqGetToken \(url) fail for \(userName), detail: \(error) ")
                rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
            }
           }
    }
    
    func reqLogout(_ account: String,_ rsp: @escaping (Int,String)->Void){
        //log.w("agoralab no api for logout")
        rsp(ErrCode.XOK,"")
    }
    
    func reqAlertDelete(_ token:String,_ index:Int,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.delete
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageRead.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        log.i("al reqAlertDelete \(req) return code \(value.code)")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
                    case .failure(let error):
                        log.e("al reqAlertDelete \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
                        log.i("al reqAlertBatchDelete rsp \(value.msg)(\(value.code))")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
                    case .failure(let error):
                        log.e("al reqAlertBatchDelete \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
    }
    
//    func addAlert(_ token:String,_ account:String, _ dev:IotDevice, _ alertType:Int,_ rsp:@escaping(Int,String)->Void){
//        let header = Header()
//        let payload = AlertMessageAdd.Payload(tenantId:account,
//                                              productId: dev.productId,
//                                              deviceId:dev.deviceId,
//                                              deviceName: dev.deviceName,
//                                              description: "this is a desc",
//                                              fileUrl: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
//                                              status: 0,
//                                              messageType: alertType
//        )
//        let req = AlertMessageAdd.Req(header,payload)
//        let headers : HTTPHeaders = ["Authorization":token]
//        log.i("al addAlert req \(req)")
//        AF.request(url.add,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
//                  .validate()
//                  .responseDecodable(of:AlertMessageAdd.Rsp.self){(dataRsp:AFDataResponse<AlertMessageAdd.Rsp>) in
//                    switch dataRsp.result{
//                    case .success(let value):
//                        log.i("al addAlert rsp \(value.msg)(\(value.code))")
//                        if(value.code == AgoraLab.tokenExpiredCode){
//                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
//                            return
//                        }
//                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
//                    case .failure(let error):
//                        log.e("al addAlert rsp \(url.add) fail for \(req), detail: \(error) ")
//                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
//                    }
//                }
//        
//    }
    
    func reqAlertRead(_ token:String,_ index:Int,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.singleRead
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageRead.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        log.i("al reqAlertRead rsp \(value.msg)(\(value.code))")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
                    case .failure(let error):
                        log.e("al reqAlertRead \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
    }
    
    func reqSysAlertRead(_ token:String,_ index:Int,_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageRead.Req(header,index)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.sysReadMsg
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageRead.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        log.i("al reqSysAlertRead rsp \(value.msg)(\(value.code))")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
                    case .failure(let error):
                        log.e("al reqSysAlertRead \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
                        log.i("al reqAlertBatchRead rsp:\(value.msg)(\(value.code))")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
                    case .failure(let error):
                        log.e("al reqAlertBatchRead \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
                    }
                }
    }
    
    func reqSysAlertBatchRead(_ token:String,_ indexes:[UInt64],_ rsp:@escaping(Int,String) -> Void){
        let header = Header()
        let req = AlertMessageBatchRead.Req(header,indexes)
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.sysReadMsgBatch
        log.i("al reqSysAlertBatchRead \(indexes)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertMessageBatchRead.Rsp.self){(dataRsp:AFDataResponse<AlertMessageBatchRead.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        log.i("al reqSysAlertBatchRead rsp:\(value.msg)(\(value.code))")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg)
                    case .failure(let error):
                        log.e("al reqSysAlertBatchRead \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
                        log.i("al reqAlertById rsp \(value.msg)(\(value.code)) with \(String(describing: alerts)) alerts")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg,alerts)
                    case .failure(let error):
                        log.e("al reqAlertById \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
    }
    
    func reqSysAlertById(_ token:String,_ alertMessageId:UInt64, _ rsp:@escaping (Int,String,IotAlarm?) -> Void){
        let header = Header()
        let headers : HTTPHeaders = ["Authorization":token]
        let url = http + api.sysGetById
        log.i("al reqSysAlertById \(alertMessageId)")
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
                        log.i("al reqSysAlertById rsp \(value.msg)(\(value.code)) with \(String(describing: alerts)) alerts")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg,alerts)
                    case .failure(let error):
                        log.e("al reqSysAlertById \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
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
        log.i("al reqAlertCount \(req)")
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:AlertCount.Rsp.self){(dataRsp:AFDataResponse<AlertCount.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        log.i("al reqAlertCount rsp \(value.msg)(\(value.code)) with \(value.data) alerts")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,0)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg,value.data)
                    case .failure(let error):
                        log.e("al reqAlertCount \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",0)
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
        log.i("al reqSysAlertCount \(req)")
        let url = http + api.sysGetAlertCount
        AF.request(url,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
                  .validate()
                  .responseDecodable(of:SysAlertCount.Rsp.self){(dataRsp:AFDataResponse<SysAlertCount.Rsp>) in
                    switch dataRsp.result{
                    case .success(let value):
                        log.i("al reqSysAlertCount rsp \(value.msg)(\(value.code)) with \(value.data) alerts")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,0)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg,value.data)
                    case .failure(let error):
                        log.e("al reqSysAlertCount \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",0)
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
        log.i("al reqAlert \(req)")
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
                                    log.i("alert item \(item)")
                                }
                            }
                        }
                        else{
                            log.e("al reqAlert rsp no data found")
                        }
                        log.i("al reqAlert rsp \(value.msg)(\(value.code)) with \(alerts.count) alerts")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg,alerts)
                    case .failure(let error):
                        log.e("al reqAlert \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
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
        log.i("al reqSysAlert \(req)")
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
                        log.i("al reqSysAlert rsp \(value.msg)(\(value.code)) with \(alerts.count) alerts")
                        if(value.code == AgoraLab.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.msg,nil)
                            return
                        }
                        rsp(value.code == 0 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.msg,alerts)
                    case .failure(let error):
                        log.e("al reqSysAlert \(url) fail for \(req), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
//                  .responseString(completionHandler: {(response) in
//                  switch response.result{
//                  case .success(let value):
//                      log.e(value)
//                      _ = JSON(value)
//                      //cb(ErrCode.XERR_ALARM_NOT_FOUND,value,nil)
//                  case .failure(let error):
//                      log.e("http request detail: \(error) ")
//                      //cb(ErrCode.XERR_ACCOUNT_REGISTER,"")
//                  }
//                 })
    }
    
//    func reqAlarms(_ appId:String, _ devices:[IotDevice], _ query:IAlarmMgr.QueryParam, _ rsp: @escaping (Int, String, [IotAlarm]?) -> Void) {
//        var devId:[String] = []
//        for dev in devices{
//            devId.append(String(dev.deviceMac))
//        }
//        
//        let date = String(format:"%04d-%02d-%02d",query.year,query.month,query.day)
//        
//        let req : Alarm.Req = Alarm.Req(appId:appId,
//                                        deviceIdList: devId,
//                                        date:date,
//                                        page:query.pageIndex,
//                                        size:query.pageSize,
//                                        type:query.type)
//            
//        let headers : HTTPHeaders = ["Authorization":arg.Authorization]
//            
//        AF.request(url.getPage,method: .post,parameters:req,encoder:JSONParameterEncoder.default, headers: headers)
//                  .validate()
//                  .responseDecodable(of:Alarm.Rsp.self){(dataRsp:AFDataResponse<Alarm.Rsp>) in
//                    switch dataRsp.result{
//                    case .success(let value):
//                        if(value.code != 200){
//                            log.e("al reqAlarm \(req) return code \(value.code)")
//                            rsp(ErrCode.XERR_ALARM_NOT_FOUND,value.message,nil)
//                            return
//                        }
//                        var alarms:[IotAlarm] = []
//                        if(value.data != nil){
//                            for item in value.data!{
//                                let alarm:IotAlarm = IotAlarm(
//                                    alarmId:item.alarmId,
//                                    type:item.alarmType,
//                                    description: item.alarmDescription,
//                                    attachMsg: item.attachMsg,
//                                    occurDate: item.date,
//                                    timestamp:item.timestamp,
//                                    deviceId: item.recordInfo.deviceId,
//                                    deviceUid: item.recordInfo.deviceUid,
//                                    recordChannel: item.recordInfo.recordChannel,
//                                    readed: item.read)
//                                alarms.append(alarm)
//                            }
//                        }
//                        rsp(value.code == 200 ? ErrCode.XOK : ErrCode.XERR_ALARM_NOT_FOUND,value.message,alarms)
//                    case .failure(let error):
//                        log.e("al reqAlarm \(url.alarmInfo) fail for \(req), detail: \(error) ")
//                        rsp(ErrCode.XERR_ALARM_NOT_FOUND,error.errorDescription ?? "网络请求失败",nil)
//                    }
//                }
//            
//    }
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
