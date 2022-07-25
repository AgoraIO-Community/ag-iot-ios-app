//
//  NetWorkTool.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit
import Alamofire

typealias NWFinishedBlock = (_ response:Any?,_ isSuccess:Bool)->()

fileprivate let mobile_login_token = "mobile_login_token"
/*
class NetWorkTool: NSObject {
  
    static let defManager:SessionManager = {
        
        var defHeaders=Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        
        let defConf = URLSessionConfiguration.default
        
        //网络请求超时时长
        defConf.timeoutIntervalForRequest = 30
        
        defConf.httpAdditionalHeaders = defHeaders
        
        return Alamofire.SessionManager(configuration: defConf)
        
    }()
    
    fileprivate override init() {
        super.init()
    }
}

extension NetWorkTool{
    
    class func request(url:String , meth:HTTPMethod = .get , parameter:Parameters? = nil , header:HTTPHeaders? = nil ,paraEncoding:ParameterEncoding? = nil,isShowHUD:Bool = true,isPostJSONEncoding:Bool = true ,result:@escaping NWFinishedBlock) {
        
        var urlStr = ""
        
        if url.hasPrefix("http://itunes.apple.com") {
            
            urlStr =  url
        
        }else {
           
            urlStr = cBaseURL + url
            
        }
        
        var headerDict = header
        
        let uToken = ""
        
//        let uToken = TDDataBaseManager.shared.getUserAccountModel().model?.token ?? "-"
        
            print(uToken)
        
            if headerDict != nil {
                headerDict![mobile_login_token]=uToken
            }else{
                headerDict = [mobile_login_token:uToken]
            }
        
    
        var paEncode:ParameterEncoding! = paraEncoding
        
        if paEncode == nil {
            
            if meth == .post && isPostJSONEncoding {
                
               paEncode = JSONEncoding.default
                
            }else{
                
               paEncode = URLEncoding.default
            }
        }
        
        
        if  isShowHUD {
            
//            TDTiensHUD.showNetWorkWait()
        }

        NetWorkTool.defManager.request(urlStr, method: meth, parameters: parameter, encoding: paEncode , headers: headerDict).responseJSON { (response) in
            
            if  isShowHUD {
                
//                TDTiensHUD.disMiss()
            }
            
            if (response.error != nil) || (response.response?.statusCode != 200) {
                TDLog(response)
                    
//                TDTiensHUD.showNetWorkError()
                
                
                result(nil,false)
                
                return
            }
            
            if let response = response.value as? [String:Any], let code = response["code"] as? NSNumber, code == 900 {
                
//                TDTiensHUD.showInfo(info: "登录失效,请重新登录")
            
//                TDDataBaseManager.shared.userSignOut()
                
                result(nil,false)
                
                return
            }
            
            
            result(response.value,true);
        }
    }
}

*/
