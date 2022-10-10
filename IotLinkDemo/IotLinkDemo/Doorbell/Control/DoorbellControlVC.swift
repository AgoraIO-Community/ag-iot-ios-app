//
//  DoorbellControlVC.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/11.
//

import Foundation
import JXSegmentedView
import AgoraIotLink
import UIKit

class DoorbellControlVC: UIViewController {
    
    var device:IotDevice? = nil
//    init(device:IotDevice) {
//        self.device = device
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    
    lazy var periodLabel : UILabel = {
        let label:UILabel = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        label.width = 80
        label.text = "发送周期"
        return label
    }()
    
    lazy var sliderLabel : UILabel = {
        let label:UILabel = UILabel()
        label.backgroundColor = .white
        label.text = "2"
        return label
    }()
    
    lazy var slider : UISlider = {
        let slider:UISlider = UISlider()
        slider.minimumTrackTintColor = .blue
        slider.maximumTrackTintColor = .white
//        slider.backgroundColor = .white
        slider.minimumValue = 0.01
        slider.maximumValue = 5
        slider.isContinuous = true
        slider.value = 2
        return slider
    }()
    
    lazy var labelSend : UILabel = {
        let label:UILabel = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        label.width = 80
        label.text = "发送数据"
        return label
    }()
    
    lazy var textToSend: TextInputView = {
        
        let vew = TextInputView()
        //vew.leftImage = UIImage.init(named: "login_user")
        vew.textField.placeholder = "请输入发送数据"
        vew.textField.delegate = self
        vew.textField.tag = 89
        vew.textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        vew.textField.keyboardType = UIKeyboardType.asciiCapable
        
        return vew
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("播放sd卡", for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#6A6A6A")
        
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.setTitleColor(UIColor.init(hexString: "#25DEDE"), for: .normal)
        btn.layer.cornerRadius = 10.S
        btn.addTarget(self, action: #selector(playBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var sendBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("发送", for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#6A6A6A")
        
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.setTitleColor(UIColor.init(hexString: "#25DEDE"), for: .normal)
        btn.layer.cornerRadius = 10.S
        btn.addTarget(self, action: #selector(sendBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var sendRepeat : UIButton = {
        let btn = UIButton()
        btn.setTitle("周期发送开始", for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#6A6A6A")
        
        btn.titleLabel?.font = FontPFMediumSize(18)
        btn.setTitleColor(UIColor.init(hexString: "#25DEDE"), for: .normal)
        btn.layer.cornerRadius = 10.S
        btn.addTarget(self, action: #selector(sendRepeatBtnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var textField:TextInputField = {
        
        let textField = TextInputField()
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black

        textField.placeholder = ""
        textField.placeholderColor = UIColor(hexString: "#DEDEDE")
        textField.placeholderFont = FontPFRegularSize(13)
        textField.font = FontPFRegularSize(13)

        textField.autocapitalizationType = .none

        //textField.leftView = showLeftImageV
        textField.leftViewMode = UITextField.ViewMode.never
        textField.rightViewMode = UITextField.ViewMode.never
        textField.layer.cornerRadius = 10.S
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
//        textField.borderStyle = .roundedRect

        return textField
    }()
//
    
    @objc func SliderChanged(_ slider:UISlider)
    {
        sliderLabel.text = String(slider.value)
    }
    
    let videoH : CGFloat = 200.VS
    let topMarginH : CGFloat = 1.VS
    let bottomMarginH : CGFloat = 16.VS
    let toolBarH : CGFloat = 56.VS
    lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.backgroundColor = UIColor.gray
        return videoView
        
    }()
    
    private func setupUI(){
        //view.addSubview(textToSend)
        view.addSubview(videoView)
        view.addSubview(playBtn)
        view.addSubview(periodLabel)
        view.addSubview(sliderLabel)
        view.addSubview(slider)
        view.addSubview(labelSend)
        view.addSubview(textField)
        view.addSubview(sendBtn)
        view.addSubview(sendRepeat)
        
        videoView.snp.makeConstraints { make in
            make.top.equalTo(topMarginH)
            make.left.right.equalToSuperview()
            make.height.equalTo(videoH)
        }

        slider.addTarget(self, action: #selector(self.SliderChanged), for: .valueChanged)
        
        let dist = 0
        playBtn.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(dist - 60)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
        }
        slider.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(0)
            make.centerX.equalToSuperview()
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.height.equalTo(30*ScreenHS)
        }
        sliderLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(dist + 30)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.height.equalTo(30)
        }
        periodLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(dist + 30)
            make.right.equalTo(100)
            make.left.equalTo(10)
        }
        textField.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(dist + 70)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.height.equalTo(50*ScreenHS)
        }
        labelSend.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(dist + 70)
            make.right.equalTo(100)
            make.left.equalTo(10)
        }
        sendBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(dist + 110)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
        }
        sendRepeat.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(dist + 150)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
        }
    }
    
    @objc func textDidChangeNotification(textField:UITextField)  {
        print("\(textField.text)")
    }
    
    @objc func sendBtnEvent(btn:UIButton){
        let data:Data = textField.text?.data(using: .utf8) ?? Data()
        AgoraIotLink.iotsdk.deviceMgr.sendMessage(data: data, description: "this is description") { ec, msg in
            log.i("demo send message \(msg)(\(ec))")
            if(ec != ErrCode.XOK){
                AGToolHUD.showFaild(info: msg)
            }
        }
    }
    func startToPlay(btn:UIButton){
        let file = "saf"
        AGToolHUD.showNetWorkWait()
        AgoraIotLink.iotsdk.deviceMgr.startPlayback(channelName: file) { [weak self](ec, msg) in
            if(ec == ErrCode.XOK){
                AGToolHUD.disMiss()
            }
            else{
                AGToolHUD.showfaild(info: msg, dismissBlock: {})
            }
        } stateChanged: { [weak self](s, info) in
            switch(s){
            case .LocalError:
                AGToolHUD.showfaild(info: info, dismissBlock: {})
            case .RemoteJoin:
                log.i("demo ctrl state:\(info)(RemoteJoin)")
            case .RemoteLeft:
                btn.setTitle("播放sd卡", for: .normal)
                log.i("demo ctrl state:\(info)(RemoteLeft)")
            case .LocalReady:
                btn.setTitle("停止播放", for: .normal)
                log.i("demo ctrl state:\(info)(LocalReady)")
            case .VideoReady:
                AgoraIotLink.iotsdk.deviceMgr.setPlaybackView(peerView: self?.videoView)
            }
        }
    }
    @objc func playBtnEvent(btn:UIButton){
        let text:String = playBtn.titleLabel?.text ?? "";
        
        if(text ==  "播放sd卡"){
            if(AgoraIotLink.iotsdk.callkitMgr.getNetworkStatus().isBusy){
                AGAlertViewController.showTitle("提示", message: "正在通过中，需要停止通话才能播放sd卡，是否停止通话", cancelTitle: "取消", commitTitle: "确定") {[weak self] in
                    AgoraIotLink.iotsdk.callkitMgr.callHangup { ec, msg in
                        self?.startToPlay(btn: btn)
                    }
                }
            cancelAction: {[weak self] in
                }
            }
            else{
                startToPlay(btn:btn)
            }
        }
        else{
            AgoraIotLink.iotsdk.deviceMgr.stopPlayback()
            btn.setTitle("播放sd卡", for: .normal)
        }
    }
    
    var repeating:Bool = false
    var timer:Timer? = nil
    var msgCounter:Int = 0
    @objc func sendRepeatBtnEvent(btn:UIButton){
        repeating = !repeating
        btn.setTitle(repeating ? "周期发送停止" : "周期发送开始", for: .normal)
        if(repeating){
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(slider.value),repeats:true,block: { tm in
                let data:Data = self.textField.text?.data(using: .utf8) ?? Data()
                self.msgCounter = self.msgCounter + 1
                AgoraIotLink.iotsdk.deviceMgr.sendMessage(data: data, description: "this is description") { ec, msg in
                    log.i("demo send message \(msg)(\(ec))")
                    if(ec != ErrCode.XOK){
                        AGToolHUD.showHint(hint: "第" + String(self.msgCounter) + "条消息发送失败:" + msg)
                    }
                }
            })
        }
        else{
            timer?.invalidate()
            msgCounter = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let result:(Int,String)->Void = { ec, msg in
            log.level(ec == ErrCode.XOK ? .info : .error, "demo sendMessageBegin() \(msg)(\(ec))")
            if(ec != ErrCode.XOK){
                AGToolHUD.showFaild(info: msg)
            }
        }
        let statusUpdated:(MessageChannelStatus,String,Data?)->Void = { status,msg,data in
            log.i("demo sendMessage status updated:\(status),\(msg)")
            if(status == .DataArrived){
                AGToolHUD.showSuccess(info: "rtm info :\(msg)")
            }
            if(data != nil){
                log.i("demo 收到设备数据长度：" + String(data!.count))
                AGToolHUD.showSuccess(info: "rtm info :\(msg)")
            }
        }
        AgoraIotLink.iotsdk.deviceMgr.sendMessageBegin(deviceId: device!.deviceId,result:result,statusUpdated:statusUpdated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AgoraIotLink.iotsdk.deviceMgr.sendMessageEnd()
    }
}

extension DoorbellControlVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension DoorbellControlVC : UITextFieldDelegate{
    
}
