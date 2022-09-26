//
//  BluefiResultCell.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/9/21.
//

import UIKit

class BluefiResultCell: UITableViewCell {
    
    var curIndexPath : IndexPath?
    
    var model:ESPPeripheral?{

        didSet{

            guard let model = model else { return }

            titleLabel.text = (model.name != "" ? model.name:"no name")
            selectButton.isSelected = model.isSelect

        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var valueChangedAction:((_ curIdex: IndexPath)->(Void))?
    
    func createSubviews(){
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(47)
            make.centerY.equalTo(contentView)
        }
        contentView.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(contentView)
        }
    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = FontPFMediumSize(18)
        label.textColor = UIColor(hexString: "#2B2B2B")
        return label
    }()
    
    private lazy var selectButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_unselect"), for: .normal)
        button.setImage(UIImage(named: "country_selected"), for: .selected)
        button.addTarget(self, action: #selector(didClickEditButton(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc private func didClickEditButton(_ button:UIButton){
        valueChangedAction?(curIndexPath ??  NSIndexPath.init(row: 0, section: 0) as IndexPath)
    }
        
    func setTitle(_ title:String?) -> Void {
        titleLabel.text = title
    }
    
    @objc func valueChanged(_ aSwitch:UISwitch) {
        valueChangedAction?(curIndexPath ?? NSIndexPath.init(row: 0, section: 0) as IndexPath)
    }

}
