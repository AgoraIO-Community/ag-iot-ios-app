//
//  GeneralSettingCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit

class GeneralSettingCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews(){
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(47)
            make.centerY.equalTo(contentView)
        }
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(contentView)
        }
        
    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(hexRGB: 0x333333)
        return label
    }()
    
    lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        return imgView
    }()
    
    func setTitle(_ title:String?) -> Void {
        titleLabel.text = title
    }
}
