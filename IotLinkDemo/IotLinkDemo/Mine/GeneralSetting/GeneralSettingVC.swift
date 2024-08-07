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
    private let cacheTitle = "Clear cache data".L
    
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
                cacheTitle
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
        case cacheTitle:
            clearCacheData()
            break
        default:
            break
        }
    }
    
    // MARK: - 下一页
    // 消息推送设置
    private func showPushMsgSettingVC(){
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
        AGAlertViewController.showTitle("Clear AppId data".L, message: "clear application tip".L) {
            TDUserInforManager.shared.clearMasterAppId()
            TDUserInforManager.shared.userSignOut()
            AGToolHUD.showInfo(info: "appId has been cleared tip".L)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                TDUserInforManager.shared.exitApplication()
            }
        }
    }
    
    private func clearCacheData(){
        
        let fileManager = FileManager.default
            guard let folderPath = recordVideoFolder else {
                print("文件夹路径为空")
                return
            }
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: folderPath)
                for file in files {
                    let filePath = NSString(string: folderPath).appendingPathComponent(file)
                    try fileManager.removeItem(atPath: filePath)
                    print("删除文件：\(filePath)")
                }
            } catch {
                print("清除文件失败：\(error.localizedDescription)")
            }
        
    }
    
    //MARK: ----- property
    var recordVideoFolder: String? {//NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory
        if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            let direc = NSString(string: path).appendingPathComponent("VideoFile") as String
            if !FileManager.default.fileExists(atPath: direc) {
                try? FileManager.default.createDirectory(atPath: direc, withIntermediateDirectories: true, attributes: [:])
            }
            return direc
        }
        return nil
    }

}
