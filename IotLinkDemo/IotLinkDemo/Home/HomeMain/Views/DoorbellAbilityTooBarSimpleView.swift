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

    typealias ConnectBtnBlock = (_ btn : UIButton) -> ()
    var connectBtnBlock:ConnectBtnBlock?
    var converseBtnBlock:((_ btn : UIButton) -> (Void))?
    var muteSoundBtnBlock:((_ btn : UIButton) -> (Void))?
    var shotScreenBtnBlock:(() -> (Void))?
    var recordScreenBtnBlock:((_ btn : UIButton) -> (Void))?
    
    var streamModel: MStreamModel? {
        didSet{
            connectBtn.setTitle("拉流".L, for:.normal)
            connectBtn.setTitle("停止".L, for:.selected)
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
        bgView.addSubview(connectBtn)
        bgView.addSubview(muteSoundBtn)
        bgView.addSubview(recordBtn)
        bgView.addSubview(converseBtn)
        
    }
    
    fileprivate func setUpConstraints() {
        //每个控件宽度
        let cusomW = (ScreenWidth-20.S-24.S-50)/4
        
        let offSetValue = 8.S
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        connectBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }

        muteSoundBtn.snp.makeConstraints { (make) in
            make.left.equalTo(connectBtn.snp.right).offset(offSetValue)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }

        recordBtn.snp.makeConstraints { (make) in
            make.left.equalTo(muteSoundBtn.snp.right).offset(offSetValue)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }

        converseBtn.snp.makeConstraints { (make) in
            make.left.equalTo(recordBtn.snp.right).offset(offSetValue)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 30.S))
        }
    }
    
     lazy var bgView:UIView = {
        let view = UIView()
         view.backgroundColor = UIColor.clear //(hexString: "#28292D")
        return view
    }()
    
    lazy var connectBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("call".L, for:.normal)
        btn.setTitle("hangUp".L, for:.selected)
        btn.tag = 1001
        btn.isSelected = false
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var muteSoundBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("unmute".L, for:.normal)
        btn.setTitle("mute".L, for:.selected)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var recordBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("record".L, for:.normal)
        btn.setTitle("stop".L, for:.selected)
        btn.tag = 1003
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var converseBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("converse".L, for:.normal)
        btn.setTitle("forbitConverse".L, for:.selected)
        btn.tag = 1004
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnEvent(btn : UIButton){
        switch btn.tag {
        case 1001:
            debugPrint("呼叫:\(btn.isSelected)")
            connectBtnBlock?(btn)
            btn.isSelected = !btn.isSelected
            break
        case 1002:
            debugPrint("静音")
            muteSoundBtnBlock?(btn)
            break
        case 1003:
            debugPrint("录像")
            recordScreenBtnBlock?(btn)
            break
        case 1004:
            debugPrint("通话")
            converseBtnBlock?(btn)
            break
        default:
            break
        }
    }
}

extension DoorbellAbilityTooBarSimpleView{
    func handelHorBtnSuccess(_ isSuccess : Bool){//呼叫
        DispatchQueue.main.async {
            // 在主线程执行的代码
            self.connectBtn.isSelected = isSuccess
        }
    }
    
    func handelCallSuccess(_ isSuccess : Bool){//通话
        converseBtn.isSelected = isSuccess
    }
    
    func handelMuteAudioStateText(_ isSuccess : Bool){//静音
        muteSoundBtn.isSelected = isSuccess
    }
    
    func handleRecordScreenBtnSuccess(_ isChange : Bool){//录屏
        recordBtn.isSelected = isChange
    }
}

