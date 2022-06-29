//
//  DoorbellAbilityTooBarView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit
import AgoraIotSdk
//import <MobileCoreServices/MobileCoreServices.h>

//实时检测底部工具条竖屏页面
class DoorbellAbilityTooBarView: UIView, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    typealias DoorfullHorBtnBlock = () -> ()
    var doorfullHorBtnBlock:DoorfullHorBtnBlock?
    var callBtnBlock:((_ btn : UIButton) -> (Void))?
    var changeSoundBtnBlock:(() -> (Void))?
    //保存裁剪图片
    var shotScreenBtnBlock:(() -> (Void))?
    
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
        bgView.addSubview(screenShotBtn)
        
    }
    
    fileprivate func setUpConstraints() {
   
        //每个控件宽度
        let cusomW = (ScreenWidth-30.S)/5
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        fullHorBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 42.S))
        }

        changeSoundBtn.snp.makeConstraints { (make) in
            make.left.equalTo(fullHorBtn.snp.right)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 42.S))
        }

        callBtn.snp.makeConstraints { (make) in
            make.left.equalTo(changeSoundBtn.snp.right)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 56.VS))
        }

        recordSceeenBtn.snp.makeConstraints { (make) in
            make.left.equalTo(callBtn.snp.right)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 42.S))
        }

        screenShotBtn.snp.makeConstraints { (make) in
            make.left.equalTo(recordSceeenBtn.snp.right)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: cusomW, height: 42.S))
        }
    }
    
     lazy var bgView:UIView = {

        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#28292D")
        view.layer.cornerRadius = 8.VS
        view.layer.masksToBounds = true

        return view
    }()
    
    lazy var fullHorBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "full_screen"), for: .normal)
        btn.tag = 1001
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
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
        case 1001:
            debugPrint("横屏")
            doorfullHorBtnBlock?()
            break
        case 1002:
            debugPrint("变声")
            changeSoundBtnBlock?()
            break
        case 1003://"请求通话"
            callBtnBlock?(btn)
            break
        case 1004:
            debugPrint("录屏")
            AGToolHUD.showInfo(info:"该功能暂未开放，敬请期待！")
//            recordScreen(btn)
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

extension DoorbellAbilityTooBarView{

    func recordScreen(_ btn : UIButton){
        //btn.isSelected = !btn.isSelected
        if btn.isSelected == true {
            debugPrint("正在录制,调用停止")
            DoorBellManager.shared.talkingRecordStart { success, msg in
                if success{
                    btn.isSelected = !btn.isSelected
                    debugPrint("开始录制调用成功")
                    //todo:
                }
            }
            
        }else{
            debugPrint("未录制,调用开始")
            DoorBellManager.shared.talkingRecordStop { success, msg in
                if success{
                    btn.isSelected = !btn.isSelected
                    debugPrint("停止录制调用成功")
                    //todo:
                }
            }
        }
    } 
}

extension DoorbellAbilityTooBarView{
    
    func handelCallSuccess(_ isSuccess : Bool){
        callBtn.isSelected = isSuccess
    }
    
    func handleChangeSoundSuccess(_ isChange : Bool){
        changeSoundBtn.isSelected = isChange
    }
}

