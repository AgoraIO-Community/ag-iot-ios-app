//
//  ReceiveDeviceShareVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import AgoraIotSdk
import SVProgressHUD

class ReceiveDeviceShareVC: UIViewController {
    
    var shareInfo: ShareItem?

    private lazy var shareView:ReceiveDeviceShareView = {
        let shareView = ReceiveDeviceShareView()
        shareView.backgroundColor = .white
        shareView.layer.cornerRadius = 10
        shareView.layer.masksToBounds = true
        shareView.clickAcceptButtonAction = { [weak self] in
            DeviceManager.shared.acceptDevice("", order: self?.shareInfo?.para ?? "") { ec, msg in
                if ec != ErrCode.XOK {
                    SVProgressHUD.showError(withStatus: msg)
                }
            }
            self?.dismiss(animated: true)
        }
        shareView.clickCancelButtonAction = { [weak self] in
            DeviceManager.shared.refuseDevice(id: "\(self?.shareInfo?.id ?? 0)") { ec, msg in
                if ec != ErrCode.XOK {
                    SVProgressHUD.showError(withStatus: msg)
                }
            }
            self?.dismiss(animated: true)
        }
        return shareView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    private func setupUI(){
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)

        view.addSubview(shareView)
        shareView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300.S)
            make.height.equalTo(530.S)
        }
    }
    
    private func setupData(){
        shareView.setAccount(shareInfo?.shareName ?? "", deviceName: shareInfo?.productName ?? "", imageUrl: nil)
    }

}
