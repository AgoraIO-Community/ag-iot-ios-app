//
//  PersonalInfoCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit

private let kHeadImgHeight: CGFloat = 36
class PersonalInfoCell: UITableViewCell {
    
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        return label
    }()
    
    private lazy var headImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = kHeadImgHeight * 0.5
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    private lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        return imgView
    }()
    
    private lazy var lineV:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexadecimal: "EFEFEF")
        return view
    }()
    
    
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
            make.left.equalTo(35)
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(headImgView)
        headImgView.snp.makeConstraints { make in
            make.right.equalTo(-63)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(kHeadImgHeight)
        }
        
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(-40)
            make.centerY.equalTo(contentView)
        }

        contentView.addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.left.equalTo(15)
            make.bottom.equalTo(-1)
            make.height.equalTo(1)
        }
        
    }

    func set(title:String?, headImgUrl:String? = nil, headImage:UIImage? = nil) -> Void {
        headImgView.kf.setImage(with: URL(string: headImgUrl ?? ""), placeholder: UIImage(named: "userimage"))
        if headImage != nil {
            headImgView.image = headImage
        }
        headImgView.isHidden = headImgUrl == nil && headImage == nil
        titleLabel.text = title
    }
}
