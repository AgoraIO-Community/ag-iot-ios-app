//
//  AGConfirmBaseView.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/5.
//

import Foundation

import UIKit

private let buttonHeight:CGFloat = 40

class AGConfirmView: UIView {
    let showButton:Bool
    let title:String
    let message:String
    init(title:String,message:String, showButton:Bool){
        self.title = title
        self.message = message
        self.showButton = showButton
        
        let defaultFrame = CGRect(x:0, y:0, width:300, height:600)
        super.init(frame:defaultFrame)
        createSubviews()
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.text = title
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var messageLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = message
        
        label.lineBreakMode = .byWordWrapping
        label.preferredMaxLayoutWidth = 400
        //label.sizeToFit()
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

    private func createSubviews(){
        // 标题
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-200)
        }
        
        // 消息
        customView = messageLabel
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.equalTo(30)
            make.right.equalTo(-30)
            //make.bottom.equalTo(-109)
        }
        
        // 取消
        if(showButton){
            addSubview(cancelButton)
            cancelButton.snp.makeConstraints { make in
                make.right.equalTo(self.snp.centerX).offset(-10)
                make.top.equalTo(messageLabel.snp.bottom).offset(80)
                make.width.greaterThanOrEqualTo(90)
                make.height.equalTo(buttonHeight)
            }
        
            // 确定
            addSubview(commitButton)
            commitButton.snp.makeConstraints { make in
                make.left.equalTo(self.snp.centerX).offset(10)
                make.top.equalTo(messageLabel.snp.bottom).offset(80)
                make.width.greaterThanOrEqualTo(90)
                make.height.equalTo(buttonHeight)
            }
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
