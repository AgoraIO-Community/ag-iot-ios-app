//
//  DoorbellSaveImgAlertView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/20.
//

import UIKit
import ZLPhotoBrowser

public enum SaveImgAlertType: Int{
    ///默认
    case none = 0
    ///保存图片
    case saveImg = 1
    ///保存视频
    case saveVideo = 2
}

class DoorbellSaveImgAlertView: UIView {
    
    let topMarginH : CGFloat = 47.VS
    let toolBarH : CGFloat = 56.VS
    
//    weak var delegate : VideoAlertTipViewDelegate?
    
    var shotImage : UIImage?
    
    var alertType : SaveImgAlertType?{
        
        didSet{
            guard let type = alertType else { return }
            
            switch type {
            case .saveImg:
                tipsLabel.text = "截图已保存至相册"
                break
            case .saveVideo:
                tipsLabel.text = "视频已保存至相册"
                break
            default:
                break
            }
            alertIconImageV.image = shotImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#2F2F2F")
        
        setUpViews()
        
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(alertIconImageV)
        addSubview(tipsLabel)
        addSubview(handelBtn)
        
        alertIconImageV.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(41)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(alertIconImageV.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(13)
        }
   
        handelBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipsLabel.snp.bottom).offset(3)
            make.width.equalTo(50)
            make.height.equalTo(15)
        }
        
    }
    
    lazy var alertIconImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFit
        imageV.image = UIImage.init(named: "fail_info")
        return imageV
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#D5D5D5")
        label.font = FontPFRegularSize(9)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "截图已保存至相册"
        return label
    }()
    
    lazy var handelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("查看相册", for: .normal)
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(UIColor.init(hexString: "#0091FF"), for: .normal)
        btn.titleLabel?.font = FontPFRegularSize(8)
        btn.addTarget(self, action: #selector(btnEvent), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnEvent(){
   
        switch alertType {
        case .saveImg:
            showImagePickerVC()
            break
        case .saveVideo:
            showImagePickerVC()
            break
        default:
            break
        }
    }
}

extension DoorbellSaveImgAlertView{
    private func showImagePickerVC(){
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = true
        config.allowTakePhoto = false
        config.allowRecordVideo = false
        config.maxSelectCount = 1
        config.allowEditVideo = false
        config.allowEditImage = false
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            guard let image = images.first else {return }
            debugPrint("获取图片成功")

        }
        ps.showPhotoLibrary(sender: currentViewController())
    }
    
}
