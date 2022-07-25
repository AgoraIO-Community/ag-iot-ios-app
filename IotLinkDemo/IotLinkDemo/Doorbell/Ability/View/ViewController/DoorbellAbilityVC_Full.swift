//
//  DoorbellAbilityVC_Full.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/25.
// 门铃控制横屏全屏

import UIKit

extension DoorbellAbilityVC {
    
    //------横屏回调------
    func fullHBtnClick() {
        
        debugPrint("转为横屏")
        isHorizonFull = true
        
        //容器类横屏操作
        doorVCFullHBlock?()
        //设备转为横屏
        changeToHorizon()
        topAbilityV.snp.updateConstraints { (make) in
            make.height.equalTo(ScreenWidth)
            make.top.left.right.equalToSuperview()
        }
        
        //视频视图等横屏适应
        topAbilityV.handelHFullScreen(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    //------竖屏回调------
    func backVBtnClick(){
        
        debugPrint("返回竖屏")
        isHorizonFull = false
        
        //容器类竖屏屏操作
        doorVCBackVBlock?()
        //设备转为竖屏
        changeToVertical()
        topAbilityV.snp.updateConstraints { (make) in
            make.height.equalTo(338.VS)
            make.top.left.right.equalToSuperview()
        }

        //视频视图等竖屏适应
        topAbilityV.handelHFullScreen(false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    //------屏幕转屏------
    func changeToUnkonw(){
        
        let value = UIInterfaceOrientation.unknown.rawValue
        if UIDevice.current.responds(to: #selector(setValue(_:forKey:))) {
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        
    }
    
    func changeToVertical(){
        
        changeToUnkonw()
        let value = UIInterfaceOrientation.portrait.rawValue
        if UIDevice.current.responds(to: #selector(setValue(_:forKey:))) {
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    func changeToHorizon(){
        
        changeToUnkonw()
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        if UIDevice.current.responds(to: #selector(setValue(_:forKey:))) {
            UIDevice.current.setValue(value, forKey: "orientation")
//            UINavigationController.attemptRotationToDeviceOrientation()
         }
        
    }
    
}
