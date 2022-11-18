//
//  AppDelegate.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/14.
//

import UIKit
import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let tabVC=AGTabBarVC()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window=UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController=tabVC
        window?.makeKeyAndVisible()
        
        initializeUI()
        
        //初始化AgoraIotsdk
        initAgoraIot()
        
        configOther()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return .landscapeRight
         return .all
    }

    func initializeUI() {
        //初始化遮罩
        AGToolHUD.initializeHUD()
        
    }
    
    func configOther(){
        
        AF.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let state = UIApplication.shared.applicationState
        if state == .background{//锁屏和按home进入后台都会走
            debugPrint("进入后台111")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        let screenBrightness = UIScreen.main.brightness
        if screenBrightness > 0 {//home键
            debugPrint("home键")
            //被动呼叫按下电源键挂断发通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteSysHangupNotify), object: nil)
        }else{//锁屏
            debugPrint("锁屏")
            //被动呼叫按下电源键挂断发通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cRemoteSysHangupNotify), object: nil)
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        debugPrint("回到前台111")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cApplicationWillEnterForegroundNotify), object: nil)
        
    }
}

