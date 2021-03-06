//
//  MessagePlayerVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/13.
//

import UIKit
import SVProgressHUD
import AgoraIotLink
import SJVideoPlayer
import Alamofire

class MessagePlayerVC: UIViewController {
    
    var msgId: UInt64?
    
    private var isDownloading = false
    
    private var originBarTintColor:UIColor?
    private var originTitleTextAttributes:[NSAttributedString.Key :Any]?
    
    private lazy var player = {
        return playerView.player
    }()
    
    private lazy var playerView: DoorbellPlayerView = {
        let playerView = DoorbellPlayerView()
        playerView.clickDeleteButtonAction = { [weak self] in
            self?.playerView.pause()
            self?.player.isFitOnScreen = false
            self?.tryDeleteCurrentPlayingMsg()
        }
        playerView.clickDownloadButtonAction = {[weak self] in
            if self == nil {
                return
            }
            if self!.isDownloading {
                return
            }
            if let url =  self?.player.assetURL {
                self!.isDownloading = true
                self!.downloadCurrentPlayingVideo(url)
            }
        }
        return playerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = originBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = originTitleTextAttributes
    }

    
    private func setupUI(){
        view.backgroundColor = .black
        originBarTintColor = self.navigationController?.navigationBar.barTintColor
        originTitleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//        player.isFitOnScreen = true
    }
    
    private func setupData(){
        if msgId != nil {
            loadMsgDetailForId(msgId!)
        }
    }
    
    // ?????????????????????????????????
    private func tryDeleteCurrentPlayingMsg(){
        dismiss(animated: true)
        AGAlertViewController.showTitle("??????", message: "???????????????????????????????????????", cancelTitle: "??????", commitTitle: "??????") {[weak self] in
            if self?.msgId != nil {
                self?.deleteMessages(self?.msgId)                
            }
        }
    }
    
    // ????????????
    private func deleteMessages(_ id: UInt64? = nil ){
        var msgidList = [UInt64]()
        msgidList.append(id!)
        let sdk = AgoraIotManager.shared.sdk
        guard let alarmMgr = sdk?.alarmMgr else{ return }
        alarmMgr.delete(alarmIdList: msgidList) {[weak self] ec, err in
            if(ec != ErrCode.XOK){
                SVProgressHUD.showError(withStatus: "??????????????????\(err)")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            SVProgressHUD.showSuccess(withStatus: "????????????")
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // ??????????????????
    private func loadMsgDetailForId(_ msgId:UInt64) {
        
        let sdk = AgoraIotManager.shared.sdk
        guard let alarmMgr = sdk?.alarmMgr else{ return }
        SVProgressHUD.show()
        alarmMgr.queryById(alertMessageId:msgId, result: {[weak self] ec, err, alert in
            if(ec != ErrCode.XOK){
                SVProgressHUD.showError(withStatus: "????????????????????????\(err)")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            guard let msg = alert else {
                SVProgressHUD.dismiss()
                return
            }
            guard let url = URL(string: msg.fileUrl) else {
                SVProgressHUD.showError(withStatus: "????????????????????????")
                SVProgressHUD.dismiss(withDelay: 2)
                return
            }
            self?.player.urlAsset =  SJVideoPlayerURLAsset(url: url)
            SVProgressHUD.dismiss()
        })
    }

    // ??????
    func downloadCurrentPlayingVideo(_ url:URL){
        DoorbellDownlaodManager.shared.download(url: url)
        DownloadProgressVC.show()
    }
}
