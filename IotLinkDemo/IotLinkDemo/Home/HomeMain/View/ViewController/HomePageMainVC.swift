//
//  HomePageMainVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit

class HomePageMainVC: AGBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.cyan
        
        checkLoginState()
    }
    
    //检查用户登录状态
    func checkLoginState(){
        
        TDUserInforManager.shared.checkLoginState()
        
    }
 
}
