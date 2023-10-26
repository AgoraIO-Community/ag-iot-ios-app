//
//  CallFullScreemVC.swift
//  IotLinkDemo
//
//  Created by admin on 2023/6/1.
//

import UIKit

//添加新设备通知（蓝牙配网）
let ReceiveFirstVideoFrameNotify = "cReceiveFirstVideoFrameNotify"

class CallFullScreemVC: UIViewController {

    
    private var originBarTintColor:UIColor?
    private var originTitleTextAttributes:[NSAttributedString.Key :Any]?
    
    
    var CallFullScreemBlock:((_ sessionId : String) -> (Void))?
    
    var sessionId: String? {
        didSet{
            guard let sessionId = sessionId else {
                return
            }
            let statusCode : Int = sdk?.callkitMgr.setPeerVideoView(sessionId: sessionId, peerView:videoView) ?? 0
            debugPrint("statusCode:\(statusCode)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        sdk?.callkitMgr.mutePeerAudio(sessionId: "", mute: false, result: {ec,msg in})
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.view.backgroundColor = MainColor
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = originTitleTextAttributes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        view.backgroundColor = UIColor.lightGray
        addRightBarButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveFirstVideo), name: Notification.Name(ReceiveFirstVideoFrameNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(remoteHangup), name: Notification.Name(cRemoteHangupNotify), object: nil)
        
        registerMsgListener()
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func receiveFirstVideo(){//收到首帧
        let statusCode : Int = sdk?.callkitMgr.setPeerVideoView(sessionId: sessionId ?? "", peerView:videoView) ?? 0
        debugPrint("receiveFirstVideo statusCode:\(statusCode)")
    }
    
    @objc private func remoteHangup(){//收到对端挂断通知
        navigationController?.popViewController(animated: false)
    }
    
    // 设置UI
    private func setUpUI(){
        view.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.top.left.bottom.right.equalTo(view)
        }
        
        view.addSubview(accecptButton)
        accecptButton.snp.makeConstraints { make in
            make.top.equalTo(videoView.snp.bottom).offset(30)
            make.left.equalTo(15)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
    }
    
    lazy var videoView:UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var accecptButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("发送数据", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 50 * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sendMsgButton), for: .touchUpInside)
        return button
    }()

    @objc private func sendMsgButton(){
        let paramDic = ["key":"value","key1":"value1"]
        let paramStr = paramDic.convertDictionaryToJSONString()
        let ret = sdk?.callkitMgr.sendCommand(sessionId: sessionId!, cmd: paramStr, onCmdSendDone: { errCode in
            debugPrint("onCmdSendDone:\(errCode)")
        })
    }
    
    func registerMsgListener(){
        sdk?.callkitMgr.onReceivedCommand(receivedListener: { sessionId, cmd in
            debugPrint("onReceivedCommand:sessionId:\(sessionId),cmd:\(cmd)")
            AGToolHUD.showInfo(info: cmd)
        })
    }
    
    private func addRightBarButtonItem() {
        navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "doorbell_back")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
    }
    
    @objc func leftBtnDidClick(){
        CallFullScreemBlock?(sessionId ?? "")
        navigationController?.popViewController(animated: false)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
