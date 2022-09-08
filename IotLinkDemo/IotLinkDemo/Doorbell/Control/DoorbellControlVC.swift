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
    
    private func setupUI(){
        //view.addSubview(textToSend)
        view.addSubview(periodLabel)
        view.addSubview(sliderLabel)
        view.addSubview(slider)
        view.addSubview(labelSend)
        view.addSubview(textField)
        view.addSubview(sendBtn)
        view.addSubview(sendRepeat)

        slider.addTarget(self, action: #selector(self.SliderChanged), for: .valueChanged)
        
        slider.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(-120)
            make.centerX.equalToSuperview()
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.height.equalTo(30*ScreenHS)
        }
        sliderLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(-90)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.height.equalTo(30)
        }
        periodLabel.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(-90)
            make.right.equalTo(100)
            make.left.equalTo(10)
        }
        textField.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
            make.height.equalTo(50*ScreenHS)
        }
        labelSend.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(-40)
            make.right.equalTo(100)
            make.left.equalTo(10)
        }
        sendBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.left.equalTo(100)
            make.right.equalTo(-100)
        }
        sendRepeat.snp.makeConstraints{ make in
            make.centerY.equalToSuperview().offset(75)
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
        AgoraIotLink.iotsdk.deviceMgr.sendMessageBegin(device: device!) { ec, msg in
            log.level(ec == ErrCode.XOK ? .info : .error, "demo sendMessageBegin() \(msg)(\(ec))")
            if(ec != ErrCode.XOK){
                AGToolHUD.showFaild(info: msg)
            }
        } statusUpdated: { status,msg,data in
            if(status == .DataArrived){
                log.i("demo sendMessage status updated:\(status),\(msg)")
                AGToolHUD.showSuccess(info: "rtm info :\(msg)")
            }
            else if(data != nil){
                log.i("demo 收到设备数据长度：" + String(data!.count))
                AGToolHUD.showSuccess(info: "rtm info :\(msg)")
            }
        }
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
