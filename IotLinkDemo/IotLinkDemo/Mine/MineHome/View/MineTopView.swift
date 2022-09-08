//
//  MineTopView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit

private let kImageViewHieght: CGFloat = 60

class MineTopView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickArrowButton))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickArrowButtonAction:(()->(Void))?
    
    private lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "userimage")
        imageView.layer.cornerRadius = kImageViewHieght * 0.5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        return label
    }()
    
    private lazy var countLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xF7B500)
        return label
    }()
    
    private lazy var arrowButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "arrow-right"), for: .normal)
        button.addTarget(self, action: #selector(didClickArrowButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private func createSubviews(){
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(countLabel)
        addSubview(arrowButton)
        
        imageView.snp.makeConstraints { make in
            make.left.equalTo(35)
            make.top.equalTo(60)
            make.width.height.equalTo(kImageViewHieght)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(18)
            make.bottom.equalTo(imageView.snp.centerY)
        }
        
        countLabel.snp.makeConstraints{make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(nameLabel.snp.left)
        }
        
        arrowButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.right.equalTo(-30)
            make.width.height.equalTo(40)
        }
    }
    
    @objc private func didClickArrowButton(){
        clickArrowButtonAction?()
    }
    
    func setHeadImg(_ img:String?, name:String?, count:Int = 0) {
        imageView.kf.setImage(with: URL(string: img ?? ""), placeholder: UIImage(named: "userimage"))
        nameLabel.text = name
        countLabel.text = "\(count)台设备"
    }
}
