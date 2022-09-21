//
//  DoorbellPlayerView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/6.
//

import UIKit
import SJVideoPlayer

private let kDoorbellPlayerViewTagDefination = 1000
private let kDoorbellPlayerViewTagFullScreen = 1001
private let kDoorbellPlayerViewTagMute = 1002

class DoorbellPlayerView: UIView {
    
    var clickDeleteButtonAction:(()->(Void))?
    
    var clickDownloadButtonAction:(()->(Void))?
    
    var clickDefinationButtonAction:(()->(Void))?
    
    var isDownloading = false {
        didSet {
            self.bottomView.downloadButton.isEnabled = !isDownloading
        }
    }
    
    var quantityValue : Int = 0 {
        didSet{
            powerView.progressValue = CGFloat(quantityValue) / CGFloat(100)
        }
    }
    
    var defination: Int = 0 {
        didSet {
            definationButton.setTitle(defination == 0 ? "SD":"HD", for: .normal)
        }
    }
    
    private var isRotation = false
    
    private lazy var fullscreenItem:SJEdgeControlButtonItem = {
        let fullscreenItem = SJEdgeControlButtonItem(image: UIImage(named: "msg_fullscreen"), target: self, action: #selector(didClickFullScreenButton), tag: kDoorbellPlayerViewTagFullScreen)
        return fullscreenItem
    }()
    
    private lazy var definationButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("SD", for:.normal)
        btn.setTitleColor(UIColor.init(hexString: "#F3F3F3"), for: .normal)
        btn.titleLabel?.font = FontPFRegularSize(10)
        btn.layer.cornerRadius = 3.S
        btn.layer.borderColor = UIColor.init(hexString: "#979797").cgColor
        btn.layer.borderWidth = 1.S
        btn.addTarget(self, action: #selector(didClickDefinationButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var definationItem:SJEdgeControlButtonItem = {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 68, height: 21))
        customView.addSubview(definationButton)
        definationButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
        let item = SJEdgeControlButtonItem(customView: customView, tag: kDoorbellPlayerViewTagDefination)
        return item
    }()
    
    private lazy var powerView:VipProgressView = {
        let progressV = VipProgressView.init(frame: CGRect.init(x: 0, y: 0, width: 29.S, height: 13.S))
        return progressV
    }()
    
    private lazy var customBackBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "doorbell_back"), for: .normal)
        btn.addTarget(player, action: Selector(("_backButtonWasTapped")), for: .touchUpInside)
        return btn
    }()
    
    private lazy var muteItem:SJEdgeControlButtonItem = {
        let muteItem = SJEdgeControlButtonItem(image: UIImage(named: "msg_voiceon"), target: self, action: #selector(didClickMuteScreenButton), tag: kDoorbellPlayerViewTagMute)
        return muteItem
    }()
    
    private lazy var topView:DoorbellPlayerTopView = {
        let topView = DoorbellPlayerTopView()
        topView.backgroundColor = .red
        topView.clickFullScreenButtonAction = { [weak self] in
            if self == nil { return }
            self!.player.onlyFitOnScreen = true
            self!.player.isFitOnScreen = !self!.player.isFullscreen
        }
        topView.clickMuteButtonAction = { [weak self] in
            
        }
        return topView
    }()
    
    private lazy var rightView: DoorbellPlayerBottomView = {
        return createControlView()
    }()
    
    private lazy var bottomView:DoorbellPlayerBottomView = {
        return createControlView()
    }()
    
    lazy var player:SJVideoPlayer = {
        let player = SJVideoPlayer()
        player.defaultEdgeControlLayer.isHiddenBackButtonWhenOrientationIsPortrait = true
        player.isPausedInBackground = true
        player.resumePlaybackWhenAppDidEnterForeground = true
        player.onlyFitOnScreen = false
        player.defaultEdgeControlLayer.bottomAdapter.removeItem(forTag: SJEdgeControlLayerBottomItem_Separator)
        player.defaultEdgeControlLayer.bottomAdapter.exchangeItem(forTag: SJEdgeControlLayerBottomItem_DurationTime, withItemForTag: SJEdgeControlLayerBottomItem_Progress)
        player.defaultEdgeControlLayer.bottomAdapter.removeItem(forTag: SJEdgeControlLayerBottomItem_Play)
        player.defaultEdgeControlLayer.bottomAdapter.removeItem(forTag: SJEdgeControlLayerBottomItem_Full)
        player.defaultEdgeControlLayer.isHiddenBottomProgressIndicator = true
        // 占位图
//        player.presentView.placeholderImageView.image = UIImage(named: "msg_preview_placeholder")
//        player.defaultEdgeControlLayer.bottomHeight = 150
//        player.defaultEdgeControlLayer.topHeight = 80
        
        // 竖屏全屏后允许旋转
        player.allowsRotationInFitOnScreen = true
        
        // 允许剪切
        player.defaultEdgeControlLayer.isEnabledClips = true
        player.defaultEdgeControlLayer.clipsConfig.saveResultToAlbum = true
        player.defaultEdgeControlLayer.clipsConfig.disableScreenshot = true
        player.defaultEdgeControlLayer.clipsConfig.disableGIF = true
        
        // 隐藏锁
        player.defaultEdgeControlLayer.leftAdapter.isHidden = true
        
        // 监听播放结束
        player.playbackObserver.playbackDidFinishExeBlock = { [weak self]_ in
            self?.updatePlayButtonStatus()
        }
        
        // 监听播放状态改变
        player.playbackObserver.playbackStatusDidChangeExeBlock = { [weak self] _ in
            self?.updatePlayButtonStatus()
        }
        
        player.playbackObserver.assetStatusDidChangeExeBlock = { [weak player] _ in
            debugPrint("assetStatusDidChangeExeBlock:\(player?.assetStatus.rawValue)")
        }
        // 禁用手势
        player.gestureRecognizerShouldTrigger = { player,type,location in
            return false
        }
        // 不自动隐藏控制层
        player.controlLayerAppearManager.needAppear()
        player.controlLayerAppearManager.isDisabled = true
        
        player.rotationObserver.onRotatingChanged = { [weak self] (mgr,isRotationing) in
                    if self == nil {return}
                    if isRotationing == true{
                        self!.isRotation = !self!.isRotation
                        self!.player.defaultEdgeControlLayer.bottomAdapter.isHidden = self!.isRotation
                        self!.fullscreenItem.isHidden = self!.isRotation
                        //self!.showRightView()
                    }else{
                        self!.switchForRotation()
                    }
                }
        
        // 监听屏幕旋转
//        player.rotationObserver.rotationDidStartExeBlock = { [weak self] mgr in
//            if self == nil {return}
//            self!.isRotation = !self!.isRotation
//            self!.player.defaultEdgeControlLayer.bottomAdapter.isHidden = self!.isRotation
//            self!.fullscreenItem.isHidden = self!.isRotation
//            self!.showRightView()
//        }
        player.fitOnScreenObserver.fitOnScreenDidEndExeBlock = {[weak self] mgr in
            self?.switchForFullScreen()
        }
//
//        player.rotationObserver.rotationDidEndExeBlock = { [weak self] mgr in
//            self?.switchForRotation()
//        }
        
        return player
    }()
    
    private lazy var playerContainerView:UIView = {
        return UIView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews(){
        
        addSubview(playerContainerView)
        playerContainerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(300.S)
        }
        
        playerContainerView.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
//        player.defaultEdgeControlLayer.topAdapter.add(definationItem)
        player.defaultEdgeControlLayer.topAdapter.add(muteItem)
//        player.defaultEdgeControlLayer.topAdapter.add(fullscreenItem)
        player.defaultEdgeControlLayer.topAdapter.removeItem(forTag: SJEdgeControlLayerTopItem_Back)
        player.defaultEdgeControlLayer.topAdapter.reload()
        
        player.defaultEdgeControlLayer.topContainerView.addSubview(powerView)
        powerView.snp.makeConstraints { (make) in
            make.left.equalTo(24.S)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 29.S, height: 13.S))
        }
        powerView.progressValue = 0.0
        
        player.defaultEdgeControlLayer.topContainerView.addSubview(customBackBtn)
        customBackBtn.snp.makeConstraints { make in
            make.right.equalTo(powerView.snp.left).offset(-20)
            make.centerY.equalTo(powerView)
            make.width.height.equalTo(40)
        }
        
        switchForFullScreen()
    }
    
    private func switchForFullScreen() {
        bottomView.removeFromSuperview()
        let fullScreen = player.isFitOnScreen
        if fullScreen {
            player.defaultEdgeControlLayer.bottomHeight = 150
            player.defaultEdgeControlLayer.bottomAdapter.addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(56)
            }
            powerView.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(safeAreaTopSpace() * 0.5)
                make.left.equalToSuperview().offset(80.S)
            }
            customBackBtn.isHidden = false
            
        }else{
            player.defaultEdgeControlLayer.bottomHeight = 49
            addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(56)
                make.top.equalTo(playerContainerView.snp.bottom)
            }
            
            powerView.snp.updateConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(24.S)
            }
            customBackBtn.isHidden = true
        }
    }
    
    private func switchForRotation() {
        if player.currentOrientation.isLandscape {
            customBackBtn.isHidden = false
            player.needHiddenStatusBar()
            powerView.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(10)
                make.left.equalToSuperview().offset(80.S)
            }
        }
//        else if player.isFitOnScreen {
//            customBackBtn.isHidden = false
//            powerView.snp.updateConstraints { make in
//                make.centerY.equalToSuperview().offset(safeAreaTopSpace() * 0.5)
//                make.left.equalToSuperview().offset(80.S)
//            }
//        }
    else{
            customBackBtn.isHidden = true
            powerView.snp.updateConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(24.S)
            }
        }
    }
    
    private func updatePlayButtonStatus() {
        bottomView.playButton.isSelected = player.isPaused
        rightView.playButton.isSelected = player.isPaused
    }
    
    func showRightView(){
        if rightView.superview == nil {
            rightView.isRotation = true
            player.defaultEdgeControlLayer.rightContainerView.addSubview(rightView)
            rightView.snp.makeConstraints { make in
                make.left.right.bottom.top.equalToSuperview()
            }
        }
        rightView.isHidden = !isRotation
    }
    
    private func createControlView() -> DoorbellPlayerBottomView{
            let bottomView = DoorbellPlayerBottomView()
            bottomView.clickRotationButtonAction = {[weak self] in
                if self == nil { return }
                self!.player.onlyFitOnScreen = false
                self!.player.rotate()
            }
            
            bottomView.clickPlayButtonAction = {[weak self] in
                if self == nil {return }
                self!.player.isPaused ? self!.player.play() : self!.player.pauseForUser()
            }
            
            bottomView.clickClipsButtonAction = {[weak self] in
                if self == nil {return }
                self!.player.defaultClipsControlLayer.config = self!.player.defaultEdgeControlLayer.clipsConfig
                self!.player.switcher.switchControlLayer(forIdentifier: SJControlLayer_Clips)
                self!.player.defaultClipsControlLayer.perform(NSSelectorFromString("exportVideoItemWasTapped"), with: nil, afterDelay: 0)
            }
            bottomView.clickDeleteButtonAction = {[weak self] in
                self?.clickDeleteButtonAction?()
            }
            
            bottomView.clickDownloadButtonAction = {[weak self] in
                self?.clickDownloadButtonAction?()
            }
            
            return bottomView
    }
    
    @objc private func didClickDefinationButton(_ button: UIButton){
        self.clickDefinationButtonAction?()
    }
    
    // 全屏
    @objc private func didClickFullScreenButton(){
        self.player.onlyFitOnScreen = true
        self.player.isFitOnScreen = !self.player.isFitOnScreen
    }
    
    // 静音
    @objc private func didClickMuteScreenButton(){
        self.player.isMuted = !self.player.isMuted
        muteItem.image = self.player.isMuted ? UIImage(named: "msg_voiceoff") : UIImage(named: "msg_voiceon")
        player.defaultEdgeControlLayer.topAdapter.reload()
    }
    
    func pause() {
        player.pauseForUser()
    }
    
    func play() {
        player.play()
    }
}
