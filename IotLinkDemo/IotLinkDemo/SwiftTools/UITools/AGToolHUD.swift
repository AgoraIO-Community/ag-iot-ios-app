//
//  AGToolHUD.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/12.
//

import UIKit
import SVProgressHUD

class AGToolHUD: NSObject {
    
    class func initializeHUD(){
        
        //背部设置一个透明蒙版,防止正在提示的时候用户点击
        SVProgressHUD.setDefaultMaskType(.clear)
        //文字背景颜色
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.3, alpha: 0.8))
        //文字颜色
        SVProgressHUD.setForegroundColor(UIColor.white)
        //info等的自动取消时间
        SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(dismissTime))
        
    }
    
    class func showHint(hint:String){
        disMiss()
        self.configDefaultParam()
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showInfo(withStatus: hint)
    }
    
    //显示文字和小叹号
    class func showInfo(info: String){
        disMiss()
        self.configDefaultParam()
        SVProgressHUD.showInfo(withStatus: info)
    }
    
    //显示文字和成功对号
    class func showSuccess(info: String){
        disMiss()
        self.configDefaultParam()
        SVProgressHUD.showSuccess(withStatus: info)
    }
    
    //显示文字和成功对号
    class func showFaild(info: String){
        disMiss()
        self.configDefaultParam()
        SVProgressHUD.showError(withStatus: info)
    }
    
    //显示文字和加载中的转圈动画
    class func show(info: String){
        self.configDefaultParam()
        SVProgressHUD.show(withStatus: info)
    }
    
    //给显示文字和小叹号添加消失回调
    class func showText(info:String, dismissBlock:@escaping ()->()) {
        showInfo(info: info)
        SVProgressHUD.dismiss(withDelay: TimeInterval(dismissTime)) {
            dismissBlock()
        }
    }
    
    /// 失败消失回调
    class func showfaild(info:String, dismissBlock:@escaping ()->()) {
        showFaild(info: info)
        SVProgressHUD.dismiss(withDelay: TimeInterval(dismissTime)) {
            dismissBlock()
        }
    }
    
    /// 成功消失回调
    class func showSuccess(info:String, dismissBlock:@escaping ()->()) {
        showSuccess(info: info)
        SVProgressHUD.dismiss(withDelay: TimeInterval(dismissTime)) {
            dismissBlock()
        }
    }
    
    //显示Gif格式的网络加载的等待指示
    class func showGifNetWorkWait(){
        
        SVProgressHUD.dismiss()
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setImageViewSize(CGSize(width: 50.S, height: 50.S))

        let parResult = UIImage.parseGIFDataToImageArray(gifName:"loading.gif")
        let img = UIImage.animatedImage(with: parResult.imageArr, duration: parResult.totalDuration)
        
        SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(60))
        SVProgressHUD.show(img!, status: "")
//        SVProgressHUD.show(withStatus: TiensLocalString("处理中,请稍候..."))
        
    }
    
    //显示网络加载的等待指示
    class func showNetWorkWait(_ interval:Double = 15){
        
        //SVProgressHUD.dismiss()
        SVProgressHUD.setBackgroundColor(UIColor.gray)
        SVProgressHUD.setImageViewSize(CGSize(width: 50.S, height: 50.S))
        
        var arr = [UIImage]()
        for i in 1..<12{
            
            let imgStr = "loading\(i)"
            let tempImg = UIImage(named: imgStr)
            if  tempImg != nil {
                arr.append(tempImg!)
            }
        }
        
        let img = UIImage.animatedImage(with: arr, duration: 1.2)
        
        SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(interval))
        SVProgressHUD.show(img!, status: "")
        //        SVProgressHUD.show(withStatus: TiensLocalString("处理中,请稍候..."))
        
    }
    
    class func showUpgrading(){
        
        //SVProgressHUD.dismiss()
        SVProgressHUD.setBackgroundColor(UIColor.gray)
        SVProgressHUD.setImageViewSize(CGSize(width: 50.S, height: 50.S))
        
        var arr = [UIImage]()
        for i in 1..<12{
            
            let imgStr = "loading\(i)"
            let tempImg = UIImage(named: imgStr)
            if  tempImg != nil {
                arr.append(tempImg!)
            }
        }
        
        let img = UIImage.animatedImage(with: arr, duration: 1.2)
        
        SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(Double.infinity))
        SVProgressHUD.show(img!, status: "升级版本中...")
    }
    
    //显示网络加载错误的指示
    class func showNetWorkError(){
        
        showInfo(info: TiensLocalString("网络连接失败,请检查你的网络设置"))
    }
    
    //显示文字和等待指示
    class func showWaitWithInfo(info: String){
        
        self.configDefaultParam()
        SVProgressHUD.show(withStatus: info)
        
    }
    
    class func configDefaultParam(){
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(TimeInterval(dismissTime))
        SVProgressHUD.setBackgroundColor(UIColor.black.withAlphaComponent(0.6))
        SVProgressHUD.setImageViewSize(CGSize(width: 28, height: 28))
        
        if let successImage: UIImage = UIImage(named: "toastSuccess") {
            SVProgressHUD.setSuccessImage(successImage)
        }
        
        if let faildImage: UIImage = UIImage(named: "toastfaild") {
            SVProgressHUD.setErrorImage(faildImage)
        }
    }
    
    //消失
    class func disMiss() {
        
        SVProgressHUD.dismiss()
        
    }
    
}
