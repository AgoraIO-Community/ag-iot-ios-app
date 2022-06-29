//
//  PersonalInfoVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit
import ZLPhotoBrowser
import AgoraIotSdk
import SVProgressHUD

private let kRightImageCellID = "kRightImageCellID"
private let kSubTitleCellID = "kSubTitleCellID"

class PersonalInfoVC: UIViewController {
    
    private var dataArray = [AGTitleCellData]()

    private let headTitle = "头像"
    private let  nicknameTitle = "昵称"
    
    private var headData: AGRightImageCellData?
    private var nicknameData: AGSubtitleCellData?
    
    private let bgColor = UIColor.white
    
    var userInfo:UserInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDataIfNeeded()
    }
    
    
    private func setupUI() {
        navigationItem.title = "个人资料"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        tableView.register(AGSubTitleCell.self, forCellReuseIdentifier: kSubTitleCellID)
        tableView.register(PersonalInfoCell.self, forCellReuseIdentifier: kRightImageCellID)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = bgColor
    }

    private func refreshData(){
        
        headData = AGRightImageCellData(title: headTitle, imagUrl: self.userInfo?.avatar ?? "")
//        nicknameData = AGSubtitleCellData(title: nicknameTitle, subtitle: self.userInfo?.name ?? "", showArrow: true)
        
        dataArray = [
            headData!,
//            nicknameData!
        ]
        tableView.reloadData()
    }
    
    private func loadDataIfNeeded(){
        if userInfo == nil {
            AgoraIotManager.shared.sdk?.accountMgr.getAccountInfo(result: { [weak self] _, _, userInfo in
                self?.userInfo = userInfo
                self?.refreshData()
            })
        }else{
            refreshData()
        }
    }

    // MARK: - lazy
    
    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        return tableV
    }()
    
    // MARK: -
    // 点击头像
    private func didSelectHeadCell(){
        
        showChangeSoundAlert()
        
//        AGActionSheetVC.showTitle("头像",alwaysHideIndicator: true, items: ["相册中选择","拍照","取消"], selectIndex: 0) {[weak self] item, index in
//            switch index {
//            case 0:
//                self?.showImagePickerVC()
//                break
//            case 1:
//                self?.showCameraVC()
//                break
//            default:
//                break
//            }
//        }
    }
    
    //头像选择弹框
    func showChangeSoundAlert(){

        let proAlertVC = SelectHeardImgVC()
        proAlertVC.selectHeardImgAlertBlock = { [weak self] (heardImage) in
            
            debugPrint("关闭头像选择弹框")
            self?.headData?.image = heardImage
            self?.uploadHeadImage(heardImage)
            self?.tableView.reloadData()
             
        }
        
        proAlertVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        proAlertVC.modalPresentationStyle = .overCurrentContext
        currentViewController().present(proAlertVC, animated: true, completion: nil)
        
    }
    
    private func showImagePickerVC(){
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = false
        config.allowTakePhoto = false
        config.maxSelectCount = 1
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] (images, assets, isOriginal) in
            self?.headData?.image = images.first
            self?.uploadHeadImage(images.first)
            self?.tableView.reloadData()
        }
        ps.showPhotoLibrary(sender: self)
    }
    
    private func showCameraVC(){
        let config = ZLPhotoConfiguration.default()
        config.allowTakePhoto = true
        config.allowRecordVideo = false
        let camera = ZLCustomCamera()
        camera.takeDoneBlock = { [weak self] (image, videoUrl) in
            self?.headData?.image = image
            self?.uploadHeadImage(image)
            self?.tableView.reloadData()
        }
        showDetailViewController(camera, sender: nil)
    }
    
    // 上传头像
    private func uploadHeadImage(_ image: UIImage?) {
        if image == nil {
            return
        }
        AgoraIotManager.shared.sdk?.accountMgr.updateHeadIcon(image: image!, result: { [weak self] ec, msg, url in
            if(ec == ErrCode.XOK){
                self?.userInfo?.avatar = url
                self?.updateHeadImge()
            }
        })
    }
    
    // 修改头像
    private func updateHeadImge(){
        if userInfo == nil {
            return
        }
        AgoraIotManager.shared.sdk?.accountMgr.updateAccountInfo(info: userInfo!, result: { ec, msg in
            if(ec != ErrCode.XOK){
                SVProgressHUD.showError(withStatus: "修改头像失败")
            }else{
                AGToolHUD.showInfo(info: "头像修改成功")
            }
        })
    }
    
    // 点击昵称
    private func showEditNicknameVC(){
        let vc = EditNicknameVC()
        vc.nickname = userInfo?.name
        vc.editSuccessAction = { [weak self] text in
            self?.nicknameData?.subtitle = text
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PersonalInfoVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        if cellData is AGRightImageCellData {
            let data = cellData as! AGRightImageCellData
            let cell:PersonalInfoCell = tableView.dequeueReusableCell(withIdentifier:kRightImageCellID, for: indexPath) as! PersonalInfoCell
            cell.set(title: data.title, headImgUrl: data.imagUrl, headImage: data.image)
            return cell
        }
        
        let data = cellData as! AGSubtitleCellData
        let cell: AGSubTitleCell = tableView.dequeueReusableCell(withIdentifier: kSubTitleCellID, for: indexPath) as! AGSubTitleCell
        cell.set(title: data.title, subTitle: data.subtitle, showArrow: data.showArrow)
        
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
        let data = dataArray[indexPath.row]
        switch data.title {
        case headTitle:
            didSelectHeadCell()
            break
        case nicknameTitle:
            showEditNicknameVC()
            break
        default:
            break
        }
    }
}


