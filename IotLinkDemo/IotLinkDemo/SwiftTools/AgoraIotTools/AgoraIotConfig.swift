//
//  AgoraIotConfig.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/21.
//

import Foundation

/*
 //prd env
 public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
 //dev env
 public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
 //aboard
 public static let masterServerUrl:String = "https://app.agoralink-iot-na.sd-rtn.com"
 public static let slaveServerUrl:String = "https://api.agora.io/agoralink/na/api"
 */
class AgoraIotConfig{
//    public static let appId = "d01**********************a586a"  //测试rtm
//    public static let productKey = "EJ******COl5"
//    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
//    public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
//    public static let projectId:String = "s*****P"
//
//    public static let ntfAppKey: String = "5*****12" //离线推送的appkey
//    public static let ntfApnsCertName:String = "i*****od"////离线推送的AnpsCertName
//    ///
#if false //正式环境:gzh03，控制台：https://console.agora.io/project/wpe9W2hZd/extension?id=iot
          //配合callkit.sim/iotlink.huashu/gzh03.sh(account:gzh03)
          //配合callkit.sim/iotlink.huashu/china01.sh(account:gzh03),开通了云存，告警
          //配合callkit.sim/iotlink.xianbin/g711a_prd.sh(account:gzh03),开通了云存，告警
    public static let appId = "5a571630366b473cb5b55c00c99453cf"
    public static let productKey = "EJJImEJ4S4IIK"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "wpe9W2hZd"
    
    public static let ntfAppKey: String = "81286824#1013503" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iotcallkitdemo.prd.p12"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif false //gzh 正式环境，配合callkit.sim/iotlink.alert.test/test_gzh_prd.gzh_console
    public static let appId = "67f4672937984023bf378863a6c1450e"
    public static let productKey = "EJIJ4SS64ImJ5"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "4OJG85tCF"
    
    public static let ntfAppKey: String = "81718082#964971" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iotcallkitdemo.prd.p12"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif false //北美（生产）环境联调参数
    public static let appId = "33d7efec22164719b84693c2641f7cf3"
    public static let productKey = "EJJ5m5ISm464K"
    public static let masterServerUrl:String = "https://app.agoralink-iot-na.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/na/api"
    public static let projectId:String = "Lnv6EmM3_"
    
    public static let ntfAppKey: String = "41315488#529643" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iotcallkitdemo.prd.p12"////离线推送的AnpsCertName（开发环境为：io.agora.iot）

#elseif false //文强测试多呼一账号(testflight 1039)
    public static let appId = "4f9ddb84a67d47b7952c75939e28effc"
    public static let productKey = "EJJIJ55EKSmJm"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "A6xnD0-vq"
    
    public static let ntfAppKey: String = "41315488#529643" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iotcallkitdemo.prd.p12"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#elseif false //文强测试海外(北美)账号(testflight 1037),foreign01.sh
    public static let appId = "a0a50c6b596f4fa5aed574bed6784394"
    public static let productKey = "EJJIm6IJJSJS5"
    public static let masterServerUrl:String = "https://app.agoralink-iot-na.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/na/api"
    public static let projectId:String = "fQCHe6Qmq"
    
    public static let ntfAppKey: String = "41315488#529643" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iotcallkitdemo.prd.p12"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif false //正式环境,纯呼叫测试
    public static let appId = "4b31fcfaca7c472cbb07637260953037"
    public static let productKey = "EJIJEIm68gl5b5lI4" //"EJ5IJK4m7Fl4EJI"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "aWZhPaN_C"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iotlink.prd.012"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#elseif false //给先斌用来测试模拟设备告警的 对应:iotlink.alert.test/test_gzh_g722_url_2,开通了云存
    public static let appId = "75b71ce931804fbbbaa1951aeb6e9d7e"
    public static let productKey = "EJJlElI56EE6vl5COlm"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    //public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
    public static let projectId:String = "Gp-8DXj0H"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#elseif false //
    public static let appId = "75b71ce931804fbbbaa1951aeb6e9d7e"
    public static let productKey = "EJJlElI56EE6vl5COlm"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "Gp-8DXj0H"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）

#elseif false  //文强测试1040 / 1041 版本,海外测试版本
    public static let appId = "a6d6dba434be4b6683fad1aba6a7f75e"  //测试rtm
    public static let productKey = "EJJIm6IK6mE6I"
    public static let masterServerUrl:String = "https://app.agoralink-iot-na.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/na/api"
    public static let projectId:String = "WsXoa7uR2"
    
    public static let ntfAppKey: String = "41717241#975823" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#elseif false //测试环境，方方的test rtm,多呼一配置,multi_call.sh
    public static let appId = "d0177a34373b482a9c4eb4dedcfa586a"  //测试rtm
    public static let productKey = "EJImm64m65ECOl5"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
    public static let projectId:String = "zqch5Wte2"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）

#elseif false //正式环境:华叔的测试告警图片和视频url
    //配合callkit.sim/iotlink.xianbin/g711a_prd.sh(gzh03)   //g711a编码
    public static let appId = "4b31fcfaca7c472cbb07637260953037"  
    public static let productKey = "EJIJEIm68gl5b5lI4"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "aWZhPaN_C"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#elseif false //华叔的测试告警图片和视频url,配合：callkit.sim/iotlink.alert.test/test_gzh_g722_url_2
    public static let appId = "d0177a34373b482a9c4eb4dedcfa586a"  //测试rtm
    public static let productKey = "EJImm64m65ECOl5"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
    public static let projectId:String = "sA1Owwj7P"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    ///
    ///
#elseif false //文强企业微信发过来的测试人员的账号
    public static let appId = "78cf02cdf35443f99d4cb2bf436be098"  //测试rtm
    public static let productKey = "EJJEmm5KISS54"
//    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
//    public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "hye3LEp5E"
    
    public static let ntfAppKey: String = "52315488#392012" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#elseif false //文强申请的账号测试 升级
    public static let appId = "41af1c745b05480fb0767df3ac695e26" //文强测试
    public static let productKey = "EJImm64m65ECOl5"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "A8bqzqT9h"

    public static let ntfAppKey: String = "52115750#399986" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif false //文强申请的账号测试 测试视频加密
    public static let appId = "73268edd5d9f4b518b5ee315bb1fbaf2" //文强测试
    public static let productKey = "EJJJJJKmIKJ5zPl"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "6ROvoEJSn"

    public static let ntfAppKey: String = "81717241#1023627" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif false //正式上架配置，给文强测试也用这个
    public static let appId = "4b31fcfaca7c472cbb07637260953037" //文强测试
    public static let productKey = "EJIJEIm68gl5b5lI4"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.agora.io/agoralink/cn/api"
    public static let projectId:String = "aWZhPaN_C"

    public static let ntfAppKey: String = "52116232#400198" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif false //简化版呼叫 测试环境配置
    public static let appId = "d0177a34373b482a9c4eb4dedcfa586a" //文强测试
    public static let productKey = "EJImm64m65ECOl5"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://iot-api-gateway.sh.agoralab.co/api"
    public static let projectId:String = "fV833nCXq"

    public static let ntfAppKey: String = "52116232#400178" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
#elseif true //简化版呼叫 生产环境配置
    public static let appId = "4b31fcfaca7c472cbb07637260953037" //文强测试
    public static let productKey = "EJIJEIm68gl5b5lI4"
    public static let masterServerUrl:String = "https://app.agoralink-iot-cn.sd-rtn.com"
    public static let slaveServerUrl:String = "https://api.sd-rtn.com/agoralink/cn/api"
    public static let projectId:String = "aWZhPaN_C"

    public static let ntfAppKey: String = "52116232#400198" //离线推送的appkey
    public static let ntfApnsCertName:String = "io.agora.iot.prod"////离线推送的AnpsCertName（开发环境为：io.agora.iot）
    
#endif
}

