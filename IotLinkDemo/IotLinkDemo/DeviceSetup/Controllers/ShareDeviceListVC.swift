//
//  ShareDeviceListVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh
import AgoraIotLink

private let kCellID = "ShareDeviceInfoCell"

struct ShareDeviceInfo {
    
    var headImage:String = ""
    var nickname:String = ""
    var account:String = ""
}

class ShareDeviceListVC: UIViewController {

    var device: IotDevice?
    
    var dataArray = [DeviceCancelable]()
    
    fileprivate lazy var  deviceShareVM = DeviceShareViewModel()
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 68
        tableV.backgroundColor = .white
        tableV.emptyDataSetSource = self
        tableV.emptyDataSetDelegate = self
        tableV.tableHeaderView = headerView
        tableV.register(ShareDeviceInfoCell.self, forCellReuseIdentifier: kCellID)
        tableV.tableFooterView = UIView()
        return tableV
    }()
    
    private lazy var topLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        return label
    }()
    
    private lazy var headerView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.bottom.equalTo(-10)
        }
        return view
    }()
    

    lazy var addButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("添加共享", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = UIColor(hexRGB: 0x1A1A1A)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickAddShareButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    private func setupUI() {
        self.title = "共享设备"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-100)
            make.width.equalTo(285)
            make.height.equalTo(56)
        }
    }
    
    private func setupData(){
        
//        dataArray = [
//            ShareDeviceInfo(headImage: "https://img2.baidu.com/it/u=976187030,237040006&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", nickname: "昵称", account: "13234**832"),
//            ShareDeviceInfo(headImage: "https://img2.baidu.com/it/u=976187030,237040006&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", nickname: "昵称", account: "13234**832"),
//            ShareDeviceInfo(headImage: "https://img2.baidu.com/it/u=976187030,237040006&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", nickname: "昵称", account: "13234**832")
//        ]
//        self.topLabel.text = dataArray.count > 0 ? "可视门铃已共享给" : "可视门铃暂未共享给其他人"
//        tableView.reloadData()
        
        //------------以上为本地数据------------
        
        AGToolHUD.showNetWorkWait()
        guard let device = device else { return }
        deviceShareVM.cancelShare(device: device) {[weak self] success, msg,deviceCancelable in
            AGToolHUD.disMiss()
            if success == true {
                
                AGToolHUD.showInfo(info: "共享设备列表获取成功")
                guard let dataArr = deviceCancelable else{ return }
                self?.dataArray = dataArr
//                for deviceLable in dataArr {
//                    self?.dataArray.append(ShareDeviceInfo(headImage:deviceLable.avatar, nickname: deviceLable.deviceNickname, account: deviceLable.email))
//                }
                self?.topLabel.text = self?.dataArray.count ?? 0 > 0 ? "可视门铃已共享给" : "可视门铃暂未共享给其他人"
                self?.tableView.reloadData()
                
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        
        
        
    }
    
    // 点击添加共享
    @objc private func didClickAddShareButton(){
        let vc = DeviceAddShareVC()
        vc.device = device
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension ShareDeviceListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:ShareDeviceInfoCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! ShareDeviceInfoCell
        cell.set(nickname: cellData.phone, account: cellData.appuserId, headImg: cellData.avatar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ShareDeviceDetailVC()
        vc.cancelUser =  dataArray[indexPath.row]
        vc.device = device
        navigationController?.pushViewController(vc , animated: true)
    }
}


extension ShareDeviceListVC: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let customView = UIView()
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "暂无共享给其他人\n请添加"
        titleLabel.textColor = UIColor(hexRGB: 0x000000, alpha: 0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        customView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(customView.snp.centerY).offset(-20)
        }
        
        customView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        return customView
    }
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
        
    }
}
