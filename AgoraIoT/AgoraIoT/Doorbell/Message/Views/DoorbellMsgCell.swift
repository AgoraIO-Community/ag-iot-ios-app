//
//  DoorbellMsgCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/6.
//

import UIKit
import AgoraIotSdk
import Kingfisher

// 是否包含设备
enum DoorbellMsgCellDeviceStyle {
    case none   // 无
    case some // 有
}

class MsgData:NSObject {
    var alarm: IotAlarm
    var isPlaying = false
    var isSelected = false
    var canEdit = false
    var isDownloading = false
    
    init(alarm:IotAlarm, isPlaying:Bool = false, isSelected:Bool = false, canEidt:Bool = false) {
        self.alarm = alarm
        self.isPlaying = isPlaying
        self.isSelected = isSelected
        self.canEdit = canEidt
    }
}

class DoorbellMsgCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var deviceStyle: DoorbellMsgCellDeviceStyle = .none {
        didSet {
            if deviceStyle == .none {
                layoutForStyleNone()
            }else{
                layoutForStyleSome()
            }
        }
    }
    
    var bgStyle: AlamMsgVCBgStyle = .black {
        didSet {
            if bgStyle == .black {
                backgroundColor = .black
                contentView.backgroundColor = .black
                bgView.backgroundColor =  UIColor(hexRGB: 0x25262A)
                nameLabel.textColor = .white
                infoLabel.textColor = UIColor(hexRGB: 0xB7B6B6)
                dateLabel.textColor = UIColor(hexRGB: 0xB7B6B6)
                deviceLabel.textColor = UIColor(hexRGB: 0xB7B6B6)
            }else{
                backgroundColor = UIColor(hexRGB: 0xF8F8F8)
                contentView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
                bgView.backgroundColor =  .white
                nameLabel.textColor = .black
                infoLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
                dateLabel.textColor = UIColor(hexRGB: 0xB7B6B6)
                deviceLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
            }
        }
    }
    
    private lazy var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd   HH:mm"
        return formatter
    }()
    
    private lazy var messageTypeValues: [Int:String] = [
        0 : "声音检测",
        1 : "移动侦测",
        2 : "PIR红外检测",
        4 : "按钮报警",
        99 : "其他告警"
    ]
    
    private lazy var bgView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexRGB: 0x25262A)
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
    
    private lazy var playCoverView:UIView = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.text = "播放中"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.text = "移动侦测"
        return label
    }()
    
    private lazy var infoLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xB7B6B6)
        return label
    }()
    
    private lazy var dateLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(hexRGB: 0xB7B6B6)
        return label
    }()
    
    private lazy var selectedbutton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_unselect"), for: .normal)
        button.setImage(UIImage(named: "country_selected"), for: .selected)
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var deviceLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xB7B6B6)
        return label
    }()
    
    
    private func createSubviews(){
        contentView.addSubview(bgView)
        contentView.backgroundColor = UIColor(hexRGB: 0x000000)
        bgView.addSubview(iconImgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(infoLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(selectedbutton)
        bgView.addSubview(playCoverView)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15))
        }
        layoutForStyleNone()
    }
    
    private func layoutForStyleNone() {
        
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.width.equalTo(116)
            make.height.equalTo(66)
        }
        
        playCoverView.snp.makeConstraints { make in
            make.edges.equalTo(iconImgView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(17)
            make.top.equalTo(18)
            make.right.equalTo(-50)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(17)
            make.bottom.equalTo(-40)
            make.right.equalTo(-50)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(infoLabel)
            make.bottom.equalTo(-18)
        }
        
        // 可编辑标记
        selectedbutton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.width.height.equalTo(20)
        }
    }
    
    private func layoutForStyleSome() {
        // 设备
        bgView.addSubview(deviceLabel)
        
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.width.equalTo(116)
            make.height.equalTo(66)
        }
        
        playCoverView.snp.makeConstraints { make in
            make.edges.equalTo(iconImgView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(17)
            make.top.equalTo(13)
            make.right.equalTo(-50)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(17)
            make.top.equalTo(28)
            make.right.equalTo(-50)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(infoLabel)
            make.bottom.equalTo(-33)
        }
        
        deviceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-14)
            make.left.equalTo(infoLabel)
            make.right.equalTo(-50)
        }
        
        // 可编辑标记
        selectedbutton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.width.height.equalTo(20)
        }
    }
    
    func setMsgData(_ data: MsgData) {
        iconImgView.kf.setImage(with: URL(string: ""), placeholder: UIImage(named: "msg_preview_placeholder"))
        playCoverView.isHidden = !data.isPlaying
        nameLabel.text = messageTypeValues[Int(data.alarm.messageType)] ?? "未知"
        infoLabel.text = data.alarm.desc
        let interval = TimeInterval(truncating: (data.alarm.createdDate) as NSNumber) / 1000.0
        dateLabel.text = formatter.string(from: Date(timeIntervalSince1970: interval))
        deviceLabel.text = "来自设备 \(data.alarm.deviceName)"
        selectedbutton.isHidden = !data.canEdit
        selectedbutton.isSelected = data.isSelected
    }
    
}
