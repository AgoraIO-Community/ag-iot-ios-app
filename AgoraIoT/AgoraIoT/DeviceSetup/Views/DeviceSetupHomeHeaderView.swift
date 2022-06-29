//
//  DeviceSetupHomeHeaderView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/17.
//

import UIKit

private let kImageViewHieght: CGFloat = 90

class DeviceSetupHomeHeaderView: UIView {
    
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
    
    var showTitle = true {
        didSet{
            self.titleLabel.isHidden = !showTitle
            imageView.snp.updateConstraints { make in
                make.top.equalTo(showTitle ? 70 : 40)
            }
        }
    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.text = "设备信息"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        return label
    }()
    
    private lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10.S
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "doorbell2")
        return imageView
    }()
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        return label
    }()
    
    private lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        return imgView
    }()
    
    private func createSubviews(){
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(arrowImgView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(35)
            make.top.equalTo(37)
        }
        
        imageView.snp.makeConstraints { make in
            make.left.equalTo(35)
            make.top.equalTo(70)
            make.width.height.equalTo(kImageViewHieght)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(18)
            make.centerY.equalTo(imageView)
        }
        
        arrowImgView.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.right.equalTo(-40)
        }
        
        // 横线
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexRGB: 0xEFEFEF)
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalTo(16).priority(.low)
            make.right.equalTo(-16).priority(.low)
            make.height.equalTo(1)
            make.top.equalTo(imageView.snp.bottom).offset(15)
        }
    }
    
    @objc private func didClickArrowButton(){
        clickArrowButtonAction?()
    }
    
    func setHeadImg(_ img:String?, name:String?) {
        imageView.kf.setImage(with: URL(string: img ?? ""), placeholder: UIImage(named: "doorbell2"))
        nameLabel.text = name ?? "<未命名>"
    }

}
