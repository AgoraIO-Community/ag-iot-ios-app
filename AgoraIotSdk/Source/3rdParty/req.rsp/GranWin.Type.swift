//
//  Granwin.Type.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/4/23.
//

import Foundation
import Alamofire
extension GranWin{
    class api{
        static let EmailVerifyCode="/email/code/get"
        static let Login="/user/login"
        static let CerGet="/device/invent/certificate/get"
        static let Logout="/"
        static let PasswordUpdate = "/user/password/update"
        static let PasswordReset = "/user/password/reset"
        static let Register="/user/register"
        static let GetCode="/email/code/get"
        static let GetSms = "/sms/code/get"
        static let DeviceList="/user/device/list"
        static let ProductList="/app/product/list"
        static let BindDevice="/user/device/bind"
        static let UserCancel = "/user/cancel"
        static let UserInfo = "/user/info/get"
        static let UserInfoUpdate = "/user/info/update"
        static let UnbindDevice="/user/device/unbind"
        static let RenameDevice="/user/device/update"
        static let ShareToUser = "/user/device/share/touser"
        static let ShareAccept = "/user/device/accept"
        static let ShareOwnDevice = "/user/device/own/devices"
        static let ShareWithMe = "/user/device/share/withme"
        static let ShareCancel = "/user/device/share/cancel/list"
        static let ShareRemove = "/user/device/member/remove"
        static let SharePushAdd = "/device/share/push/add"
        static let SharePushDel = "/device/share/push/del"
        static let SharePushDetail = "/device/share/push/details"
        static let SharePushList = "/device/share/push/list"
    }
    
    static let appShadowProductKey = "EJIEEItkledlS46SI"
    static let tokenExpiredCode = 1010 //10006
    //https://confluence.agoralab.co/pages/viewpage.action?pageId=940802349
    struct Rsp: Decodable{
            let code:Int
            let tip:String
        }
    fileprivate struct RspRegister: Decodable{
            let code:Int
            let tip:String
        }
    class CertGet{
        struct Info : Decodable{
            let privateKey:String
            let certificatePem:String
            let certificateArn:String
            let regionId:String
            let domain:String
            let thingName:String
            let region:String
            let deviceId:UInt64
        }
        struct Rsp : Decodable{
            let code:Int
            let info:Info?
            let tip:String
        }
    }
    
    class UserInfoUpdate{
        struct Req : Encodable{
            var name:String?
            var avatar:String?
            var sex:Int?
            var age:Int?
            var birthday:String?
            var height:UInt?
            var weight:UInt?
            var countryId:String?
            var country:String?
            var provinceId:String?
            var province:String?
            var cityId:String?
            var city:String?
            var areaId:String?
            var area:String?
            var address:String?
            var background:String?
            
            public init(_ info:UserInfo){
                self.name = info.name
                self.avatar = info.avatar
                self.sex = info.sex
                self.age = info.age
                self.birthday = info.birthday
                self.height = info.height as? UInt
                self.weight = info.weight as? UInt
                self.country = info.country
                self.countryId = info.countryId
                self.province = info.province
                self.provinceId = info.provinceId
                self.city = info.city
                self.cityId = info.cityId
                self.area = info.area
                self.areaId = info.areaId
                self.address = info.address
                self.background = info.background
            }
        }
    }
    
    class UserInfoGet{
        struct Info : Decodable{
            let account:String
            let address:String?
            let age:Int?
            let area:String?
            let areaId:String?
            let avatar:String?
            let background:String?
            let birthday:String?
            let city:String?
            let cityId:String?
            let country:String?
            let countryId:String?
            let createBy:UInt64
            let createTime:UInt64
            let deleted:UInt?
            let email:String?
            let height:UInt?
            let id:UInt64?
            let identityId:String?
            let merchantId:UInt64?
            let merchantName:String?
            let name:String?
            let param:String?
            let phone:String?
            let province:String?
            let provinceId:String?
            let sex:Int?
            let status:Int
            let updateBy:UInt64?
            let updateTime:UInt64?
            let weight:UInt?
        }
        
        struct Rsp : Decodable{
            let code:Int
            let info:Info?
            let tip:String
        }
    }
    class RenameDevice{
        struct Rsp: Decodable{
                let code:Int
                let tip:String
            }
    }
    class ProductList{
        struct Req : Encodable{
            var pageNo : Int? = 1
            var pageSize : Int? = 10
            var productTypeId : String?
            var connectType : String?
            var blurry : String?
        }
        struct Info : Decodable{
            
        }
        struct PageTurn : Decodable{
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
        public struct PrdItem : Decodable{
            let alias : String
            let bindType:UInt
            let connectType : UInt
            let createTime : UInt64
            let deleted : UInt
            let id : UInt64
            public let imgBig : String
            public let imgSmall : String
            let merchantId : UInt64
            let merchantName : String
            let name : String
            let productKey : String
            let productTypeId : UInt64
            let productTypeName : String
            let status : UInt
            let updateBy : UInt64?
            let updateTime : UInt64?
        }
        struct Rsp : Decodable{
            let code : Int
            let tip : String
            let pageTurn : PageTurn?
            let list : [PrdItem]?
        }
    }
    class DevList{
        struct Rsp: Decodable{
            struct Item : Decodable{
                let appuserId:String
                let productId:String
                let createTime:UInt64
                let sharer:String
                let uType:String
                let updateTime:UInt64
                let productKey:String
                let deviceId:String
                let connect:Bool
                let mac:String
                let deviceNickname:String
                
            }
            let code:Int
            let tip:String
            
            let info:[Item]?
        }
    }
    struct Login{
        struct Rsp: Decodable {
            struct Pool : Decodable{
                let identifier:String
                let identityId:String
                let identityPoolId:String
                let token:String
            }
            struct Proof:Decodable{
                let accessKeyId:String
                let secretKey:String
                let sessionToken:String
                let sessionExpiration:UInt64
            }
            struct Info: Decodable{
                let account:String
                let endpoint:String
                let region:String
                //let refresh:String
                let expiration:Int
                let granwin_token:String
                let pool:Pool
                let proof:Proof
            }
            let code: Int
            let info:Info?
            let tip:String
        }

    }

    class arg{
        static let merchantId = "100000000000000000"
        static let clientId = "100000000000000000"
    }
    func handleRspCert(_ certRsp:CertGet.Rsp,_ rsp:@escaping(Int,String,GranWinSession.Cert?)->Void){
        if(certRsp.code != 0){
            log.e("gw handleRspCert rsp error:\(certRsp.code),tip:\(certRsp.tip)")
            rsp(ErrCode.XERR_ACCOUNT_LOGIN,certRsp.tip,nil)
            return;
        }
        guard let info = certRsp.info else{
            log.e("gw handleRspCert rsp info is null")
            rsp(ErrCode.XERR_ACCOUNT_LOGIN,certRsp.tip,nil)
            return
        }
        var cert = GranWinSession.Cert()
        /*
         let privateKey:String
         let certificatePem:String
         let certificateArn:String
         let regionId:String
         let domain:String
         let thingName:String
         let region:String
         let deviceId:UInt64
         */
        cert.privateKey = info.privateKey
        cert.certificatePem = info.certificatePem
        cert.certificateArn = info.certificateArn
        cert.regionId = info.regionId
        cert.domain = info.domain
        cert.thingName = info.thingName
        cert.region = info.region
        cert.deviceId = info.deviceId
        
        log.i("gw thingName: \(cert.thingName)")
        rsp(ErrCode.XOK,certRsp.tip,cert)
    }
    func handleRspLogin(_ loginRsp:Login.Rsp,_ rsp: @escaping (Int,String,GranWinSession?)->Void){
        if(loginRsp.code != 0){
            log.e("gw handleRspLogin rsp error:\(loginRsp.code),tip:\(loginRsp.tip)")
            var ec = ErrCode.XERR_ACCOUNT_LOGIN
            if(loginRsp.code == 10002){
                ec = ErrCode.XERR_ACCOUNT_NOT_EXIST
            }
            else if(loginRsp.code == 10003){
                ec = ErrCode.XERR_ACCOUNT_PASSWORD_ERR
            }
            rsp(ec,loginRsp.tip,nil)
            return;
        }
        guard let info = loginRsp.info else{
            log.e("gw handleRspLogin rsp info is null")
            rsp(ErrCode.XERR_ACCOUNT_LOGIN,loginRsp.tip,nil)
            return
        }
        let sess = GranWinSession()
        
        sess.account = info.account
        sess.proof_sessionToken = info.proof.sessionToken
        sess.proof_secretKey = info.proof.secretKey
        sess.granwin_token = info.granwin_token
        sess.endPoint = info.endpoint
        sess.pool_token = info.pool.token
        sess.pool_identifier = info.pool.identifier
        sess.pool_identityId = info.pool.identityId
        sess.pool_identityPoolId = info.pool.identityPoolId
        sess.region = info.region
        //sess.granwinToken = info.granwin_token
        
        log.i("gw token: \(sess.granwin_token)")
        log.i("gw poolIdentifier: \(info.pool.identifier)")

        rsp(ErrCode.XOK,loginRsp.tip,sess)
    }
    func handleRspProductList(_ prdListRsp:ProductList.Rsp,_ rsp:@escaping (Int,String,[ProductInfo])->Void){
        var prds:[ProductInfo] = []
        if(prdListRsp.code != 0){
            log.e("gw handleRspProductList rsp error:\(prdListRsp.code),tip:\(prdListRsp.tip)")
            rsp(ErrCode.XERR_DEVMGR_QUEYR,prdListRsp.tip,prds)
            return
        }
        if(prdListRsp.list != nil){
            for item in prdListRsp.list!{
                log.i("gw prod number:\(item.id)")
                log.i("        alias:\(item.alias)");
                log.i("        id:\(item.productKey)")
                log.i("        name:\(item.name)")
                log.i("        typename:\(item.productTypeName)")
                prds.append(ProductInfo(
                    alias:item.alias,
                    bindType: item.bindType,
                    connectType : item.connectType,
                    createTime : item.createTime,
                    deleted : item.deleted,
                    number : String(item.id),
                    imgBig : item.imgBig,
                    imgSmall : item.imgSmall,
                    merchantId : item.merchantId,
                    merchantName : item.merchantName,
                    name : item.name,
                    id : item.productKey,
                    productTypeId : item.productTypeId,
                    productTypeName : item.productTypeName,
                    status : item.status,
                    updateBy : item.updateBy ?? 0,
                    updateTime: item.updateTime ?? 0
                ))
            }
        }
        rsp(ErrCode.XOK,prdListRsp.tip,prds)
    }
    func handleRspDevList(_ devListRsp:DevList.Rsp,_ rsp:@escaping (Int,String,[IotDevice])->Void){
        var devs:[IotDevice] = []
        if(devListRsp.code != 0){
            log.e("gw handleRspDevList rsp error:\(devListRsp.code),tip:\(devListRsp.tip)")
            rsp(ErrCode.XERR_DEVMGR_QUEYR,devListRsp.tip,devs)
            return
        }
        if(devListRsp.info != nil){
            for item in devListRsp.info!{
                let productId = item.productId
                let deviceId = item.mac
                
                if(item.productKey == GranWin.appShadowProductKey){
                    log.i("gw  skip shadow productId:\(productId) deviceId:\(deviceId)")
                    continue
                }
                log.i("gw  productId:\(productId) deviceId:\(deviceId)")
                log.i("    deviceName:'\(item.deviceNickname)'")
                log.i("    deviceMac:\(item.mac)")
                log.i("    productKey:\(item.productKey)")
                log.i("    sharer:\(item.sharer)")
                log.i("    userType:\(item.uType)")
                log.i("    connected:\(item.connect)")
                
                let userType:Int = Int(item.uType) ?? 0
                if(userType <= 0 || userType > 3){
                    log.e("gw device userType Error,default to 0")
                }
                
                devs.append(IotDevice(
                    userId:item.appuserId,
                    userType: userType,
                    deviceId: deviceId,
                    deviceName: item.deviceNickname,
                    deviceNumber: item.deviceId,
                    tenantId: "",
                    
                    productId: item.productKey,
                    productNumber:item.productId,
                    
                    sharer:item.sharer,
                    createTime:item.createTime,
                    updateTime:item.updateTime,

                    connected: item.connect
                ))
            }
        }
        rsp(ErrCode.XOK,devListRsp.tip,devs)
    }
}
