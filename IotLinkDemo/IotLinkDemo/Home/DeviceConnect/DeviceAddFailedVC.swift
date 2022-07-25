//
//  DeviceAddFailedVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit
import YYKit
import AgoraIotLink

class DeviceAddFailedVC: UIViewController {

    var device:IotDevice?

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
        
        self.title = "添加失败"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(didClickCanelBarItem))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "45d2cf")
        
        let resultView = ConnectResultView()
        resultView.name = device?.deviceName
        resultView.result = .fail
        view.addSubview(resultView)
        resultView.snp.makeConstraints { make in
            make.left.equalTo(25.S)
            make.right.equalTo(-25.S)
            make.top.equalTo(25.S)
            make.height.equalTo(130.S)
        }
        
        let tipsLabel = YYLabel()
        tipsLabel.numberOfLines = 0
        let clickableTips = "联系客服提交解绑申请"
        let tips = "设备已被其他用户绑定，不能重复绑定\n请到原账号进行移除，或\(clickableTips)"
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10.S
        style.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.S),
        ]
        let attributedTips = NSMutableAttributedString.init(string: tips, attributes:attributes)
        let clickRange =  NSRange(location: tips.count - clickableTips.count , length: clickableTips.count)
        attributedTips.setTextHighlight(clickRange, color: UIColor(hexRGB: 0x49A0FF), backgroundColor: nil) { _, _, _, _ in
            print("点击了字符串-------")
            //TODO: 跳转到解绑申请页面
        }
        tipsLabel.attributedText = attributedTips
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(resultView.snp.bottom).offset(18.S)
            make.width.equalTo(270.S)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func didClickCanelBarItem(){
        dismiss(animated: true)
    }

}
