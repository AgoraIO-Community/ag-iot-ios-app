//
//  DoorbellAbilityTooBarSimpleView.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/29.
//

import UIKit
import AgoraIotLink
//import <MobileCoreServices/MobileCoreServices.h>

//实时检测底部工具条竖屏页面
class DoorbellAbilityTooBarSimpleView: UIView, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    typealias DoorfullHorBtnBlock = (_ btn : UIButton) -> ()
    var doorfullHorBtnBlock:DoorfullHorBtnBlock?
    var callBtnBlock:((_ btn : UIButton) -> (Void))?
    var changeSoundBtnBlock:((_ btn : UIButton) -> (Void))?
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
        bgView.addSubview(fullHorBtn)
        bgView.addSubview(changeSoundBtn)
        bgView.addSubview(callBtn)
        bgView.addSubview(recordSceeenBtn)
        
    }
    
    fileprivate func setUpConstraints() {
   
        //每个控件宽度
        let cusomW = (ScreenWidth-30.S-24.S-50)/4
        
        let offSetValue = 8.S
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        fullHorBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }

        changeSoundBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fullHorBtn.snp.right).offset(offSetValue)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }

        callBtn.snp.makeConstraints { (make) in
            make.left.equalTo(changeSoundBtn.snp.right).offset(offSetValue)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }

        recordSceeenBtn.snp.makeConstraints { (make) in
            make.left.equalTo(callBtn.snp.right).offset(offSetValue)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }
    }
    
     lazy var bgView:UIView = {

        let view = UIView()
         view.backgroundColor = UIColor.clear //(hexString: "#28292D")
//         view.alpha = 0.6
//        view.layer.cornerRadius = 8.VS
//        view.layer.masksToBounds = true

        return view
    }()
    
    lazy var fullHorBtn: UIButton = {
        let btn = UIButton()
//        btn.setImage(UIImage.init(named: "full_screen"), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("呼叫", for:.normal)
        btn.setTitle("挂断", for:.selected)
        btn.tag = 1001
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var changeSoundBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("静音", for:.normal)
        btn.setTitle("播放", for:.selected)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var callBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("录像", for:.normal)
        btn.setTitle("停录", for:.selected)
        btn.tag = 1003
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var recordSceeenBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("通话", for:.normal)
        btn.setTitle("禁麦", for:.selected)
        btn.tag = 1004
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    

    @objc func btnEvent(btn : UIButton){
        
        switch btn.tag {
        case 1001:
            debugPrint("呼叫:\(btn.isSelected)")
            doorfullHorBtnBlock?(btn)
            btn.isSelected = !btn.isSelected
            self.fullHorBtn.isEnabled = false
            break
        case 1002:
            debugPrint("静音")
            changeSoundBtnBlock?(btn)
            break
        case 1003:
            debugPrint("录像")
            recordScreenBtnBlock?(btn)
            break
        case 1004:
            debugPrint("通话")
            callBtnBlock?(btn)
            break
        default:
            break
        }
        
    } 
}

extension DoorbellAbilityTooBarSimpleView{
    
    
    
    func handelHorBtnSuccess(_ isSuccess : Bool){//呼叫
        print("handelHorBtnSuccess:______\(Thread.current)")
        DispatchQueue.main.async {
            // 在主线程执行的代码
            self.fullHorBtn.isSelected = isSuccess
            self.fullHorBtn.isEnabled = true
            print("handelHorBtnSuccess:---\(self.fullHorBtn.isSelected)")
        }
       
//        if isSuccess == false {
//            fullHorBtn.setTitle("呼叫", for: .normal)
//        }
    }
    
    func handelCallSuccess(_ isSuccess : Bool){//通话
        recordSceeenBtn.isSelected = isSuccess
    }
    
    func handleChangeSoundSuccess(_ isChange : Bool){//静音/播放
        changeSoundBtn.isSelected = isChange
    }
    
    func handleRecordScreenBtnSuccess(_ isChange : Bool){//录屏
        callBtn.isSelected = isChange
    }
}

