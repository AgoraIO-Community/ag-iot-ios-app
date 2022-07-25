//
//  GlobalConstant.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/14.
//

import Foundation

import UIKit
//屏幕宽高比例缩放值
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let ScreenZS = ScreenWidth/375.0
let ScreenHS = ScreenHeight/812.0

let StatusBarHeight = UIApplication.shared.statusBarFrame.height

//判断是否是全面屏(返回true为全面屏)
let isFullScreen = ScreenHeight/ScreenWidth > 1.9


//获取底部安全区域的高度间隙
func safeAreaBottomSpace() -> CGFloat {
  
    var bottomSpace:CGFloat = 0
    
    if #available(iOS 11.0, *) {
       bottomSpace=UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0
    }
    
    return bottomSpace
}

//获取顶部安全区域的高度
func safeAreaTopSpace() -> CGFloat {
    var space:CGFloat = 0
    if #available(iOS 11.0, *) {
        space = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.top ?? 0
    }
    return space
}

//获取全面屏顶部多出的安全区域高度
func moreSafeAreaTopSpace() -> CGFloat {
    var space:CGFloat = 24.0
    if isFullScreen {
        space = 0
    }
    return space
}

//获取全面屏底部多出的安全区域高度
func moreSafeAreaBottomSpace() -> CGFloat {
    var space:CGFloat = 34.0
    if isFullScreen {
        space = 0
    }
    return space
}


func RandomColor() -> UIColor {
    
    return RGBColor(CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)))
}
//颜色
public func RGBColor(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

func rgba(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat, _ a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

//全局主题色
let MainColor = UIColor.white
//全局背景色
let BGColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)

//平方-简-中黑体 和大小
func FontPFMediumSize(_ fontSize:CGFloat) -> UIFont {
    return UIFont.init(name: "PingFangSC-Medium", size: fontSize*ScreenZS)!
}
//平方-简-标准字体 和大小
func FontPFRegularSize(_ fontSize:CGFloat) -> UIFont {
    return UIFont.init(name: "PingFangSC-Regular", size: fontSize*ScreenZS)!
}


func TDLog<T>(_ message : T, file : String = #file, lineNumber : Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):line:\(lineNumber)]- \(message)")
    #endif
}


//各种框框消失时间
let dismissTime=2

//结束编辑
func endEditing(){
 UIApplication.shared.keyWindow?.endEditing(true)
}

func TiensLocalString(_ key:String) -> String {
    //APPLanguageCountryManager.shared()?.getLanguage()
    //let pathStr=Bundle.main.path(forResource: "en", ofType: "lproj")

//    guard let path = pathStr else {
//        return ""
//    }
//
//    return Bundle(path: path)?.localizedString(forKey: key, value: nil, table: nil) ?? ""
    
    return key
}

/// 当前控制器
public func currentViewController() -> UIViewController {
    
    var result: UIViewController?
    var window = UIApplication.shared.keyWindow
    
    if window?.windowLevel != UIWindow.Level.normal  {
        let windows = UIApplication.shared.windows
        for tmpWin in windows {
            if tmpWin.windowLevel == UIWindow.Level.normal {
                window = tmpWin
                break
            }
        }
    }
    
    result = window?.rootViewController
    
    while true {
        if (result?.presentedViewController != nil) {
            result = result?.presentedViewController!
        } else if result!.isKind(of: UITabBarController.classForCoder()) {
            let tabBar: UITabBarController = result as! UITabBarController
            result = tabBar.selectedViewController!
        } else if result!.isKind(of: UINavigationController.classForCoder()) {
            let nav: UINavigationController = result as! UINavigationController
            result = nav.visibleViewController!
        } else {
            break
        }
    }
    return result!
}

#if DEBUG
let wechatKey = ""
#else
let wechatKey = ""
#endif

/// 比如百度地图Key
let BDMapKey = ""


/// 确保主线程
func dispatch_async_main_safe(block :@escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
