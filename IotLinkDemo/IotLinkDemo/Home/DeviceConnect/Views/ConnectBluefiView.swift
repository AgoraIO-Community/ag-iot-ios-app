//
//  ConnectBluefiView.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/9/22.
//

import UIKit

class ConnectBluefiView: UIView {
    
    var cancelConnectBtnActionBlock:(() -> (Void))?

    var itemArray = [ConnectItemLabel]()
    
    
    func selectBtn(_ index : Int) {
        
        let itemView = itemArray[index]
        itemView.selectButton.isSelected = true
        
    }
    
    func resetSelectBtn() {
        
        for item in itemArray {
            item.selectButton.isSelected = false
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpViews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(cancelButton)
        
        bgView.addSubview(subTitleLabel)

        //todo:
        // 步骤
        let stepTextArray = [
            "手机与设备连接成功",
            "向设备发送信息成功",
            "设备连接WiFi成功",
            "设备连接云端成功",
            "初始化成功"
        ]
        var i = 0
        for text in stepTextArray {
            let stepLabel = ConnectItemLabel()
            stepLabel.setText(text, index: i + 1)
            bgView.addSubview(stepLabel)
            stepLabel.snp.makeConstraints { make in
                make.left.equalTo(77.S)
                make.top.equalTo(160.S + (i * 40).S)
            }
            i += 1
            
            itemArray.append(stepLabel)
        }
        
        
    }
    
    fileprivate func setUpConstraints() {
   
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{ (make) in
            
            make.top.equalTo(20.VS)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 200.S, height: 30.VS))
                                        
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-27.S)
            make.width.equalTo(50.S)
            make.height.equalTo(30.VS)
        }
        
        subTitleLabel.snp.makeConstraints{ (make) in
            
            make.top.equalTo(titleLabel.snp.bottom).offset(39.VS)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 200.S, height: 25.VS))
                                        
        }

    }
  
     lazy var bgView:UIView = {

        let view = UIView()
         view.backgroundColor = UIColor.white

        return view
    }()
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = FontPFMediumSize(21)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 1)
        label.textAlignment = .center
        label.text = "正在添加设备..."
        return label
    }()
    
    private lazy var subTitleLabel:UILabel = {
        let label = UILabel()
        label.font = FontPFMediumSize(16)
        label.textAlignment = .center
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.text = "请确保设备处于通电状态"
        return label
    }()

    private lazy var countTimeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = "00:00"
        return label
    }()
    
    private lazy var cancelButton:UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x1DD6D6), for: .normal)
        button.titleLabel?.font = FontPFRegularSize(18)
        button.backgroundColor = .clear
        button.isEnabled = true
        button.addTarget(self, action: #selector(didClickCanceltButton), for: .touchUpInside)
        return button
        
    }()

    
     @objc func didClickCanceltButton(){
         
         cancelConnectBtnActionBlock?()
        
    }
    
}
