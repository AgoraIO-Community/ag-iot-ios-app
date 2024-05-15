//
//  AVStreamVC.swift
//  IotLinkDemo
//
//  Created by admin on 2024/3/15.
//

import UIKit
import AgoraIotLink

private let kCellID = "AVStreamCell"


class AVStreamVC: UIViewController {

    var AVStreamVCBlock:((_ mainStreamModel : MStreamModel ) -> (Void))?
    
    var mStreamArray = [MStreamModel]()
    var cellArray = [AVStreamCell]()
    
            
    var connectObj: IConnectionObj? {
        didSet{
            guard let connectObj = connectObj else {
                return
            }
//            let conObj = getConnectObj(connectId)
//            let statusCode : Int = conObj?.setPreviewDisplayView(subStreamId: .PUBLIC_STREAM_1, displayView: nil) ?? 0
//            debugPrint("statusCode:\(statusCode)")
        }
    }
    
    deinit {
        log.i("AVStreamVC 销毁了")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "流媒体"
        addLeftBarButtonItem()
        loadData()
        setUpUI()
//        configFirstCell()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        for streamModel in mStreamArray{
//            if streamModel.isSubcribedAV == true && streamModel.streamId != .PUBLIC_STREAM_1{
//                log.i("viewWillAppear: 退出流媒体页面 停止拉流")
//                streamModel.isSubcribedAV = false
//                DoorBellManager.shared.streamRecordStop(streamModel.connectObj, subStreamId: streamModel.streamId)
//            }
//        }
    }
    
    func configFirstCell(){
        let cell = getCellWithTag(tag: 1)
        cell.configPeerView()
        
    }
    
    func getCellWithTag(tag:Int) -> AVStreamCell {
        if let cell = tableView.viewWithTag(tag) as? AVStreamCell{
            return cell
        }
        debugPrint("未找到对应cell：\(tag)")
        return AVStreamCell()
    }
    
    // 设置UI
    private func setUpUI(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(15)
        }
    }
    
    func loadData(){
        mStreamArray.removeAll()
        for i in 1...9{
            let mModel = MStreamModel()
            mModel.connectObj = connectObj
            mModel.streamId = StreamId(rawValue: i) ?? .BROADCAST_STREAM_1
            mStreamArray.append(mModel)
        }
        for i in 11...18{
            let mModel = MStreamModel()
            mModel.connectObj = connectObj
            mModel.streamId = StreamId(rawValue: i) ?? .BROADCAST_STREAM_1
            mStreamArray.append(mModel)
        }
        
//        // 初始化时创建单元格并保存在数组中
//        for _ in 0..<mStreamArray.count {
//            let cell = AVStreamCell(style: .default, reuseIdentifier: nil)
//            cellArray.append(cell)
//        }
        
        print(" loadData: mStreamArray: \(mStreamArray.count)")
    }
    
    lazy var tableView:UITableView = {
        let tableView = UITableView()
//        tableView.register(AVStreamCell.self, forCellReuseIdentifier: kCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 200
        return tableView
    }()
    
    private func addLeftBarButtonItem() {
        navigationItem.leftBarButtonItem=UIBarButtonItem(image: UIImage(named: "doorbell_back")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBtnDidClick))
    }
    
    @objc func leftBtnDidClick(){
        AVStreamVCBlock?(mStreamArray.first!)
        navigationController?.popViewController(animated: false)
    }
    
  
}

extension AVStreamVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mStreamArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 直接从数组中获取对应的单元格对象
        
        var cell : AVStreamCell?
        if cellArray.count == mStreamArray.count || indexPath.row < cellArray.count {
             cell = cellArray[indexPath.row]
            print("-------🌹🌹🌹-------index.row:\(indexPath.row)  cell.count:\(String(describing: cellArray.count))-------🌹🌹🌹---------")
        }else{
             cell = AVStreamCell(style: .default, reuseIdentifier: nil)
            cellArray.append(cell!)
            print("-------♥️♥️♥️-------index.row:\(indexPath.row)  cell.count:\(String(describing: cellArray.count))-------♥️♥️♥️---------")
        }
        
        
        
        let streamModel = mStreamArray[indexPath.row]
        cell?.indexPath = indexPath
        cell?.tag = streamModel.streamId.rawValue
        cell?.streamModel = streamModel

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
