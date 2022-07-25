//
//  DispatchCenter.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/22.
// 跳转中心

import Foundation
import UIKit

public enum JumpType {
    ///登录
    case login
    ///注册
    case register
    ///选择国家
    case selectCountry
    ///设置密码
    case setPassword(account:String, captchaCode:String, type:SetPasswordType)
    ///重置密码
    case resetPassword
    //验证码
    case verifyCode(account:String, type:VerifyInputType)
    
}
public enum JumpStyle {
    case push
    case present
}

public class DispatchCenter {
    
    /// 调度中心无参无返回值调取
    ///
    /// - Parameters:
    ///   - type: 模块类型
    ///   - vc: 当前控制器：self
    ///   - style: push 或者present
    public class func DispatchType(type:JumpType, vc:UIViewController?, style:JumpStyle = .present) {
        
        var currentNav:UINavigationController? = nil
        if vc == nil || vc?.navigationController == nil {
            currentNav = getCurrentNavVC()
        }else {
            currentNav = vc?.navigationController
        }
        
        var controller:UIViewController? = nil
        
        
        switch type {
        //登录
        case .login:
            controller =  LoginMainVC()
            break
        //注册
        case .register:
            controller = RegisterMainVC()
            break
        //选择国家
        case .selectCountry:
            let  tempVC = CountrySelectVC()
            tempVC.countryArray = [CountryModel]()
            controller = tempVC
            break
        //设置密码
        case .setPassword(let account, let code, let type):
            let tempVC = SetPasswordVC()
            tempVC.accountText = account
            tempVC.captchaText = code
            tempVC.style = type
            controller = tempVC
            break
        //重置密码
        case .resetPassword:
            controller = ResetPasswordVC()
            break
        //验证码
        case .verifyCode(let account, let type):
            let  tempVC = VerifyInputCodeVC()
            tempVC.accountText = account
            tempVC.style = type
            controller = tempVC
        }
        
        
        guard let newVC = controller else {
            print("初始化失败")
            return
        }
        
        
        if style == .present {
                    
            let nav = AGNavigationVC(rootViewController: newVC)
            nav.modalPresentationStyle = .fullScreen
            currentNav?.present(nav, animated: true, completion: nil)
        }else {
            currentNav?.pushViewController(newVC, animated: true)
        }
        
    }
    
    
    public  class func getCurrentNavVC() -> UINavigationController?{
                
        var window:UIWindow? = UIApplication.shared.keyWindow
        if window != nil && window?.windowLevel != UIWindow.Level.normal {
            let windows:[UIWindow] = UIApplication.shared.windows
            for tmpWin in windows{
                if tmpWin.windowLevel == UIWindow.Level.normal{
                    window = tmpWin
                    break
                }
            }
        }
        
        let frontView:UIView? =  window?.subviews.last
        let next = frontView?.next
        var rootVC:UIViewController? = nil
        
        if next is UIViewController{
            rootVC = next as? UIViewController
        }else{
            rootVC = window?.rootViewController;
        }
                
        if let tabVC = rootVC as? UITabBarController,let navVC = tabVC.children[tabVC.selectedIndex] as? UINavigationController {
            
            if let presentedVC = rootVC?.presentedViewController,presentedVC.isKind(of: UINavigationController.classForCoder())   {
                //return
                return presentedVC as? UINavigationController
            }
            
            //return
            return navVC
        }
        if let navVC = rootVC as? UINavigationController{
            if let presentedVC = rootVC?.presentedViewController,presentedVC.isKind(of: UINavigationController.classForCoder())   {
                //return
                return presentedVC as? UINavigationController
            }
            //return
            return navVC
        }
        
        return nil
    }
    
    
}

fileprivate func DeBugLog<T>(_ message : T, file : String = #file, lineNumber : Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):line:\(lineNumber)]- \(message)")
    #endif
}
