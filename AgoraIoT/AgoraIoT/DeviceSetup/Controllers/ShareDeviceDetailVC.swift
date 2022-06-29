//
//  ShareDeviceDetailVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/19.
//

import UIKit
import AgoraIotSdk

private let buttonHeight: CGFloat = 40
private let kRightImageCellID = "kRightImageCellID"
private let kSubTitleCellID = "kSubTitleCellID"

class ShareDeviceDetailVC: UIViewController {

    var device: IotDevice?
    var cancelUser : DeviceCancelable?
    
    var dataArray = [AGTitleCellData]()
    private let headTitle = "头像"
    private let accountTitle = "账号"
    private let expireTitle = "有效期"
    
    private var accountData:DeviceSetupHomeCellData?
    
    fileprivate lazy var  deviceShareVM = DeviceShareViewModel()
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = .white
        tableV.register(AGSubTitleCell.self, forCellReuseIdentifier: kSubTitleCellID)
        tableV.register(AGRightImageCell.self, forCellReuseIdentifier: kRightImageCellID)
        tableV.tableFooterView = UIView()
        return tableV
    }()
    

    lazy var cancelButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消共享", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x262626), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = buttonHeight * 0.5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexRGB: 0x000000, alpha: 0.85).cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        self.title = "共享详情"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-100)
            make.width.equalTo(120)
            make.height.equalTo(buttonHeight)
        }
    }
    
    private func setupData(){
       
        var phoneNum =  cancelUser?.phone ?? ""
        if phoneNum.contains("+86") {
            let startIndex = phoneNum.startIndex
            phoneNum.replaceSubrange(phoneNum.index(startIndex, offsetBy: 0)...phoneNum.index(startIndex, offsetBy: 2), with: "")
        }
        
        let head = AGRightImageCellData(title: headTitle, imagUrl: cancelUser?.avatar ?? "")
        let account = AGSubtitleCellData(title: accountTitle, subtitle: phoneNum.replacePhone(), showArrow: false)
//        let expire = AGSubtitleCellData(title: expireTitle, subtitle: "永久有效", showArrow: true)
        dataArray = [
            head,
            account,
//            expire
        ]
        tableView.reloadData()
    }
    
    // 点击取消共享
    @objc private func didClickCancelButton(){
   
        AGAlertViewController.showTitle("确认取消共享", message: "您是否已确认要取消共享？") {[weak self] in
            self?.cancelShareAccount()
        }
    }
    
    func cancelShareAccount(){
  
        AGToolHUD.showNetWorkWait()
        guard let cancelUser = cancelUser else { return }

        deviceShareVM.removeMember(deviceId: cancelUser.deviceNumber, userId:cancelUser.appuserId) {[weak self] success, msg in
            AGToolHUD.disMiss()
            if success == true {
                AGToolHUD.showInfo(info: "已取消共享")
                self?.navigationController?.popViewController(animated: true)
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        
    }
    
    // 点击国家地区
    private func didSelectAreaCell(){

    }
    
    // 点击账号
    private func didSelectAccountCell(){
        AGEditAlertVC.showTitle("账号", editText: "老账号") { [weak self] value in
            self?.accountData?.subTitle = value
            self?.tableView.reloadData()
        }
    }

}


extension ShareDeviceDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        if cellData is AGRightImageCellData {
            let data = cellData as! AGRightImageCellData
            let cell:AGRightImageCell = tableView.dequeueReusableCell(withIdentifier: kRightImageCellID, for: indexPath) as! AGRightImageCell
            cell.set(title: data.title, imgUrl: data.imagUrl)
            return cell
        }
        let data = cellData as! AGSubtitleCellData
        let cell:AGSubTitleCell = tableView.dequeueReusableCell(withIdentifier: kSubTitleCellID, for: indexPath) as! AGSubTitleCell
        cell.set(title: data.title, subTitle: data.subtitle, showArrow: data.showArrow)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = dataArray[indexPath.row]
        switch cellData.title {
        case headTitle:
            didSelectAreaCell()
            break
        case accountTitle:
//            didSelectAccountCell()
            break
        case expireTitle:
            
            break
        default:
            break
        }
    }
}
