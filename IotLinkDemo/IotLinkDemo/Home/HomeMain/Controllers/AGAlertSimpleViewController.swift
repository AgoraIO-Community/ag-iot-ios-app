//
//  AGAlertSimpleViewController.swift
//  IotLinkDemo
//
//  Created by admin on 2023/6/9.
//

import UIKit

//隐藏弹框
let AGAlertSimpleViewHiddenNotify = "cAddDeviceSuccessNotify"

class AGAlertSimpleViewController: UIViewController {
    
    
    var alertView:AGAlertBaseView = {
        let alertView = AGAlertBaseView()
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        return alertView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenAlert), name: Notification.Name(AGAlertSimpleViewHiddenNotify), object: nil)
    }
    
    @objc private func hiddenAlert(){//移除自己
        self.dismiss(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    private func setupUI(){
        view.addSubview(alertView)
        alertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
        }
    }
    
    func setTitle(_ title:String?, message:String?,cancelTitle:String,commitTitle:String ,commitAction: (()->(Void))?, cancelAction:(()->(Void))? = nil) {
        alertView.titleLabel.text = title
        alertView.messageLabel.text = message
        alertView.cancelButton.setTitle(cancelTitle, for: .normal)
        alertView.commitButton.setTitle(commitTitle, for: .normal)
        alertView.clickCancelButtonAction = {[weak self] in
            self?.dismiss(animated: false)
            cancelAction?()
        }
        alertView.clickCommitButtonAction  = {[weak self] in
            self?.dismiss(animated: false)
            commitAction?()
        }
    }
    
    static func showTitle(_ title:String?, message:String?,cancelTitle:String = "取消",commitTitle:String = "确定",commitAction: (()->(Void))?,cancelAction:(()->(Void))? = nil)  {
        let vc = AGAlertSimpleViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.setTitle(title, message: message, cancelTitle: cancelTitle, commitTitle: commitTitle, commitAction: commitAction, cancelAction: cancelAction)
//        currentViewController().present(vc, animated: false)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: false)
//        UIApplication.shared.keyWindow?.addSubview(vc.view)
    }
    

}
