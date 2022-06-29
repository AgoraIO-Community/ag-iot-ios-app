//
//  DeviceResetView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

class DeviceResetView: UIView {
    
    lazy var nextButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = .gray
        button.isEnabled = false
        button.layer.cornerRadius = 28.S
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickNextButton(_:)), for: .touchUpInside)
        return button
    }()
    
    var clickCancelAction:(()->(Void))?
    var clickNextButtonAction:(()->(Void))?

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func createSubviews(){
        
        // 提示
        let tipsArray = [
            "请先安装电池或连接电源",
            "再按住电池仓内的SET按钮5秒",
            "随后听到提示音并确认指示灯闪烁"
        ]
        
        var i = 0
        for text in tipsArray {
            let stepLabel = DeviceItemLabel()
            stepLabel.setText(text, index: i + 1)
            addSubview(stepLabel)
            stepLabel.snp.makeConstraints { make in
                make.left.equalTo(70.S)
                make.top.equalTo(30.S + (i * 28).S)
            }
            i += 1
        }
        
        // 图片
        let imageView = UIImageView()
        addSubview(imageView)
        imageView.image = UIImage(named: "doorbell2")
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(137.S)
            make.width.equalTo(322.S)
            make.height.equalTo(322.S)
        }
        
        // 确认按钮
        let checkButton = UIButton(type: .custom)
        checkButton.setImage(UIImage(named: "ic_unchecked"), for: .normal)
        checkButton.setImage(UIImage(named: "ic_checked"), for: .selected)
        checkButton.addTarget(self, action: #selector(didClickCheckButton(_:)), for: .touchUpInside)
        addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.left.equalTo(40.S)
            make.top.equalTo(imageView.snp.bottom).offset(26.S)
            make.width.height.equalTo(20.S)
        }
        
        // 确认文字
        let checkLabel = UILabel()
        checkLabel.font = UIFont.systemFont(ofSize: 17.S)
        checkLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        addSubview(checkLabel)
        checkLabel.text = "请确认指示灯在闪烁或者听到提示音"
        addSubview(checkLabel)
        checkLabel.snp.makeConstraints { make in
            make.left.equalTo(70.S)
            make.centerY.equalTo(checkButton)
        }
        
        // 下一步
        addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(70.S)
            make.width.equalTo(285.S)
            make.height.equalTo(56.S)
        }
    }
    
    // MARK: - actions
    
    // 点击取消
    @objc private func didClickCancelButton(){
        clickCancelAction?()
    }
    
    // 点击选中
    @objc private func didClickCheckButton(_ button:UIButton){
        button.isSelected = !button.isSelected
        nextButton.isEnabled = button.isSelected
        nextButton.backgroundColor = button.isSelected ? UIColor(hexRGB: 0x1A1A1A) : .gray
    }

    // 点击下一步
    @objc private func didClickNextButton(_ button:UIButton){
        clickNextButtonAction?()
    }
}
