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
        title = "about".L
        
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
            versionLabel.text = "versionNumber".L + "：2.1.2.0"
//            versionLabel.text = "versionNumber".L + "：\(version)"
        }
        view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImgView.snp.bottom).offset(10)
        }
        
        let tipsLabel = YYLabel()
        tipsLabel.numberOfLines = 0
        let privacyTips = "privacyPolicy".L
        let userProtocolTips = "userAgreement".L
        let tipsHeader = "byUsingThisApplicationYouAgree".L
        let tips = tipsHeader + "\n\(privacyTips)" + " and " + "\(userProtocolTips)"
        let attributedTips = NSMutableAttributedString.init(string: tips)
        attributedTips.lineSpacing = 10
        attributedTips.alignment = .center
        attributedTips.font = UIFont.systemFont(ofSize: 12)
        attributedTips.color = .black
        let privacyRange = NSRange(location:tipsHeader.count, length: privacyTips.count+1)
        let userProtocolRange =  NSRange(location: tips.count - userProtocolTips.count , length: userProtocolTips.count)
        attributedTips.setTextHighlight(privacyRange, color: UIColor(hexRGB: 0x49A0FF), backgroundColor: .black) { [weak self]  _, _, _, _ in
            debugPrint("点击隐私政策-------")
            self?.showProtocolAlert(.priviteProtocol)
        }
        attributedTips.setTextHighlight(userProtocolRange, color: UIColor(hexRGB: 0x49A0FF), backgroundColor: .black) {[weak self]  _, _, _, _ in
            debugPrint("点击用户协议-------")
            self?.showProtocolAlert(.userProtocol)
        }
        tipsLabel.attributedText = attributedTips
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-120)
            make.width.equalTo(200)
        }
    }
    
    //跳转用户协议和隐私政策
    func showProtocolAlert(_ proType : ProtocolType){
        
        let proAlertVC = LoginProtocolAlertVC()
        proAlertVC.proType = proType
        proAlertVC.pageSource = .aboutPage
        
        proAlertVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        proAlertVC.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(proAlertVC, animated: true, completion: nil)
        
    }
}
