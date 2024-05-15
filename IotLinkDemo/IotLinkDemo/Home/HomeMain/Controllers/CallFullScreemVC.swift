//
//  CallFullScreemVC.swift
//  IotLinkDemo
//
//  Created by admin on 2023/6/1.
//

import UIKit
import AgoraIotLink

//添加新设备通知（蓝牙配网）
let ReceiveFirstVideoFrameNotify = "cReceiveFirstVideoFrameNotify"

class CallFullScreemVC: UIViewController {

    
    private var originBarTintColor:UIColor?
    private var originTitleTextAttributes:[NSAttributedString.Key :Any]?
    
    var videoQAlertView: VideoQAlertView?
    var CallFullScreemBlock:(() -> (Void))?
    var curTransferValue:String = ""
    
    var connectObj: IConnectionObj? {
        didSet{
            guard let connectObj = connectObj else {
                return
            }
            let statusCode : Int = connectObj.setVideoDisplayView(subStreamId: .BROADCAST_STREAM_1, displayView: videoView)
            debugPrint("statusCode:\(statusCode)")
        }
    }
    
    var transferCmdString:String?{
        didSet{
            guard let transferCmdString = transferCmdString else {
                return
            }
            curTransferValue.append("\n" + transferCmdString)
            transferResultView.text = curTransferValue
        }
        
    }
    
    var isTransferEnd:Bool?{
        didSet{
            guard let isTransferEnd = isTransferEnd else {
                return
            }
            accecptButton.isSelected = !isTransferEnd
        }
    }
    
    deinit {
        log.i("CallFullScreemVC 销毁了")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.view.backgroundColor = MainColor
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = originTitleTextAttributes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        view.backgroundColor = UIColor.lightGray
        addRightBarButtonItem()
        
        if connectObj?.isFileTransfering() == true{
            accecptButton.isSelected = true
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(remoteHangup), name: Notification.Name(cRemoteHangupNotify), object: nil)
        
//        registerMsgListener()
        
        
        // Do any additional setup after loading the view.
    }
    
//    @objc private func remoteHangup(){//收到对端挂断通知
//        navigationController?.popViewController(animated: false)
//    }
    
    // 设置UI
    private func setUpUI(){
        view.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalTo(view)
        }
        
//        view.addSubview(videoQAButton)
//        videoQAButton.snp.makeConstraints { make in
//            make.top.equalTo(80)
//            make.left.equalTo(15)
//            make.width.equalTo(80)
//            make.height.equalTo(50)
//        }
        
        view.addSubview(accecptButton)
        accecptButton.snp.makeConstraints { make in
            make.top.equalTo(videoView.snp.top).offset(30)
            make.left.equalTo(15)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
        
        let tempW = view.frame.size.width
        view.addSubview(transferResultView)
        transferResultView.snp.makeConstraints { make in
            make.top.equalTo(accecptButton.snp.bottom).offset(20)
            make.left.equalTo(15)
            make.width.equalTo(tempW-35)
            make.height.equalTo(450)
        }
    }
    
    lazy var videoView:UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var accecptButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("开始传输", for: .normal)
        button.setTitle("结束传输", for: .selected)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 50 * 0.5
        button.layer.masksToBounds = true
        button.isSelected = false
        button.addTarget(self, action: #selector(sendMsgButton(btn:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoQAButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("视频质量", for: .normal)
        button.setTitle("关闭弹框", for: .selected)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .lightGray
//        button.layer.cornerRadius = 50 * 0.5
//        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(videoQAButtonPress), for: .touchUpInside)
        return button
    }()
    
    private lazy var transferResultView:UITextView = {
        
        let  textView = UITextView()
        textView.text = ""
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = UIColor.green
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isScrollEnabled = true
        
        return textView
        
    }()
    
    @objc private func videoQAButtonPress(){
        
//        if videoQAlertView == nil {
//            videoQAlertView = VideoQAlertView(frame: CGRect.zero)
//            videoQAlertView?.connectId = connectId11
//            view.addSubview(videoQAlertView!)
//        } else {
//            videoQAlertView?.removeFromSuperview()
//            videoQAlertView = nil
//        }
        
    }

    @objc private func sendMsgButton(btn:UIButton){

        guard let connectObj = connectObj  else { return }
        
//        // 订阅 UNICAST_STREAM_3 这个流的音视频数据，订阅时还可以附加简短的消息通知到对端
//        // 应用层可以根据自己的业务需求定义这种简短消息格式，例如：指定播放文件名，开始播放位置等
//        connectObj.streamSubscribeStart(peerStreamId: .UNICAST_STREAM_3, attachMsg: "file=13.mp4; pos=5000") { errCode, msg in }
//        
//        // 设置 UNICAST_STREAM_3这个流的视频帧显示控件，如果不设置，默认不显示视频帧
//        connectObj.setVideoDisplayView(subStreamId: .UNICAST_STREAM_3, displayView: mVideoView)
//        
//        // 设置UNICAST_STREAM_3这个流的音频播放是否静音，如果不设置，默认静音不播放
//        connectObj.muteAudioPlayback(subStreamId: .UNICAST_STREAM_3, previewAudio: false) { errCode, msg in }
//        
//        // 设置 UNICAST_STREAM_3这个流的音频播放播放音量，默认是100，原始音量播放
//        connectObj.setAudioPlaybackVolume(subStreamId: .UNICAST_STREAM_3, volumeLevel: 120) { errCode, msg in }
//        
//        // 取消订阅 UNICAST_STREAM_3 这个流的音视频数据
//        // 取消订阅后，不能再收看相应流的音视频数据，相应属性(是否禁音、音量、显示控件等) 都恢复默认值
//        connectObj.streamSubscribeStop(peerStreamId: .UNICAST_STREAM_3)
        
        
        
        if btn.isSelected == false {
            let ret = connectObj.fileTransferStart(startMessage: "file1;file2;file3")
            if ret == ErrCode.XOK {
                btn.isSelected = !btn.isSelected
            }else{
                AGToolHUD.showInfo(info: "开始传输失败:\(String(describing: ret))")
            }
            print("sendMsgButton : ret :\(String(describing: ret))")
        }else{
            if connectObj.isFileTransfering() {
                connectObj.fileTransferStop()
            }
            btn.isSelected = false
        }
        
    }
    
    func registerMsgListener(){
//        sdk?.callkitMgr.onReceivedCommand(receivedListener: { connectId, cmd in
//            debugPrint("onReceivedCommand:connectId:\(connectId),cmd:\(cmd)")
//            AGToolHUD.showInfo(info: cmd)
//        })
    }
    
    private func addRightBarButtonItem() {
        navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "doorbell_back")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
    }
    
    @objc func leftBtnDidClick(){
        CallFullScreemBlock?()
        navigationController?.popViewController(animated: false)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // 隐藏 VideoQAlertView
        if videoQAlertView != nil {
            videoQAlertView?.removeFromSuperview()
            videoQAlertView = nil
        }
    }
}


class VideoQAlertView: UIView {
    
    var connectId : String?{
        didSet{
            guard let tempConnectId = connectId else { return }
        }
    }
    
    var videoQAlertViewBlock:((_ sendBtn:UIButton) -> (Void))?
    
    let originalVideoButton = UIButton()
    var superResolutionButtons = [UIButton]()
    let superQualityButton = UIButton()
    let qualityLabel = UILabel()
    let qualitySlider = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        // 设置 VideoQAlertView 的宽度和高度为屏幕的三分之二
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        self.frame = CGRect(x: 0, y: screenHeight * 1 / 2, width: screenWidth, height: screenHeight * 1 / 2)
        
        // 添加原视频按钮
        originalVideoButton.setTitle("原视频", for: .normal)
        originalVideoButton.backgroundColor = UIColor.lightGray
        originalVideoButton.tag = 1
        originalVideoButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        addSubview(originalVideoButton)
        
        // 添加四个倍数超分按钮
        let titles = ["1倍超分", "1.33倍", "1.5倍", "2倍"]
        for (index, title) in titles.enumerated() {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.tag = index + 2
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.backgroundColor = UIColor.lightGray
            superResolutionButtons.append(button)
            addSubview(button)
        }
        
        // 添加超级画质按钮
        superQualityButton.setTitle("超级画质", for: .normal)
        superQualityButton.backgroundColor = UIColor.lightGray
        superQualityButton.tag = 6
        superQualityButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        addSubview(superQualityButton)
        
        // 添加画质深度 Label 和 UISlider
        qualityLabel.text = "画质深度: 0"
        qualityLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(qualityLabel)
        
        qualitySlider.minimumValue = 0
        qualitySlider.maximumValue = 256
        qualitySlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        qualitySlider.addTarget(self, action: #selector(sliderValueEnded(_:)), for: .touchUpInside)
        addSubview(qualitySlider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 设置各个控件的布局
        let buttonWidth = self.bounds.width / 4
        let buttonHeight : CGFloat = 50.0
        let space : CGFloat = 20.0
        
        originalVideoButton.frame = CGRect(x: 15, y: space, width: 80, height: buttonHeight)
        
        for (index, button) in superResolutionButtons.enumerated() {
            button.frame = CGRect(x: 10 + CGFloat(index) * buttonWidth + CGFloat(5*index), y: buttonHeight + space*2, width: buttonWidth, height: CGFloat(buttonHeight))
        }
        
        superQualityButton.frame = CGRect(x: 10, y: buttonHeight * 2 + space*3, width: buttonWidth+20, height: buttonHeight)
        
        qualityLabel.frame = CGRect(x: 10, y: buttonHeight * 3 + space*4, width: 110, height: buttonHeight)
        qualitySlider.frame = CGRect(x: 120, y:buttonHeight * 3 + space*4, width: self.bounds.width - 130, height: buttonHeight)
    }
    
    @objc func buttonTapped(_ sender:UIButton) {
        
        
        // 恢复其他按钮的颜色
        self.originalVideoButton.backgroundColor = .lightGray
        self.originalVideoButton.isSelected = false
        
        self.superResolutionButtons.forEach { $0.backgroundColor = .lightGray; $0.isSelected = false }
        
        self.superQualityButton.backgroundColor = .lightGray
        self.superQualityButton.isSelected = false
        
        sender.backgroundColor = .black
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
        case 1:
            print("原视频按钮被点击了")
            setSuperResolutionDefault()
        case 2:
            print("1倍超分按钮被点击了")
            setSuperResolutionValue(mSrDegree: .srDegree_100)
        case 3:
            print("1.33倍超分按钮被点击了")
            setSuperResolutionValue(mSrDegree: .srDegree_133)
        case 4:
            print("1.5倍超分按钮被点击了")
            setSuperResolutionValue(mSrDegree: .srDegree_150)
        case 5:
            print("2倍超分按钮被点击了")
            setSuperResolutionValue(mSrDegree: .srDegree_200)
        case 6:
            print("超级画质按钮被点击了")
        default:
            break
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        print("Slider value changed: \(sender.value)")
        qualityLabel.text = "画质深度: \(sender.value)"
    }
    
    @objc func sliderValueEnded(_ sender: UISlider) {
        print("Slider value ended: \(sender.value)")
        if self.superQualityButton.isSelected == true{
            setSuperQualityValue(sliderValue: sender.value)
        }
    }
    
    func setSuperResolutionDefault(){
//        let connectionObj = sdk?.connectionMgr.getConnectionObj(connectionId: connectId ?? "")
//        let videoQAparam = VideoQualityParam()
//        videoQAparam.mQualityType = .normal
//        let ret = connectionObj?.setPreviewVideoQuality(subStreamId: .PUBLIC_STREAM_1, videoQuality:videoQAparam )
//        if ret == 0{
//            AGToolHUD.showInfo(info: "设置成功！")
//        }else{
//            AGToolHUD.showInfo(info: "设置失败！ errcode:\(String(describing: ret))")
//        }
        
    }
    
    func setSuperResolutionValue(mSrDegree : VideoSuperResolution){
//        let connectionObj = sdk?.connectionMgr.getConnectionObj(connectionId: connectId ?? "")
//        let videoQAparam = VideoQualityParam()
//        videoQAparam.mQualityType = .sr
//        videoQAparam.mSrDegree = mSrDegree
//        let ret = connectionObj?.setPreviewVideoQuality(subStreamId: .PUBLIC_STREAM_1, videoQuality:videoQAparam )
//        if ret == 0{
//            AGToolHUD.showInfo(info: "设置成功！")
//        }else{
//            AGToolHUD.showInfo(info: "设置失败！ errcode:\(String(describing: ret))")
//        }
    }
    
    func setSuperQualityValue(sliderValue : Float){
//        let connectionObj = sdk?.connectionMgr.getConnectionObj(connectionId: connectId ?? "")
//        let videoQAparam = VideoQualityParam()
//        videoQAparam.mQualityType = .si
//        videoQAparam.mSiDegree = Int(sliderValue)
//        let ret = connectionObj?.setPreviewVideoQuality(subStreamId: .PUBLIC_STREAM_1, videoQuality:videoQAparam )
//        if ret == 0{
//            AGToolHUD.showInfo(info: "设置成功！")
//        }else{
//            AGToolHUD.showInfo(info: "设置失败！ errcode:\(String(describing: ret))")
//        }
    }
    
}

