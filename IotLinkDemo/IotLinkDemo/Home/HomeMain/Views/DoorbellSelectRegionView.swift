//
//  DoorbellSelectRegionView.swift
//  IotLinkDemo
//
//  Created by admin on 2024/7/4.
//

import UIKit

private let kBtnHeight :CGFloat = 36

class DoorbellSelectRegionView: UIView {
    private var buttons: [UIButton] = []
    var selectedButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickSelectedButtonAction:((UIButton)->(Void))?
    var clickDeleteButtonAction:(()->(Void))?
    var clickCancelButtonAction:(()->(Void))?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select a region".L + "："
        return label
    }()
    
    private func createSubviews(){
        backgroundColor = .white
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(180)
        }
        
        setupButtons()
        setupConstraints()
        
        selectedButton = buttons[0]
        selectedButton?.isSelected = true
        selectedButton?.backgroundColor = UIColor.hex(hex: 0x26B5FF)
    }
    
    private func setupButtons() {
        let buttonTitles = ["CN", "NA", "AP", "EU"]
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 5.0
            button.setTitleColor(.white, for: .selected)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = UIColor.white
            button.isSelected = false
            buttons.append(button)
            addSubview(button)
        }
    }
    
    private func setupConstraints() {
        guard buttons.count > 0 else { return }
        
        for (index, button) in buttons.enumerated() {
            button.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.bottom.equalToSuperview()
                
                // 设置第一个按钮的 leading
                if index == 0 {
                    make.leading.equalToSuperview().offset(0)
                } else {
                    // 相邻按钮之间的间距为10
                    make.leading.equalTo(buttons[index - 1].snp.trailing).offset(10)
                }
                
                // 设置最后一个按钮的 trailing
                if index == buttons.count - 1 {
                    make.trailing.equalToSuperview().offset(0)
                }
                
                // 设置每个按钮的宽度相等
                if index < buttons.count - 1 {
                    let nextButton = buttons[index + 1]
                    make.width.equalTo(nextButton)
                }
            }
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        selectedButton?.backgroundColor = .white
        selectedButton?.isSelected = false
        
        sender.backgroundColor = UIColor.hex(hex: 0x26B5FF)
        sender.isSelected = true
        selectedButton = sender
    }
    
}
