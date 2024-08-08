//
//  AGConfirmAlertBaseView.swift
//  IotLinkDemo
//
//  Created by admin on 2023/7/27.
//

import UIKit

private let buttonHeight:CGFloat = 40

class AGConfirmAlertBaseView: UIView {
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
        
        // 确定
        addSubview(commitButton)
        commitButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(-25)
            make.width.greaterThanOrEqualTo(120)
            make.height.equalTo(buttonHeight)
        }
    }
    
    // MARK: - actions
    @objc private func didClickCommitButton(_ button:UIButton){
        clickCommitButtonAction?()
    }
}
