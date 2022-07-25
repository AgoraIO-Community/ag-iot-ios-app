//
//  MineCell.swift
//  ios_haiwai
//
//  Created by msbfp on 2021/11/25.
//

import UIKit

private let dotviewWidth: CGFloat = 8

class MinePageCell: UITableViewCell {

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
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(dotView)
        dotView.snp.makeConstraints { make in
            make.right.equalTo(-56)
            make.width.height.equalTo(dotviewWidth)
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(-40)
            make.centerY.equalTo(contentView)
        }

    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(hexRGB: 0x333333)
        return label
    }()
    
    private lazy var dotView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexRGB: 0xFF4D4F)
        view.layer.cornerRadius = dotviewWidth * 0.5
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        return imgView
    }()
    
    func setImgName(_ img:String?,title:String?, showDot:Bool = false) -> Void {
        titleLabel.text = title
        dotView.isHidden = !showDot
    }
}
