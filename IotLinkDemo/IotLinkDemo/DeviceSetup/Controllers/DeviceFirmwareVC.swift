//
//  DeviceFirmwareVC.swift
//  IotLinkDemo
//
//  Created by ADMIN on 2022/8/4.
//

import Foundation

import UIKit
import AgoraIotLink
import SVProgressHUD

private let kCellID = "DeviceFirmwareVC"

class DeviceFirmwareVC: UIViewController {
    var device :IotDevice!
    var firmwareInfo : FirmwareInfo? = nil
    private var dataArray = [DeviceSetupHomeCellData]()
    private let deviceIDTitle = "设备固件升级"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.title = "设备固件升级"
        if(firmwareInfo == nil){
            SVProgressHUD.show()
            AgoraIotLink.iotsdk.deviceMgr.otaGetInfo(deviceId: device.deviceId) { ec, msg, info in
                SVProgressHUD.dismiss()
                if(ErrCode.XOK == ec){
                    guard let info = info else{
                        return
                    }
                    self.firmwareInfo = info
                    self.setupUI()
                    
                }
            }
            return
        }
        
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            //make.edges.equalTo(UIEdgeInsets.zero)
            //make.center.equalToSuperview()
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.size.equalTo(view.size)
            //make.width.equalTo(300)
        }
        
        view.addSubview(warning)
        warning.snp.makeConstraints{ make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
           // make.width.equalTo(view.snp.width)
        }
        warning.isHidden = true
    }
    
    lazy var warning:UIView = {
        let warn = UILabel()
        
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "请注意:升级过程中", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]));
        text.append(NSAttributedString(string: "不能断电\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]));
        text.append(NSAttributedString(string: "否则会由于突然断电导致升级失败\n", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        text.append(NSAttributedString(string: "机器可能会无法开机", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
        warn.attributedText = text
    
        warn.lineBreakMode = .byWordWrapping
        warn.width = 300
        warn.numberOfLines = 3
        warn.textAlignment = .center
        warn.sizeToFit()
        return warn
    }()
    
    lazy var infoView:UIView = {
        //firmwareInfo!.isUpgrade = true
        let ver = "最新版本号:" + (firmwareInfo?.upgradeVersion ?? "")
        let hint = firmwareInfo?.isUpgrade == false ? "已经是最新版本" : ver
        
        let remark:String = firmwareInfo!.remark
        let update = firmwareInfo?.isUpgrade == false ? ("当前版本号:" + firmwareInfo!.currentVersion) : "\n更新内容:\n\(remark)"
        let view = AGConfirmView(title: hint, message: update, showButton: firmwareInfo!.isUpgrade)
        
        view.clickCancelButtonAction = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        view.clickCommitButtonAction = {[weak self] in
            let upgradeId = String(self?.firmwareInfo!.upgradeId ?? "")
            AGToolHUD.showUpgrading()
            var cnt:Int = 0
            var timer:Timer? = nil
            self?.warning.isHidden = false
            AgoraIotLink.iotsdk.deviceMgr.otaUpgrade(upgradeId: upgradeId) { ec, msg in
                if(ec != ErrCode.XOK){
                    log.e("otaUpgrade failed:" + msg)
                    AGToolHUD.disMiss()
                    AGToolHUD.showInfo(info:msg)
                    self?.warning.isHidden = true
                }
                else{
                    timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { [weak self](_) in
                        AgoraIotLink.iotsdk.deviceMgr.otaQuery(upgradeId: upgradeId, result:{ec,msg,status in
                            log.i("otaQuery ret cnt:\(cnt) status:\(status?.status) msg:\(msg)")
                            cnt = cnt + 1
                            if(cnt > 76){//timeout exception，granwin expires in 4min
                                timer?.invalidate()
                                self?.warning.isHidden = true
                                AGToolHUD.disMiss()
                                if(ec == ErrCode.XERR_NETWORK){
                                    AGToolHUD.showInfo(info: "本地网络异常，无法获取升级状态")
                                }
                                else if(ec != ErrCode.XOK){
                                    AGToolHUD.showInfo(info:"更新固件失败")
                                }
                                else{
                                    AGToolHUD.showInfo(info:"更新固件超时")
                                }
                            }
                            else{
                                if(status?.status == 1){
                                    timer?.invalidate()
                                    AGToolHUD.disMiss()
                                    AGToolHUD.showInfo(info:"更新固件成功")
                                    self?.warning.isHidden = true
                                    self?.navigationController?.popViewController(animated: true)
                                }
                                else if(status?.status == 2){
                                    timer?.invalidate()
                                    AGToolHUD.disMiss()
                                    AGToolHUD.showInfo(info:"更新固件失败")
                                    self?.warning.isHidden = true
                                }
                                else if(status?.status == 3){
                                    timer?.invalidate()
                                    AGToolHUD.disMiss()
                                    AGToolHUD.showInfo(info:"更新固件取消")
                                    self?.warning.isHidden = true
                                }
                                else if(status?.status == 4){
                                    timer?.invalidate()
                                    AGToolHUD.disMiss()
                                    AGToolHUD.showInfo(info:"固件待升级")
                                }
                                else if(status?.status == 5){
                                    //AGToolHUD.disMiss()
                                    //AGToolHUD.showInfo(info:"固件升级中")
                                }
                                else{
                                    timer?.invalidate()
                                    AGToolHUD.disMiss()
                                    AGToolHUD.showInfo(info:"异常返回值")
                                    self?.warning.isHidden = true
                                }
                            }
                        })
                    })
                }
            }
        }
        return view
    }()
    
    private func setupData(){
        if(firmwareInfo == nil){
            SVProgressHUD.show()
            AgoraIotLink.iotsdk.deviceMgr.otaGetInfo(deviceId: device.deviceId) { ec, msg, info in
                SVProgressHUD.dismiss()
                if(ErrCode.XOK == ec){
                    guard let info = info else{
                        return
                    }
                    self.firmwareInfo = info
                    self.setupUI()
                    //AGFirmwareVC.showInfo(info)
                }
            }
        }
        else{
            //AGFirmwareVC.showInfo(firmwareInfo!)
            //self.setupData()
        }
    }
    
    private func updateDeviceName(name: String){
        if device == nil {
            return
        }
        AgoraIotManager.shared.sdk?.deviceMgr.renameDevice(deviceId: device!.deviceId, newName: name, result:{[weak self] ec, msg in
            if(ec == ErrCode.XOK){
                //self?.headerView.name = name
                self?.device?.deviceName = name
            }else{
                SVProgressHUD.showError(withStatus: "修改失败:\(msg)")
            }
        })
    }
}

extension DeviceFirmwareVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataArray[indexPath.row]
        let cell:DeviceInfoCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! DeviceInfoCell
        cell.set(title: cellData.title, subTitle: cellData.subTitle)
        return cell
    }
}
