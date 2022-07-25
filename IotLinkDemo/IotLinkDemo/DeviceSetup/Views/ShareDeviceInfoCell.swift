//
//  ShareDeviceInfoCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit

// 头像宽高
private let kImageHeight: CGFloat = 36

class ShareDeviceInfoCell: UITableViewCell {
    
    private lazy var headImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = kImageHeight * 0.5
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    private lazy var nicknameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.35)
        return label
    }()
    
//    private lazy var accountLabel:UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
//        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.35)
//        return label
//    }()

    private lazy var arrowImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "info_right_arrow")
        return imgView
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews(){
        contentView.addSubview(headImgView)
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(37)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kImageHeight)
        }
        
        
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }
//        contentView.addSubview(accountLabel)
//        accountLabel.snp.makeConstraints { make in
//            make.left.equalTo(nicknameLabel)
//            make.bottom.equalTo(headImgView)
//        }
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(-40)
            make.centerY.equalTo(contentView)
        }
    }
    
    func set(nickname:String, account:String, headImg: String?) -> Void {
        
        var phoneNum = nickname
        if phoneNum.contains("+86") {
            let startIndex = phoneNum.startIndex
            phoneNum.replaceSubrange(phoneNum.index(startIndex, offsetBy: 0)...phoneNum.index(startIndex, offsetBy: 2), with: "")
        }
        nicknameLabel.text = phoneNum.replacePhone()
//        accountLabel.text = account
        headImgView.kf.setImage(with: URL(string: headImg ?? ""), placeholder: UIImage(named: "userimage"))

    }
}
