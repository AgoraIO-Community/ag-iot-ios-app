//
//  DeviceInfoVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import AgoraIotLink
import SVProgressHUD

private let kCellID = "DeviceInfoCell"

class DeviceInfoVC: UIViewController {
    
    var device :IotDevice?
    private var dataArray = [DeviceSetupHomeCellData]()
    private let deviceIDTitle = "设备ID"
    
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
        topView.name = device?.deviceName
        topView.clickEditButtonAction = {[weak self] in
            AGEditAlertVC.showTitle("修改设备名称", editText: self?.device?.deviceName ?? "",alertType:.modifyDeviceName ) {[weak self] value in
                self?.updateDeviceName(name: value)
            }
        }
        return topView
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        self.title = "设备信息"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    private func setupData(){
        let deviceID = DeviceSetupHomeCellData(title: deviceIDTitle, subTitle: device?.deviceId ?? "<未知>",showDot: false)
        
        dataArray = [
            deviceID
        ]
        tableView.reloadData()
    }
    
    private func updateDeviceName(name: String){
        if device == nil {
            return
        }
        AgoraIotManager.shared.sdk?.deviceMgr.renameDevice(deviceId: device!.deviceId, newName: name, result:{[weak self] ec, msg in
            if(ec == ErrCode.XOK){
                self?.headerView.name = name
                self?.device?.deviceName = name
            }else{
                SVProgressHUD.showError(withStatus: "修改失败:\(msg)")
            }
        })
    }
}



extension DeviceInfoVC: UITableViewDelegate, UITableViewDataSource {
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
