//
//  ReceiveDeviceShareView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit

private let kBtnHeight: CGFloat = 42

class ReceiveDeviceShareView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickAcceptButtonAction:(()->(Void))?
    
    var clickCancelButtonAction:(()->(Void))?
    
    lazy var accountLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.text = "13849589543"
        return label
    }()
    
    lazy var imageView:UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 8
        imgView.layer.masksToBounds = true
        imgView.image = UIImage(named: "doorbell2")
        return imgView
    }()
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        return label
    }()
    
    private lazy var accecptButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("接受共享", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = kBtnHeight * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickAcceptButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x262626), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
        return button
    }()
    
    private func createSubviews(){
        addSubview(accountLabel)
        accountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(30.S)
        }
        
        let tipsLabel = UILabel()
        tipsLabel.font = UIFont.systemFont(ofSize: 14)
        tipsLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        tipsLabel.text = "向您分享了一个智能设备"
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(67.S)
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(100.S)
            make.width.height.equalTo(254.S)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(10.S)
        }
        
        addSubview(accecptButton)
        accecptButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-74.S)
            make.width.equalTo(254.S)
            make.height.equalTo(kBtnHeight)
        }
        
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-30.S)
            make.width.equalTo(100.S)
            make.height.equalTo(32.S)
        }
    }
    
    @objc private func didClickAcceptButton(){
        clickAcceptButtonAction?()
    }
    
    @objc private func didClickCancelButton(){
        clickCancelButtonAction?()
    }
    
    func setAccount(_ account:String?, deviceName:String?, imageUrl:String? = nil) {
        accountLabel.text = account
        nameLabel.text = deviceName
        imageView.kf.setImage(with: URL(string: deviceName ?? ""), placeholder:  UIImage(named: "doorbell2"))
    }
}
