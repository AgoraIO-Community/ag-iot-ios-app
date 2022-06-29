//
//  DeviceBaseSetupVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import AgoraIotSdk

private let kCellID = "PushMsgSettingCell"

class DeviceBaseSetupVC: UIViewController {

    //上个页面传入
    var device: IotDevice?
    
    var dataArray = [DeviceSetUpModel]()
    
    var curIndex : IndexPath?
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = .white
        tableV.allowsSelection = false
        tableV.tableFooterView = UIView()
        return tableV
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        title = "基本功能设置"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(SwitchSettingCell.self, forCellReuseIdentifier: kCellID)
    }
    
    private func setupData(){
        
        let deviceFunc =  DeviceSetUpModel()
        deviceFunc.funcName = "状态指示灯"
        deviceFunc.funcId = 108
        
        dataArray = [
            deviceFunc,
        ]
        tableView.reloadData()
    }
    
}

extension DeviceBaseSetupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = dataArray[indexPath.row]
        let cell:SwitchSettingCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! SwitchSettingCell
        cell.curIndexPath = indexPath
        cell.model = model
        // 点击按钮
        cell.valueChangedAction = { [weak self] aswitch,curIndexPath in
            self?.curIndex = curIndexPath
            self?.switchValueChangedForTitle(model,aswitch.isOn)
        }
        return cell
    }
    
    // 开关值变化
    func switchValueChangedForTitle(_ model : DeviceSetUpModel, _ isOn : Bool) {
        switch model.funcId {
        case 108:
            setDeviceProperty(model,isOn)
            break
        default:
            break
        }
    }
    

}

extension DeviceBaseSetupVC{
    
    //单值设置属性操作直接调用接口
    func setDeviceProperty(_ model : DeviceSetUpModel, _ isOn : Bool){
        
        guard let device = device else { return }
        let pointId = String(model.funcId)
        
        let parmDic = [pointId:isOn] as [String:Any]
        
        AGToolHUD.showNetWorkWait()
        DoorBellManager.shared.setDeviceProperty(device, dict: parmDic) {[weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success == true {
                AGToolHUD.showInfo(info:"设置成功" )
                model.funcBoolValue = isOn
                self?.handelSetUpDeviceResult(model)
            }else{
                AGToolHUD.showInfo(info: "\(msg)")
            }
        }
        
    }
    
    func handelSetUpDeviceResult(_ model : DeviceSetUpModel) {
        
        guard let indexPath = curIndex else { return }
        let tempCell : SwitchSettingCell = tableView.cellForRow(at: indexPath) as! SwitchSettingCell
        tempCell.model = model
        
    }
    
}
