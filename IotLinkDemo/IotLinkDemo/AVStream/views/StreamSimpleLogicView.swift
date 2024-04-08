
//
//  StreamSimpleLogicView.swift
//  IotLinkDemo
//
//  Created by admin on 2023/5/29.
//
import UIKit
import AgoraIotLink
import Photos


//视频上层逻辑操作View
class StreamSimpleLogicView: UIView {
    
    var topMarginH : CGFloat = 66.VS
    let toolBarH : CGFloat = 45.VS
    
    var logicLeftBackHBlock:(() -> (Void))?
    var logicfullHorBtnBlock:(() -> (Void))?
    
    
    var callAnswerBtnBlock:(() -> (Void))? //挂断
    var callAnswerHungUpBlock:(() -> (Void))? //接听
    var logicFullScreenBlock:(() -> (Void))? //全屏
    var logicAVStreamBlock:((_ connentId:String) -> (Void))? //流媒体点击
    var logicEnableAVStreamBlock:(() -> (Void))? //开启拉流
    
    var startRecord : Bool = false //开始录屏
    var videoPath : String = ""
    
    var streamModel: MStreamModel? {
        didSet{
            guard let tempModel = streamModel else {
                return
            }
            toolBarView.streamModel = tempModel
            
            topMarginH = 40
            
            topControlView.tipsLabel.text = ""
            topControlView.nodeIdLabel.text = "streamId: \(tempModel.streamId.rawValue)"
            
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
    
    deinit {
        debugPrint("StreamSimpleLogicView 被释放了")
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
    }
    
    fileprivate lazy var topControlView:TopControTooBarSimpleView = {
        
        let view = TopControTooBarSimpleView()
        return view
    }()
    

    lazy var toolBarView:StreamTooBarSimpleView = {

        let view = StreamTooBarSimpleView()
        view.doorfullHorBtnBlock = {[weak self] button in
            if button.isSelected == false{
                self?.logicEnableAVStreamBlock?()
                self?.enableAV()
            }else{
                self?.disEnableAV()
            }
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

}

extension StreamSimpleLogicView{//下层View传值
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension StreamSimpleLogicView{

    func enableAV(){
        
        guard let streamModel = streamModel else { return }
        
        let connectObj = streamModel.connectObj
        let connentInfor = connectObj?.getInfo()
        guard  connentInfor?.mState == .connected else {
            AGToolHUD.showInfo(info: "当前未连接成功，请稍后重试")
            return
        }
        
        DoorBellManager.shared.streamSubscribeStart(streamModel.connectObj, subStreamId: streamModel.streamId, cb: {[weak self] success, msg in
            if success{
                self?.toolBarView.handelHorBtnSuccess(true)
                self?.handelMuteAudioStateText(false)
            }
         })
        streamModel.isSubcribedAV = true
    }
    
    func disEnableAV(){
        
        guard let streamModel = streamModel else { return }
        
        DoorBellManager.shared.streamRecordStop(streamModel.connectObj, subStreamId: streamModel.streamId)
        streamModel.isSubcribedAV = false
        handelStateNone()
    }
    
    //静音
    func shutDownAudio(_ btn : UIButton){
        
        guard let streamModel = streamModel else { return }
        
        guard let streamStatus = streamModel.connectObj?.getStreamStatus(peerStreamId: streamModel.streamId),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时进行静音！")
            return
        }
        
        DoorBellManager.shared.mutePeerAudio(streamModel.connectObj, subStreamId: streamModel.streamId, mute: !btn.isSelected) { success, msg in
            if success{
                log.i("设置静音成功")
                btn.isSelected = !btn.isSelected
            }
        }
    }
    
    func handelCallStateText(_ isCallSuc : Bool?){
        
        toolBarView.handelHorBtnSuccess(isCallSuc ?? false)
    }
    
    func handelMuteAudioStateText(_ isCallSuc : Bool?){
        
        toolBarView.handelMuteAudioStateText(isCallSuc ?? false)
    }
    
    //设置按钮回到初始状态
    func handelStateNone(){
        toolBarView.handelCallSuccess(false)
        toolBarView.handelMuteAudioStateText(false)
        toolBarView.handleRecordScreenBtnSuccess(false)
    }
}


extension StreamSimpleLogicView{//下层View传值
    
    func recordScreenPre(){
        
        if fetchPHAuthorization() == true{
            recordScreen()
        }
        
    }
    
    func recordScreen(){
        
        guard let streamModel = streamModel else { return }
        
        guard let streamStatus = streamModel.connectObj?.getStreamStatus(peerStreamId: streamModel.streamId),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时进行录制！")
            return
        }
        
        if startRecord == false {
            videoPath = getTempVideoUrl()
            print("videoPath:\(videoPath)")
            DoorBellManager.shared.talkingRecordStart(outFilePath:videoPath,streamModel.connectObj, subStreamId: streamModel.streamId, cb: {[weak self] success, msg in
                if success{
                    self?.toolBarView.callBtn.isSelected = true
                    self?.startRecord = true
                    debugPrint("开始录制调用成功")
                }
            })
            
        }else{
            DoorBellManager.shared.talkingRecordStop(streamModel.connectObj, subStreamId: streamModel.streamId, cb: {[weak self] success, msg in
                if success{
                    self?.toolBarView.callBtn.isSelected = false
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
                    self?.recordScreen()
                }
            }
            return false
        } else {
            return true
        }
        
    }
    
    func shotScreen(){
        
        guard let streamModel = streamModel else { return }
        
        guard let streamStatus = streamModel.connectObj?.getStreamStatus(peerStreamId: streamModel.streamId),streamStatus.mSubscribed == true else {
            log.i("recordScreen fail streamStatus status is error")
            AGToolHUD.showInfo(info: "请在正常预览视频时进行截图！")
            return
        }
        
        let imagePath = getTempImageUrl()
        DoorBellManager.shared.capturePeerVideoFrame(saveFilePath:imagePath,streamModel.connectObj, subStreamId: streamModel.streamId, cb: { [weak self] errCode, w, h in
            
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
 
//    func saveAVToAlbum(_ videoPath: String) {
//        let videoURL = URL(fileURLWithPath: videoPath)
//        
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
//        }) { success, error in
//            if success {
//                print("视频保存成功！")
//                AGToolHUD.showInfo(info: "视频保存失败！")
//            } else {
//                print("视频保存失败：\(error?.localizedDescription ?? "未知错误")")
//                AGToolHUD.showInfo(info: "视频保存失败！")
//            }
//        }
//    }

    
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

