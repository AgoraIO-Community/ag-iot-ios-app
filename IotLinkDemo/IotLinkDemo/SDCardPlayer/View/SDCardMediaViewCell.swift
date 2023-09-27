//
//  SDCardMediaViewCell.swift
//  IotLinkDemo
//
//  Created by admin on 2023/7/13.
//

import UIKit
import AgoraIotLink

class SDCardMediaViewCell: UITableViewCell {
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    var mediaItem: DevMediaItem? {
        didSet{
            guard let mediaItem = mediaItem else {
                return
            }
            nameLabel.text = mediaItem.mFileId
//            videoUrlLabel.text = mediaItem.mVideoUrl
        }
    }
    
    var coverImg : UIImage? {
        didSet{
            guard let coverImg = coverImg else {
                return
            }
            iconImgView.image = coverImg
        }
    }
    
    var indexPath : IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    private func createSubviews(){

        contentView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        
        contentView.addSubview(iconImgView)
        iconImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(iconImgView.snp.right).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
        contentView.addSubview(videoUrlLabel)
        videoUrlLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(iconImgView.snp.right).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.black
        label.text = ""
        return label
    }()
    
    private lazy var videoUrlLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.black
        label.text = ""
        return label
    }()
    
    private lazy var statusLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xF7B500)
        return label
    }()
    
    private lazy var iconImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
        return imgView
    }()

    
}
