//
//  NotifyMsgSectionHeaderView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/13.
//

import UIKit

private let kbuttonHeight:CGFloat = 28

class NotifyMsgSectionHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickEditButtonAction:((UIButton)->(Void))?
    
    // 日期
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "请查收通知消息"
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    // 编辑
    lazy var editButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("编辑", for: .normal)
        button.setTitle("完成", for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor(hexRGB: 0x1DD6D6), for: .normal)
        button.addTarget(self, action: #selector(didClickEditButton), for: .touchUpInside)
        return button
    }()
    
    private func createSubviews(){
        backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(22)
            make.width.equalTo(107)
            make.height.equalTo(kbuttonHeight)
        }
    
        addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.width.equalTo(50)
            make.height.equalTo(40)
            make.centerY.equalTo(tipsLabel)
        }
    }
    
    // 点击编辑
    @objc private func didClickEditButton(_ button:UIButton){
        clickEditButtonAction?(button)
    }
}
