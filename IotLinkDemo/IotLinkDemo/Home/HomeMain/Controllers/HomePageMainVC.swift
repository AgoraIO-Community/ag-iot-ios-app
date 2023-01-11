//
//  HomePageMainVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit
import SnapKit
import DZNEmptyDataSet
import AgoraIotLink
import Alamofire
import MJRefresh
import SVProgressHUD
import SwiftDate


// 网络监测通知
let cNetChangeNotify = "cNetChangeNotify"
//添加新设备通知（蓝牙配网）
let cAddDeviceSuccessNotify = "cAddDeviceSuccessNotify"

private let kCellID = "HomeMainDeviceCell"



class HomePageMainVC: AGBaseVC {
    
    var dataSource:[[IotDevice]] = [[IotDevice]]()
    var shareDevieces = [IotDevice]()
    
    // 告警消息时间
    var alarmDates = [String: UInt64]()

    lazy var topView:MainTopView = {
        let topView = MainTopView()
        topView.clickAddButtonAction = {[weak self] in
            self?.addDevice()
        }
        return topView
    }()
    
    lazy var tipsView:NetworkTipsView = {
        let tips = NetworkTipsView()
        return tips
    }()
    
    lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(HomeMainDeviceCell.self, forCellReuseIdentifier: kCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoginState()
        addObserver()
        setUpUI()
        // 监听网络状态
        startListeningNetStatus()
        // 添加下拉刷新
        addRefresh()
        
    }
    
    // 收到共享设备
    func showReceiveShareDevice(shareInfo: ShareItem) {
        let vc = ReceiveDeviceShareVC()
        vc.shareInfo = shareInfo
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏导航栏
        navigationController?.navigationBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 显示导航栏
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(TDUserInforManager.shared.isLogin){
            getDevicesArray()
        }
        //checkNewShareDevice()
    }
    
     //检查用户登录状态
    private func checkLoginState(){
        TDUserInforManager.shared.checkLoginState()
    }
    
    // 添加监听
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLoginSuccess), name: Notification.Name(cUserLoginSuccessNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAddDeviceSuccess), name: Notification.Name(cAddDeviceSuccessNotify), object: nil)
    }
    
    @objc private func receiveAddDeviceSuccess(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            // 获取设备列表
            self?.getDevicesArray()
            self?.getPropertyList();
            debugPrint("添加设备成功回调刷新")
        }
        
    }
    
    @objc private func receiveLoginSuccess(){
        // 获取设备列表
        getDevicesArray()
        getPropertyList();
    }
    
    // 设置UI
    private func setUpUI(){
        view.addSubview(topView)
        view.addSubview(tipsView)
        view.addSubview(tableView)
        topView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view)
            make.height.equalTo(110)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tipsView.snp.bottom)
        }
    }
    
    // 添加设备
    @objc private func addDevice(){
        print("点击添加设备")
        let vc = QRCodeReaderVC()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        vc.getScanResult = { [weak self] resultStr in
            self?.showResetVC(resultStr: resultStr)
        }
    }
    
    private func showResetVC(resultStr:String){
        let resetVC = DeviceResetVC()
        resetVC.productKey = resultStr
        let resetNC = AGNavigationVC(rootViewController: resetVC)
        resetNC.modalPresentationStyle = .overFullScreen
        present(resetNC, animated: true)
    }
    
    // 监听网络状态
    private func startListeningNetStatus(){
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { [weak self] status in
            let height = status == .notReachable ? 44 : 0
            self?.tipsView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(self?.topView.snp.bottom ?? 0)
                make.height.equalTo(height)
            }
            self?.tipsView.isHidden = status != .notReachable
            
            var netType = "none"
            switch status {
                case .notReachable, .unknown:
                    netType = "none"
                case .reachable(.ethernetOrWiFi):
                    netType = "wifi"
                case .reachable(.cellular):
                    netType = "cellular"
             }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cNetChangeNotify), object: nil, userInfo: ["netType":netType])
        })
    }
    
    // 获取是否有设备分享给我
//    private func checkNewShareDevice(){
//        DeviceManager.shared.qureySharePushList(result: {[weak self] items in
//            if let shareInfo = items?.first {
//                self?.showReceiveShareDevice(shareInfo: shareInfo)
//            }
//        })
//    }
    
    // 获取消息列表
    private func loadAlarmDates() {
        // 清空原有字典
        alarmDates.removeAll()
        let sdk = AgoraIotManager.shared.sdk
        guard let alarmMgr = sdk?.alarmMgr else{ return }
        var query:IAlarmMgr.QueryParam
        let date = Date()
        let beginDate = Date(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0,second: 0)
        let endDate = Date(year: date.year, month: date.month, day: date.day, hour: 23, minute: 59,second: 59)
        query = IAlarmMgr.QueryParam(dateBegin: beginDate)
        query.createdDateEnd = endDate
       
        query.status = 0
        query.currentPage = 1
        query.pageSize = 50
        alarmMgr.queryByParam(queryParam: query) { [weak self] ec, msg, alarms in
            if(ec != ErrCode.XOK){
                debugPrint("查询告警记录失败")
//                SVProgressHUD.showError(withStatus: msg)
//                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            guard let alarmList = alarms else {
                return
            }
            
            for alarm:IotAlarm in alarmList {
                if let oldTime = self?.alarmDates[alarm.deviceId] {
                    self?.alarmDates[alarm.deviceId] = max(alarm.createdDate, oldTime)
                }else{
                    self?.alarmDates[alarm.deviceId] = alarm.createdDate
                }
            }
            self?.tableView.reloadData()
        }
    }
    private func getPropertyList(){
        DeviceManager.shared.displayPropertyList()
    }
    // 获取设备列表
    private func getDevicesArray(){
//        SVProgressHUD.show()
        DeviceManager.shared.updateDevicesList{[weak self] _, _, devs in
            guard let devices = devs else { return }
            var normalDevices = [IotDevice]()
            var shareDevieces = [IotDevice]()
            for dev in devices {
                if dev.sharer != "0" {
                    shareDevieces.append(dev)
                }else{
                    normalDevices.append(dev)
                }
            }
            TDUserInforManager.shared.currentDeviceCount = normalDevices.count
            self?.shareDevieces = shareDevieces
            self?.dataSource = [normalDevices,shareDevieces]
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.reloadData()
//            SVProgressHUD.dismiss()
            self?.loadAlarmDates()
        }
    }
    
    // 下拉刷新
    private func addRefresh(){
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.getDevicesArray()
        })
    }
}


extension HomePageMainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let devices = dataSource[section]
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && shareDevieces.count > 0 {
            return "我接收的共享"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = self.dataSource[indexPath.section][indexPath.row]
        let cell:HomeMainDeviceCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! HomeMainDeviceCell
        cell.setDevice(device, alarmDate: alarmDates[device.deviceId] ?? 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = self.dataSource[indexPath.section][indexPath.row]
        let dbVC = DoorbellContainerVC()
        dbVC.device = device
        navigationController?.pushViewController(dbVC, animated: true)
    }
}

extension HomePageMainVC: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let customView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "暂无设备"
        titleLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        customView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(customView.snp.centerY).offset(-20)
        }
        
        let button = UIButton(type: .custom)
        button.setTitle("添加设备", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.addTarget(self, action: #selector(addDevice), for: .touchUpInside)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(hexRGB: 0x1a1a1a)
        customView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(customView.snp.centerY).offset(20)
            make.width.equalTo(140)
            make.height.equalTo(56)
        }
        
        customView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        return customView
    }
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
        getDevicesArray()
    }
}
