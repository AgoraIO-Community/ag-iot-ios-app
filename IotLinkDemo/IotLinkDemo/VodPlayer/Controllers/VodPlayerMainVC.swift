//
//  VodPlayerMainVC.swift
//  IotLinkDemo
//
//  Created by admin on 2023/7/10.
//

import UIKit

class VodPlayerMainVC: AGBaseVC {

    
    //---进度条---
    var progressSlider: UISlider!
    var playbackTimer: Timer?
    var isOpen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpUI(){
        // 设置进度条
        progressSlider = UISlider(frame: CGRect(x: 30, y: view.bounds.height - 300, width: view.bounds.width-60, height: 30))
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(progressSlider)
        
        view.addSubview(vodDisplayView)
        vodDisplayView.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.left.right.equalTo(view)
            make.height.equalTo(200)
        }
        
        view.addSubview(playBtn)
        playBtn.snp.makeConstraints { make in
            make.top.equalTo(vodDisplayView.snp.bottom).offset(30)
            make.left.equalTo(vodDisplayView.snp.left).offset(20)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
    }
    
    lazy var vodDisplayView:UIView = {
        let vodView = UIView()
        vodView.backgroundColor = UIColor.cyan
        
        return vodView
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("播放", for:.normal)
        btn.setTitle("暂停", for:.selected)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(playClick(btn:)), for: .touchUpInside)
        return btn
    }()

}

extension VodPlayerMainVC{
    
    func openVodPlayer(){
        
        sdk?.vodPlayerMgr.open(mediaUrl: "https://aios-personalized-wuw.oss-cn-beijing.aliyuncs.com/ts_muxer.m3u8", callback: { [weak self] errCode, displayView in
             self?.setDisPlayView(displayView)
             sdk?.vodPlayerMgr.play()
            self?.isOpen = true
        })
        
//        let vFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200)
//        sdk?.vodPlayerMgr.setDisplayView(vodDisplayView, vFrame)
        
    }
    
    @objc func playClick(btn : UIButton){
        if btn.isSelected == false {
            if isOpen == false {
                openVodPlayer()
            }else{
                sdk?.vodPlayerMgr.play()
            }
            // 启动 Timer 每秒钟更新一次进度条
            playbackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        }else{
            
            sdk?.vodPlayerMgr.pause()
            playbackTimer?.invalidate()
            playbackTimer = nil
            
//            sdk?.vodPlayerMgr.stop()
//            sdk?.vodPlayerMgr.close()
//            isOpen = false
     
        }
        btn.isSelected = !btn.isSelected
    }
    
    @objc private func updateProgressBar() {

        // 更新进度条的进度
        let progress = (sdk?.vodPlayerMgr.getPlayingProgress())!
        progressSlider.value = Float(progress)
        if progress >= 1{
            if playbackTimer != nil {
                playbackTimer?.invalidate()
                playbackTimer = nil
            }
            playBtn.isSelected = !playBtn.isSelected
        }
        print("更新进度条:  progress:\(progress)")
        
    }

    
    // 监听进度条值的变化
    @objc func progressSliderValueChanged(_ slider: UISlider) {
        let duration = (sdk?.vodPlayerMgr.getPlayDuration())!
        let targetTime  = Double(slider.value) * duration
        let ret = sdk?.vodPlayerMgr.seek(seekPos: targetTime)
 
    }
    
    func setDisPlayView(_ displayView:UIView){
        vodDisplayView.addSubview(displayView)
        displayView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(200)
        }
    }
    
}
