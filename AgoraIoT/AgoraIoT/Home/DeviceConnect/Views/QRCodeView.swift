//
//  QRCodeView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

class QRCodeView: UIView {
    lazy var commitButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("听到提示音", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = UIColor(hexRGB: 0x1A1A1A)
        button.layer.cornerRadius = 28.S
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickCommitButton(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var qrImageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var clickCommitButtonAction:(()->(Void))?
    var clickCancelButtonAction:(()->(Void))?


    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func createSubviews(){
        
        // 提示
        let tipsLabel = UILabel()
        addSubview(tipsLabel)
        tipsLabel.textAlignment = .center
        tipsLabel.font = UIFont.systemFont(ofSize: 15.S ,weight: .medium)
        tipsLabel.text = "将二维码正对摄像头，保持15-20cm距离"
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(35.S)
        }
        
        let tipsLabel2 = UILabel()
        addSubview(tipsLabel2)
        tipsLabel2.textAlignment = .center
        tipsLabel2.font = UIFont.systemFont(ofSize: 15.S ,weight: .medium)
        tipsLabel2.text = "保持静止几秒钟，随后会听到提示音"
        addSubview(tipsLabel)
        tipsLabel2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(62.S)
        }
        
        // 二维码图片
        addSubview(qrImageView)
        qrImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(105.S)
            make.width.equalTo(260.S)
            make.height.equalTo(260.S)
        }
        
        // 示意图
        let imageView = UIImageView()
        addSubview(imageView)
        imageView.image = UIImage(named: "scan")
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(qrImageView.snp.bottom).offset(38.S)
            make.width.equalTo(213.S)
        }
        
        // 确认文字
        let checkLabel = UILabel()
        addSubview(checkLabel)
        checkLabel.numberOfLines = 0
        checkLabel.text = "如没有听到提示音，请检查摄像头 调整距离、角度、多试几次"
        checkLabel.textAlignment = .center
        checkLabel.textColor = UIColor(hexRGB: 0xF7B500)
        checkLabel.font = UIFont.systemFont(ofSize: 13.S)
        addSubview(checkLabel)
        checkLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(203)
            make.top.equalTo(imageView.snp.bottom).offset(5.S)
        }
        
        // 听到提示音
        addSubview(commitButton)
        commitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20.S - safeAreaBottomSpace())
            make.width.equalTo(285.S)
            make.height.equalTo(56.S)
        }
    }
    
    // MARK: - actions
    
    // 点击听到提示音
    @objc private func didClickCommitButton(_ button:UIButton){
        clickCommitButtonAction?()
    }
}
