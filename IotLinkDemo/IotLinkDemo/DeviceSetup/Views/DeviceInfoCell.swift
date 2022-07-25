//
//  DeviceInfoCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit

class DeviceInfoCell: UITableViewCell {
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        return label
    }()
    
    private lazy var subTitleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        return label
    }()

    private lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        imgView.isHidden = true
        return imgView
    }()
    
    var showArrow = false {
        didSet {
            arrowImgView.isHidden = !showArrow
            subTitleLabel.snp.updateConstraints { make in
                make.right.equalTo(showArrow ? -63 : -35)
            }
        }
    }
    

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
            make.left.equalTo(35)
            make.centerY.equalToSuperview()
        }
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.right.equalTo(-35)
            make.width.equalTo(200)
            make.centerY.equalToSuperview()
        }
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(-40)
            make.centerY.equalTo(contentView)
        }
    }
    
    func set(title:String, subTitle:String?, isPlaceholder: Bool = false) -> Void {
        titleLabel.text = title
        subTitleLabel.text = subTitle
        subTitleLabel.textColor = isPlaceholder ? UIColor(hexRGB: 0x000000, alpha: 0.3) : UIColor(hexRGB: 0x000000, alpha: 0.5)
        subTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: isPlaceholder ? .regular : .medium)
    }

}
