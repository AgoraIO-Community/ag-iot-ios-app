//
//  MinePageMainVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit
import AgoraIotLink
import Alamofire

class MineCellData {
    var imgName:String = ""
    var title:String = ""
    var subTitle:String = ""
    var showDot: Bool = false
    
    init(imgName: String, title: String) {
        self.imgName = imgName
        self.title = title
    }
}

private let kCellID = "MineCell"

class MinePageMainVC: AGBaseVC {

//    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    var dataArray = Array<MineCellData>()
    private let messageTitle = "messageCenter".L
    private let settingTitle = "generalSettings".L
    private let aboutTitle = "about".L
    private var userInfo :UserInfo?
    var message: MineCellData?
    var alamUnreadCount: UInt = 0 {
        didSet{
            message?.showDot = alamUnreadCount + notifyUnrendCount > 0
            tableView.reloadData()
        }
    }
    var notifyUnrendCount: UInt = 0 {
        didSet{
            message?.showDot = alamUnreadCount + notifyUnrendCount > 0
            tableView.reloadData()
        }
    }
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableV.tableHeaderView = mineHeaderView
        return tableV
    }()
    
    lazy var tipsView:NetworkTipsView = {
        let tips = NetworkTipsView()
        return tips
    }()
    
    private lazy var mineHeaderView:MineTopView = {
        let topView = MineTopView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 150))
    
        topView.clickArrowButtonAction = {[weak self] in
            let vc = PersonalInfoVC()
            vc.userInfo = self?.userInfo
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    
        return topView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        updateUIWithUserModel()
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: cNetChangeNotify), object: nil, queue: nil) {[weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIWithUserModel()
    }
    
    private func updateUIWithUserModel(){
        var account = TDUserInforManager.shared.getKeyChainAccount()
        
        let nodeId = sdk?.getUserNodeId()
        self.mineHeaderView.setHeadImg(userInfo?.avatar, name: account,count:DeviceManager.shared.devices?.count ?? 0,uid: nodeId ?? "")

        
        // 如果是电话号码，隐藏中间4位
//        if account.checkPhone() {
//            let startIndex = account.startIndex
//            account.replaceSubrange(account.index(startIndex, offsetBy: 3)...account.index(startIndex, offsetBy: 6), with: "****")
//        }
//        AgoraIotManager.shared.sdk?.accountMgr.getAccountInfo(result: { [weak self] _, _, userInfo in
////            let uid:String = DeviceManager.shared.sdk?.accountMgr.getUserId() ?? ""
//            let nodeId = sdk?.getUserNodeId()
//            self?.mineHeaderView.setHeadImg(userInfo?.avatar, name: account,count:DeviceManager.shared.devices?.count ?? 0,uid: nodeId ?? "")
//            self?.userInfo = userInfo
//            if(self?.userInfo?.sex == 0){
//                self?.userInfo?.sex = 1
//            }
//            if(self?.userInfo?.age == 0){
//                self?.userInfo?.age = 10
//            }
//        })
//        // 更新是否有告警消息
//        AgoraIotManager.shared.sdk?.alarmMgr.queryCount(productId: nil, deviceId: nil, messageType: nil, status: 0, createDateBegin: nil, createDateEnd: nil, result: {[weak self] _, _, count in
//            DispatchQueue.main.async {
//                self?.alamUnreadCount = count
//            }
//        })
//        // 更新是否有通知消息
//        if let ids = DeviceManager.shared.deviceIds {
//            AgoraIotManager.shared.sdk?.alarmMgr.querySysCount(productId: nil, deviceIds: ids, messageType: nil, status: 0, createDateBegin: nil, createDateEnd: nil, result: {[weak self] ec, msg, count in
//                DispatchQueue.main.async {
//                    self?.notifyUnrendCount = count
//                }
//            })
//        }
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(MinePageCell.self, forCellReuseIdentifier: kCellID)
        tableView.tableFooterView = UIView()
    }
    
    private func setupData(){
//        message = MineCellData(imgName: "mine_diamond", title: messageTitle)
        let setting = MineCellData(imgName: "mine_diamond", title: settingTitle)
        let about = MineCellData(imgName: "mine_vip", title: aboutTitle)
        
        dataArray = [
//            message!,
            setting,
            about,
        ]
        tableView.reloadData()
    }
    
    // 点击消息中心
    private func didSelectMessageCell(){
        let vc = MessageCenterVC()
        vc.alamUnreadCount = Int(alamUnreadCount)
        vc.notifyUnreadCount = Int(notifyUnrendCount)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 点击通用设置
    private func didSelectSettingCell(){
        let vc = GeneralSettingVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 点击关于
    private func didSelectAboutCell(){
        let vc = AboutVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension MinePageMainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:MinePageCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! MinePageCell
        cell.setImgName(cellData.imgName, title: cellData.title,subTitle: cellData.subTitle, showDot: cellData.showDot)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tipsView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NetworkReachabilityManager.default?.status == .notReachable ? 44 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = dataArray[indexPath.row]
        switch cellData.title {
        case messageTitle:
            didSelectMessageCell()
            break
        case settingTitle:
            didSelectSettingCell()
            break
        case aboutTitle:
            didSelectAboutCell()
            break
        default:
            break
        }
    }

}
