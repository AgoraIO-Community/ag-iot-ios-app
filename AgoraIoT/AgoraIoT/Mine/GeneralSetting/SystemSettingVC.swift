//
//  SystemSettingVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/13.
//

import UIKit

private let kCellID = "SystemSettingCell"


class SystemSettingVC: UIViewController {
    
    struct SystemCellData {
        var title = ""
        var info = ""
        var state = false
    }
    
    private let noticeTitle = "通知提醒"
    private var backgroundRunTitle = "允许后台运行"
    private var dataArray = [SystemCellData]()
    
    private let bgColor = UIColor(hexRGB: 0xF6F6F6)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    private func setupUI() {
        navigationItem.title = "系统权限设置"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(SystemSettingCell.self, forCellReuseIdentifier: kCellID)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = bgColor
    }
    
    @objc private func willEnterForground() {
        setupData()
    }
    
    private func setupData(){
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var isOpenNoti = false
            if(settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined) {
                isOpenNoti = false
            }else if settings.authorizationStatus == .authorized {
                isOpenNoti = true
            }
            
            let notice = SystemCellData(title: self.noticeTitle, info: "为及时收到报警消息，建议开启此选项", state: isOpenNoti)
            
//            var isSupport = false
//            let device = UIDevice.current
//            if device.responds(to: NSSelectorFromString("isMultitaskingSupported")) {
//                isSupport = device.isMultitaskingSupported
//            }
//
//            let bg =  SystemCellData(title: self.backgroundRunTitle, info: "为接收远程呼叫或通知，建议开启此选项", state: isSupport)
            self.dataArray = [notice]
            DispatchQueue.main.async {
                self.tableView.reloadData()                
            }
        }
    }
    

    // MARK: - lazy
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        return tableV
    }()
    
}

extension SystemSettingVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SystemSettingCell = tableView.dequeueReusableCell(withIdentifier:kCellID, for: indexPath) as! SystemSettingCell
        let data = dataArray[indexPath.row]
        cell.setTitle(data.title, info: data.info, state: data.state)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = dataArray[indexPath.row]
        switch data.title {
        case noticeTitle, backgroundRunTitle:
            showSettingVC()
            break
        default:
            break
        }
    }

    
    // 系统设置
    private func showSettingVC(){
        let url = URL(string: UIApplication.openSettingsURLString)
        UIApplication.shared.open(url!)
    }

}
