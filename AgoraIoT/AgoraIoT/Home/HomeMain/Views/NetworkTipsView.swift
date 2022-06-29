//
//  NetworkTipsView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/22.
//

import UIKit

class NetworkTipsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xFDAB2C)
        label.text = "当前网络不可用，请检查手机网络"
        return label
    }()
    
    private lazy var imgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "add_fail")
        return imgView
    }()
    
    private func createSubviews(){
        backgroundColor = UIColor(hexRGB: 0xFEFDDD)
        addSubview(imgView)
        addSubview(titleLabel)
        imgView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.centerY.equalToSuperview()
        }
    }

}
