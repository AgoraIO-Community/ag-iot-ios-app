//
//  DoorBell.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/18.
//

import Foundation

public class DoorBell{
    private var dev:IotDevice
    private let lock: NSLock = NSLock()
    var dict:Dictionary<String,Any> = [:]
    
    public func sync(devMgr:IDeviceMgr,result:@escaping(Int,String)->Void){
//        devMgr.setDeviceProperty(deviceId:dev.deviceId, properties: dict, result: {
//            (ec,msg) in
//            self.dict.removeAll()
//            result(ec,msg)
////            guard let props = props else {
////                result(ErrCode.XERR_DEVMGR_PROPERTY,"查询设备属性失败")
////                return
////            }
////            self.lock.lock()
////            var ep:String = ""
////            log.i("dict used \(self) \(self.dict)")
////            for e in self.dict{
////                switch e.key{
////                case "100":
////                    if(e.value as? Bool != props[e.key] as? Bool){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("osdSWitch")
////                        log.w("osdSwitch 100:\(e.value)")
////                    }
////                case "101":
////                    if(e.value as? Int != props[e.key] as? Int){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("nightView")
////                        log.w("nightView 101:\(e.value)")
////                    }
////                case "102":
////                    if(e.value as? Bool != props[e.key] as? Bool){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("motionAlarm")
////                        log.w("motionAlarm 102:\(e.value)")
////                    }
////                case "103":
////                    if(e.value as? Int != props[e.key] as? Int){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("priSwitch")
////                        log.w("priSwitch 103:\(e.value)")
////                    }
////                case "104":
////                    if(e.value as? Int != props[e.key] as? Int){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("volume")
////                        log.w("volume 104:\(e.value)")
////                    }
////                case "105":
////                    if(e.value as? Bool != props[e.key] as? Bool){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("forceAlarm")
////                        log.w("forceAlarm 105:\(e.value)")
////                    }
////                case "106":
////                    if(e.value as? Int != props[e.key] as? Int){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("quantity")
////                        log.w("quantity 106:\(e.value)")
////                    }
////                case "1000":
////                    if(e.value as? Int != props[e.key] as? Int){
////                        if(ep != ""){ep.append(",")}
////                        ep.append("powerState")
////                        log.w("powerState 1000:\(e.value)")
////                    }
////                default:
////                    log.e("unknonw prop \(e.key)")
////                }
////            }
////            self.dict.removeAll()
////            self.lock.unlock()
////            if(ep != ""){
////                result(ErrCode.XERR_DEVMGR_PROPERTY,"获取设备状态'\(ep)'与设置不一致")
////            }
////            else{
////                result(ErrCode.XOK,"获取设备状态")
////            }
//        })
    }
    
    public var osdSWitch:Bool?        //100
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["100"] as? Bool
        }
        set{
            dev.props?["100"] = newValue
            dict["100"] = newValue
        }
    }
    public var nightView:Int?           //101
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["101"] as? Int
        }
        set{
            dev.props?["101"] = newValue
            lock.lock()
            dict["101"] = newValue
            lock.unlock()
        }
    }
    public var motionAlarm:Bool?        //102
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["102"] as? Bool
        }
        set{
            dev.props?["102"] = newValue
            lock.lock()
            dict["102"] = newValue
            lock.unlock()
        }
    }
    public var pirSwitch:Int?           //103
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["103"] as? Int
        }
        set{
            dev.props?["103"] = newValue
            lock.lock()
            dict["103"] = newValue
            lock.unlock()
        }
    }
    public var volume:Int?              //104
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["104"] as? Int
        }
        set{
            dev.props?["104"] = newValue
            lock.lock()
            dict["104"] = newValue
            lock.unlock()
        }
    }
    public var forceAlarm:Bool?         //105
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["105"] as? Bool
            
        }
        set{
            dev.props?["105"] = newValue
            lock.lock()
            dict["105"] = newValue
            lock.unlock()
        }
    }
//    public var quantity:Int?            //106
//    {
//        get{
//            guard let prop = dev.props else{return nil}
//            return prop["106"] as? Int
//        }
//        set{
//            dev.props?["106"] = newValue
//            lock.lock()
//            dict["106"] = newValue
//            lock.unlock()
//        }
//    }
    public var powerState:Int?          //1000
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["1000"] as? Int
        }
        set{
            dev.props?["1000"] = newValue
            lock.lock()
            dict["1000"] = newValue
            lock.unlock()
            //log.i("dict before \(dict)")
        }
    }
    
    public var videoQuality:Int? //107
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["107"] as? Int
        }
        set{
            dev.props?["107"] = newValue
            lock.lock()
            dict["107"] = newValue
            lock.unlock()
        }
    }
    
    public var indcatorLed:Int? //108
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["108"] as? Int
        }
        set{
            dev.props?["108"] = newValue
            lock.lock()
            dict["108"] = newValue
            lock.unlock()
        }
    }
    
    public var tfCardFormat:Int? //112
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["112"] as? Int
        }
        set{
            dev.props?["112"] = newValue
            lock.lock()
            dict["112"] = newValue
            lock.unlock()
        }
    }
    
    public var previewDuration:Int? //113
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["113"] as? Int
        }
        set{
            dev.props?["113"] = newValue
            lock.lock()
            dict["113"] = newValue
            lock.unlock()
        }
    }
    
    public var vocieDectect:Int? //115
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["115"] as? Int
        }
        set{
            dev.props?["115"] = newValue
            lock.lock()
            dict["115"] = newValue
            lock.unlock()
        }
    }
    
    public var quality:Int? //106
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["106"] as? Int
        }
        set{
            dev.props?["106"] = newValue
            lock.lock()
            dict["106"] = newValue
            lock.unlock()
        }
    }
    
    public var wifiSsid:String? //501
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["501"] as? String
        }
        set{
            dev.props?["501"] = newValue
            lock.lock()
            dict["501"] = newValue
            lock.unlock()
        }
    }
    
    public var ipAddress:String? //502
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["502"] as? String
        }
        set{
            dev.props?["502"] = newValue
            lock.lock()
            dict["502"] = newValue
            lock.unlock()
        }
    }
    
    public var devMac:String? //503
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["503"] as? String
        }
        set{
            dev.props?["503"] = newValue
            lock.lock()
            dict["503"] = newValue
            lock.unlock()
        }
    }
    
    public var timeZone:Int? //504
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["504"] as? Int
        }
        set{
            dev.props?["504"] = newValue
            lock.lock()
            dict["504"] = newValue
            lock.unlock()
        }
    }
    
    public var version:String? //109
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["109"] as? String
        }
        set{
            dev.props?["109"] = newValue
            lock.lock()
            dict["109"] = newValue
            lock.unlock()
        }
    }
    
    public var cardState:Int? //110
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["110"] as? Int
        }
        set{
            dev.props?["110"] = newValue
            lock.lock()
            dict["110"] = newValue
            lock.unlock()
        }
    }
    
    public var cardSpace:Int? //111
    {
        get{
            guard let prop = dev.props else{return nil}
            return prop["111"] as? Int
        }
        set{
            dev.props?["111"] = newValue
            lock.lock()
            dict["111"] = newValue
            lock.unlock()
        }
    }
    
    init(dev:IotDevice){
        self.dev = dev
    }
}

extension IotDevice{
    public func toDoorBell()->DoorBell{
        return DoorBell(dev:self)
    }
}
