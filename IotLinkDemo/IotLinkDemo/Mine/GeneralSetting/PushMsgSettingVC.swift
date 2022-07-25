//
//  PushMsgSettingVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit
import AgoraIotLink

private let kCellID = "PushMsgSettingCell"

class PushMsgSettingVC: UIViewController {
    
    var dataArray = [DeviceSetUpModel]()
    
    private let alamTitle = "告警消息"
    private var  currentCell : SwitchSettingCell?
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = .white
        return tableV
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        title = "消息推送"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(SwitchSettingCell.self, forCellReuseIdentifier: kCellID)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }
    
    private func setupData(){
        
        let deviceFunc =  DeviceSetUpModel()
        deviceFunc.funcName = alamTitle
        deviceFunc.funcBoolValue = queryNotifySwitch()//查询服务器的当前值
        dataArray = [
            deviceFunc
        ]
        tableView.reloadData()
    }
    
}

extension PushMsgSettingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataArray[indexPath.row]
        let cell:SwitchSettingCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! SwitchSettingCell
        cell.model = model
        cell.curIndexPath = indexPath
        // 点击按钮
        cell.valueChangedAction = { [weak self] aswitch , curIndex in
            self?.switchValueChangedForTitle(isOpen: aswitch.isOn,curIndex, model.funcName)
        }
        return cell
    }
    
    // 开关值变化
    func switchValueChangedForTitle(isOpen : Bool,_ curIdex: IndexPath, _ title:String) {
        
        currentCell = tableView.cellForRow(at: curIdex) as? SwitchSettingCell
        switch title {
        case alamTitle:
            enableNotify(enable: isOpen)
            break
        default:
            break
        }
    }
    
}

extension PushMsgSettingVC{
    
    //推送开关控制接口
    func enableNotify(enable:Bool){
        
        guard let sdk = AgoraIotManager.shared.sdk else { return }
        sdk.notificationMgr.enableNotify(enable: enable, result: {[weak self] ec, msg in
            if (ec !=  ErrCode.XOK) {
                debugPrint("\(msg)")
                AGToolHUD.showInfo(info: msg)
                self?.currentCell?.aSwitch.isOn = !enable
                return
            }
            AGToolHUD.showInfo(info: "告警消息开关设置成功！")
        })
        
    }
    
    //查询推送开关状态接口
    func queryNotifySwitch()->Bool{
        
        guard let sdk = AgoraIotManager.shared.sdk else { return false}
        let isOpen = sdk.notificationMgr.notifyEnabled()
        return isOpen
        
    }
    
    func checkPushNotification(checkNotificationStatus isEnable : ((Bool)->())? = nil){

            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in

                    switch setttings.authorizationStatus{
                    case .authorized:
                        print("enabled notification setting")
                        isEnable?(true)
                    case .denied:
                        print("setting has been disabled")
                        isEnable?(false)
                    case .notDetermined:
                        print("something vital went wrong here")
                        isEnable?(false)
                    case .provisional:
                        isEnable?(false)
                    case .ephemeral:
                        isEnable?(false)
                    @unknown default:
                        isEnable?(false)
                    }
                }
            } else {

                let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
                if isNotificationEnabled == true{
                    print("enabled notification setting")
                    isEnable?(true)
                }else{
                    print("setting has been disabled")
                    isEnable?(false)
                }
            }
        }


}
