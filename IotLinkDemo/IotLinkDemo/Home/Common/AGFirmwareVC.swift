//
//  AGFirmwareVC.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/4.
//

import Foundation

import UIKit
import AgoraIotLink

class AGFirmwareVC: UIViewController {
    var info:FirmwareInfo
    init(info:FirmwareInfo){
        self.info = info
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textVersion:UILabel = {
        let ver = UILabel()
        ver.font = UIFont.systemFont(ofSize: 16)
        //textField.clearButtonMode = .always
        //textField.placeholder = "请输入分享账号"
        ver.textColor = UIColor.black//修改颜色
        let verNum = (info.isUpgrade) ? "最新版本号:" + (info.upgradeVersion) :  "当前版本号:" + (info.currentVersion)
        ver.text = verNum
        return ver
    }()
    
    lazy var textHint:UILabel = {
        let hint = UILabel()
        hint.font = UIFont.systemFont(ofSize: 16)
        //textField.clearButtonMode = .always
        //textField.placeholder = "请输入分享账号"
        hint.textColor = UIColor.black//修改颜色
        hint.text = info.remark
        return hint
    }()
    
    lazy var alertView:AGAlertBaseView = {
        let alertView = AGAlertBaseView()
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        return alertView
    }()
    
    lazy var confirmView:AGConfirmView = {
        let confirm = AGConfirmView(title:"已经是最新版本",message:"当前版本:" + info.currentVersion,showButton: false)
        return confirm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        setupUI()
        
        if(info.isUpgrade){
            alertView.clickCancelButtonAction = {[weak self] in
                self?.dismiss(animated: false)
            }
            alertView.clickCommitButtonAction = {[weak self] in
                AgoraIotLink.iotsdk.deviceMgr.otaUpgrade(upgradeId: String(self?.info.upgradeId ?? "")) { ec, msg in
                    if(ec != ErrCode.XOK){
                        log.e("otaUpgrade failed:" + msg)
                    }
                }
                self?.dismiss(animated: true)
            }
        }
        else{
            confirmView.clickCommitButtonAction = {[weak self] in
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func setupUI(){
        let customView = UIView()
        
        if(info.isUpgrade){
            view.addSubview(alertView)
            alertView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(300)
            }
            alertView.titleLabel.text = "发现新版本"
            alertView.customView = customView
        }
        else{
            view.addSubview(confirmView)
            
            confirmView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(300)
            }
            //confirmView.customView = customView
        }

//        customView.snp.makeConstraints { make in
//            make.left.equalTo(23)
//            make.right.equalTo(-23)
//            make.top.equalTo(24)
//            make.bottom.equalTo(-65)
//            make.height.equalTo(80)
//        }
//        customView.addSubview(textVersion)
//
//        textVersion.snp.makeConstraints { make in
//            make.edges.equalTo(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
//        }
//
//        customView.addSubview(textHint)
//        textHint.snp.makeConstraints { make in
//            make.edges.equalTo(UIEdgeInsets(top: 50, left: 20, bottom: 0, right: 0))
//        }
    }
    
    static func showInfo(_ info:FirmwareInfo){
        currentViewController().present(AGFirmwareVC(info:info), animated: false)
    }
}
