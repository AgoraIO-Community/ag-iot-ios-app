//
//  DoorbellSelectAllView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/11.
//

import UIKit

private let kBtnHeight :CGFloat = 36

class DoorbellSelectAllView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var disabled = false {
        didSet{
            self.selectedbutton.isEnabled = !disabled
            self.deletebutton.isEnabled = !disabled
        }
    }
    
    var clickSelectedButtonAction:((UIButton)->(Void))?
    var clickDeleteButtonAction:(()->(Void))?
    
    lazy var selectedbutton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_unselect"), for: .normal)
        button.setImage(UIImage(named: "country_selected"), for: .selected)
        button.setTitle("全选", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(UIColor(hexRGB: 0x000000, alpha:0.85), for: .normal)
        button.addTarget(self, action: #selector(didClickSelectedButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var deletebutton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("删除", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        button.layer.cornerRadius = kBtnHeight * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickDeleteButton), for: .touchUpInside)
        return button
    }()
    
    private func createSubviews(){
        backgroundColor = .white
        
        addSubview(selectedbutton)
        selectedbutton.snp.makeConstraints { make in
            make.left.equalTo(36)
            make.top.equalTo(33)
            make.width.equalTo(80)
            make.height.equalTo(kBtnHeight)
        }
        
        addSubview(deletebutton)
        deletebutton.snp.makeConstraints { make in
            make.centerY.equalTo(selectedbutton)
            make.right.equalTo(-53)
            make.width.equalTo(81)
            make.height.equalTo(kBtnHeight)
        }
    }
    
    // 点击全选
    @objc private func didClickSelectedButton(_ button:UIButton){
        clickSelectedButtonAction?(button)
    }
    
    // 点击删除
    @objc private func didClickDeleteButton(){
        clickDeleteButtonAction?()
    }

}
