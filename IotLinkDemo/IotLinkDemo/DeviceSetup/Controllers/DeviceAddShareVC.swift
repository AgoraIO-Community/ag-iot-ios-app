//
//  DeviceAddShareVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import AgoraIotLink

private let kCellID = "DeviceInfoCell"

class DeviceAddShareVC: UIViewController {

    var device: IotDevice?
    
    var dataArray = [DeviceSetupHomeCellData]()
    private let areaTitle = "国家/地区"
    private let accountTitle = "账号"
    
    private var accountData:DeviceSetupHomeCellData?
    
    fileprivate lazy var  deviceShareVM = DeviceShareViewModel()
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = .white
        tableV.tableHeaderView = headerView
        tableV.register(DeviceInfoCell.self, forCellReuseIdentifier: kCellID)
        tableV.tableFooterView = UIView()
        return tableV
    }()
    
    private lazy var headerView:DeviceSetupHomeHeaderView = {
        let topView = DeviceSetupHomeHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 167))
        topView.setHeadImg("", name: "可视门铃")
        topView.showTitle = false
        topView.clickArrowButtonAction = {[weak self] in
            debugPrint("去分享详情")
        }
        return topView
    }()

    lazy var doneButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = UIColor(hexRGB: 0x1A1A1A)
        button.layer.cornerRadius = 28.S
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickDoneButton), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        self.title = "添加共享"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-100)
            make.width.equalTo(285)
            make.height.equalTo(56)
        }
    }
    
    private func setupData(){
       
        //去除国家选择需求注释
//        var countryName = "请选择国家/地区"
//        if TDUserInforManager.shared.curCountryModel?.countryName != nil {
//            countryName = TDUserInforManager.shared.curCountryModel?.countryName ?? ""
//        }
//        let area = DeviceSetupHomeCellData(title: areaTitle, subTitle: countryName)
        accountData = DeviceSetupHomeCellData(title: accountTitle)
        dataArray = [
//            area,
            accountData!
        ]
        tableView.reloadData()
    }
    
    // 点击完成
    @objc private func didClickDoneButton(){
        
        AGToolHUD.showNetWorkWait()
        guard let device = device, let account = accountData?.subTitle else { return }
        
        if device.userType == 1 {
            
            deviceShareVM.sharePushDeviceTo(device: device, account:account, type: "3") {[weak self] success, msg in
                
                AGToolHUD.disMiss()
                if success == true {
                    AGToolHUD.showInfo(info: "添加成功")
                    self?.navigationController?.popViewController(animated: true)
                }else{
                    AGToolHUD.showInfo(info: msg)
                }
                
            }
            
        }else {
            
            //暂时不需要
//            deviceShareVM.shareDeviceTo(device: device, account:account, type: "3") {[weak self] success, msg in
//
//                AGToolHUD.disMiss()
//                if success == true {
//                    AGToolHUD.showInfo(info: "添加成功")
//                    self?.navigationController?.popViewController(animated: true)
//                }else{
//                    AGToolHUD.showInfo(info: msg)
//                }
//
//            }
            
        }
    }
    
    // 点击国家地区
    private func didSelectAreaCell(){
        
        let  tempVC = CountrySelectVC()
        tempVC.countryArray = [CountryModel]()
        tempVC.countryVCBlock = { [weak self] (code,countryName) in
            
            let tempData = self?.dataArray[0]
            tempData?.subTitle = countryName
            self?.tableView.reloadData()

        }
        self.navigationController?.pushViewController(tempVC, animated: true)
        
    }
    
    // 点击账号
    private func didSelectAccountCell(){
        AGEditAlertVC.showTitle("账号", editText: "") { [weak self] value in
            self?.accountData?.subTitle = value
            self?.tableView.reloadData()
        }
    }

}


extension DeviceAddShareVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:DeviceInfoCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! DeviceInfoCell
        cell.showArrow = true
        let isPlaceholder = cellData.title == accountTitle && cellData.subTitle?.isEmpty ?? true
        if isPlaceholder {
            cellData.subTitle = "请输入账号"
        }
        cell.set(title: cellData.title, subTitle: cellData.subTitle, isPlaceholder: isPlaceholder)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = dataArray[indexPath.row]
        switch cellData.title {
        case areaTitle:
            didSelectAreaCell()
            break
        case accountTitle:
            didSelectAccountCell()
            break
        default:
            break
        }
    }
}
