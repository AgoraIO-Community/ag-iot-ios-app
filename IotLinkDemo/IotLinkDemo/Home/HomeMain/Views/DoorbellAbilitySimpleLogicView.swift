//
//  DoorbellAbilitySimpleLogicView.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/29.
//
import UIKit
import AgoraIotLink
import Photos

public enum VideoAlertTipType: Int{
    ///默认
    case none = 0
    ///加载中
    case loading = 1
    ///加载失败
    case loadFail = 2
    ///设备休眠
    case deviceSleep = 3
    ///已链接
    case connected = 4
    ///预览中
    case playing = 5
}

//视频上层逻辑操作View
class DoorbellAbilitySimpleLogicView: UIView {
    var isOnCalling : Bool = false //正在通话中
    
    var topMarginH : CGFloat = 66.VS
    let toolBarH : CGFloat = 45.VS
    
    var logicfullHorBtnBlock:(() -> (Void))? //发起链接
    var logicFullScreenBlock:(() -> (Void))? //全屏
    var logicAVStreamBlock:(() -> (Void))? //流媒体点击
    var logicEnableAVStreamBlock:(() -> (Void))? //开启拉流
    var logicDisableAVStreamBlock:(() -> (Void))? //停止拉流
    
    var startRecord : Bool = false //开始录屏
    var videoPath : String = ""
        
    var tipType : VideoAlertTipType{
        didSet{
            switch tipType{
            case .none:
                topControlView.tipsLabel.text = "未连接..."
                topControlView.memberLabel.text = "人数:0"
            case .loading:
                self.isOnCalling = false
                topControlView.tipsLabel.text = "呼叫中..."
                topControlView.memberLabel.text = "人数:0"
            case .loadFail:
                topControlView.tipsLabel.text = "呼叫失败"
            case .deviceSleep:
                self.isOnCalling = false
                topControlView.tipsLabel.text = "设备休眠中..."
            case .connected:
                self.isOnCalling = true
                topControlView.tipsLabel.text = "已连接"
            case .playing:
                self.isOnCalling = true
                topControlView.tipsLabel.text = "预览中..."
            }
        }
    }
    
    var device: MDeviceModel?{
        didSet{
            topControlView.device = device
        }
    }
    
    var streamModel: MStreamModel? {
        didSet{
            guard let tempModel = streamModel else {
                return
            }
            toolBarView.streamModel = tempModel
            
            topMarginH = 40
            
            topControlView.tipsLabel.text = ""
            topControlView.nodeIdLabel.text = "streamId: \(tempModel.streamId.rawValue)"
            
            avStreamBtn.isHidden = true
            rtmSendMsgBtn.isHidden = true
            fullScreenBtn.isHidden = true
            
            screenShotBtn.snp.updateConstraints{ (make) in
                make.centerY.equalToSuperview().offset(0)
            }
        }
    }
        
    override init(frame: CGRect) {
        self.tipType = .deviceSleep
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    deinit {
        debugPrint("DoorbellAbilitySimpleLogicView 被释放了")
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
            make.bottom.equalToSuperview().offset(-6.S)
            make.left.right.equalToSuperview().inset(10.S).priority(.low)
        }
        
        addSubview(saveImgAlertView)
        saveImgAlertView.snp.makeConstraints { (make) in
            make.height.equalTo(92)
            make.width.equalTo(98)
            make.bottom.equalTo(toolBarView.snp.top).offset(-42.VS)
            make.right.equalToSuperview().inset(15.S).priority(.low)
        }
        
        addSubview(avStreamBtn)
        avStreamBtn.snp.makeConstraints { (make) in
            make.left.equalTo(10.S)
            make.centerY.equalToSuperview().offset(-25)
            make.size.equalTo(CGSize.init(width: 60.S, height: 30.S))
        }
        
        addSubview(rtmSendMsgBtn)
        rtmSendMsgBtn.snp.makeConstraints { (make) in
            make.left.equalTo(10.S)
            make.centerY.equalToSuperview().offset(25)
            make.size.equalTo(CGSize.init(width: 60.S, height: 30.S))
        }

        addSubview(screenShotBtn)
        screenShotBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-10.S)
            make.centerY.equalToSuperview().offset(25)
            make.size.equalTo(CGSize.init(width: 60.S, height: 30.S))
        }
        
        addSubview(fullScreenBtn)
        fullScreenBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-10.S)
            make.centerY.equalToSuperview().offset(-25)
            make.size.equalTo(CGSize.init(width: 60.S, height: 30.S))
        }
        
        addSubview(previewBtn)
        previewBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(toolBarView.snp.top).offset(-10.VS)
            make.size.equalTo(CGSize.init(width: 80.S, height: 40.S))
        }
    }
    
    fileprivate lazy var topControlView:TopControTooBarSimpleView = {
        let view = TopControTooBarSimpleView()
        return view
    }()
    

    lazy var toolBarView:DoorbellAbilityTooBarSimpleView = {
        let view = DoorbellAbilityTooBarSimpleView()
        view.connectBtnBlock = {[weak self] button in
            if button.isSelected == false{
                self?.tipType = .loading
                self?.logicfullHorBtnBlock?()
            }else{
                self?.handUpDevice()
            }
        }
        view.converseBtnBlock = {[weak self] button in
            //本地语音通话tip
            self?.callPhone(button)
        }
        view.muteSoundBtnBlock = {[weak self] button in
            //静音
            self?.shutDownAudio(button)
        }
        view.shotScreenBtnBlock = { [weak self] in
            self?.shotScreen()
        }
        view.recordScreenBtnBlock = {[weak self] button in
            //录屏
            self?.recordScreenPre()
        }
        return view
    }()
    
    fileprivate lazy var saveImgAlertView:DoorbellSaveImgAlertView = {
        let view = DoorbellSaveImgAlertView()
        view.isHidden = true
        return view
    }()
    
    lazy var screenShotBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("截图", for:.normal)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(screenShot(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var fullScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("全屏", for:.normal)
        btn.tag = 1003
        btn.addTarget(self, action: #selector(fullScreen(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rtmSendMsgBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("消息".L, for:.normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.tag = 1004
        btn.addTarget(self, action: #selector(rtmSendMsg(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var avStreamBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("流媒体".L, for:.normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.tag = 1005
        btn.addTarget(self, action: #selector(avStreamPress(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var previewBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.red, for: .selected)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8.VS
        btn.layer.masksToBounds = true
        btn.setTitle("预览".L, for:.normal)
        btn.setTitle("停止".L, for:.selected)
        btn.tag = 1006
        btn.addTarget(self, action: #selector(previewBtnPress(btn:)), for: .touchUpInside)
        return btn
    }()
}

extension DoorbellAbilitySimpleLogicView{//下层View传值
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension DoorbellAbilitySimpleLogicView{
    //点击预览按钮
    @objc func previewBtnPress(btn : UIButton){
        debugPrint("previewBtnPress：点击")
        if btn.isSelected == false{
            logicEnableAVStreamBlock?()
            enableAV()
        }else{
            logicDisableAVStreamBlock?()
            disEnableAV()
        }
    }
    
    //点击流媒体
    @objc func avStreamPress(btn : UIButton){
        debugPrint("avStreamPress：点击")
        logicAVStreamBlock?()
    }
    
    //点击发送消息
    @objc func rtmSendMsg(btn : UIButton){
        debugPrint("rtmSendMsg：点击")
        showSendMsgAlert()
    }
    
    func showSendMsgAlert(){
        guard let device = device, let conObj = device.connectObj else {
            AGToolHUD.showInfo(info: "请先呼叫设备")
            return
        }
        
        AGConfirmEditAlertVC.showTitleTop("请输入要发送的信息", editText: "请输入要发送的信息") { msg in
            guard let paramData = msg.data(using: .utf8) else{
                AGToolHUD.showInfo(info: "消息转换失败")
                return
            }

            _ = conObj.sendMessageData(messageData: paramData)
            print("showSendMsgAlert：-----\(msg)")
        }
    }

    //点击截图
    @objc func screenShot(btn : UIButton){
        shotScreen()
    }
    
    //点击全屏
    @objc func fullScreen(btn : UIButton){
        logicFullScreenBlock?()
    }
        
    func enableAV(){
        guard let device = device else { return }
        log.i("enableAV:\(String(describing: device.connectObj))")
        let connectObj = device.connectObj
        let connentInfor = connectObj?.getInfo()
        guard  connentInfor?.mState == .connected else {
            log.i("enableAV mPeerNodeId:\(String(describing: connentInfor?.mPeerNodeId)),stare:\(String(describing: connentInfor?.mState.rawValue))")
            AGToolHUD.showInfo(info: "当前未连接成功，请稍后重试)")
            return
        }
        
        DoorBellManager.shared.streamSubscribeStart(device.connectObj, subStreamId: .BROADCAST_STREAM_1, cb: {[weak self] success, msg in
            if success{
                self?.handelMuteAudioStateText(false)
            }
         })
    }
    
    func disEnableAV(){
        guard let device = device else { return }
        DoorBellManager.shared.streamRecordStop(device.connectObj, subStreamId: .BROADCAST_STREAM_1)
        previewBtn.isSelected = false
        handelStateNone()
        self.tipType = .connected
    }
    
    //语音通话
    func callPhone(_ btn : UIButton){
        guard let device = device else { return }
        
        guard let streamStatus = device.connectObj?.getStreamStatus(peerStreamId: .BROADCAST_STREAM_1),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时进行截图！")
            return
        }
           
        var isPermitAudio : Bool = true
        debugPrint("请求通话")
        if btn.isSelected {//挂断
            debugPrint("挂断通话")
            isPermitAudio = false
        }
        DoorBellManager.shared.publishAudioEnable(device.connectObj, mute: isPermitAudio, cb: {[weak self] success, msg in
            if success{
                let isSelect = !btn.isSelected
                self?.toolBarView.handelCallSuccess(isSelect)
                self?.isOnCalling = true
                if isPermitAudio == true {//挂断电话
                    self?.isOnCalling = false
                }
            }
         })
    }
    
    //静音
    func shutDownAudio(_ btn : UIButton){
        guard let device = device else { return }
        
        guard let streamStatus = device.connectObj?.getStreamStatus(peerStreamId: .BROADCAST_STREAM_1),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时设置音放！")
            return
        }
        
        DoorBellManager.shared.mutePeerAudio(device.connectObj, subStreamId: .BROADCAST_STREAM_1, mute: !btn.isSelected) { success, msg in
            if success{
                log.i("设置静音成功")
                btn.isSelected = !btn.isSelected
            }
        }
    }
    
    //挂断设备
    func handUpDevice(){
        guard let device = device, let connectObj = device.connectObj else {
            debugPrint("挂断:device为空")
            handelCallStateText(false)
            tipType = .none
            return
        }
        let conInfor = connectObj.getInfo()
        log.i("handUpDevice: 应用层挂断 peerId:\(conInfor.mPeerNodeId)")
        DoorBellManager.shared.hungUpAnswer(connectObj) { success, msg in
            if success {
                debugPrint("挂断成功")
                AGToolHUD.showInfo(info: "挂断成功")
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
    }
    
    func handelCallStateText(_ isCallSuc : Bool?){
        toolBarView.handelHorBtnSuccess(isCallSuc ?? false)
    }
    
    func handelMuteAudioStateText(_ isCallSuc : Bool?){
        toolBarView.handelMuteAudioStateText(isCallSuc ?? false)
    }
    
    //设置预览按钮状态
    func handePreviewBtnStateText(_ isAVStreamSuc : Bool?){
        previewBtn.isSelected = isAVStreamSuc ?? false
    }
    
    func handelUserMembers(_ members : Int){
        topControlView.memberLabel.text = "人数:\(members)"
    }
    
    //设置按钮回到初始状态
    func handelStateNone(){
        previewBtn.isSelected = false
        toolBarView.handelCallSuccess(false)
        toolBarView.handelMuteAudioStateText(false)
        toolBarView.handleRecordScreenBtnSuccess(false)
    }
}


extension DoorbellAbilitySimpleLogicView{//下层View传值
    func recordScreenPre(){
        if fetchPHAuthorization() == true{
            recordScreen()
        }
    }
    
    func recordScreen(){
        guard let device = device else { return }
        
        guard let streamStatus = device.connectObj?.getStreamStatus(peerStreamId: .BROADCAST_STREAM_1),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时进行录制！")
            return
        }
        
        if startRecord == false {
            videoPath = getTempVideoUrl()
            print("startRecord：videoPath:\(videoPath)")
            DoorBellManager.shared.talkingRecordStart(outFilePath:videoPath, device.connectObj, subStreamId: .BROADCAST_STREAM_1, cb: {[weak self] success, msg in
                if success{
                    self?.toolBarView.recordBtn.isSelected = true
                    self?.startRecord = true
                    debugPrint("开始录制调用成功")
                }
            })
            
        }else{
            DoorBellManager.shared.talkingRecordStop(device.connectObj, subStreamId: .BROADCAST_STREAM_1, cb: {[weak self] success, msg in
                if success{
                    self?.toolBarView.recordBtn.isSelected = false
                    self?.startRecord = false
                    self?.saveAVToAlbum(videoPath: self?.videoPath ?? "")
                    debugPrint("停止录制调用成功")
                }
            })
        }
    }
        
    func fetchPHAuthorization()->Bool{
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            AGToolHUD.show(info: "请开启相册权限")
            return false
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization {[weak self] (status) in
                if status == .denied {
                    AGToolHUD.show(info: "请开启相册权限")
                } else if status == .authorized {
                    DispatchQueue.main.async {
                        self?.recordScreen()
                    }
                }
            }
            return false
        } else {
            return true
        }
    }
    
    func shotScreen(){
        guard let device = device else { return }
        guard let streamStatus = device.connectObj?.getStreamStatus(peerStreamId: .BROADCAST_STREAM_1),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时进行截图！")
            return
        }
        
        let imagePath = getTempImageUrl()
        DoorBellManager.shared.capturePeerVideoFrame(saveFilePath:imagePath,device.connectObj, subStreamId: .BROADCAST_STREAM_1, cb: { [weak self] errCode, w, h in
            
            if errCode == 0{
                debugPrint("截屏成功")
                guard let shotImg = UIImage(contentsOfFile: imagePath) else {
                    print("无法加载图像：\(imagePath)")
                    AGToolHUD.showInfo(info: "图片截屏失败！")
                    return
                }
                self?.saveImgToAlbum(shotImg)
                self?.handelSaveImgAlert(shotImg)
            }
        })
    }
 
    func saveAVToAlbum(videoPath: String) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath) {
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: videoPath))
                assetRequest?.creationDate = Date() // 可选：设置视频创建日期
            }) { success, error in
                if success {
                    AGToolHUD.showInfo(info: "视频保存成功")
                    print("视频保存成功")
                } else {
                    AGToolHUD.showInfo(info: "视频保存失败")
                    print("视频保存失败：\(error?.localizedDescription ?? "未知错误")")
                }
            }
        } else {
            AGToolHUD.showInfo(info: "视频保存失败")
            print("视频不兼容，无法保存到相册")
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
    
    func getTempVideoUrl() -> String {
        let videoName = String.init(format: "out_test%@.mp4", UUID().uuidString)
        let videoPath = NSString(string: recordVideoFolder).appendingPathComponent(videoName) as String

        return videoPath
    }
    
    func getTempImageUrl() -> String {
        let videoName = String.init(format: "out_test%@.jpg", UUID().uuidString)
        let videoPath = NSString(string: recordVideoFolder).appendingPathComponent(videoName) as String

        return videoPath
    }
    
    //MARK: ----- property
    var recordVideoFolder: String {//NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory
        if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            let direc = NSString(string: path).appendingPathComponent("VideoFile") as String
            if !FileManager.default.fileExists(atPath: direc) {
                try? FileManager.default.createDirectory(atPath: direc, withIntermediateDirectories: true, attributes: [:])
            }
            return direc
        }
        return ""
    }
}
