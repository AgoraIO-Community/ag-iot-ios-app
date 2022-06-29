//
//  DoorbellSectionView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/9.
//

import UIKit

private let kbuttonHeight:CGFloat = 28

class DoorbellSectionView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bgStyle: AlamMsgVCBgStyle = .black {
        didSet {
            if bgStyle == .black {
                backgroundColor = .black
                let titleColor = UIColor(hexRGB: 0xD3D3D3)
                let borderColpr = UIColor(hexRGB: 0x7E7E7E).cgColor
                dateButton.setTitleColor(titleColor, for: .normal)
                dateButton.layer.borderColor = borderColpr
                typeButton.setTitleColor(titleColor, for: .normal)
                typeButton.layer.borderColor = borderColpr
                deviceButton.setTitleColor(titleColor, for: .normal)
                deviceButton.layer.borderColor = borderColpr
                deviceButton.isHidden = true
            }else{
                backgroundColor = UIColor(hexRGB: 0xF8F8F8)
                let titleColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
                let borderColpr = UIColor(hexRGB: 0x000000, alpha:0.25).cgColor
                dateButton.setTitleColor(titleColor, for: .normal)
                dateButton.layer.borderColor = borderColpr
                typeButton.setTitleColor(titleColor, for: .normal)
                typeButton.layer.borderColor = borderColpr
                deviceButton.setTitleColor(titleColor, for: .normal)
                deviceButton.layer.borderColor = borderColpr
                deviceButton.isHidden = true
            }
        }
    }
    
    var clickDateButtonAction:(()->(Void))?
    
    var clickTypeButtonAction:(()->(Void))?
    
    var clickDeviceButtonAction:(()->(Void))?
    
    var clickEditButtonAction:((UIButton)->(Void))?

    private lazy var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 日期
    private lazy var dateButton:UIButton = {
        let button = createButton(title: "日期")
        button.addTarget(self, action: #selector(didClickDateButton), for: .touchUpInside)
        return button
    }()
    
    // 全部类型
    private lazy var typeButton:UIButton = {
        let button = createButton(title: "全部类型")
        button.addTarget(self, action: #selector(didClickTypeButton), for: .touchUpInside)
        return button
    }()
    
    // 全部类型
    private lazy var deviceButton:UIButton = {
        let button = createButton(title: "设备")
        button.addTarget(self, action: #selector(didClickTypeButton), for: .touchUpInside)
        return button
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
    
    private func createButton(title:String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(named: "msg_downarrow"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.setTitleColor(UIColor(hexRGB: 0xD3D3D3), for: .normal)
        button.layer.cornerRadius = kbuttonHeight * 0.5
        button.layer.borderColor = UIColor(hexRGB: 0x7E7E7E).cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.transform = CGAffineTransform(rotationAngle: Double.pi)
        button.titleLabel?.transform = CGAffineTransform(rotationAngle: Double.pi)
        button.imageView?.transform = CGAffineTransform(rotationAngle: Double.pi)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        return button
    }
    
    
    private func createSubviews(){
        addSubview(dateButton)
        dateButton.snp.makeConstraints { make in
            make.left.equalTo(26)
            make.top.equalTo(28)
            make.width.equalTo(107)
            make.height.equalTo(kbuttonHeight)
        }
        
        addSubview(typeButton)
        typeButton.snp.makeConstraints { make in
            make.left.equalTo(dateButton.snp.right).offset(12)
            make.centerY.equalTo(dateButton)
            make.width.equalTo(80)
            make.height.equalTo(kbuttonHeight)
        }
        
        addSubview(deviceButton)
        deviceButton.snp.makeConstraints { make in
            make.left.equalTo(typeButton.snp.right).offset(12)
            make.centerY.equalTo(dateButton)
            make.width.equalTo(80)
            make.height.equalTo(kbuttonHeight)
        }
        
        addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.width.equalTo(50)
            make.height.equalTo(40)
            make.centerY.equalTo(dateButton)
        }
    }
    
    // 点击日期
    @objc private func didClickDateButton(){
        clickDateButtonAction?()
    }
    
    // 点击类型
    @objc private func didClickTypeButton(){
        clickTypeButtonAction?()
    }
    
    // 点击类型
    @objc private func didClickDeivceButton(){
        clickDeviceButtonAction?()
    }
    
    
    // 点击编辑
    @objc private func didClickEditButton(_ button:UIButton){
        clickEditButtonAction?(button)
    }
    
    func setDate(_ date:Date) {
        var dateText = "今天"
        if !date.isToday {
            dateText = formatter.string(from: date)
        }
        self.dateButton.setTitle(dateText, for: .normal)
    }
    
    func setType(_ type:String) {
        self.typeButton.setTitle(type, for: .normal)
    }
}
