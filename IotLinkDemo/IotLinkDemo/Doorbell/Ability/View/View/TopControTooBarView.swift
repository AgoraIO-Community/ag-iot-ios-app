//
//  TopControTooBarView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/9.
//

import UIKit
import AgoraIotLink


//视频控制操作View
class TopControTooBarView: UIView {
    
    // 当前选中的类型
    private var selectedType = 0
    var device: IotDevice? {
        didSet{
            if(device?.connected == false){
                tipsLabel.text = "设备离线"
            }
        }
    }
    
    var quantityValue : Int?{
        
        didSet{
            guard let quantityValue = quantityValue else { return }
            if quantityValue == 100{//电量最高级别时，进度条充满
                elQuantityImageV.progressValue = 1.0
            }else{
                let proValue : CGFloat = CGFloat(quantityValue)/CGFloat(100)
                if  quantityValue != 0, proValue != 0.0 {
                    elQuantityImageV.progressValue = proValue
                }
            }

        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setUpViews()
        setUpConstraints()
        //addObserver()
    }
    
//    private func addObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveMemberStateChanged(notification:)), name: Notification.Name(cMemberStateUpdated), object: nil)
//    }
    
//    @objc private func receiveMemberStateChanged(notification: NSNotification){
//        //变声通话通知
//        guard let members = notification.userInfo?["members"] as? Int else { return }
//        tipsLabel.text = "通话人数:\(members)"
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(bgView)
        bgView.addSubview(elQuantityImageV)
//        bgView.addSubview(verticalScreenBtn)
        bgView.addSubview(volumeBtn)
        bgView.addSubview(pictureQualityBtn)
        bgView.addSubview(tipsLabel)
        bgView.addSubview(memberLabel)
    }
    
    fileprivate func setUpConstraints() {
        bgView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        elQuantityImageV.snp.makeConstraints { (make) in
            make.left.equalTo(24.S)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 29.S, height: 13.S))
        }
        elQuantityImageV.progressValue = 0.0
 
//        verticalScreenBtn.snp.makeConstraints { (make) in
//            make.right.equalTo(-20.S)
//            make.centerY.equalToSuperview()
//            make.size.equalTo(CGSize.init(width: 24.S, height: 24.S))
//        }

        volumeBtn.snp.makeConstraints { (make) in
//            make.right.equalTo(verticalScreenBtn.snp.left).offset(-20.S)
            make.right.equalTo(-20.S)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 24.S, height: 24.S))
        }

        pictureQualityBtn.snp.makeConstraints { (make) in
            make.right.equalTo(volumeBtn.snp.left).offset(-20.S)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 40.S, height: 21.S))
        }

        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(elQuantityImageV.snp.right).offset(20.S)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 75.S, height: 17.S))
        }
        
        memberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tipsLabel.snp.right).offset(20.S)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 75.S, height: 17.S))
        }
    }
    
    fileprivate lazy var bgView:UIView = {

        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
//    lazy var elQuantityImageV: UIImageView = {
//        let imageV = UIImageView()
//        imageV.contentMode = .scaleAspectFit
//        imageV.image = UIImage.init(named: "buttery_bg")
//        return imageV
//    }()
    
    lazy var elQuantityImageV:VipProgressView = {
        
        let progressV = VipProgressView.init(frame: CGRect.init(x: 0, y: 0, width: 29.S, height: 13.S))
//        progressV.layer.cornerRadius = 1.S
        return progressV
        
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
//        label.frame = CGRect.init(x: 0, y: 0, width: 100.S, height: 17.S)
        label.textColor = UIColor(hexString: "#25DEDE")
        label.font = FontPFMediumSize(12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clear
        label.text = "正在通话中..."
        return label
    }()
    
    lazy var memberLabel: UILabel = {
        let label = UILabel()
//        label.frame = CGRect.init(x: 0, y: 0, width: 100.S, height: 17.S)
        label.textColor = UIColor(hexString: "#25DEDE")
        label.font = FontPFMediumSize(12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clear
        label.text = "通话人数:0"
        return label
    }()

    lazy var pictureQualityBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("标清", for:.normal)
        btn.setTitleColor(UIColor.init(hexString: "#F3F3F3"), for: .normal)
        btn.titleLabel?.font = FontPFRegularSize(10)
        btn.layer.cornerRadius = 3.S
//        btn.layer.masksToBounds = true
        btn.layer.borderColor = UIColor.init(hexString: "#979797").cgColor
        btn.layer.borderWidth = 1.S
        btn.tag = 1001
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var volumeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "voice_out"), for: .normal)
        btn.setImage(UIImage.init(named: "voice_off"), for: .selected)
        btn.tag = 1002
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var verticalScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "ver_full_screen"), for: .normal)
        btn.tag = 1003
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnEvent(btn : UIButton){
        switch btn.tag {
        case 1001:
            debugPrint("设置画质")
            showPictureQualiSheet()
            break
        case 1002:
            debugPrint("设置静音")
            shutDownAudio(btn)
            break
        case 1003:
            debugPrint("竖屏全屏")
            break
        default:
            break
        }
    }
    
    func shutDownAudio(_ btn : UIButton){
        
        var isShutAudio : Bool = true
        if btn.isSelected {
            isShutAudio = false
        }
        DoorBellManager.shared.mutePeerAudio(mute: isShutAudio) { success, msg in
            if success{
                log.i("设置静音成功")
                btn.isSelected = !btn.isSelected
            }
         }
    }
    
    func showPictureQualiSheet(){
        
        let itemsCode = [1,2]
        AGActionSheetVC.showTitle("画质设置", items: ["标清","高清"], selectIndex: self.selectedType) {[weak self] item, index in
            if self == nil { return }
            self?.selectedType = index
            self?.setDeviceProperty(itemsCode[index],item)
        }
        
    }
    
    //单值设置属性操作直接调用接口
    func setDeviceProperty(_ value : Int,_ title : String){
        
        guard let device = device else { return }
        let parmDic = ["107":value] as [String:Any]
        
        AGToolHUD.showNetWorkWait()
        DoorBellManager.shared.setDeviceProperty(device, dict: parmDic) {[weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success == true {
                AGToolHUD.showInfo(info:"设置成功" )
                self?.pictureQualityBtn.setTitle(title, for: .normal)
            }else{
                AGToolHUD.showInfo(info: "\(msg)")
            }
        }
        
    }
    
}


extension TopControTooBarView{
    
    func handelHScreenControlBarView(_ isFull : Bool){
        
        if isFull == true {
            volumeBtn.snp.updateConstraints { (make) in
                make.right.equalTo(-93)
            }
            
            elQuantityImageV.snp.updateConstraints { (make) in
                make.left.equalTo(93)
            }
        }else{
            volumeBtn.snp.updateConstraints { (make) in
                make.right.equalTo(-20.S)
             }
            
            elQuantityImageV.snp.updateConstraints { (make) in
                make.left.equalTo(24.S)
            }
        }
        
    }
}

//MARK: - 电池进度条
class VipProgressView: UIView {
    
    var progressValue:CGFloat?{
        
        didSet{
            
            guard let progressValue = progressValue else {return}
            let w : CGFloat = (self.bounds.size.width-6.5)*progressValue
            UIView.animate(withDuration: 0.25, animations: {
                
                self.topV.snp.updateConstraints { (make) in
                    make.width.equalTo(w)
                }
            
            }) { (_) in
                
            }
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setUpUI()
    }
    
    func setUpUI() {
        
        addSubview(bgV)
        bgV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bgV.addSubview(bottomV)
        bottomV.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.left.equalTo(2)
            make.bottom.equalTo(-2)
            make.width.equalTo(self.bounds.size.width-6.5)
        }
        
        bgV.addSubview(topV)
        topV.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.left.equalTo(2)
            make.bottom.equalTo(-2)
            make.width.equalTo(self.bounds.size.width-6.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage.init(named: "buttery_bg")
        return imageV
    }()
    
    lazy var bottomV: UIView = {
        let vew = UIView()
        vew.backgroundColor = UIColor(hexString: "#000000")
        return vew
    }()
    
    lazy var topV: UIView = {
        let vew = UIView()
        vew.backgroundColor = UIColor(hexString: "#D5D5D5")
        return vew
    }()
    
}
