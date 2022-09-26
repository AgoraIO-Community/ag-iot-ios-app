//
//  DeviceAddSuccessVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit
import AgoraIotLink
import SVProgressHUD

class DeviceAddSuccessVC: UIViewController {
    
    var device:IotDevice?
    
    var deviceId: String?
    
    private lazy var resultView: ConnectResultView = {
        let resultView = ConnectResultView()
        resultView.name = device?.deviceName
        resultView.result = .success
        resultView.clickEditButtonAction = {[weak self] in
            self?.showEditAlertVC()
        }
        return resultView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func setupUI(){
        view.backgroundColor = .white
        
        self.title = "添加成功"
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(didClickCanelBarItem))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "45d2cf")
        
        view.addSubview(resultView)
        resultView.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.top.equalTo(25)
            make.height.equalTo(130)
        }
    }
    
    private func loadData(){
        if deviceId != nil {
            DeviceManager.shared.queryDeviceWithId(deviceId!, forceUpdate: true) { [weak self] _, _, dev in
                guard let device = dev else {
                   return
                }
                self?.resultView.name = device.deviceName
                self?.resultView.imageUrl = device.productInfo?.imgSmall
                self?.device = device
            }
        }
    }

    @objc private func didClickCanelBarItem(){
        guard let rootVC = navigationController?.viewControllers.first else { return }
        if rootVC is DeviceResetVC {
            dismiss(animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }

    private func showEditAlertVC(){
        
        AGEditAlertVC.showTitle("修改设备名称",editText: device?.deviceName ?? "") { [weak self] text in
            print("修改后的名字：----\(text)")
            self?.updateDeviceName(name: text)
        }
    }
    
    private func updateDeviceName(name: String){
        if device == nil {
            return
        }
        AgoraIotManager.shared.sdk?.deviceMgr.renameDevice(deviceId: device!.deviceId, newName: name, result:{[weak self] ec, msg in
            if(ec == ErrCode.XOK){
                self?.resultView.name = name
                self?.device?.deviceName = name
            }else{
                SVProgressHUD.showError(withStatus: "修改失败:\(msg)")
            }
        })
    }
}
