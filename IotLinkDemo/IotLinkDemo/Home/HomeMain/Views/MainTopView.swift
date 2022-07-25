//
//  MainTopView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/21.
//

import UIKit

class MainTopView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickAddButtonAction:(()->(Void))?
    
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        label.text = "我的设备"
        return label
    }()
    
    private lazy var addButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: ""), for: .normal)
        button.setImage(UIImage(named: "device_add"), for: .normal)
        button.addTarget(self, action: #selector(didClickAddButton), for: .touchUpInside)
        return button
    }()
    
    private func createSubviews(){
        addSubview(titleLabel)
        addSubview(addButton)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(-10)
        }
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-20)
            make.width.height.equalTo(40)
        }
    }
    
    @objc private func didClickAddButton(){
        clickAddButtonAction?()
    }
}
