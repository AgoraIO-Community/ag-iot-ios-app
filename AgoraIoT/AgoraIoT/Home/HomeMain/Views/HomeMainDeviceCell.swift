//
//  HomeMainDeviceCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/21.
//

import UIKit
import AgoraIotSdk
import Kingfisher

class HomeMainDeviceCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    private lazy var bgView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.text = "可视门铃（WIFI）"
        return label
    }()
    
    private lazy var statusLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xF7B500)
        return label
    }()
    
    private func createSubviews(){
        contentView.addSubview(bgView)
        contentView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        bgView.addSubview(iconImgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(statusLabel)
            
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25))
        }
        
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.top.equalTo(20)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(20)
            make.top.equalTo(20)
            make.right.equalTo(-20)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(20)
            make.bottom.equalTo(-60)
            make.right.equalTo(-20)
        }
    }
    
    func setDevice(_ device:IotDevice,alarmDate:UInt64) {
        nameLabel.text = device.deviceName
        let offlineColor = UIColor(hexRGB: 0xF7B500)
        let onLineColor = UIColor(hexRGB: 0x000000, alpha: 0.25)
        let dateStr = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(alarmDate / 1000)))
        statusLabel.text = device.connected ? "移动侦测 \(dateStr)" : "离线"
        statusLabel.textColor = device.connected ? onLineColor: offlineColor
        iconImgView.kf.setImage(with: URL(string: device.productInfo?.imgSmall ?? ""), placeholder:  UIImage(named: "doorbell"))
    }
    
}
