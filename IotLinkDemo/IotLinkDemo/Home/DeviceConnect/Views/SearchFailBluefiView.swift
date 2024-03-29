//
//  SearchFailBluefiView.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/9/23.
//

import UIKit

class SearchFailBluefiView: UIView {
    
    var searchFailNextActionBlock:(() -> (Void))?
    
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
        bgView.addSubview(nextButton)
        
        // 步骤
        let stepTextArray = [
            "请检查设备是否处于待配网状态",
            "检查设备是否在附近",
        ]
        var i = 0
        for text in stepTextArray {
            let stepLabel = DeviceItemLabel()
            stepLabel.setText(text, index: i + 1)
            bgView.addSubview(stepLabel)
            stepLabel.snp.makeConstraints { make in
                make.left.equalTo(45.S)
                make.top.equalTo(150.VS + (i * 40).S)
            }
            i += 1
        }
        
    }
    
    fileprivate func setUpConstraints() {
   
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{ (make) in
            
            make.top.equalTo(40.S)
            make.left.equalTo(30.S)
            make.size.equalTo(CGSize.init(width: 300.S, height: 80.VS))
                                        
        }

        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-80.VS)
            make.left.equalTo(30.S)
            make.right.equalTo(-30.S)
            make.height.equalTo(60.VS)
        }
        


    }
  
     lazy var bgView:UIView = {

        let view = UIView()
         view.backgroundColor = UIColor.white

        return view
    }()
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = FontPFMediumSize(18)
        label.textColor = UIColor.black
        label.numberOfLines = 2
        label.textAlignment = .left
        label.text = "未搜索到设备\n请排查以下问题后重试"
        return label
    }()
    

    
    private lazy var nextButton:UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("按步骤重试", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = UIColor(red: 63/255.0, green: 117/255.0, blue: 238/255.0, alpha: 0.8)
        button.isEnabled = true
        button.layer.cornerRadius = 30.VS
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)
        return button
        
    }()// 63 117 238

    
     @objc func didClickNextButton(){
         
         searchFailNextActionBlock?()
        
    }
    
}
