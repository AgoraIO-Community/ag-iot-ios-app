//
//  GranWin.Share.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/5/31.
//

import Foundation
import Alamofire

extension GranWin{
    public func shareToUser(token:String,deviceNumber:String,email:String,type:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:Dictionary = ["deviceId":deviceNumber,"email":email,"type":type]
        let url = http + api.ShareToUser
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw shareToUser \(url) fail,\(deviceNumber) for \(email), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareToUser: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
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
                        log.e("gw shareToUser \(url) fail for \(email), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
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
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
    public func shareOwnDevice(token:String,rsp:@escaping(Int,String,[DeviceShare]?)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = [:]
        let url = http + api.ShareOwnDevice
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: OwnDevice.Rsp.self) { (dataRsp : AFDataResponse<OwnDevice.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        var devs:[DeviceShare]? = nil
                        if(value.code != 0 || value.info == nil){
                            log.e("gw shareOwnDevice \(url) fail, detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareOwnDevice: \(value.tip)(\(value.code))")
                            devs = [DeviceShare]()
                            for item in value.info!{
                                
//                                if(item.productKey == GranWin.appShadowProductKey){
//                                    log.i("gw  shareCancelable productId:\(item.productKey) deviceId:\(item.deviceId)")
//                                    continue
//                                }
                                
                                let dev = DeviceShare()
                                dev.nickName = item.nickName
                                dev.deviceNumber = item.deviceId
                                dev.count = item.count
                                dev.time = item.time
                                dev.deviceId = item.mac
                                devs?.append(dev)
                            }
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,nil)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw shareOwnDevice failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            rsp(ec,value.tip,devs)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw shareOwnDevice \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
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
    public func shareWithMe(token:String,rsp:@escaping(Int,String,[DeviceShare]?)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = [:]
        let url = http + api.ShareWithMe
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: ShareWithme.Rsp.self) { (dataRsp : AFDataResponse<ShareWithme.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        var devs:[DeviceShare]? = nil
                        if(value.code != 0 || value.info == nil){
                            log.e("gw shareWithMe \(url) fail, detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareWithMe: \(value.tip)(\(value.code))")
                            devs = [DeviceShare]()
                            for item in value.info!{
                                let dev = DeviceShare()
                                dev.nickName = item.nickName
                                dev.deviceNumber = item.deviceId
                                dev.count = 0
                                dev.time = item.time
                                dev.deviceId = item.mac
                                devs?.append(dev)
                            }
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,nil)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw shareWithMe failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            rsp(ec,value.tip,devs)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw shareWithMe \(url) fail, detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
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
        /*
         {"code":0,"info":[{"appuserId":"686044235892076544","connect":false,"createTime":1654506410562,"deviceId":"689613094541373440","deviceNickname":"Ag给我的","email":"goooon@126.com","mac":"IVFES3LNGY2G2NRVIVBU63BVFU3DQOBYHEYDGMRVHA4DMMRT","nickName":"goon","productId":"684391604434317312","productKey":"EJImm64m65ECOl5","sharer":"686044235892076544","uType":"2","updateTime":0},{"appuserId":"693984974375477248","connect":false,"createTime":1654605588469,"deviceId":"689613094541373440","deviceNickname":"sdasd","mac":"IVFES3LNGY2G2NRVIVBU63BVFU3DQOBYHEYDGMRVHA4DMMRT","nickName":"ddae","productId":"684391604434317312","productKey":"EJImm64m65ECOl5","sharer":"693984974375477248","uType":"3","updateTime":0}],"tip":"响应成功"}
         */
        struct Rsp:Decodable{
            let code:Int
            let tip:String
            let info:[Info]?
        }
    }
    
    public func shareCancelable(token:String,deviceNumber:String,rsp:@escaping(Int,String,[DeviceCancelable]?)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = ["deviceId":deviceNumber]
        let url = http + api.ShareCancel
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: ShareCancel.Rsp.self) { (dataRsp : AFDataResponse<ShareCancel.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        var devsCancel:[DeviceCancelable]? = nil
                        if(value.code != 0 || value.info == nil){
                            log.e("gw shareCancelable \(url) fail for \(deviceNumber) detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareCancelable: \(value.tip)(\(value.code))")
                            devsCancel = [DeviceCancelable]()
                            for item in value.info!{
                                
                                let devs = DeviceCancelable()
                                devs.appuserId = item.appuserId
                                devs.avatar = item.avatar ?? ""
                                devs.connect = item.connect
                                devs.createTime = item.createTime
                                devs.deviceNumber = item.deviceId
                                devs.deviceNickname = item.deviceNickname
                                devs.email = item.email ?? ""
                                devs.deviceId = item.mac
                                devs.nickName = item.nickName ?? ""
                                devs.phone = item.phone ?? ""
                                devs.productId = item.productId
                                devs.productKey = item.productKey
                                devs.sharer = item.sharer
                                devs.uType = item.uType
                                devs.updateTime = item.updateTime
                                devsCancel?.append(devs)
                            }
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,nil)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw shareCancelable failed: for \(deviceNumber) \(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            rsp(ec,value.tip,devsCancel)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw shareCancelable \(url) fail for \(deviceNumber) detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
        }
        
//        .responseString(completionHandler: {(response) in
//        switch response.result{
//        case .success(let value):
//            log.e(value)
//            _ = JSON(value)
//            //cb(ErrCode.XERR_ALARM_NOT_FOUND,value,nil)
//        case .failure(let error):
//            log.e("http request detail: \(error) ")
//            //cb(ErrCode.XERR_ACCOUNT_REGISTER,"")
//        }
//       })
    }
    
    
    public func shareRemove(token:String,deviceNumber:String,userId:String,rsp:@escaping(Int,String)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = ["deviceId":deviceNumber,"userId":userId]
        let url = http + api.ShareRemove
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: Rsp.self) { (dataRsp : AFDataResponse<Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        if(value.code != 0){
                            log.e("gw shareRemove \(url) fail for \(deviceNumber), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw shareRemove: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
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
                        log.e("gw shareRemove \(url) fail for \(deviceNumber), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
                            log.e("gw sharePushAdd \(url) fail for \(deviceNumber), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw sharePushAdd: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
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
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip)
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
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败")
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
    
    public func sharePushDetail(token:String,id:String,rsp:@escaping(Int,String,ShareDetail?)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params:[String:String] = ["id":id]
        let url = http + api.SharePushDetail
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: PushDetail.Rsp.self) { (dataRsp : AFDataResponse<PushDetail.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        var detail:ShareDetail? = nil
                        if(value.code != 0){
                            log.e("gw sharePushDetail \(url) fail for \(id), detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw sharePushDetail: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,nil)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw sharePushDetail failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            else{
                                    let det = ShareDetail()
                                    let item = value.info
                                    det.auditStatus = item.auditStatus
                                    det.content = item.content
                                    det.createBy = item.createBy
                                    det.createTime = item.createTime
                                    det.deleted = item.deleted
                                    det.id = item.id
                                    det.merchantId = item.merchantId
                                    det.merchantName = item.merchantName
                                    det.msgType = item.msgType
                                    det.para = item.para
                                    det.permission = item.permission
                                    det.status = item.status
                                    det.title = item.title
                                    det.type = item.type
                                    det.updateBy = item.updateBy ?? 0
                                    det.updateTime = item.updateTime ?? 0
                                    det.userId = item.userId
                                    detail = det
                            }
                            rsp(ec,value.tip,detail)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw sharePushDetail \(url) fail for \(id), detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil)
                    }
                }
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
    
    public func sharePushList(token:String,pageNo:Int,pageSize:Int,auditStatus:String, rsp:@escaping(Int,String,[ShareItem]?,PageTurn?)->Void){
        let header : HTTPHeaders = ["Content-Type":"text/html; charset=utf-8", "token":token]
        let params = ["pageNo":String(pageNo),"pageSize":String(pageSize),"auditStatus":auditStatus]
        let url = http + api.SharePushList
        log.i("gw sharePushList:\(params)")
        AF.request(url,method: .post,parameters: params,encoder: JSONParameterEncoder.default, headers: header)
            .validate()
            .responseDecodable(of: PushList.Rsp.self) { (dataRsp : AFDataResponse<PushList.Rsp>) in
                switch dataRsp.result{
                case .success(let value):
                    DispatchQueue.main.async {
                        var ec = ErrCode.XOK
                        var items:[ShareItem]? = nil
                        var pageturn : PageTurn? = nil
                        if(value.code != 0){
                            log.e("gw sharePushList \(url) fail, detail: \(value.tip)(\(value.code)) ")
                        }
                        else{
                            log.i("gw sharePushList: \(value.tip)(\(value.code))")
                        }
                        if(value.code == GranWin.tokenExpiredCode){
                            rsp(ErrCode.XERR_TOKEN_EXPIRED,value.tip,nil,nil)
                        }
                        else{
                            if(value.code != 0){
                                log.e("gw sharePushList failed:\(value.tip)(\(value.code))")
                                ec = ErrCode.XERR_UNKNOWN
                            }
                            else{
                                items = [ShareItem]()
                                if(value.list != nil){
                                    for info in value.list!{
                                        let item = ShareItem()
                                        item.auditStatus = info.auditStatus
                                        item.content = info.content
                                        item.createBy = info.createBy
                                        item.createTime = info.createTime
                                        item.deleted = info.deleted
                                        item.deviceNumber = info.deviceId
                                        item.id = info.id
                                        item.img = info.img
                                        item.merchantId = info.merchantId
                                        item.merchantName = info.merchantName
                                        item.msgType = info.msgType
                                        item.para = info.para
                                        item.permission = info.permission
                                        item.productName = info.productName
                                        item.pushTime = info.pushTime
                                        item.shareName = info.shareName ?? ""
                                        item.status = info.status
                                        item.title = info.title
                                        item.type = info.type
                                        item.userId = info.userId
                                        items?.append(item)
                                    }
                                }
                                
                                if let turn = value.pageTurn
                                {
                                    pageturn?.currentPage = turn.currentPage
                                    pageturn?.end = turn.end
                                    pageturn?.firstPage = turn.end
                                    pageturn?.nextPage = turn.nextPage
                                    pageturn?.page = turn.page
                                    pageturn?.pageCount = turn.pageCount
                                    pageturn?.pageSize = turn.pageSize
                                    pageturn?.prevPage = turn.prevPage
                                    pageturn?.rowCount = turn.rowCount
                                    pageturn?.start = turn.start
                                    pageturn?.startIndex = turn.startIndex
                                }
                            }
                            rsp(ec,value.tip,items,pageturn)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log.e("gw sharePushList \(url) fail  detail: \(error) ")
                        rsp(ErrCode.XERR_NETWORK,error.errorDescription ?? "网络请求失败",nil,nil)
                    }
                }
        }
    }
}
