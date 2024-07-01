//
//  TopControTooBarSimpleView.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/29.
//

import UIKit
import AgoraIotLink

//视频控制操作View
class TopControTooBarSimpleView: UIView {
    // 当前选中的类型
    private var selectedType = 0
    var device: MDeviceModel? {
        didSet{
            guard let device = device else {
                return
            }
            nodeIdLabel.text = device.peerNodeId
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setUpViews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(bgView)
        bgView.addSubview(nodeIdLabel)
        bgView.addSubview(tipsLabel)
    }
    
    fileprivate func setUpConstraints() {
        bgView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }

        nodeIdLabel.snp.makeConstraints { (make) in
            make.left.equalTo(24.S)
            make.top.equalTo(10.S)
            make.size.equalTo(CGSize.init(width: 200.S, height: 17.S))
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(24.S)
            make.top.equalTo(nodeIdLabel.snp.bottom)
            make.size.equalTo(CGSize.init(width: 150.S, height: 17.S))
        }
    }
    
    fileprivate lazy var bgView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var nodeIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white //UIColor(hexString: "#25DEDE")
        label.font = FontPFMediumSize(12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.blue
        label.text = ""
        return label
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white //UIColor(hexString: "#25DEDE")
        label.font = FontPFMediumSize(12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.green
        label.text = "未连接..."
        return label
    }()
    
    lazy var memberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white //UIColor(hexString: "#25DEDE")
        label.font = FontPFMediumSize(12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clear
        label.text = "number".L + ":0"
        return label
    }()

}

