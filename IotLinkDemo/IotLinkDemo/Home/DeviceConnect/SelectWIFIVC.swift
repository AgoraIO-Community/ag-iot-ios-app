//
//  SelectWIFIVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/24.
//

import UIKit
import IQKeyboardManagerSwift
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension

class SelectWIFIVC: UIViewController {
    
    var productKey:String!

    private lazy var locationManager:CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        return manager
    }()

    private func isWifiAccountCorrect(wifiName:String,password:String,cb:@escaping(Bool,String)->Void){
        let wifiConfig = NEHotspotConfiguration(ssid: wifiName, passphrase: password, isWEP: false)
        wifiConfig.joinOnce = false
        NEHotspotConfigurationManager.shared.apply(wifiConfig){ (error) in
            guard let error = error else{
                cb(true,"")
                return
            }
            if(error._code == 13){
                //already joined
                cb(true,"")
            }
            else{
                cb(false,"\(error)")
            }
        }
    }
    
    private lazy var selectView:SelectWIFIView = {
        let view = SelectWIFIView()
        view.clickWifiButtonAction = {[weak self] in
            self?.checkShowWifiAlert()
        }
        view.clickNextButtonAction = {[weak self] (wifiName, password) in
//            self?.isWifiAccountCorrect(wifiName: wifiName, password: password, cb:{ec,msg in
//                if(ec){
//                    let vc = CreateQRCodeVC()
//                    vc.wifiName = wifiName
//                    vc.password = password
//                    vc.productKey = self?.productKey
//                    self?.navigationController?.pushViewController(vc, animated: true)
//                }
//                else{
//                    AGToolHUD.showInfo(info: "无法连接网络，请确保账号密码正确:\(msg)")
//                }
//            })
            
            //跳转蓝牙配网
            let vc = BluefiResultVC()
            vc.wifiName = wifiName
            vc.password = password
            vc.productKey = self?.productKey
            self?.navigationController?.pushViewController(vc, animated: true)
            
            //跳转二维码扫描配网
//            let vc = CreateQRCodeVC()
//            vc.wifiName = wifiName
//            vc.password = password
//            vc.productKey = self?.productKey
//            self?.navigationController?.pushViewController(vc, animated: true)
            
        }
        view.wifiTextFieldBeginEdit = {[weak self] in
            self?.checkShowWifiAlert()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLocation()
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupUI(){
        self.title = "连接WiFi"
        let cancelBarBtnItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didClickCancelBarBtnItem))
        cancelBarBtnItem.tintColor = UIColor(hexRGB: 0x1DD6D6)
        navigationItem.rightBarButtonItem = cancelBarBtnItem
        
        view.backgroundColor = .white
        view.addSubview(selectView)
        selectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func didClickCancelBarBtnItem(){
        dismiss(animated: true)
    }
         
    private func startLocation(){
        
        var status = CLAuthorizationStatus.notDetermined
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        if status == .denied {
            let alert = UIAlertController(title: "没有开启定位", message: "请到设置中开启定位", preferredStyle: .alert)
            let action = UIAlertAction(title: "去设置", style: .cancel, handler: { action in
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!)
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)

        }else{
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func willEnterForeground(){
        startLocation()
    }
    
    // 获取WiFi名称
    private func getWiFiName() -> String? {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            return nil
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            return nil
        }
        var wifiName: String?
        for interface in swiftInterfaces {
            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                return nil
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                return nil
            }
            wifiName = (SSIDDict["SSID"] as? String)
        }
        return wifiName
    }
    
    private func checkShowWifiAlert(){
        let name = getWiFiName()
        if name == nil {
            AGAlertViewController.showTitle("目前手机没有连接WiFi", message: "手机连接WiFi后才能与设备联网", cancelTitle: "取消", commitTitle: "连接") {
//                let url = URL(string: UIApplication.openSettingsURLString)
                let url = URL(string: "App-Prefs:root=WIFI")
                UIApplication.shared.open(url!)
            }
        }else{
//            let url = URL(string: UIApplication.openSettingsURLString)
            let url = URL(string: "App-Prefs:root=WIFI")
            UIApplication.shared.open(url!)
        }
        view.endEditing(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SelectWIFIVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        selectView.setWiFiName(getWiFiName())
    }
}
