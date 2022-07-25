//
//  DoorbellAnswerLogicView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/9.
//

import UIKit
import AgoraIotLink

//接听门铃呼叫上层逻辑视图
class DoorbellAnswerLogicView: UIView {
    
    let topMarginH : CGFloat = 47.VS
    let toolBarH : CGFloat = 56.VS
    
    var callAnswerBtnBlock:(() -> (Void))?
    var callAnswerHungUpBlock:(() -> (Void))?
    
    var deviceName : String?{
        
        didSet{
            guard let deviceName = deviceName else { return }
            deviceView.deviceName = deviceName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(topControlView)
        topControlView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(topMarginH)
            
        }
        
        addSubview(bottomBgView)
        bottomBgView.snp.makeConstraints { (make) in
            make.top.equalTo((338 - 56).VS)
            make.left.right.bottom.equalToSuperview()
            
        }
        
//        addSubview(bottomBgView)
//        bottomBgView.snp.makeConstraints { (make) in
//            make.top.equalTo((338 - 56).VS)
//            make.left.right.bottom.equalToSuperview()
//
//        }
 
        bottomBgView.addSubview(deviceView)
        deviceView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(8.S)
            make.right.equalTo(-8.S)
            make.height.equalTo(47.VS)
        }
        
        bottomBgView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-(288 + 30).VS)//30为额外减去，适配下屏
            make.left.equalTo(8.S)
            make.right.equalTo(-8.S)
            make.height.equalTo(22.VS)
        }
        
        bottomBgView.addSubview(handUpBtn)
        handUpBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(54.VS)
            make.left.equalTo(59.S)
            make.width.height.equalTo(78.S)
        }
        
        bottomBgView.addSubview(handUpLabel)
        handUpLabel.snp.makeConstraints { (make) in
            make.top.equalTo(handUpBtn.snp.bottom).offset(10.VS)
            make.left.right.equalTo(handUpBtn)
            make.height.equalTo(20.S)
        }
        
        bottomBgView.addSubview(answerBtn)
        answerBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(54.VS)
            make.right.equalTo(-59.S)
            make.width.height.equalTo(78.S)
        }
        
        bottomBgView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(answerBtn.snp.bottom).offset(10.VS)
            make.left.right.equalTo(answerBtn)
            make.height.equalTo(20.S)
        }
        
        bottomBgView.addSubview(changeSoundBtn)
        changeSoundBtn.snp.makeConstraints { (make) in
            make.top.equalTo(handUpBtn.snp.bottom).offset(64.VS)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(26.S)
        }
        
        bottomBgView.addSubview(changeSoundLabel)
        changeSoundLabel.snp.makeConstraints { (make) in
            make.top.equalTo(changeSoundBtn.snp.bottom).offset(10.VS)
            make.centerX.equalToSuperview()
            make.width.equalTo(80.S)
            make.height.equalTo(17.S)
        }
        
        
    }
    
    fileprivate lazy var topControlView:UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.init(hexString: "000000")
        return view
    }()
    
    fileprivate lazy var bottomBgView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.init(hexString: "000000")
        return view
    }()
    
    lazy var changeSoundLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#DCDCDC")
        label.font = FontPFRegularSize(12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "变声通话"
        return label
    }()
    
    lazy var changeSoundBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "change_voice"), for: .normal)
        btn.setImage(UIImage.init(named: "change_voice_on"), for: .selected)
        btn.tag = 1001
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var handUpLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#FFFFFF")
        label.font = FontPFRegularSize(14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "挂断"
        return label
    }()
    
    lazy var handUpBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "hangup"), for: .normal)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#FFFFFF")
        label.font = FontPFRegularSize(14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "接听"
        return label
    }()
    
    lazy var answerBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "answer"), for: .normal)
        btn.tag = 1003
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#DCDCDC")
        label.font = FontPFRegularSize(16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "有人按门铃…"
        return label
    }()
    
    lazy var deviceView:DeviceBarView = {
        
        let view = DeviceBarView()
        return view
        
    }()
    
    @objc func btnEvent(btn : UIButton){
        if btn.tag ==  1001{
            debugPrint("变声")
            showProtocolAlert(btn)
            
        }else if btn.tag ==  1002{
            debugPrint("挂断")
            DoorBellManager.shared.hungUpAnswer {[weak self] success, msg in
                if success {
                    debugPrint("挂断成功")
                    self?.callAnswerHungUpBlock?()
                }else{
                    AGToolHUD.showInfo(info: msg)
                    self?.callAnswerHungUpBlock?()
                }
            }
            
        }else if btn.tag ==  1003{
            debugPrint("接听")
            DoorBellManager.shared.callAnswer {[weak self] success, msg in
                if success {
                    debugPrint("接听成功")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: cReceiveCallSuccessNotify), object: nil, userInfo: ["success":true])
                }
                self?.callAnswerBtnBlock?()
            } actionAck: { [weak self] ack in
                self?.handelAnswerCallAct(ack)
            }
        }
    }
    
    //处理呼叫返回
    func handelAnswerCallAct(_ act:ActionAck){
        
        AGToolHUD.disMiss()
        
        if(act == .CallOutgoing){
            debugPrint("本地来电振铃")
        }
        else if(act == .RemoteHangup){
            //设备休眠时会走此回调
            debugPrint("设备挂断")
            callAnswerHungUpBlock?()
        }
        else if(act == .RemoteAnswer || act == .CallForward){
            debugPrint("设备接听")
        }
        else if(act == .RemoteVideoReady){
            debugPrint("获取到首帧")
        }
        else if(act == .LocalTimeout || act == .UnknownAction){
            debugPrint("呼叫超时")
        }
    }
    
    //变声弹框
    func showProtocolAlert(_ btn : UIButton){
        
        let proAlertVC = ChanceSoundAlertVC()
        proAlertVC.chanceSoundAlertBlock = { (effectId,effectName) in
            debugPrint("关闭变声弹框")
            DoorBellManager.shared.setAudioEffect(effectId: effectId) { success, msg in
                if success {
                    debugPrint("变声成功")
                    if effectId == .NORMAL {
                        TDUserInforManager.shared.curEffectId = .NORMAL
                        btn.isSelected = false
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cReceiveChangeSoundSuccessNotify), object: nil, userInfo: ["effectName":effectName,"success":false])
                    }else{
                        TDUserInforManager.shared.curEffectId = effectId
                        btn.isSelected = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cReceiveChangeSoundSuccessNotify), object: nil, userInfo: ["effectName":effectName,"success":true])
                    }
                }
            }
        }
        
        proAlertVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        proAlertVC.modalPresentationStyle = .overCurrentContext
        currentViewController().present(proAlertVC, animated: true, completion: nil)
        
    }
    
}

class DeviceBarView: UIView{
    
    var deviceName : String?{
        didSet{
            guard let deviceName = deviceName else { return }
            deviceNameLabel.text = "设备名称：\(deviceName)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        bgView.addSubview(iconImageV)
        iconImageV.snp.makeConstraints { (make) in
            make.left.equalTo(19.S)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(9.S)
        }
        
        bgView.addSubview(deviceNameLabel)
        deviceNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageV.snp.right).offset(13.S)
            make.right.equalTo(-15.S)
            make.centerY.equalToSuperview()
            make.height.equalTo(18.S)
        }
    }
    
    fileprivate lazy var bgView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.init(hexString: "000000")
        view.cornerRadius = 4.S
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.init(hexString: "#3D3F46").cgColor
        
        return view
    }()
    
    lazy var iconImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFit
        imageV.image = UIImage.init(named: "diamond_icon")
        return imageV
    }()
    
    lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#FFFFFF")
        label.font = FontPFRegularSize(13)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.text = "设备名称：创米小白可视门铃D1"
        return label
    }()
    
}
