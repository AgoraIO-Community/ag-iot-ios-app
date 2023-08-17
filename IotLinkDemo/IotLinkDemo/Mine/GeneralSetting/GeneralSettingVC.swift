//
//  GeneralSettingVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit

private let kCellID = "GeneralSettingCell"

class GeneralSettingVC: AGBaseVC {

    
    private var dataArray = Array<Array<String>>()

    private let pushMsgTitle = "messages".L
    private var versionTitle = "检查应用更新"
    private let accountSafeTitle = "accountSecurity".L
    private let systemSetUpTitle = "systemPermissionSettings".L
    private let appIdTitle = "Clear AppId data".L
    
    private let bgColor = UIColor(hexRGB: 0xF6F6F6)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    
    private func setupUI() {
        navigationItem.title = "generalSettings".L
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(GeneralSettingCell.self, forCellReuseIdentifier: kCellID)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = bgColor
    }

    
    private func setupData(){
        dataArray = [
            [
//                pushMsgTitle,
//                versionTitle,
                accountSafeTitle,
//                systemSetUpTitle,
                appIdTitle,
            ],
        ]
        tableView.reloadData()
    }

    // MARK: - lazy
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        return tableV
    }()
    
}

extension GeneralSettingVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GeneralSettingCell = tableView.dequeueReusableCell(withIdentifier:kCellID, for: indexPath) as! GeneralSettingCell
        cell.setTitle(dataArray[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = bgColor
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = bgColor
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == dataArray.count - 1 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = dataArray[indexPath.section][indexPath.row]
        switch title {
        case pushMsgTitle:
            showPushMsgSettingVC()
            break
        case versionTitle:
            
            break
        case accountSafeTitle:
            showAccountSafeVC()
            break
        case systemSetUpTitle:
            showSystemSettingVC()
            break
        case appIdTitle:
            showAppIdClearAlert()
            break
        default:
            break
        }
    }
    
    // MARK: - 下一页
    // 消息推送设置
    private func showPushMsgSettingVC(){
        let vc = PushMsgSettingVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 账号安全
    private func showAccountSafeVC(){
        let vc = AccountSafeVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 系统设置
    private func showSystemSettingVC(){
        let vc = SystemSettingVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAppIdClearAlert(){
        AGAlertViewController.showTitle("Clear AppId data".L, message: "温馨提示：清除AppId数据后，应用将自动退出,需重新启动应用才生效") {
            TDUserInforManager.shared.clearMasterAppId()
            TDUserInforManager.shared.userSignOut()
            AGToolHUD.showInfo(info: "已清除appId,应用即将自动退出,请重新打开")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                TDUserInforManager.shared.exitApplication()
            }
        }
    }

}
