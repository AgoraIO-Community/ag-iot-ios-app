//
//  VideoAlertTipView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/9.
//

import UIKit

public enum VideoAlertTipType: Int{
    ///默认
    case none = 0
    ///加载中
    case loading = 1
    ///加载失败
    case loadFail = 2
    ///设备离线
    case deviceOffLine = 3
    ///设备休眠
    case deviceSleep = 4
}

protocol VideoAlertTipViewDelegate : NSObjectProtocol{
    
    func reCallBtnClick()
    func checkDeviceBtnClick()
    func resetDeviceBtnClick()
    
}

//视频加载错误上层View
class VideoAlertTipView: UIView {
    
    let topMarginH : CGFloat = 47.VS
    let toolBarH : CGFloat = 56.VS
    
    weak var delegate : VideoAlertTipViewDelegate?
    
    var tipType : VideoAlertTipType?{
        
        didSet{
            guard let type = tipType else { return }
            handelBtn.isHidden = false
            alertIconImageV.isHidden = false
            handelBtn.setTitleColor(UIColor.init(hexString: "#1DD6D6"), for: .normal)
            switch type {
            case .loading:
                handelBtn.isHidden = true
                alertIconImageV.isHidden = true
                tipsLabel.text = "远程视频加载中..."
                break
            case .loadFail:
                alertIconImageV.image = UIImage.init(named: "fail_info")
                handelBtn.setTitle("点击重试", for: .normal)
                tipsLabel.text = "视频加载失败"
                break
            case .deviceOffLine:
                alertIconImageV.image = UIImage.init(named: "offline_info")
                handelBtn.setTitleColor(UIColor.init(hexString: "#F7B500"), for: .normal)
                handelBtn.setTitle("请检查设备状态", for: .normal)
                tipsLabel.text = "设备离线"
                break
            case .deviceSleep:
                alertIconImageV.image = UIImage.init(named: "sleep_info")
                handelBtn.setTitle("点击重启", for: .normal)
                tipsLabel.text = "设备休眠"
                break
            default:
                break
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#575757")
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(alertIconImageV)
        addSubview(tipsLabel)
        addSubview(handelBtn)
        
        tipsLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(100.S)
            make.height.equalTo(17.VS)
        }
        
        alertIconImageV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tipsLabel.snp.top).offset(-12.VS)
            make.width.equalTo(23.S)
            make.height.equalTo(23.S)
        }
        
        handelBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipsLabel.snp.bottom).offset(2.VS)
            make.width.equalTo(120.S)
            make.height.equalTo(24.VS)
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
        label.textColor = UIColor(hexString: "#E5E5E5")
        label.font = FontPFMediumSize(12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "视频加载失败"
        return label
    }()
    
    lazy var handelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("点击重试", for: .normal)
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(UIColor.init(hexString: "#1DD6D6"), for: .normal)
        btn.titleLabel?.font = FontPFMediumSize(11)
        btn.addTarget(self, action: #selector(btnEvent), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnEvent(){
   
        switch tipType {
        case .loadFail:
            delegate?.reCallBtnClick()
            break
        case .deviceOffLine:
            delegate?.checkDeviceBtnClick()
            break
        case .deviceSleep:
            delegate?.resetDeviceBtnClick()
            break
        default:
            break
        }
    }
}
