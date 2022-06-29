//
//  AwsClient.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/14.
//

//import Foundation
//class AWSListener{
//    typealias CB = (GWIotMessageType,String, Dictionary<String, Any>?)->Void
//    var cb:CB?
//    var timer:Timer?
//    init(_ cb:@escaping CB){
//        self.cb = cb
//    }
//    func setTimer(timer:Timer){
//        self.timer = timer
//    }
//    func invoke(type:GWIotMessageType, status:String, dict:Dictionary<String, Any>?){
//        if(cb != nil){
//            cb!(type,status,dict)
//        }
//        timer?.invalidate()
//        //cb = nil
//        timer = nil
//    }
//    func invalidate(){
//        timer!.invalidate()
//        timer = nil
//    }
//}
//class AWSClient : NSObject{
//    var listeners:[AWSListener] = []
//    func toolsChangeToJson(info: Any) -> Dictionary<String, Any>?{
//        //
//        guard let data = try? JSONSerialization.data(withJSONObject: info, options: []) else { return nil }
//        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//        let dict = json as? Dictionary<String, Any>
//        //log.i("diction \(dic)")
//        return dict
//    }
//
//    func connect(clientId:String,endPoint:String,token:String,identityId:String,identityPoolId:String,region:String, result:@escaping(Int,String)->Void){
//        //note
//        //1、需要开启定位权限
//        //2、需要开启获取路由器ssid的权限
//        log.i("GrawinAPKit creating ...")
//        
//        
//        let cb = {
//            (type:GWIotMessageType, status:String, any:Any?) in
//            let dict = any == nil ? nil : self.toolsChangeToJson(info: any!)
//            log.i("aws recv status type:\(type.rawValue) status:\(status) data:\(String(describing: dict))")
//            DispatchQueue.main.async {
//                for l in self.listeners{
//                    l.invoke(type: type, status: status, dict: dict)
//                }
//                self.listeners.removeAll()
//                
//                switch type {
//                case .connectState:
//                    _ = 1
//                case .receiveData:
//                    _ = 2
//                @unknown default:
//                    log.e("client recived unknown type : \(type.rawValue)")
//                }
//            }
//        }
//        
//        GranwinAPKit.shared().setAWSListener(cb)
//        GranwinAPKit.shared().delegate = self
//        //log.i("setupAwsIotClient:\nclientId:\(clientID),\nendPoint:\(endPoint),\ntoken:\(token),\nid:\(id),\npoolId:\(poolId),\nregion:\(region)")
//        GranwinAPKit.shared().setupAwsIotClient(clientId, mCustomerSpecificEndpoint: endPoint, token: token, identityId: identityId, identityPoolId: identityPoolId, mRegion: region) { (status:GWIoTMQTTStatus) in
//            switch status {
//            case .unknown:
//                log.i("Aws iot is :.unknown")
//            case .connecting:
//                log.i("Aws iot is :.connecting")
//            case .connected:
//                log.i("Aws iot is :.connected")
//            case .disconnected:
//                log.i("Aws iot is :.disconnected")
//            case .connectionRefused:
//                log.i("Aws iot is :.connectionRefused")
//            case .connectionError:
//                log.i("Aws iot is :.connectionError")
//            case .protocolError:
//                log.i("Aws iot is :.protocolError")
//            @unknown default:
//                log.e("Aws iot status error")
//            }
//        }
//        GranwinAPKit.shared().start()
//        result(ErrCode.XOK,"")
//    }
//    func disconnect(){
//        
//    }
//    func setDeviceProperty(account:String, device: IotDevice, properties: Dictionary<String, Any>, result: @escaping (Int, String,Dictionary<String, Any>?) -> Void) {
//        //log.i("aws setDeviceProperty \t\naccount:\(account) , \t\nproductKey:\(device.productKey), \t\nproperties: \(properties)")
//        if(properties.count != 0){
//            GranwinAPKit.shared().setAWSDeviceStatus(account, productKey: device.productKey, mac: device.deviceMac, params: properties)
//        }
//        
//        self.getDeviceProperty(device:device,result:result)
//    }
//    
//    func getDeviceProperty(device: IotDevice, result: @escaping (Int, String, Dictionary<String, Any>?) -> Void) {
//        DispatchQueue.main.async {
//            let listener = AWSListener({
//                (type,status,data) in
//                switch type {
//                case .connectState:
//                    result(ErrCode.XERR_BAD_STATE,status,nil)
//                case .receiveData:
//                    result(ErrCode.XOK,status,data)
//                @unknown default:
//                    result(ErrCode.XERR_UNKNOWN,"服务器返回参数异常",nil)
//                }
//            })
//            
//            
//            self.listeners.append(listener)
//            let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){tm in
//                //listener.invalidate()
//                result(ErrCode.XERR_TIMEOUT,"等待处理超时",nil)
//            }
//            listener.setTimer(timer: timer)
//            GranwinAPKit.shared().getAWSDeviceStatus(device.deviceMac)
//        }
//    }
//}
//
//extension AWSClient : GranwinAPKitDelegate{
//    func onNotify(_ connectId: String, topic: String, data: Any?) {
//        log.e("unhandled aws notify \(connectId) topic:\(topic)")
//    }
//}
