//
//  PushMsgSettingCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit
import SwiftDate

class SwitchSettingCell: UITableViewCell {

    var curIndexPath : IndexPath?
    
    var model:DeviceSetUpModel?{

        didSet{

            guard let model = model else { return }

            titleLabel.text = model.funcName
            if model.funcBoolValue == true {
                aSwitch.setOn(true, animated: true)
            }else{
                aSwitch.setOn(false, animated: true)
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
    
    var valueChangedAction:((_ aSwitch: UISwitch,_ curIdex: IndexPath)->(Void))?
    
    func createSubviews(){
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(47)
            make.centerY.equalTo(contentView)
        }
        contentView.addSubview(aSwitch)
        aSwitch.snp.makeConstraints { make in
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
    
    lazy var aSwitch:UISwitch = {
        let aSwitch = UISwitch()
        aSwitch.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        return aSwitch
    }()
    
    func setTitle(_ title:String?) -> Void {
        titleLabel.text = title
    }
    
    @objc func valueChanged(_ aSwitch:UISwitch) {
        valueChangedAction?(aSwitch,curIndexPath ?? NSIndexPath.init(row: 0, section: 0) as IndexPath)
    }

}

