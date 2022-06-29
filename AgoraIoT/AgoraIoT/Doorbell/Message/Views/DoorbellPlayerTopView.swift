//
//  DoorbellPlayerTopView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/7.
//

import UIKit

class DoorbellPlayerTopView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickFullScreenButtonAction:(()->(Void))?
    
    var clickMuteButtonAction:(()->(Void))?
    
    var clickDefinitionButtonAction:(()->(Void))?

    
    // 旋转
    private lazy var fullScreenButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_fullscreen"), for: .normal)
        button.addTarget(self, action: #selector(didClickFullScreenButton), for: .touchUpInside)
        return button
    }()
    
    // 静音
    private lazy var muteButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_voiceon"), for: .normal)
        button.setImage(UIImage(named: "msg_voiceoff"), for: .selected)
        button.addTarget(self, action: #selector(didClickMuteButton), for: .touchUpInside)
        return button
    }()
    
    // 清晰度
    lazy var definitionButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("高清", for: .normal)
        button.addTarget(self, action: #selector(didClickDefinitionButton), for: .touchUpInside)
        return button
    }()
    
    
    private func createSubviews(){
        addSubview(fullScreenButton)
        fullScreenButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(0)
            make.width.height.equalTo(42)
        }
        addSubview(muteButton)
        muteButton.snp.makeConstraints { make in
            make.right.equalTo(fullScreenButton.snp.left).offset(-20)
            make.centerY.equalTo(fullScreenButton)
            make.width.height.equalTo(42)
        }
    }
    
    // 点击全屏
    @objc private func didClickFullScreenButton(){
        clickFullScreenButtonAction?()
    }
    
    // 点击静音
    @objc private func didClickMuteButton(){
        clickMuteButtonAction?()
    }
    
    // 点击删除
    @objc private func didClickDefinitionButton(){
        clickDefinitionButtonAction?()
    }

}
