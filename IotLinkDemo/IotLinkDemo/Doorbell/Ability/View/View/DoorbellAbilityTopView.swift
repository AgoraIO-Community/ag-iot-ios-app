//
//  DoorbellAbilityTopView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit
import AgoraIotLink

protocol DoorbellAbilityTopViewDelegate : NSObjectProtocol{
    
    //视频异常视图回调
    func reCallBtnClick()
    func checkDeviceBtnClick()
    func resetDeviceBtnClick()
    
}

class DoorbellAbilityTopView: UIView {

    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    let videoH : CGFloat = 200.VS
    let topMarginH : CGFloat = 66.VS
    let bottomMarginH : CGFloat = 16.VS
    let toolBarH : CGFloat = 56.VS
    
    weak var delegate : DoorbellAbilityTopViewDelegate?
    
    var fullHBtnClickBlock:(() -> (Void))?
    var backVBtnClickBlock:(() -> (Void))?
    
    var device: IotDevice?{
        didSet{
            logicView.device = device
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
        
        addSubview(videoParentView)
        videoParentView.snp.makeConstraints { make in
            make.top.equalTo(topMarginH)
            make.left.right.equalToSuperview()
            make.height.equalTo(videoH)
        }
        
        addSubview(logicView)
        logicView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        addSubview(videoTipView)
        videoTipView.snp.makeConstraints { make in
            make.top.equalTo(topMarginH)
            make.left.right.equalToSuperview()
            make.height.equalTo(videoH)
        }
   
    }
    
    
    // 承载播放器的view
    lazy var videoParentView: UIView = {
       
        let videoView = UIView()
        videoView.backgroundColor = UIColor.clear
        return videoView
        
    }()
    
    // 播放器异常处理view
    lazy var videoTipView: VideoAlertTipView = {
       
        let videoTipView = VideoAlertTipView()
        videoTipView.delegate = self
        videoTipView.tipType = .loading
        return videoTipView
        
    }()
    
    // 承载操作事件的view
    lazy var logicView: DoorbellAbilityLogicView = {

        let logicView = DoorbellAbilityLogicView()
        logicView.logicfullHorBtnBlock = { [weak self] in
            self?.fullHBtnClickBlock?()
        }
        logicView.logicLeftBackHBlock = { [weak self] in
            self?.backVBtnClickBlock?()
        }
        
        return logicView

    }()
    
 
    
}

//MARK: - 视频异常视图回调
extension DoorbellAbilityTopView : VideoAlertTipViewDelegate{
    
    func reCallBtnClick() {
        delegate?.reCallBtnClick()
    }
    
    func checkDeviceBtnClick() {
        delegate?.checkDeviceBtnClick()
    }
    
    func resetDeviceBtnClick() {
        delegate?.resetDeviceBtnClick()
    }
}

extension DoorbellAbilityTopView{
    
    //设置播放器view
    func configPeerView() {
        let statusCode : Int = sdk?.callkitMgr.setPeerVideoView(peerView: videoParentView) ?? 0
        debugPrint("--- \(statusCode)")
    }
    
    //设置播放器异常页
    func handelVideoTopView(tipsType:VideoAlertTipType){
        if tipsType == .none {
            videoTipView.isHidden = true
        }else{
            videoTipView.isHidden = false
            videoTipView.tipType = tipsType
        }
    }
    
    func handelHFullScreen(_ isFull : Bool){
        
        print("-----\(ScreenWidth)\n\(ScreenHeight))")
        if isFull == true {
            
            videoParentView.snp.updateConstraints{ make in
                make.top.equalTo(0)
                make.left.right.equalToSuperview()
                make.height.equalTo(ScreenWidth)
            }
            
            videoTipView.snp.updateConstraints { make in
                make.top.equalTo(0)
                make.left.right.equalToSuperview().inset(76)
                make.height.equalTo(ScreenWidth)
            }
  
        }else{
            
            videoParentView.snp.updateConstraints{ make in
                make.top.equalTo(topMarginH)
                make.left.right.equalToSuperview()
                make.height.equalTo(videoH)
            }
            
            videoTipView.snp.updateConstraints { make in
                make.top.equalTo(topMarginH)
                make.left.right.equalToSuperview()
                make.height.equalTo(videoH)
            }
 
        }
        
        logicView.handelHScreenToolBarView(isFull)
        
    }
    
}


extension DoorbellAbilityTopView{//下层view传值
    
    func setQuantityValue(_ value : Int){
        logicView.handelQuantityValue(value)
    }
    
}


