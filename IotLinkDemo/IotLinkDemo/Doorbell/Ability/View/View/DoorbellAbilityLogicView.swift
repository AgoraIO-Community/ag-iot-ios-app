//
//  DoorbellAbilityLogicView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/9.
//

import UIKit
import AgoraIotLink

//首帧可显示成功的通知（被动呼叫）
let cReceiveChangeSoundSuccessNotify = "cReceiveChangeSoundSuccessNotify"
let cReceiveCallSuccessNotify = "cReceiveCallSuccessNotify"

//视频上层逻辑操作View
class DoorbellAbilityLogicView: UIView {
    
    var isOnCalling : Bool = false //正在通话中
    var isChangeSodSeting : Bool = false //正在变声设置中
    
    let topMarginH : CGFloat = 66.VS
    let toolBarH : CGFloat = 56.VS
    
    var logicLeftBackHBlock:(() -> (Void))?
    var logicfullHorBtnBlock:(() -> (Void))?
    
        
    var device: IotDevice?{
        didSet{
            topControlView.device = device
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        addObserver()
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 注册通知
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveChangeSoundSuccess(notification:)), name: Notification.Name(cReceiveChangeSoundSuccessNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCallSuccess(notification:)), name: Notification.Name(cReceiveCallSuccessNotify), object: nil)
    }
    
    @objc private func receiveChangeSoundSuccess(notification: NSNotification){
        //变声通话通知
        guard let effectName = notification.userInfo?["effectName"] as? String,let isSuccess = notification.userInfo?["success"] as? Bool else { return }
        handelChangeSoundTipText(isSuccess,effectName)
        toolBarView.handleChangeSoundSuccess(isSuccess)
        toolBarHView.handleChangeSoundSuccess(isSuccess)
        isChangeSodSeting = true
    }
    
    @objc private func receiveCallSuccess(notification: NSNotification){
        //通话通知
        guard let isSuccess = notification.userInfo?["success"] as? Bool else { return }
        //如果已经设置变声通话，此处不再更改文案，避免覆盖
        if isChangeSodSeting == false {
            handelCallStateText(isSuccess)
        }
        toolBarView.handelCallSuccess(isSuccess)
        toolBarHView.handelCallSuccess(isSuccess)
        isOnCalling = true
    }
    
    deinit {
        debugPrint("loginView被释放了")
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpViews(){
        
        addSubview(topControlView)
        topControlView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(topMarginH)
            
        }
        
        addSubview(toolBarView)
        toolBarView.snp.makeConstraints { (make) in
            make.height.equalTo(toolBarH)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(15.S).priority(.low)
        }
        
        addSubview(saveImgAlertView)
        saveImgAlertView.snp.makeConstraints { (make) in
            make.height.equalTo(92)
            make.width.equalTo(98)
            make.bottom.equalTo(toolBarView.snp.top).offset(-42.VS)
            make.right.equalToSuperview().inset(15.S).priority(.low)
        }
        
        addSubview(toolBarHView)
        toolBarHView.snp.makeConstraints { (make) in
            make.width.equalTo(76)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        addSubview(leftBackHView)
        leftBackHView.snp.makeConstraints { (make) in
            make.width.equalTo(76)
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }

    }
    
    fileprivate lazy var topControlView:TopControTooBarView = {
        
        let view = TopControTooBarView()
        return view
    }()
    

    fileprivate lazy var toolBarView:DoorbellAbilityTooBarView = {

        let view = DoorbellAbilityTooBarView()
        view.doorfullHorBtnBlock = {[weak self] in
            debugPrint("转为横屏")
            self?.logicfullHorBtnBlock?()
        }
        view.callBtnBlock = {[weak self] button in
            //本地语音通话tip
            self?.callPhone(button)
        }
        view.changeSoundBtnBlock = {[weak self] () in
            //变声语音通话
            self?.showChangeSoundAlert()
        }
        view.shotScreenBtnBlock = { [weak self] in
            self?.shotScreen()
        }
        
        return view
    }()
    
    fileprivate lazy var saveImgAlertView:DoorbellSaveImgAlertView = {
        
        let view = DoorbellSaveImgAlertView()
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var toolBarHView:DoorbellAbilityTooBarHView = {

        let view = DoorbellAbilityTooBarHView()
        view.backgroundColor = UIColor(hexString: "#28292D")
        view.isHidden = true
        view.callBtnBlock = {[weak self] button in
            debugPrint("本地唤起语音通话")
            //本地语音通话tip
            self?.callPhone(button)
        }
        view.changeSoundBtnBlock = {[weak self] () in
            //变声语音通话
            self?.showChangeSoundAlert()
        }
        view.shotScreenBtnBlock = { [weak self]  in
            self?.shotScreen()
        }
        
        return view
    }()
    
    fileprivate lazy var leftBackHView:DoorbellLeftBackHView = {

        let view = DoorbellLeftBackHView()
        view.backgroundColor = UIColor(hexString: "#28292D")
        view.isHidden = true
        view.doorLeftBackHBlock = { [weak self] in
            debugPrint("返回竖屏")
            self?.logicLeftBackHBlock?()
        }
        return view
    }()

}


extension DoorbellAbilityLogicView{//下层View传值
    
    func handelQuantityValue(_ value : Int){
        topControlView.quantityValue = value
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.perform(#selector(hiddenImgAlertView), afterDelay: 2.0)
    }
    
}

extension DoorbellAbilityLogicView{
    
    func handelHScreenToolBarView(_ isFull : Bool){
        
        if isFull == true {
            
            toolBarHView.isHidden = false
            leftBackHView.isHidden = false
            toolBarView.isHidden = true
            
            saveImgAlertView.snp.updateConstraints { (make) in
                make.right.equalToSuperview().inset((76+15).S).priority(.low)
            }
            
        }else{
            
            toolBarHView.isHidden = true
            leftBackHView.isHidden = true
            toolBarView.isHidden = false
            
            saveImgAlertView.snp.updateConstraints { (make) in
                make.right.equalToSuperview().inset((15).S).priority(.low)
            }
            
        }
        
        topControlView.handelHScreenControlBarView(isFull)
        
    }
}

extension DoorbellAbilityLogicView{
    
    func callPhone(_ btn : UIButton){
        
        var isPermitAudio : Bool = false
        debugPrint("请求通话")
        if btn.isSelected {//挂断
            debugPrint("挂断通话")
            isPermitAudio = true
        }else{//请求通话
            //请求通话时变声通话置为正常
            changeSoundNormal()
        }
        DoorBellManager.shared.muteLocalAudio(mute: isPermitAudio) {[weak self] success, msg in
            if success{
                debugPrint("请求通话/或者挂断 成功")
                let isSelect = !btn.isSelected
                self?.handelCallStateText(isSelect)
                self?.toolBarView.handelCallSuccess(isSelect)
                self?.toolBarHView.handelCallSuccess(isSelect)
                self?.isOnCalling = true
                if isPermitAudio == true {//挂断电话
                    //通话结束变声通话置为正常
                    self?.changeSoundNormal()
                    self?.isOnCalling = false
                }
                
            }
         }
    }
    
    //变声恢复正常声音
    func changeSoundNormal(){
        
        DoorBellManager.shared.setAudioEffect(effectId: .NORMAL) { [weak self] success, msg in
            if success {
                debugPrint("变声恢复正常声音: 成功")
                self?.toolBarView.handleChangeSoundSuccess(false)
                self?.toolBarHView.handleChangeSoundSuccess(false)
                TDUserInforManager.shared.curEffectId = .NORMAL
            }
        }
    }
    
    //变声弹框
    func showChangeSoundAlert(){

        let proAlertVC = ChanceSoundAlertVC()
        proAlertVC.chanceSoundAlertBlock = { (effectId,effectName) in
            debugPrint("关闭变声弹框")
            DoorBellManager.shared.setAudioEffect(effectId: effectId) { [weak self] success, msg in
                if success {
                    debugPrint("变声成功")
                    if effectId == .NORMAL {
                        TDUserInforManager.shared.curEffectId = .NORMAL
                        self?.toolBarView.handleChangeSoundSuccess(false)
                        self?.toolBarHView.handleChangeSoundSuccess(false)
                        if self?.isOnCalling == true {
                            self?.handelChangeSoundTipText(false,effectName)
                        }
                    }else{
                        TDUserInforManager.shared.curEffectId = effectId
                        self?.toolBarView.handleChangeSoundSuccess(true)
                        self?.toolBarHView.handleChangeSoundSuccess(true)
                        if self?.isOnCalling == true {
                            self?.handelChangeSoundTipText(true,effectName)
                        }
                    }
                }
            }
        }
        
        proAlertVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        proAlertVC.modalPresentationStyle = .overCurrentContext
        currentViewController().present(proAlertVC, animated: true, completion: nil)
        
    }
    
    func handelCallStateText(_ isCallSuc : Bool?){
        
        if isCallSuc == true {
            debugPrint("语音通话中")
            topControlView.tipsLabel.text = "正在通话中..."
        }else{
            debugPrint("结束语音通话")
            topControlView.tipsLabel.text = ""
        }
    }
    
    func handelChangeSoundTipText(_ isChanged : Bool?,_ effectName : String){
       
        if isChanged == true {
            debugPrint("变声语音通话中")
            topControlView.tipsLabel.text = "变声通话中（\(effectName)）..."
        }else{
            debugPrint("恢复正常语音通话")
            topControlView.tipsLabel.text = "正在通话中..."
        }
    }
    
}


extension DoorbellAbilityLogicView{//下层View传值
    
    func shotScreen(){
        
        DoorBellManager.shared.capturePeerVideoFrame { [weak self] success, msg, shotImg in
            if success{
                debugPrint("截屏成功")
                guard let shotImg = shotImg else {
                    AGToolHUD.showInfo(info: "图片截屏失败！")
                    return
                }
                self?.saveImgToAlbum(shotImg)
                self?.handelSaveImgAlert(shotImg)
            }
        }
    }
    
    func saveImgToAlbum(_ image : UIImage){
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(image: UIImage,didFinishSavingWithError: NSError?,contextInfo: AnyObject) {
     
        if didFinishSavingWithError != nil {
            AGToolHUD.showInfo(info: "截图保存失败！")
            return
        }
//            AGToolHUD.showInfo(info: "截图保存成功！")
    }
    
    func handelSaveImgAlert(_ shotImage : UIImage){
        saveImgAlertView.isHidden = false
        saveImgAlertView.shotImage = shotImage
        saveImgAlertView.alertType = .saveImg
        self.perform(#selector(hiddenImgAlertView), afterDelay: 2.0)
    }
    
    // 弹出视图动画
    @objc public func hiddenImgAlertView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: []) {
            self.saveImgAlertView.x = self.saveImgAlertView.x + 150
            self.saveImgAlertView.alpha = 0.2
        } completion: { _ in
            self.saveImgAlertView.x = self.saveImgAlertView.x - 150
            self.saveImgAlertView.alpha = 1
            self.saveImgAlertView.isHidden = true
        }
     }
    
}
