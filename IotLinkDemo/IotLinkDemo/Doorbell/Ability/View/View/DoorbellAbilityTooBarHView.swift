//
//  DoorbellAbilityTooBarHView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/16.
//

import UIKit

//实时检测底部工具条横屏页面
class DoorbellAbilityTooBarHView: UIView, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var callBtnBlock:((_ btn : UIButton) -> (Void))?
    var changeSoundBtnBlock:(() -> (Void))?
    //保存裁剪图片
    var shotScreenBtnBlock:(() -> (Void))?
    //录屏
    var recordScreenBtnBlock:((_ btn : UIButton) -> (Void))?
    
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
        bgView.addSubview(callBtn)
        bgView.addSubview(recordSceeenBtn)
        bgView.addSubview(screenShotBtn)
        
    }
    
    fileprivate func setUpConstraints() {
   
        //每个控件宽度 //76
        let cusomH = (ScreenWidth-146.S)/4
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 73.S, left: 0, bottom: 73.S, right: 0))
            
        }//make.top.bottom.equalToSuperview().inset(73.S).priority(.low)

        changeSoundBtn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 42.S, height: cusomH))
        }

        callBtn.snp.makeConstraints { (make) in
            make.top.equalTo(changeSoundBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 56.S, height: cusomH))
        }

        recordSceeenBtn.snp.makeConstraints { (make) in
            make.top.equalTo(callBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 42.S, height: cusomH))
        }

        screenShotBtn.snp.makeConstraints { (make) in
            make.top.equalTo(recordSceeenBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 42.S, height: cusomH))
        }
    }
    
     lazy var bgView:UIView = {

        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#28292D")

        return view
    }()

    lazy var changeSoundBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "change_voice"), for: .normal)
        btn.setImage(UIImage.init(named: "change_voice_on"), for: .selected)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var callBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "call"), for: .normal)
        btn.setImage(UIImage.init(named: "calloff"), for: .selected)
        btn.tag = 1003
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var recordSceeenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "record"), for: .normal)
        btn.tag = 1004
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var screenShotBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "screenShot"), for: .normal)
        btn.tag = 1005
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    

    @objc func btnEvent(btn : UIButton){
        
        switch btn.tag {
            
        case 1002:
            debugPrint("变声")
            changeSoundBtnBlock?()
            break
        case 1003://"请求通话"
            callBtnBlock?(btn)
            break
        case 1004:
            debugPrint("录屏")
            recordScreenBtnBlock?(btn)
//            AGToolHUD.showInfo(info:"该功能暂未开放，敬请期待！")
            break
        case 1005:
            debugPrint("截屏")
            shotScreenBtnBlock?()
            break
        default:
            break
        }
        
    }
    
}

extension DoorbellAbilityTooBarHView{
    
    func handelCallSuccess(_ isSuccess : Bool){
        callBtn.isSelected = isSuccess
    }
    
    func handleChangeSoundSuccess(_ isChange : Bool){
        changeSoundBtn.isSelected = isChange
    }
    
    func handleRecordScreenBtnSuccess(_ isChange : Bool){
        recordSceeenBtn.isSelected = isChange
    }
}
