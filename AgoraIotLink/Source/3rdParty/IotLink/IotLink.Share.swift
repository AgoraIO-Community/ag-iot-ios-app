//
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/5/31.
//

import Foundation
import Alamofire

extension IotLink{
    public func shareToUser(token:String,deviceId:String,userId:String,type:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:Dictionary = ["mac":deviceId,"userId":userId,"type":type]
        let url = http + api.ShareToUser
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw shareToUser \(url) fail,\(deviceId) for \(userId), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareToUser: \(value.tip)(\(value.code))")
                        }
                        if(value.code == IotLink.tokenInvalidCode){
                            rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw shareToUser failed:\(value.tip)(\(value.code))")
                                if(value.code == 1){
                                    ec = ErrCode.XERR_DEVMGR_SHARE_TARGET_NOT_EXIST
                                }
                                else{
                                    ec = ErrCode.XERR_UNKNOWN
                                }
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw shareToUser \(url) fail for \(userId), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                    }
                }
        }
    }
    
    public func shareAccept(token:String,deviceName:String,order:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:Dictionary = ["deviceNickname":deviceName,"order":order]
        let url = http + api.ShareAccept
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw shareAccept \(url) fail for \(deviceName), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareAccept: \(value.tip)(\(value.code))")
                        }
                        if(value.code == IotLink.tokenInvalidCode){
                            rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw shareAccept failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw shareAccept \(url) fail for \(deviceName), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                    }
                }
        }
    }
    
    struct OwnDevice{
        public struct Device : Decodable{
            let nickName:String
            let count:Int
            let time:UInt64
            let deviceId:String
            let mac:String
        }
        public struct Rsp : Decodable{
            let code:Int
            let tip:String
            let info:[Device]?
        }
    }

    struct ShareWithme{
        public struct Device : Decodable{
            let nickName:String
            let time:UInt64
            let deviceId:String
            let mac:String
        }
        public struct Rsp : Decodable{
            let code:Int
            let tip:String
            let info:[Device]?
        }
    }
    
    struct ShareCancel{
        struct Info:Decodable{
            let appuserId:String
            let avatar:String?
            let connect:Bool
            let createTime:UInt64
            let deviceId:String
            let deviceNickname:String
            let email:String?
            let mac:String
            let nickName:String?
            let phone:String?
            let productId:String
            let productKey:String
            let sharer:String
            let uType:String
            let updateTime:UInt64
        }
        struct Rsp:Decodable{
            let code:Int
            let tip:String
            let info:[Info]?
        }
    }
    
    public func shareRemove(token:String,deviceId:String,userId:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = ["mac":deviceId,"userId":userId]
        let url = http + api.ShareRemove
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw shareRemove \(url) fail for \(deviceId), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareRemove: \(value.tip)(\(value.code))")
                        }
                        if(value.code == IotLink.tokenInvalidCode){
                            rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw shareRemove failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw shareRemove \(url) fail for \(deviceId), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                    }
                }
        }
    }
    
    public func sharePushAdd(token:String,deviceNumber:String,email:String,type:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = ["deviceId":deviceNumber,"email":email,"type":type]
        let url = http + api.SharePushAdd
        log.i("gw sharePushAdd \(params)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw sharePushAdd \(url) fail for dev:\(deviceNumber) with email:\(email) detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw sharePushAdd: \(value.tip)(\(value.code))")
                        }
                        if(value.code == IotLink.tokenInvalidCode){
                            rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw sharePushAdd failed:\(value.tip)(\(value.code))")
                                if(value.code == 12013){
                                    ec = ErrCode.XERR_DEVMGR_SHARE_ALREADY_BIND
                                }
                                else{
                                    ec = ErrCode.XERR_UNKNOWN
                                }
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw sharePushAdd \(url) fail for \(deviceNumber), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                    }
                }
        }
    }
    
    public func sharePushDel(token:String,id:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = ["id":id]
        let url = http + api.SharePushDel
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw sharePushDel \(url) fail for \(id), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw sharePushDel: \(value.tip)(\(value.code))")
                        }
                        if(value.code == IotLink.tokenInvalidCode){
                            rsp(ErrCode.XERR_TOKEN_INVALID,value.tip)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw sharePushDel failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            rsp(ec,value.tip)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw sharePushDel \(url) fail for \(id), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "network error")
                    }
                }
        }
    }
    
    struct PushDetail{
        //{"code":0,"info":{"auditStatus":false,"content":"guzhihe@agora.io分享IVFES3LNGY2G2NRVIVBU63BVFU3DQOBYHEYDGMRVHA4DMMRT设备","createBy":686044235892076544,"createTime":1654480126898,"deleted":0,"deviceId":689613094541373440,"id":693605830988247040,"merchantId":100000000000000000,"merchantName":"声网物联","msgType":1,"para":"D686044235892076544_58m7fu3rh2ww_0B3F1ED77B2185C7DE25B99B01FF8C5B","permission":3,"pushTime":1654480126898,"sharerName":"myNewName","status":1,"title":"设备 IVFES3LNGY2G2NRVIVBU63BVFU3DQOBYHEYDGMRVHA4DMMRT 分享给新成员","type":1,"userId":686044235892076544},"tip":"响应成功"}
        struct Info:Decodable{
            let auditStatus:Bool
            let content:String
            let createBy:UInt64
            let createTime:UInt64
            let deleted:Int
            let id:UInt64
            let merchantId:UInt64
            let merchantName:String
            let msgType:Int
            let para:String
            let permission:Int
            let status:Int
            let title:String
            let type:Int
            let updateBy:UInt64?
            let updateTime:UInt64?
            let userId:UInt64
        }
        struct Rsp : Decodable{
            let code:Int
            let tip:String
            let info:Info
        }
        
    }

    struct PushList{
        struct Info:Decodable{
            let auditStatus:Bool
            let content:String
            let createBy:UInt64
            let createTime:UInt64
            let deleted:Int
            let deviceId:UInt64
            let id:UInt64
            let img:String
            let merchantId:UInt64
            let merchantName:String
            let msgType:Int
            let para:String
            let permission:Int
            let productName:String
            let pushTime:UInt64
            let shareName:String?
            let status:Int
            let title:String
            let type:Int
            let userId:UInt64
        }
        struct PageTurn:Decodable{
            let currentPage : Int
            let end : Int
            let firstPage : Int
            let nextPage : Int
            let page : Int
            let pageCount : Int
            let pageSize : Int
            let prevPage : Int
            let rowCount : Int
            let start : Int
            let startIndex : Int
        }
        struct Rsp : Decodable{
            let code:Int
            let tip:String
            let list:[Info]?
            let pageTurn:PageTurn?
        }
    }

}
