//
//  AlertBaseView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

private let buttonHeight:CGFloat = 40

class AGAlertBaseView: UIView {
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var messageLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = buttonHeight * 0.5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexRGB: 0x000000, alpha: 0.85).cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
        return button
    }()
    
    lazy var commitButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = buttonHeight * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickCommitButton(_:)), for: .touchUpInside)
        return button
    }()
    
    var customView:UIView!{
        didSet{
            addSubview(customView)
        }
    }

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
        // 标题
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(24)
        }
        
        // 消息
        customView = messageLabel
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(98)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.equalTo(-109)
        }
        
        // 取消
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(-10)
            make.bottom.equalTo(-25)
            make.width.greaterThanOrEqualTo(90)
            make.height.equalTo(buttonHeight)
        }
        
        // 确定
        addSubview(commitButton)
        commitButton.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(10)
            make.bottom.equalTo(-25)
            make.width.greaterThanOrEqualTo(90)
            make.height.equalTo(buttonHeight)
        }
    }
    
    // MARK: - actions
    
    // 点击取消
    @objc private func didClickCancelButton(){
        clickCancelButtonAction?()
    }

    // 点击听到提示音
    @objc private func didClickCommitButton(_ button:UIButton){
        clickCommitButtonAction?()
    }
}
