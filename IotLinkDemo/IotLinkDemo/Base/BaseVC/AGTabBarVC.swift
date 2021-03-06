//
//  AGTabBarVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/14.
//

import UIKit

class AGTabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setTabBarProperty()
        
        createChildVC()
        
    }
    
    fileprivate func setTabBarProperty() {
        
        tabBar.isTranslucent=false
        
        tabBar.shadowImage=UIImage()
        
        tabBar.backgroundImage=UIImage()
        
//        tabBar.barTintColor=RGBColor(0,33,104)

     }
    
    
    func createChildVC() {
        
        
        let homeVC = HomePageMainVC()
        
        addChildVC(homeVC, TiensLocalString("้ฆ้กต"), "tabbar1")
        
        let myVC = MinePageMainVC()

        addChildVC(myVC, "ๆ็", "tabbar5")
    }
    
    func addChildVC(_ vc:UIViewController,_ title:String,_ imgName:String) {
        
        vc.tabBarItem.title=title
        
        vc.tabBarItem.image=UIImage(named: imgName)
        
        vc.tabBarItem.selectedImage=UIImage(named: imgName+"-selected")
        
//        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:RGBColor(227, 95,78)], for: .selected)
//
//        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:RGBColor(51, 51,51)], for: .normal)
        
        
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.lightGray], for: .normal)

//        vc.tabBarItem.titlePositionAdjustment=UIOffset(horizontal: 0, vertical: -cTitleVertical)
        
        let nav = AGNavigationVC(rootViewController: vc)
        
        addChild(nav)
    }
}
