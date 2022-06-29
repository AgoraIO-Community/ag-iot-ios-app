//
//  DeviceResetVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/22.
//

import UIKit

class DeviceResetVC: UIViewController {

    var productKey:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        self.title = "重置设备"
        let cancelBarBtnItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didClickCancelBarBtnItem))
        cancelBarBtnItem.tintColor = UIColor(hexRGB: 0x1DD6D6)
        navigationItem.rightBarButtonItem = cancelBarBtnItem
        
        let resetView = DeviceResetView()
        view.addSubview(resetView)
        resetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        resetView.clickCancelAction = {[weak self] in
            self?.dismiss(animated: true)
        }
        resetView.clickNextButtonAction = {[weak self] in
            let vc = SelectWIFIVC()
            vc.productKey = self?.productKey
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func didClickCancelBarBtnItem(){
        dismiss(animated: true)
    }
                    
}
