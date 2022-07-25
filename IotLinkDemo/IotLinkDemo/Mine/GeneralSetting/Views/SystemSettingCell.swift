//
//  SystemSettingCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/13.
//

import UIKit

class SystemSettingCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews(){
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(47)
            make.top.equalTo(16)
        }
        
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(-14)
        }
        
        contentView.addSubview(stateLabel)
        stateLabel.snp.makeConstraints { make in
            make.right.equalTo(-56)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(contentView)
        }
    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hexRGB: 0x333333)
        return label
    }()
    
    private lazy var infoLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.3)
        return label
    }()
    
    private lazy var stateLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        return label
    }()
    
    lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        return imgView
    }()
    
    func setTitle(_ title:String?, info:String, state:Bool) -> Void {
        titleLabel.text = title
        infoLabel.text = info
        stateLabel.text = state ? "已授权" : "未授权"
        stateLabel.textColor = state ? UIColor(hexRGB: 0x000000, alpha: 0.5) : .red
    }

}
