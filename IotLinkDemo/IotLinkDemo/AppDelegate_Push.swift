//
//  AppDelegate_Push.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/6/7.
//

import UIKit
import Foundation
import UserNotifications

//MARK: - 推送配置
extension AppDelegate{
    
    //MARK: - 注册推送(暂时未使用)
    func registerPush(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
}

//MARK: - 推送代理
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 苹果推送注册成功回调，将苹果返回的deviceToken上传到环信/友盟/智齿云服务器
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       
        //获取推送token,传给环信后台
        let sdk = AgoraIotManager.shared.sdk
//        sdk?.notificationMgr.updateToken(deviceToken)
        
        var deviceId = String()
        if #available(iOS 13.0, *) {
            let bytes = [UInt8](deviceToken)
            for item in bytes {
                deviceId += String(format:"%02x", item&0x000000FF)
            }
            TDLog("推送👌deviceToken：\(deviceId)")
        } else {
            let device = NSData(data: deviceToken)
            deviceId = device.description.replacingOccurrences(of:"<", with:"").replacingOccurrences(of:">", with:"").replacingOccurrences(of:" ", with:"")
            TDLog("推送👌deviceToken：\(deviceId)")
        }
    
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        TDLog("苹果推送注册失败原因：\(error)")
    }
    
    // 收到推送(iOS 10+)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        TDLog("收到的推送消息：\(userInfo) 自定义的code:\(userInfo["page_code"] ?? "未知")")
        AGToolHUD.showInfo(info: "收到推送消息：\(userInfo)")

        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            // IOS 10+ 收到远程推送

            completionHandler([.alert,.sound,.badge])

        } else {
            // IOS 10+ 收到本地推送
        }
        
        
    }
    
    // 触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        print("点击的通知消息：\(userInfo) 自定义的code:\(userInfo["page_code"] ?? "未知")")
        AGToolHUD.showInfo(info: "点击的通知消息：\(userInfo)")

        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            // IOS 10+ 收到远程推送

            //消息中心推送 跳转
            if let jumpType = userInfo["jumpType"] as? String {
                jumpPageCode(jumpType,dic: userInfo)
            }

        }
        completionHandler()
        //glacier 添加聊天推送的相关判断
        if userInfo.keys.contains("nim") {
            if ((userInfo["nim"] != nil) == true){
                NotificationCenter.default.post(name: Notification.Name("JumpChat"), object: nil)
            }
        }
    }
    
    // IOS 10以下
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(#function)
        
        AGToolHUD.showInfo(info: "10以下收到推送消息：\(userInfo)")
        
        //消息中心推送 跳转
        if let jumpType = userInfo["jumpType"] as? String {
            jumpPageCode(jumpType,dic: userInfo)
        }
        
    }

//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        print("用户没点击按钮直接点的推送消息进来的/或者该app在前台状态时收到推送消息\n\(notification.userInfo!)")
//    }
    
}

extension AppDelegate {
    
    //推送跳转
    func jumpPageCode(_ type: String,dic:[AnyHashable : Any]? = nil) {
        
    }
    
}
