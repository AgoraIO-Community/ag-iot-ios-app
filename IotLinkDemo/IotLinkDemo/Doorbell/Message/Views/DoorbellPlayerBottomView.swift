//
//  DoorbellPlayerBottomView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/7.
//

import UIKit
//import SJVideoPlayer

class DoorbellPlayerBottomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickRotationButtonAction:(()->(Void))?
    
    var clickPlayButtonAction:(()->(Void))?
    
    var clickClipsButtonAction:(()->(Void))?
    
    var clickDeleteButtonAction:(()->(Void))?
    
    var clickDownloadButtonAction:(()->(Void))?

    private lazy var bgView:UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor(hexRGB: 0x28292D)
        bgView.layer.cornerRadius = 8
        bgView.layer.masksToBounds = true
        return bgView
    }()
    var isRotation = false {
        didSet {
            if isRotation {
                layoutForRight()
            }
        }
    }
    
    // 当前播放时间
    private lazy var currentTimeLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexRGB: 0xD3D3D3)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // 总时间
    private lazy var totalTimeLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexRGB: 0xD3D3D3)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // 进度条
//    lazy var progress:SJProgressSlider = {
//        let slider = SJProgressSlider()
//        slider.trackHeight = 3
//        slider.tap.isEnabled = true
//        slider.showsBufferProgress = true
//        return slider
//    }()
    
    // 旋转
    private lazy var rotationButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_rotation"), for: .normal)
        button.addTarget(self, action: #selector(didClickRotationButton), for: .touchUpInside)
        return button
    }()
    
    // 下载
    lazy var downloadButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_download_disable"), for: .disabled)
        button.setImage(UIImage(named: "msg_download_enable"), for: .normal)
        button.addTarget(self, action: #selector(didClickDownloadButton), for: .touchUpInside)
        return button
    }()
    
    // 播放
    lazy var playButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_pause"), for: .normal)
        button.setImage(UIImage(named: "msg_play"), for: .selected)
        button.addTarget(self, action: #selector(didClickPlayButton), for: .touchUpInside)
        return button
    }()
    
    // 剪切
    private lazy var clipButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_clip"), for: .normal)
        button.addTarget(self, action: #selector(didClickClipButton), for: .touchUpInside)
        return button
    }()
    
    // 删除
    private lazy var deleteButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_delete"), for: .normal)
        button.addTarget(self, action: #selector(didClickDeleteButton), for: .touchUpInside)
        return button
    }()
    
    private func createSubviews(){
        addSubview(bgView)
        bgView.addSubview(rotationButton)
        bgView.addSubview(downloadButton)
        bgView.addSubview(playButton)
        bgView.addSubview(clipButton)
        bgView.addSubview(deleteButton)
        
        // 放到底部的布局
        layoutForBottom()
    }
    
    private func layoutForBottom() {
        
        // 背景距离左侧间距
        let bgleftMargin:CGFloat = 15
        // 按钮宽度
        let btnWidth:CGFloat = 42
        
        bgView.snp.remakeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: bgleftMargin, bottom: 0, right: bgleftMargin))
        }
        
        // 按钮间距
        let space = (ScreenWidth - bgleftMargin * 2 - btnWidth * CGFloat(bgView.subviews.count)) / CGFloat(bgView.subviews.count + 1)
        var i = 0
        for subView in bgView.subviews {
            subView.snp.remakeConstraints { make in
                make.width.height.equalTo(btnWidth)
                make.left.equalTo(space * CGFloat(i + 1) + CGFloat(i) * btnWidth)
                make.centerY.equalToSuperview()
            }
            i += 1
        }
    }
    
    private func layoutForRight() {
        rotationButton.isHidden = true
        deleteButton.isHidden = true
        
        bgView.backgroundColor = .clear
        // 背景距离左侧间距
        let topMargin:CGFloat = 15
        // 按钮宽度
        let btnWidth:CGFloat = 42
        
        bgView.snp.remakeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: topMargin, left: 0, bottom: topMargin, right: 0))
        }
        
        // 按钮间距
        let space = (ScreenWidth - topMargin * 2 - btnWidth * CGFloat(bgView.subviews.count)) / CGFloat(bgView.subviews.count + 1)
        var i = 0
        for subView in bgView.subviews {
            subView.snp.remakeConstraints { make in
                make.width.height.equalTo(btnWidth)
                make.top.equalTo(space * CGFloat(i + 1) + CGFloat(i) * btnWidth)
                make.centerX.equalToSuperview()
            }
            i += 1
        }
    }
    
    // 点击旋转按钮
    @objc private func didClickRotationButton(){
        clickRotationButtonAction?()
    }
    
    // 点击下载
    @objc private func didClickDownloadButton(){
        clickDownloadButtonAction?()
    }
    
    // 点击播放
    @objc private func didClickPlayButton(){
//        self.playButton.isSelected = !self.playButton.isSelected
        clickPlayButtonAction?()
    }
    
    // 点击剪切
    @objc private func didClickClipButton(){
        clickClipsButtonAction?()
    }
    
    // 点击删除
    @objc private func didClickDeleteButton(){
        clickDeleteButtonAction?()
    }
}
