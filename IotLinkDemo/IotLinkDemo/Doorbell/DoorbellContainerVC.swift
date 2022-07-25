//
//  DoorbellContainerVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/5.
//

import UIKit
import JXSegmentedView
import AgoraIotLink

//被动呼叫挂断的通知（被动呼叫）
let cRemoteHangupNotify = "cRemoteHangupNotify"
//被动呼叫按下电源键挂断的通知（被动呼叫）
let cRemoteSysHangupNotify = "cRemoteSysHangupNotify"
//被动呼叫中的通知（用户当前页收到被动呼叫）
let cReceiveCallNotify = "cReceiveCallNotify"


class DoorbellContainerVC: UIViewController {
    
    var device: IotDevice?
    
    //是否来自被动呼叫
    var isReceiveCall : Bool = false
    
    private let msgVC = DoorbellMessageVC()
    private let abilityVC = DoorbellAbilityVC()
    
    private var originBarTintColor:UIColor?
    private var originTitleTextAttributes:[NSAttributedString.Key :Any]?

    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView()
    var lineV =  UIView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    //是否横屏
    var isHorizonFull : Bool = false
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if isHorizonFull == true {
            return .landscapeRight
        }else{
            return .portrait
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()

        self.title = "智能门铃"
        view.backgroundColor = UIColor(hexString: "#000000")
        originBarTintColor = self.navigationController?.navigationBar.tintColor
        originTitleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
        
        //配置数据源
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titles = ["功能","消息"]
        dataSource.titleNormalColor = UIColor(hexRGB: 0xC9C9C9)
        dataSource.titleSelectedColor = UIColor(hexRGB: 0xFFFFFF)
        segmentedDataSource = dataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorColor = UIColor(hexRGB: 0x2DA4FF)
        segmentedView.indicators = [indicator]
        segmentedView.backgroundColor = UIColor(hexRGB: 0x000000)
        
        segmentedView.dataSource = dataSource
        segmentedView.delegate = self
        
        view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-safeAreaBottomSpace())
            make.height.equalTo(50)
        }

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(segmentedView.snp.top)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexRGB: 0x5B5B5B)
        view.addSubview(lineView)
        lineV = lineView
        lineView.snp.makeConstraints { make in
            make.left.right.equalTo(segmentedView)
            make.bottom.equalTo(segmentedView.snp.top)
            make.height.equalTo(1)
        }
        
        addRightBarButtonItem()
        handelDoorBellFull()
        
        if isReceiveCall == true {
            setUpAnswerView()
        }
  
    }
    
    // 注册通知
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRemoteHangup), name: Notification.Name(cRemoteHangupNotify), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSysPressHangup), name: Notification.Name(cRemoteSysHangupNotify), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUpAnswerView), name: Notification.Name(cReceiveCallNotify), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addRightBarButtonItem() {
        navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "doorbell_back")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didClickRightBarButton(_:)))
    }
    
    @objc func leftBtnDidClick(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didClickRightBarButton(_ item: UIBarButtonItem){
        let vc = DeviceSetupHomeVC()
        vc.device = device
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //收到呼叫弹框页面
    @objc func setUpAnswerView() {
        
        view.addSubview(logicAnswerView)
        logicAnswerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        logicAnswerView.deviceName = device?.deviceName
        
    }
    
    lazy var logicAnswerView: DoorbellAnswerLogicView = {
       
        let view = DoorbellAnswerLogicView()
        view.callAnswerBtnBlock = { [weak self] in
            self?.logicAnswerView.removeFromSuperview()
        }
        view.callAnswerHungUpBlock = { [weak self] in
            self?.logicAnswerView.removeFromSuperview()
            self?.leftBtnDidClick()
        }
        return view
        
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.view.backgroundColor = MainColor
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = originTitleTextAttributes
    }
}

extension DoorbellContainerVC: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //先更新数据源的数据
            dotDataSource.dotStates[index] = false
            //再调用reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }

//        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

extension DoorbellContainerVC: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        switch index {
        case 1:
            msgVC.device = device
            return msgVC
        default:
            abilityVC.device = device
            abilityVC.containerVC = self
            abilityVC.isReceiveCall = isReceiveCall
            return abilityVC
        }
    }
}

//被动呼叫通知相关操作
extension DoorbellContainerVC{
    
    @objc private func receiveRemoteHangup(){
        // 挂断来电通知，隐藏呼叫弹框
        logicAnswerView.removeFromSuperview()
        leftBtnDidClick()
    }
    
    @objc private func receiveSysPressHangup(){
        
        guard isReceiveCall == true else { return }
        // 按下系统电源键挂断电话
        DoorBellManager.shared.hungUpAnswer { success, msg in
            if success {
                debugPrint("挂断成功")
            }else{
                AGToolHUD.showInfo(info: msg)
            }
        }
        logicAnswerView.removeFromSuperview()
        leftBtnDidClick()
    }
    
}

//门铃控制容器类横竖屏操作
extension DoorbellContainerVC {
    
    func handelDoorBellFull(){
        
        abilityVC.doorVCFullHBlock = { [weak self] in
            self?.doorVCFull()
        }
        
        abilityVC.doorVCBackVBlock = { [weak self] in
            self?.doorVCBackV()
        }
    }
    
    func doorVCFull(){
        isHorizonFull = true
        lineV.isHidden = true
        segmentedView.isHidden = true
        segmentedView.contentScrollView?.isScrollEnabled = false
        listContainerView.snp.remakeConstraints(){ make in
            make.left.top.bottom.right.equalToSuperview()
        }
    }
    
    func doorVCBackV(){
        isHorizonFull = false
        lineV.isHidden = false
        segmentedView.isHidden = false
        segmentedView.contentScrollView?.isScrollEnabled = true
        listContainerView.snp.remakeConstraints(){ make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(segmentedView.snp.top)
        }
    }
    
}
