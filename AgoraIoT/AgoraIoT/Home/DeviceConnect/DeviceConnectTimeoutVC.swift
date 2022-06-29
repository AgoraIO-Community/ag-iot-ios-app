//
//  DeviceConnectTimeOutVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

class DeviceConnectTimeoutVC: UIViewController {

    var productKey:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(didClickCanelBarItem))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "45d2cf")
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "设备连接网络超时"
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(50.S)
        }
        
        // 提示
        let tipsLabel = UILabel()
        tipsLabel.text = "请排查以下问题后重试"
        tipsLabel.textColor = UIColor(hexString: "d4d4d4")
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(80.S)
        }
        
        // 步骤
        let stepTextArray = [
            "检查设备是否处于待配网状态",
            "检查WiFi是否为2.4G",
            "核对WiFi密码是否正确",
            "扫描二维码时是否听到提示音",
            "检查设备是否靠近路由器"
        ]
        var i = 0
        for text in stepTextArray {
            let stepLabel = DeviceItemLabel()
            stepLabel.setText(text, index: i + 1)
            view.addSubview(stepLabel)
            stepLabel.snp.makeConstraints { make in
                make.left.equalTo(77.S)
                make.top.equalTo(140.S + (i * 40).S)
            }
            i += 1
        }
        
        // 重试按钮
        let retryButton = UIButton(type: .custom)
        retryButton.setTitle("按步骤重试", for: .normal)
        retryButton.backgroundColor = UIColor(hexString: "1A1A1A")
        retryButton.layer.cornerRadius = 28.S
        retryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        retryButton.setTitleColor(UIColor(hexString: "#25DEDE"), for: .normal)
        retryButton.addTarget(self, action: #selector(didClickRetryButton), for: .touchUpInside)
        view.addSubview(retryButton)
        retryButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-180.S)
            make.width.equalTo(285.S)
            make.height.equalTo(56.S)
        }
    }

    @objc private func didClickCanelBarItem(){
        dismiss(animated: true)
    }
    
    @objc private func didClickRetryButton(){
        dismiss(animated: false) {[weak self] in
            let vc = DeviceResetVC()
            vc.productKey = self?.productKey
            let navc = AGNavigationVC(rootViewController: vc)
            currentViewController().present(navc, animated: false)
        }
    }

}
