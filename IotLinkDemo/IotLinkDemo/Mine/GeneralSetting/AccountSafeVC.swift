//
//  AccountSafeVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit
import AgoraIotLink

private let kCellID = "AccountSafeCell"
private let kBtnHeight:CGFloat = 40

class AccountSafeVC: UIViewController {

    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    fileprivate lazy var loginVM = LoginMainVM()
    
    private var dataArray = [String]()

    //private let modifyPwdTitle = "修改密码"
    private let destoryAccTitle = "cancelAccount".L
    
    private let bgColor = UIColor.white
    
    // MARK: - lazy
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        return tableV
    }()
    
    private lazy var logoutButton: UIButton  = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hexRGB: 0x262626), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle("logOut".L, for: .normal)
        button.layer.cornerRadius = kBtnHeight * 0.5
        button.layer.borderColor = UIColor(hexRGB: 0x000000, alpha: 0.85).cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickLogoutButton), for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        navigationItem.title = "accountSecurity".L
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(GeneralSettingCell.self, forCellReuseIdentifier: kCellID)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = bgColor
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-64)
            make.width.equalTo(120)
            make.height.equalTo(kBtnHeight)
        }
    }
    
    private func setupData(){
        dataArray = [
            //modifyPwdTitle,
            destoryAccTitle
        ]
        tableView.reloadData()
    }
    
    // 退出登录
    @objc private func didClickLogoutButton(){
        doLogOut()
    }
    
}

extension AccountSafeVC{
    
    //退出登陆
    func doLogOut(){
        
        iotsdk.release()
        TDUserInforManager.shared.userSignOut()
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: true)
        DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
        
//        loginVM.doLogOut{ [weak self] success, msg in
//
//            if success {
//                AGToolHUD.showInfo(info: "退出登录成功")
//                debugPrint("退出登录成功")
//                TDUserInforManager.shared.userSignOut()
//                self?.tabBarController?.selectedIndex = 0
//                self?.navigationController?.popToRootViewController(animated: true)
//                DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
//            }else{
//                AGToolHUD.showInfo(info: msg)
//            }
//            print("\(msg)")
//        }
        
    }
    
}

extension AccountSafeVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GeneralSettingCell = tableView.dequeueReusableCell(withIdentifier:kCellID, for: indexPath) as! GeneralSettingCell
        cell.setTitle(dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = dataArray[indexPath.row]
        switch title {
//        case modifyPwdTitle:
//            showModifyPwdVC()
//            break
        case destoryAccTitle:
            destoryAccountClick()
            break
        default:
            break
        }
    }
    
    // MARK: - 下一页
    // 消息推送设置
//    private func showModifyPwdVC(){
//        let vc = ModifyPwdVC()
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    //注销账号
    private func destoryAccountClick(){
        
        AGToolHUD.showInfo(info: "not supported yet".L)
//        AGAlertViewController.showTitle("确定注销您的账号吗？", message: "如果您确定注销您的账号，我们立即删除您账户中的个人数据，感谢您的使用!") {[weak self] in
//            self?.destoryAccount()
//        }
    }
    
    //注销账号
    private func destoryAccount(){
        AGToolHUD.showNetWorkWait()
        let account = TDUserInforManager.shared.getKeyChainAccount()
//        DoorBellManager.shared.unregister(account: account) {[weak self] success, msg in
//            AGToolHUD.disMiss()
//            if success == true{
//                AGToolHUD.showInfo(info: "账号已注销")
//                TDUserInforManager.shared.userSignOut()
//                self?.navigationController?.popToRootViewController(animated: true)
//                DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
//            }else{
//                AGToolHUD.showInfo(info: msg)
//            }
//        }
        
    }
}
