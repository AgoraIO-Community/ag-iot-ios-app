//
//  ShareDeviceSetupVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import AgoraIotLink

private let kCellID = "DeviceInfoCell"
private let buttonHeight: CGFloat = 40

class ShareDeviceSetupVC: UIViewController {

    var device: IotDevice?
    
    var dataArray = [DeviceSetupHomeCellData]()
    private let sourceTitle = "设备来自"
    private let deviceIDTitle = "设备ID"
    
    fileprivate lazy var  deviceShareVM = DeviceShareViewModel()
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableV.tableHeaderView = headerView
        tableV.register(DeviceInfoCell.self, forCellReuseIdentifier: kCellID)
        tableV.tableFooterView = UIView()
        tableV.allowsSelection = false
        return tableV
    }()
    
    private lazy var headerView:DeviceInfoView = {
        let topView = DeviceInfoView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 197))
        topView.clickEditButtonAction = {[weak self] in
            AGEditAlertVC.showTitle("修改设备名称", editText: "可视门铃",alertType: .modifyDeviceName ) { value in
                topView.name = value
            }
        }
        return topView
    }()
    
    private lazy var deleteButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("移除共享", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x262626), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = buttonHeight * 0.5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexRGB: 0x000000, alpha: 0.85).cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickDeleteButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        self.title = "共享设备设置"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-100)
            make.width.equalTo(120)
            make.height.equalTo(buttonHeight)
        }
    }
    
    private func setupData(){
        let source = DeviceSetupHomeCellData(title: sourceTitle, subTitle: device?.sharer ?? "",showDot: false)
        let deviceID = DeviceSetupHomeCellData(title: deviceIDTitle, subTitle: device?.deviceId ?? "",showDot: false)
        
        dataArray = [
            source,
            deviceID
        ]
        tableView.reloadData()
    }
    
//    @objc private func didClickDeleteButton(){
//
//        AGToolHUD.showNetWorkWait()
//        guard let device = device else { return }
//
//        deviceShareVM.removeMember(deviceId: device.deviceId, userId:device.userId) { success, msg in
//            AGToolHUD.disMiss()
//            if success == true {
//                AGToolHUD.showInfo(info: "已移除分享")
//            }else{
//                AGToolHUD.showInfo(info: msg)
//            }
//        }
//    }
    
    // 点击移除设备
    @objc private func didClickDeleteButton(){
        guard device != nil else { return }
        AGAlertViewController.showTitle("确定要移除设备吗", message: "") {[weak self] in
            self?.realRemoveDevice()
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
    
}


extension ShareDeviceSetupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:DeviceInfoCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! DeviceInfoCell
        cell.set(title: cellData.title, subTitle: cellData.subTitle)
        return cell
    }
}

