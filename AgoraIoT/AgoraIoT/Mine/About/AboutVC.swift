//
//  AboutVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit
import YYKit

class AboutVC: AGBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "关于"
        
        // 图片
        let logoImgView = UIImageView(image: UIImage(named: "clogo"))
        view.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(200)
        }
        
        // 版本
        let versionLabel = UILabel()
        versionLabel.font = UIFont.systemFont(ofSize: 12)
        versionLabel.textColor = .black
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = "版本号：\(version)"
        }
        view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImgView.snp.bottom).offset(10)
        }
        
        let tipsLabel = YYLabel()
        tipsLabel.numberOfLines = 0
        let privacyTips = "隐私政策"
        let userProtocolTips = "用户协议"
        let tips = "使用该应用即表示您同意\n\(privacyTips)与\(userProtocolTips)"
        let attributedTips = NSMutableAttributedString.init(string: tips)
        attributedTips.lineSpacing = 10
        attributedTips.alignment = .center
        attributedTips.font = UIFont.systemFont(ofSize: 12)
        attributedTips.color = .black
        let privacyRange = NSRange(location: tips.count - userProtocolTips.count - privacyTips.count - 1, length: privacyTips.count)
        let userProtocolRange =  NSRange(location: tips.count - userProtocolTips.count , length: userProtocolTips.count)
        attributedTips.setTextHighlight(privacyRange, color: UIColor(hexRGB: 0x49A0FF), backgroundColor: .black) { _, _, _, _ in
            print("点击隐私政策-------")
        }
        attributedTips.setTextHighlight(userProtocolRange, color: UIColor(hexRGB: 0x49A0FF), backgroundColor: .black) { _, _, _, _ in
            print("点击用户协议-------")
        }
        tipsLabel.attributedText = attributedTips
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-120)
            make.width.equalTo(150)
        }
    }
    
}
