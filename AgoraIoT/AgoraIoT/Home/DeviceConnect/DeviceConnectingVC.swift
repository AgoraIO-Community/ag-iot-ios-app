//
//  DeviceConnectingVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

public  let AddDeviceSuccess = "AddDeviceSuccess"

class DeviceConnectingVC: UIViewController {
    
    var time = 0
    
    private let limitTime = 30
    var productKey:String!
    
    lazy var timerLabel:UILabel = {
        let timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: 12)
        timerLabel.textColor = .black
        return timerLabel
    }()
    
    lazy var timer:Timer = {
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] t in
            guard let wSelf = self else {
                t.invalidate()
                return
            }
            
            wSelf.time += 1
            let time = wSelf.time
            wSelf.timerLabel.text = String(format: "%02zd:%02zd", time / 60,time % 60)
            if(time >= wSelf.limitTime ){
                t.invalidate()
                wSelf.showTimeoutVC()
            }
            print("self.time == \(wSelf.time)")
        }
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addObserver()
        self.timer.fire()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.timer.invalidate()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAddDeviceSuccess(_:)), name: NSNotification.Name(AddDeviceSuccess), object: nil)
    }
    
    @objc private func receiveAddDeviceSuccess(_ noti: Notification) {
        let vc = DeviceAddSuccessVC()
        vc.deviceId = noti.userInfo?["deviceId"] as? String
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        self.title = "正在添加设备"
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didClickCanelBarItem))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "45d2cf")
        
        // 提示
        let tipsLabel = UILabel()
        tipsLabel.text = "请确保设备处于通电状态"
        tipsLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        tipsLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(36)
        }
        
        // loading
        let activity = UIActivityIndicatorView()
        activity.color = .cyan
        activity.transform = CGAffineTransform(scaleX: 4, y: 4)
        view.addSubview(activity)
        activity.startAnimating()
        activity.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(100)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        // 正在建立连接
        let connectLabel = UILabel()
        connectLabel.text = "正在建立连接"
        connectLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        connectLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        view.addSubview(connectLabel)
        connectLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(activity.snp.bottom).offset(50)
        }
        
        // 计时
        view.addSubview(timerLabel)
        timerLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        timerLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        timerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(connectLabel.snp.bottom).offset(10)
        }
    }
    
    // 显示网络超时页面
    private func showTimeoutVC(){
        let timeoutVC = DeviceConnectTimeoutVC()
        timeoutVC.productKey = productKey
        navigationController?.pushViewController(timeoutVC, animated: false)
    }

    @objc private func didClickCanelBarItem(){
        navigationController?.popViewController(animated: true)
    }
}
