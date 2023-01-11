//
//  AGNavigationVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/14.
//

import UIKit

class AGNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor=MainColor
        
        navigationBar.isTranslucent=false
    navigationBar.titleTextAttributes=[NSAttributedString.Key.font:FontPFMediumSize(18),NSAttributedString.Key.foregroundColor:RGBColor(51,51,51)]
        
        navigationBar.barTintColor=UIColor.white
    //仅用这句话去掉导航栏下面的线,在10系统以上管用,10线依然存在,解决办法找UI要图,再设个背景图就好了
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = MainColor
        
        interactivePopGestureRecognizer?.delegate=self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if children.count > 0{
            
            viewController.hidesBottomBarWhenPushed=true
            viewController.navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "navBack_new")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
            
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    
    @objc func leftBtnDidClick(){
        popViewController(animated: true)
    }
    
    override var childForStatusBarStyle: UIViewController?{
        
        return visibleViewController
    }
}

extension AGNavigationVC:UIGestureRecognizerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return children.count != 1
    }
    
}
