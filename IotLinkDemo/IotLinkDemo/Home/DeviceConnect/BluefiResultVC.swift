//
//  BluefiResultVC.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/9/21.
//

import UIKit

enum connectState : Int{//设备连接成功状态
    
    ///默认
    case none = 0
    ///手机设备连接
    case deviceConnected = 1
    ///wifi连接
    case wifiConnected = 2
    ///云端连接
    case cloudConnected = 3
    ///连接失败
    case faliConnected = 4
}

private let kCellID = "BluefiResultCell"


class BluefiResultVC: UIViewController {

    //上个页面传入
    var wifiName:String = ""
    var password:String = ""
    var productKey:String!

    //bluFi
    let blueFi = ESPFBYBLEHelper.share()
    //blufiClient
    var bClient : BlufiClient?
    
    let filterContent = "BLUFI"
    
    var dataArray = [ESPPeripheral]()

    var currentModel = ESPPeripheral()
    
    
    //蓝牙搜索倒计时
    fileprivate let countDownNum:Int = 10
    fileprivate var startCount:Int = 0
    
    fileprivate var timer: Timer!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("蓝牙结果页面释放了")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
   
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //停止扫描
        blueFi.stopScan()
        //断开设备
        onDisconnected()
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //停止扫描
        blueFi.stopScan()
        //断开设备
        onDisconnected()
        
        setupSearchUI()
        startTimer()
        scanBlufi()
        
        addObserver()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
//            self?.connectView.selectBtn(0)
//        }

    }
    
    private func addObserver() {//设备添加成功
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAddDeviceSuccess(_:)), name: NSNotification.Name(AddDeviceSuccess), object: nil)
    }
    
    @objc private func receiveAddDeviceSuccess(_ noti: Notification) {
        let vc = DeviceAddSuccessVC()
        vc.deviceId = noti.userInfo?["deviceId"] as? String
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func setupSearchUI() {
        
       
        title = "搜索中"
        
        self.view.backgroundColor = UIColor(hexString: "#F2F6F7")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-86.VS)
        }

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-15.VS)
            make.centerX.equalToSuperview()
            make.width.equalTo(280.S)
            make.height.equalTo(56.VS)
        }
        
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(searchFailView)
        searchFailView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(connectFailView)
        connectFailView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(connectView)
        connectView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        
  
    }

    private lazy var tableView: UITableView  = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 56
        tableV.backgroundColor = UIColor(hexString: "#F2F6F7")
        tableV.register(BluefiResultCell.self, forCellReuseIdentifier: kCellID)
        tableV.allowsSelection = false
        tableV.isUserInteractionEnabled = true
        
        return tableV
    }()
    
    private lazy var nextButton:UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = UIColor(red: 63/255.0, green: 117/255.0, blue: 238/255.0, alpha: 0.8)
        button.isEnabled = true
        button.layer.cornerRadius = 28.VS
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)
        return button
        
    }()
    
    //搜索页面
    private lazy var searchView:SearchBluefiView = {
        
        let view = SearchBluefiView()
        view.searchNextBtnActionBlock = { [weak self] in
            self?.searchNextBtnAction()
        }

        return view
    }()
    
    //搜索失败页面
    private lazy var searchFailView:SearchFailBluefiView = {
        
        let view = SearchFailBluefiView()
        view.searchFailNextActionBlock = { [weak self] in
            self?.reTryScanBluefi()
        }
        view.isHidden = true
        return view
    }()
    
    //蓝牙配网页面
    private lazy var connectView:ConnectBluefiView = {
        
        let view = ConnectBluefiView()
        view.cancelConnectBtnActionBlock = { [weak self] in
            self?.cancelConnectBtnAction()
        }
        
        view.isHidden = true
        return view
    }()
    
    private lazy var connectFailView:ConnectFailBluefiView = {
        
        let view = ConnectFailBluefiView()
        view.connectFailNextActionBlock = { [weak self] in
            self?.connectFailView.isHidden = true
            self?.reTryScanBluefi()
        }
        
        view.isHidden = true
        return view
    }()

    //点击搜索结果页下一步，去连接设备
    @objc func didClickNextButton(){
        
        title = ""
        connectView.isHidden = false
        //停止扫描
        blueFi.stopScan()
        //连接设备
        connect()
        
    }
    
    //设备连接失败调用
    func connectFail(){
        title = "蓝牙连接失败"
        connectFailView.isHidden = false
    }
    
    //蓝牙搜索结果
    func searchNextBtnAction(){
        
        title = "蓝牙搜索结果"
        searchView.isHidden = true
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    //取消蓝牙配网流程
    func cancelConnectBtnAction(){
        
        title = "蓝牙搜索结果"
        connectView.resetSelectBtn()
        connectView.isHidden = true
        onDisconnected()
        
    }
    
    //蓝牙搜索超时调用（2分钟）
    func searchFailTimeOutAction(){
        
        if dataArray.count > 0 {//如果已搜索到结果，且到超时时间，自动跳转结果页
            searchNextBtnAction()
            return
        }
        
        title = "蓝牙搜索失败"
        //停止扫描
        blueFi.stopScan()
        //断开设备
        onDisconnected()
        
        searchView.isHidden = true
        searchFailView.isHidden = false
        
    }
    
    //搜索失败页面点击重试后调用，重新搜索
    func reTryScanBluefi(){
        
        dataArray.removeAll()
        title = "搜索中"
        searchView.isHidden = false
        searchFailView.isHidden = true
        startTimer()
        scanBlufi()
        
    }
    
    
    //连接成功状态处理
    func configConnectState(_ state : connectState){
        switch state {
        case .none:
            break
        case .deviceConnected:
            connectView.selectBtn(0)
            break
        case .wifiConnected:
            connectView.selectBtn(1)
            connectView.selectBtn(2)
            break
        case .cloudConnected:
            connectView.selectBtn(3)
            connectView.selectBtn(4)
            //todo:如果步骤都已经成功，却没收到设备添加成功的通知，跳去哪里？？？
            break
        case .faliConnected:
            cancelConnectBtnAction()
            connectFail()
            break
        }
    }

}

//倒计时
extension BluefiResultVC{
    
    func startTimer(){
        
        //发送成功之后进行倒计时
        startCount = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    
    //MARK: - 倒计时开始
    @objc func countDown() {
        
        startCount += 1
        
        let min = startCount / 60
        let sec = startCount % 60
        let text = String(format: "%02d:%02d", min,sec)
        
        searchView.configTimeOutLabel(text)
        
        //倒计时完成后停止定时器，移除动画
        if startCount >= countDownNum {
            
            searchFailTimeOutAction()
            if timer == nil {
                return
            }
            
            timer.invalidate()
            timer = nil

        }
    }
    
}

extension BluefiResultVC{
    
    
    func getDataString(){
        
        let userId = AgoraIotManager.shared.sdk?.accountMgr.getUserId() ?? ""
        let qrString = String(format: "{\"s\":\"%@\",\"p\":\"%@\",\"u\":\"%@\",\"k\":\"%@\"}",arguments:[wifiName,password,userId,productKey])
        debugPrint("qrString == \(qrString)")
        
    }
    
    func scanBlufi(){
        
        blueFi.startScan { [weak self] device in
            debugPrint("---Blufi---:\(device.name)-------:---:\(device)")
            self?.configBlueResult(device)
        }
    }
    
    func configBlueResult(_ device : ESPPeripheral){
        
        if shouldAddToSource(device) == true {
            
            if dataArray.count == 0 {
                searchView.configNextBtn()
            }
            
            device.isSelect = false
            dataArray.append(device)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func connect(){
        
        if bClient != nil {
            bClient?.close()
            bClient = nil
        }
        bClient = BlufiClient()
        bClient?.centralManagerDelete = self
        bClient?.peripheralDelegate = self
        bClient?.blufiDelegate = self
        bClient?.connect(currentModel.uuid.uuidString)
        debugPrint("正在连接：\(currentModel.name)---\(currentModel.uuid)")
        
    }
    
    func onDisconnected(){
        if bClient != nil {
            bClient?.close()
        }
    }
    
    //给外设发送WiFi信息
    func sendWifiConfigInfor(){
        
        let params = BlufiConfigureParams()
        params.opMode = OpModeSta
        params.staSsid = wifiName
        params.staPassword = password
        
//        let userId = AgoraIotManager.shared.sdk?.accountMgr.getUserId() ?? ""
//        params.uid = userId
//        params.key = productKey
        
        debugPrint("--------：\(params)")
                   
        didSetParams(params)
        
    }
    
    func didSetParams(_ params : BlufiConfigureParams){
        if bClient != nil {
            bClient?.configure(params)
        }
    }
    
    
    //给外设发送自定义消息
    func sendCustomConfigInfor(){
        
        let userId = AgoraIotManager.shared.sdk?.accountMgr.getUserId() ?? ""
        let qrString = String(format: "{\"s\":\"%@\",\"p\":\"%@\",\"u\":\"%@\",\"k\":\"%@\"}",arguments:[wifiName,password,userId,productKey])
        
        guard let data = qrString.data(using: .utf8) else { return }
        if bClient != nil {
            bClient?.postCustomData(data)
        }
        
    }
    
    func shouldAddToSource(_ device : ESPPeripheral)->Bool{
        
//        if filterContent != "" {
//            if device.name != "", device.name.hasPrefix(filterContent) == false{
//                return false
//            }else if device.name == "" {
//                return false
//            }
//        }
        
        for item in dataArray {
            if item.uuid == device.uuid {
                return false
            }
        }
        
        return true
    }
    
    
}





extension BluefiResultVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataArray.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let model = dataArray[indexPath.row]
        
        let cell:BluefiResultCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! BluefiResultCell
        cell.curIndexPath = indexPath
        cell.model = model
        // 点击按钮
        cell.valueChangedAction = { [weak self] curIndexPath in
            self?.selectValueChangedForTitle(curIndexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{

        return 80
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{

        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let titleLab = UILabel()
        titleLab.textColor = UIColor(hexString: "#2B2B2B")
        titleLab.font = FontPFMediumSize(14)
        titleLab.backgroundColor = UIColor.white
        titleLab.text = "     发现设备，请选择需要配网的设备"

        return titleLab
    }


    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{

        return UIView()
    }
    
    // 开关值变化
    func selectValueChangedForTitle(_ curIndex : IndexPath) {

        let cuModel : ESPPeripheral = dataArray[curIndex.row]

        currentModel = cuModel
        debugPrint("---:\(currentModel.name)")

        dataArray.forEach ({ item in
            item.isSelect = (item.uuid == currentModel.uuid)
        })

        tableView.reloadData()

    }

}


extension BluefiResultVC : CBCentralManagerDelegate,CBPeripheralDelegate,BlufiDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    //连接外设
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("开始连接设备了")
//        configConnectState(.deviceConnected)
//        //连接成功发送配网信息
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//            self?.sendWifiConfigInfor()
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("连接设备失败了")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("断开设备成功了")
    }
    
    //外设连接状态回调
    func blufi(_ client: BlufiClient, gattPrepared status: BlufiStatusCode, service: CBService?, writeChar: CBCharacteristic?, notifyChar: CBCharacteristic?) {
        debugPrint("Blufi gattPrepared status:\(status)")
        if status == StatusSuccess {
            debugPrint("连接设备成功 has prepared")
            configConnectState(.deviceConnected)
            //连接成功发送配网信息
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.sendWifiConfigInfor()
            }
        }else{
            debugPrint("连接设备失败")
            configConnectState(.faliConnected)
        }
        
    }
    
    func blufi(_ client: BlufiClient, didNegotiateSecurity status: BlufiStatusCode) {
        debugPrint("Blufi didNegotiateSecurity:\(status)")
        if status == StatusSuccess {
            debugPrint("Negotiate security complete")
        }else{
            debugPrint("Negotiate security failed")
        }
    }
    
    func blufi(_ client: BlufiClient, didReceiveDeviceVersionResponse response: BlufiVersionResponse?, status: BlufiStatusCode) {
        if status == StatusSuccess {
            debugPrint("Receive device version:\(response?.getVersionString())")
        }else{
            debugPrint("Receive device version error:\(status)")
        }
    }
    
    // 配网信息发送是否成功回调
    func blufi(_ client: BlufiClient, didPostConfigureParams status: BlufiStatusCode) {
        if status == StatusSuccess {
            debugPrint("Post configure params complete")
            configConnectState(.wifiConnected)
            //连接成功发送自定义消息
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.sendCustomConfigInfor()
            }
        }else{
            debugPrint("Post configure params failed:\(status)")
            configConnectState(.faliConnected)
        }
    }
    
    // 收到配网信息数据回调
    // 到这里说明，设备已经配网成功了，我们拿到前获取到的Mac，进行上云操作
    func blufi(_ client: BlufiClient, didReceiveDeviceStatusResponse response: BlufiStatusResponse?, status: BlufiStatusCode) {
        if status == StatusSuccess {
            debugPrint("Receive device status:\(response?.getStatusInfo())")
        }else{
            debugPrint("Receive device status error:\(status)")
        }
    }
    
    func blufi(_ client: BlufiClient, didReceiveDeviceScanResponse scanResults: [BlufiScanResponse]?, status: BlufiStatusCode) {
        if status == StatusSuccess {
            
            var infor = [String]()
            infor.append("Receive device scan results:\n)")
            if let scanResults = scanResults {
                for item in scanResults {
                    infor.append("SSID: \(item.ssid), RSSI: \(item.rssi)\n")
                }
            }
            debugPrint("infor:\(infor)")
            
        }else{
            debugPrint("Receive device scan results error:\(status)")
        }
    }
    
    // 收到自定义数据是否发送成功回调
    func blufi(_ client: BlufiClient, didPostCustomData data: Data, status: BlufiStatusCode) {
        if status == StatusSuccess {
            configConnectState(.cloudConnected)
            debugPrint("Post custom data complete")
        }else{
            debugPrint("Post custom data failed:\(status)")
            configConnectState(.faliConnected)
        }
    }
    
    // 收到自定义数据回调
    func blufi(_ client: BlufiClient, didReceiveCustomData data: Data, status: BlufiStatusCode) {
        let customString = String.init(data: data, encoding: .utf8)
        debugPrint("Receive device custom data:\(String(describing: customString))")
    }
}


