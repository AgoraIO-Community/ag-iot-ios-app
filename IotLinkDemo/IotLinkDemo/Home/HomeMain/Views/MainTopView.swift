//
//  MainTopView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/21.
//

import UIKit

class MainTopView: UIView {
    var clickAddButtonAction:(()->(Void))?
    var clickDeleteButtonAction:(()->(Void))?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        label.text = "myDevices".L
        return label
    }()
    
    private lazy var addButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("addDevices".L, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.addTarget(self, action: #selector(didClickAddButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("delete".L, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.addTarget(self, action: #selector(didClickDeleteButton), for: .touchUpInside)
        return button
    }()
    
    private func createSubviews(){
        addSubview(titleLabel)
        addSubview(addButton)
        addSubview(deleteButton)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(-10)
        }
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-20)
            make.width.height.equalTo(70)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(addButton.snp.left).offset(-20)
            make.width.height.equalTo(40)
        }
    }
    
    @objc private func didClickAddButton(){
        clickAddButtonAction?()
    }
    
    @objc private func didClickDeleteButton(){
        clickDeleteButtonAction?()
    }
}
