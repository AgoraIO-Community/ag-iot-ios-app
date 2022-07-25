//
//  DoorbellLeftBackHView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/16.
//

import UIKit

class DoorbellLeftBackHView: UIView {
    
    typealias DoorbellLeftBackHViewBlock = () -> ()
    var doorLeftBackHBlock:DoorbellLeftBackHViewBlock?
    
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
        bgView.addSubview(changeSoundBtn)
        
    }
    
    fileprivate func setUpConstraints() {
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            
        }

        changeSoundBtn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 42.S, height: 42.S))
        }

    }
    
     lazy var bgView:UIView = {

        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#28292D")

        return view
    }()

    lazy var changeSoundBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "doorbell_back"), for: .normal)
        btn.tag = 1001
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()

    @objc func btnEvent(btn : UIButton){
        debugPrint("点击返回竖屏")
        doorLeftBackHBlock?()
    }
    
}
