//
//  ConnectResultView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

enum ConnectResult {
    case success
    case fail
}

class ConnectResultView: UIView {
    
    private lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "doorbell2")
        imageView.layer.cornerRadius = 10.S
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private lazy var iconImageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var nameLabel:UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "可视门铃(Wi-Fi)"
        nameLabel.textColor = .black
        nameLabel.font = UIFont.systemFont(ofSize: 16.S)
        return nameLabel
    }()
    
    private lazy var resultLabel:UILabel = {
        let resultLabel = UILabel()
        resultLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        resultLabel.textColor = UIColor(hexString: "#6DD400")
        resultLabel.text = "添加成功"
        return resultLabel
    }()

    private lazy var editButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "add_edit"), for: .normal)
        button.addTarget(self, action: #selector(didClickEditButton(_:)), for: .touchUpInside)
        return button
    }()
    
    var result:ConnectResult?{
        didSet{
            if result == .success {
                iconImageView.image = UIImage(named: "add_success")
                resultLabel.text = "添加成功"
                resultLabel.textColor = UIColor(hexString: "#6DD400")
                editButton.isHidden = false
            }else{
                iconImageView.image = UIImage(named: "add_fail")
                resultLabel.text = "添加失败"
                resultLabel.textColor = UIColor(hexString: "#E02020")
                editButton.isHidden = true
            }
        }
    }
    
    var name:String?{
        didSet{
            self.nameLabel.text = name
        }
    }
    
    var imageUrl:String? {
        didSet{
            self.imageView.kf.setImage(with: URL(string: imageUrl ?? ""), placeholder: UIImage(named: "doorbell2"))
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
        
        // 图标
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalTo(imageView.snp.right)
            make.centerY.equalTo(imageView.snp.top)
            make.width.height.equalTo(22.S)
        }
        
        // 标题
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(30.S)
            make.top.equalTo(20.S)
        }
        
        // 提示
        addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(57)
        }
    
        // 编辑
        addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(nameLabel)
        }
    }
    
    // MARK: - actions
    // 点击下一步
    @objc private func didClickEditButton(_ button:UIButton){
        clickEditButtonAction?()
    }


}
