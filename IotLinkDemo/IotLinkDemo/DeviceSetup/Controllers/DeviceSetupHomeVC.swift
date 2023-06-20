//
//  DeviceSetupHomeVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/17.
//

import UIKit
import AgoraIotLink
import SVProgressHUD

class DeviceSetupHomeCellData {
    var title = ""
    var subTitle = ""
    var showDot = false
    init(title:String, subTitle:String,showDot:Bool) {
        self.title = title
        self.subTitle = subTitle
        self.showDot = showDot
    }
}

private let kCellID = "MineCell"

class DeviceSetupHomeVC: UIViewController {
    private var dataArray = [DeviceSetupHomeCellData]()
    private let baseTitle = "基本功能设置"
    private let warningTitle = "侦测告警设置"
    private let shareTitle = "共享设备"
    private let updateTitle = "设备固件升级"
    private var firmware:FirmwareInfo? = nil
    
    var device: IotDevice?
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = .white
        tableV.tableHeaderView = headerView
        tableV.register(MinePageCell.self, forCellReuseIdentifier: kCellID)
        tableV.tableFooterView = UIView()
        return tableV
    }()
    
    private lazy var headerView:DeviceSetupHomeHeaderView = {
        let topView = DeviceSetupHomeHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 197))
        topView.clickArrowButtonAction = {[weak self] in
            let vc = DeviceInfoVC()
            vc.device = self?.device
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return topView
    }()
    
    lazy var removeDeviceButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("移除设备", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x262626), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexRGB: 0x000000, alpha: 0.85).cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(removeDeviceClick), for: .touchUpInside)
        return button
    }()
    
    lazy var reWakeDeviceButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("重启设备", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x000000, alpha: 0.30), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(reWakeDeviceClick), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData(verHint: "", showDot: false)
        updateUIWithUserModel()
    }
    
    override func viewWillAppear(_ animated: Bool){
//        AgoraIotLink.iotsdk.deviceMgr.otaGetInfo(deviceId: device!.deviceId) { ec, msg, info in
//            if(ErrCode.XOK == ec){
//                guard let info = info else{
//                    return
//                }
//                self.firmware = info
//                self.setupData(verHint: info.isUpgrade ? "发现新版本:\(info.upgradeVersion)" : "已是最新版本", showDot: info.isUpgrade)
//            }
//        }
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIWithUserModel()
    }
    
    private func updateUIWithUserModel(){
        headerView.setHeadImg(device?.productInfo?.imgSmall, name: device?.deviceName)
    }
    
    private func setupUI() {
        self.title = "设置"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        view.addSubview(removeDeviceButton)
        removeDeviceButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-100)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        view.addSubview(reWakeDeviceButton)
        reWakeDeviceButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(removeDeviceButton.snp.bottom).offset(20)
            make.width.equalTo(70)
            make.height.equalTo(25)
        }
        
        
    }
    
    // 移除设备
    private func realRemoveDevice(){
        guard device != nil else { return }
        DeviceManager.shared.removeDevice(device!) {[weak self] ec, msg in
            if(ec == ErrCode.XOK) {
                //移除设备后，挂断通话
                DoorBellManager.shared.hungUpAnswer { success, msg in }
                debugPrint("调用挂断")
                self?.navigationController?.popToRootViewController(animated: true)
            }else{
                AGToolHUD.showInfo(info: "删除失败:\(msg)")
            }
        }
    }
    
    // 点击移除设备
    @objc private func removeDeviceClick(){
        guard device != nil else { return }
        AGAlertViewController.showTitle("确定要移除设备吗", message: "") {[weak self] in
            self?.realRemoveDevice()
        }
    }
    
    // 点击重启设备
    @objc private func reWakeDeviceClick(){
   
        
    }
    
    private func setupData(verHint:String,showDot:Bool){
        let base = DeviceSetupHomeCellData(title: baseTitle,subTitle: "",showDot: false)
//        let warning = DeviceSetupHomeCellData(title: warningTitle)
        let share = DeviceSetupHomeCellData(title: shareTitle,subTitle: "",showDot: false)
        let update = DeviceSetupHomeCellData(title: updateTitle, subTitle: verHint,showDot: showDot)
        
        dataArray = [
            base,
//            warning,
            share,
            update
        ]
        tableView.reloadData()
    }
    
    // 点击基本设置
    private func didSelectBaseSetupCell(){
        let vc = DeviceBaseSetupVC()
        vc.device = device
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 点击侦测警告设置
    private func didSelectWarningSetupCell(){
        let vc = DeviceWarningSetupVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 点击共享设备
    private func didSelectShareSetupCell(){
        
        if device?.userType == 2 {
            let deviceSetVC = ShareDeviceSetupVC()
            deviceSetVC.device = device
            navigationController?.pushViewController(deviceSetVC, animated: true)
        }else{
            let deviceListVC = ShareDeviceListVC()
            deviceListVC.device = device
            navigationController?.pushViewController(deviceListVC, animated: true)
        }
    }
    //点击固件信息
    private func didFirmwareSetupCell(){
        let vc = DeviceFirmwareVC()
        vc.device = device
        vc.firmwareInfo = firmware
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension DeviceSetupHomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:MinePageCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! MinePageCell
        cell.setImgName(nil, title: cellData.title,subTitle: cellData.subTitle,showDot: cellData.showDot)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = dataArray[indexPath.row]
        switch cellData.title {
        case baseTitle:
            didSelectBaseSetupCell()
            break
        case warningTitle:
            didSelectWarningSetupCell()
            break
        case shareTitle:
            didSelectShareSetupCell()
            break
        case updateTitle:
            didFirmwareSetupCell()
            break
        default:
            break
        }
    }

}
