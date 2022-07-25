//
//  NotifyMsgCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/13.
//

import UIKit

class NotifyMsgCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd   HH:mm"
        return formatter
    }()
    
    private lazy var messageTypeValues: [Int:String] = [
        1 : "设备上线",
        2 : "设备下线",
        3 : "设备绑定",
        4 : "设备解绑",
        99:"其他"
    ]
    
    private lazy var bgView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexRGB: 0x25262A)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
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
        bgView.addSubview(nameLabel)
        bgView.addSubview(infoLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(selectedbutton)
        
        layoutForStyleNone()
        setColors()
    }
    
    private func setColors(){
        backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        contentView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        bgView.backgroundColor =  .white
        nameLabel.textColor = .black
        infoLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        dateLabel.textColor = UIColor(hexRGB: 0xB7B6B6)
        deviceLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
    }
    
    private func layoutForStyleNone() {
        
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15))
        }
    
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(18)
            make.right.equalTo(-50)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(-37)
            make.right.equalTo(-50)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(infoLabel)
            make.bottom.equalTo(-17)
        }
        
        // 可编辑标记
        selectedbutton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.width.height.equalTo(20)
        }
    }
    
    
    func setMsgData(_ data: MsgData) {
        nameLabel.text = messageTypeValues[Int(data.alarm.messageType)] ?? "未知"
        infoLabel.text = data.alarm.desc
        let interval = TimeInterval(truncating: (data.alarm.createdDate) as NSNumber) / 1000.0
        dateLabel.text = formatter.string(from: Date(timeIntervalSince1970: interval))
        selectedbutton.isHidden = !data.canEdit
        selectedbutton.isSelected = data.isSelected
    }

}
