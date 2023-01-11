//
//  SearchBluefiView.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/9/22.
//

import UIKit

class SearchBluefiView: UIView {
    
    var searchNextBtnActionBlock:(() -> (Void))?

    func configTimeOutLabel(_ textContent:String, _ isResetSend:Bool = false) {
        countTimeLabel.text = textContent
        
    }
    
    func configNextBtn( _ isResult:Bool = false) {
       
        nextButton.backgroundColor = UIColor(red: 63/255.0, green: 117/255.0, blue: 238/255.0, alpha: 1)
        nextButton.isEnabled = true
        
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
        bgView.addSubview(subTitleLabel)
        bgView.addSubview(activity)
        bgView.addSubview(countTimeLabel)
//        bgView.addSubview(nextButton)
        
        activity.startAnimating()
        
    }
    
    fileprivate func setUpConstraints() {
   
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{ (make) in
            
            make.top.equalTo(50.S)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 300.S, height: 25.VS))
                                        
        }
        
        subTitleLabel.snp.makeConstraints{ (make) in
            
            make.top.equalTo(titleLabel.snp.bottom).offset(20.VS)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 300.S, height: 80.VS))
                                        
        }
 
        activity.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(100.VS)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        countTimeLabel.snp.makeConstraints{ (make) in
            
            make.top.equalTo(activity.snp.bottom).offset(10.VS)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 300.S, height: 30.VS))
                                        
        }

//        nextButton.snp.makeConstraints { (make) in
//            make.bottom.equalTo(-80.VS)
//            make.left.equalTo(30.S)
//            make.right.equalTo(-30.S)
//            make.height.equalTo(60.VS)
//        }

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
        label.textAlignment = .center
        label.text = "正在发现设备"
        return label
    }()
    
    private lazy var subTitleLabel:UILabel = {
        let label = UILabel()
        label.font = FontPFMediumSize(16)
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.numberOfLines = 2
        label.text = "请将设备保持通电状态\n 并将手机靠近设备"
        return label
    }()
    
    // loading
    private lazy var activity:UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.color = .cyan
        activity.transform = CGAffineTransform(scaleX: 4, y: 4)
        return activity
    }()

    private lazy var countTimeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = "00:00"
        return label
    }()
    
    private lazy var nextButton:UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = UIColor(red: 63/255.0, green: 117/255.0, blue: 238/255.0, alpha: 0.4)
        button.isEnabled = false
        button.layer.cornerRadius = 30.VS
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)
        return button
        
    }()

    
     @objc func didClickNextButton(){
         
         searchNextBtnActionBlock?()
        
    }
    
}
