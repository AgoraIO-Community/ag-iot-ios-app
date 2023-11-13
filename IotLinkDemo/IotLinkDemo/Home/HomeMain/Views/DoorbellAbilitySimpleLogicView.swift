//
//  DoorbellAbilitySimpleLogicView.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/29.
//
import UIKit
import AgoraIotLink
import Photos
import IJKMediaFramework


//视频上层逻辑操作View
class DoorbellAbilitySimpleLogicView: UIView {
    
    var isOnCalling : Bool = false //正在通话中
    var isChangeSodSeting : Bool = false //正在变声设置中
    
    let topMarginH : CGFloat = 66.VS
    let toolBarH : CGFloat = 45.VS
    
    var logicLeftBackHBlock:(() -> (Void))?
    var logicfullHorBtnBlock:(() -> (Void))?
    
    
    var callAnswerBtnBlock:(() -> (Void))? //挂断
    var callAnswerHungUpBlock:(() -> (Void))? //接听
    var logicFullScreenBlock:(() -> (Void))?
    
    var startRecord : Bool = false //开始录屏
    
//    let downShared = AvConverManager.shared()//转码下载
        
    var tipType : VideoAlertTipType{
        didSet{
            switch tipType{
            case .none:
                topControlView.tipsLabel.text = "设备在线..."
                topControlView.memberLabel.text = "人数:0"
            case .loading:
                self.isOnCalling = false
                topControlView.tipsLabel.text = "呼叫中..."
                topControlView.memberLabel.text = "人数:0"
            case .loadFail:
                topControlView.tipsLabel.text = "呼叫失败"
            case .deviceOffLine:
                self.isOnCalling = false
                topControlView.tipsLabel.text = "设备离线"
            case .deviceSleep:
                self.isOnCalling = false
                topControlView.tipsLabel.text = "设备休眠中..."
            case .playing:
                self.isOnCalling = true
                topControlView.tipsLabel.text = "正在通话中..."
            }
        }
    }
    var device: MDeviceModel?{
        didSet{
            topControlView.device = device
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
            make.bottom.equalToSuperview().offset(-6.S)
            make.left.right.equalToSuperview().inset(15.S).priority(.low)
        }
        
        addSubview(saveImgAlertView)
        saveImgAlertView.snp.makeConstraints { (make) in
            make.height.equalTo(92)
            make.width.equalTo(98)
            make.bottom.equalTo(toolBarView.snp.top).offset(-42.VS)
            make.right.equalToSuperview().inset(15.S).priority(.low)
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
        
        addSubview(leftBackHView)
        leftBackHView.snp.makeConstraints { (make) in
            make.width.equalTo(76)
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    fileprivate lazy var topControlView:TopControTooBarSimpleView = {
        
        let view = TopControTooBarSimpleView()
        return view
    }()
    

    fileprivate lazy var toolBarView:DoorbellAbilityTooBarSimpleView = {

        let view = DoorbellAbilityTooBarSimpleView()
        view.doorfullHorBtnBlock = {[weak self] button in
            if button.isSelected == false{
                self?.tipType = .loading
                self?.logicfullHorBtnBlock?()
                print("呼叫 呼叫按钮点击：\(button.isSelected)")
            }else{
                self?.handUpDevice()
                print("挂断 呼叫按钮点击：\(button.isSelected)")
            }
        }
        view.callBtnBlock = {[weak self] button in
            //本地语音通话tip
            self?.callPhone(button)
        }
        view.changeSoundBtnBlock = {[weak self] button in
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

}

extension DoorbellAbilitySimpleLogicView{//下层View传值
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension DoorbellAbilitySimpleLogicView{
    
    //点击截图
    @objc func screenShot(btn : UIButton){
//        guard let device = device, device.sessionId != "" else { return }
//        DoorBellManager.shared.previewStart(sessionId: device.sessionId) {[weak self] sessionId, videoWidth, videoHeight in
//            debugPrint("start:收到首帧")
//        }
//        return
        
        shotScreen()
    }
    
    //点击全屏
    @objc func fullScreen(btn : UIButton){
//        guard let device = device, device.sessionId != "" else { return }
//        DoorBellManager.shared.previewStop(sessionId: device.sessionId) { suc, msg in
//            debugPrint("previewStop:回调")
//        }
//        return
        
        logicFullScreenBlock?()
    }
    
    func callPhone(_ btn : UIButton){
        
        guard let device = device, device.sessionId != "" else { return }
        
        var isPermitAudio : Bool = false
        debugPrint("请求通话")
        if btn.isSelected {//挂断
            debugPrint("挂断通话")
            isPermitAudio = true
        }
        DoorBellManager.shared.muteLocalAudio(sessionId:device.sessionId,mute: isPermitAudio) {[weak self] success, msg in
            if success{
                debugPrint("请求通话/或者挂断 成功")
                let isSelect = !btn.isSelected
                self?.toolBarView.handelCallSuccess(isSelect)
                self?.isOnCalling = true
                if isPermitAudio == true {//挂断电话
                    //通话结束变声通话置为正常
                    self?.isOnCalling = false
                }
                
            }
         }
    }
    
    //静音
    func shutDownAudio(_ btn : UIButton){
        
        guard let device = device, device.sessionId != "" else { return }
        
        var isShutAudio : Bool = true
        if btn.isSelected {
            isShutAudio = false
        }
        
//        DoorBellManager.shared.mutePeerAudio(sessionId:device.sessionId ,mute: isShutAudio) { success, msg in
//            if success{
//                log.i("设置静音成功")
//                btn.isSelected = !btn.isSelected
//            }
//         }
        DoorBellManager.shared.mutePeerVideo(sessionId:device.sessionId ,mute: isShutAudio) { success, msg in
            if success{
                log.i("设置视频成功")
                btn.isSelected = !btn.isSelected
            }
         }
        
        logicFullScreenBlock?()
       

    }
    
    //变声恢复正常声音
    func changeSoundNormal(){
        
        DoorBellManager.shared.setAudioEffect(effectId: .NORMAL) { [weak self] success, msg in
            if success {
                debugPrint("变声恢复正常声音: 成功")
                self?.toolBarView.handleChangeSoundSuccess(false)
                TDUserInforManager.shared.curEffectId = .NORMAL
            }
        }
    }
    
    //挂断设备
    func handUpDevice(){
        guard let sessionId = device?.sessionId else {
            debugPrint("（DoorbellAbilitySimpleLogicView.swift）handUpDevice：挂断:sessionId为空:\(device?.sessionId ?? "")")
            return
        }
        DoorBellManager.shared.hungUpAnswer(sessionId: sessionId) { success, msg in
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
    
    func handelUserMembers(_ members : Int){
        topControlView.memberLabel.text = "人数:\(members)"
    }
    
    //设置按钮回到初始状态
    func handelStateNone(){
        toolBarView.handelCallSuccess(false)
        toolBarView.handleChangeSoundSuccess(false)
        toolBarView.handleRecordScreenBtnSuccess(false)
    }
}


extension DoorbellAbilitySimpleLogicView{//下层View传值
    
    func recordScreenPre(){
        
//        //测试文件转码下载
//        openDownLoadManger()
        
        //todo:暂时注释
        if fetchPHAuthorization() == true{
            recordScreen()
        }
        
    }
    
    func recordScreen(){
        
        guard let device = device, device.sessionId != "" else { return }
        
//        DoorBellManager.shared.sendCmdSDCtrl(sessionId: device.sessionId,  cb: { code, msg in
//            debugPrint("sendCmdSDCtrl成功 : \(msg)")
//        })
//
//        return
        
        if startRecord == false {
            let videoPath = getTempVideoUrl()
            print("videoPath:\(videoPath)")
            DoorBellManager.shared.talkingRecordStart(outFilePath:videoPath,sessionId: device.sessionId) {[weak self] success, msg in
                if success{
                    self?.toolBarView.callBtn.isSelected = true
                    self?.startRecord = true
                    debugPrint("开始录制调用成功")
                }
            }
            
        }else{
            DoorBellManager.shared.talkingRecordStop(sessionId: device.sessionId) {[weak self] success, msg in
                if success{
                    self?.toolBarView.callBtn.isSelected = false
                    self?.startRecord = false
                    debugPrint("停止录制调用成功")
                }
            }
        }
    }
    
    func openDownLoadManger(){
        
        let cvtParam = MediaCvtParam()
        let pathString = getTempVideoUrl()
        cvtParam.mDstFilePath = pathString
        //"https://stream-media.s3.cn-north-1.jdcloud-oss.com/0000000/output.m3u8"
        cvtParam.mSrcFileUrl = "https://stream-media.s3.cn-north-1.jdcloud-oss.com/0000000/output.m3u8"
        AvConverManager.shared()?.convert(with:cvtParam, onMediaCvtOpenDoneBlock: { reParam, errCode in
            debugPrint("openDownLoadManger:文件打开成功")
        }, onMediaConvertingDoneBlock: { reParam, durtion in
            debugPrint("openDownLoadManger:文件转换完成")
        }, onMediaConvertingError: { reParam, errCode in
            debugPrint("openDownLoadManger:文件转换失败，errCode：\(errCode)")
        })
        
    }
    
    func getTempVideoUrl() -> String {
        let videoName = String.init(format: "out_test%@.mp4", UUID().uuidString)
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
                    self?.recordScreen()
                }
            }
            return false
        } else {
            return true
        }
        
    }
    
    func shotScreen(){
        
//        DoorBellManager.shared.disConnectDevice(sessionId:device?.sessionId ?? "")
//        sdk?.release()
//        return
        
        
        guard let device = device, device.sessionId != "" else { return }
        
        
        //-------------- 测试发送SD卡回看命令----------------
//        DoorBellManager.shared.sendCmdSDCtrl(sessionId: device.sessionId,  cb: { code, msg in
//            debugPrint("sendCmdSDCtrl成功 : \(msg)")
//        })
//
//        return
        
        //-------------- 测试发送控制命令----------------
//        DoorBellManager.shared.sendCmdPtzCtrl(sessionId: device.sessionId,  cb: { code, msg in
//            debugPrint("sendCmdPtzCtrl成功 : \(msg)")
//        })
//
//        return
        
//        let queryParam = QueryParam(mFileId: "0", mBeginTimestamp: 0, mEndTimestamp: 20)
//        
//        let curTimestamp:UInt32 = 1000
//        let commanId:Int = 2012
//        let paramDic = ["sequenceId": curTimestamp, "commandId": commanId] as [String : Any]
//        
//        let jsonData = paramDic.convertDictionaryToJSONString()
//        DoorBellManager.shared.sendDevRawCustomData(sessionId: device.sessionId, customData:jsonData) { errCode, msg in
//            debugPrint("sendDevRawCustomData : \(msg)")
//        }
//          return
        
        
//        startRecord = !startRecord

        DoorBellManager.shared.capturePeerVideoFrame(sessionId:device.sessionId) { [weak self] success, msg, shotImg in
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
