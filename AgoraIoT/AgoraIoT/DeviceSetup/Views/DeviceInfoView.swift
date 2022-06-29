//
//  DeviceInfoView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit

class DeviceInfoView: UIView {
    
    private lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "doorbell2")
        imageView.layer.cornerRadius = 10.S
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameLabel:UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "可视门铃(Wi-Fi)"
        nameLabel.textColor = .black
        nameLabel.font = UIFont.systemFont(ofSize: 16.S)
        return nameLabel
    }()
    
    private lazy var editButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "add_edit"), for: .normal)
        button.addTarget(self, action: #selector(didClickEditButton(_:)), for: .touchUpInside)
        return button
    }()
    
    
    var name:String?{
        didSet{
            self.nameLabel.text = name
        }
    }
    
    
    var clickEditButtonAction:(()->(Void))?

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func createSubviews(){
        
        self.layer.cornerRadius = 10.S
        self.layer.masksToBounds = true
        backgroundColor = .white
        
        // 图片
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(25.S)
            make.width.height.equalTo(90.S)
        }
        
        // 名称
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(30.S)
            make.centerY.equalTo(imageView)
        }
    
        // 编辑
        addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(nameLabel)
        }
        
        // 横线
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexRGB: 0xEFEFEF)
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(1)
            make.top.equalTo(imageView.snp.bottom).offset(15)
        }
    }
    
    // MARK: - actions
    // 点击下一步
    @objc private func didClickEditButton(_ button:UIButton){
        clickEditButtonAction?()
    }

    func setHeadImg(_ img:String?, name:String?) {
        imageView.kf.setImage(with: URL(string: img ?? ""), placeholder: UIImage(named: "doorbell2"))
        nameLabel.text = name
    }

}
