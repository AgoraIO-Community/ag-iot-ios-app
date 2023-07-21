//
//  SDCardPlayerVC.swift
//  IotLinkDemo
//
//  Created by admin on 2023/7/12.
//

import UIKit
import AgoraIotLink

private let kCellID = "SDCardPlayerCell"

class SDCardPlayerVC: AGBaseVC {

    var mediaArray = [DevMediaItem]()
    
    var curImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    func setUpUI(){
        
        view.addSubview(displayView)
        displayView.snp.makeConstraints { make in
            make.top.equalTo(60)
            make.left.right.equalTo(view)
            make.height.equalTo(200)
        }
        
        view.addSubview(playBtn)
        playBtn.snp.makeConstraints { make in
            make.top.equalTo(displayView.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        view.addSubview(stopBtn)
        stopBtn.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.top)
            make.left.equalTo(playBtn.snp.right).offset(20)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        view.addSubview(queryBtn)
        queryBtn.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.top)
            make.left.equalTo(stopBtn.snp.right).offset(20)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        view.addSubview(imageBtn)
        imageBtn.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.top)
            make.left.equalTo(queryBtn.snp.right).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(view)
        }
        
    }

    lazy var displayView:UIView = {
        let vodView = UIView()
        vodView.backgroundColor = UIColor.cyan
        
        return vodView
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(SDCardMediaViewCell.self, forCellReuseIdentifier: kCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("播放", for:.normal)
        btn.setTitle("暂停", for:.selected)
        btn.tag = 1002
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var stopBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("停止", for:.normal)
        btn.tag = 1003
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var queryBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("查询", for:.normal)
        btn.tag = 1004
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var imageBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("获取图片", for:.normal)
        btn.tag = 1005
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    
    @objc func btnClick(btn : UIButton){//播放
        
        switch btn.tag{
        case 1002:
            
            sendCmdSDPlayCtrl()
            
            break
        case 1003:
            
            sendCmdSDStopCtrl()
            
            break
        case 1004:
            
            sendCmdSDQueryPCtrl {[weak self] code, mediaList in

                self?.mediaArray.append(contentsOf: mediaList)
                self?.tableView.reloadData()
            }
            
            break
        case 1005:
            
            sendCmdSDQueryCoverImagPCtrl { [weak self] code, data in

                if let image = UIImage(data: data) {
                    self?.curImage = image
                    self?.tableView.reloadData()
                    log.i("转化成功")
                } else {
                    log.i("转化失败")
                }
            }
            
            break
        default:
            break
        }
        
        
        
    }
        
    func getDevMediaMgr()->IDevMediaMgr{
        let sessionId = TDUserInforManager.shared.curSessionId
        return (sdk?.deviceSessionMgr.getDevMediaMgr(sessionId: sessionId))!
    }


}

extension SDCardPlayerVC{
    
    func sendCmdSDQueryPCtrl(sessionId:String = "", cb:@escaping(Int,[DevMediaItem])->Void){
   
        let mediaMgr = getDevMediaMgr()
        let param = QueryParam(mFileId: 0, mBeginTimestamp: 12, mEndTimestamp: 20, mPageIndex: 0, mPageSize: 10)
        mediaMgr.queryMediaList(queryParam: param) { errCode, mediaList in
            print("sendCmdSDCtrl---:\(errCode) mediaList:\(mediaList)")
            cb(errCode,mediaList)
        }
    
    }
    
    func sendCmdSDDeletePCtrl(sessionId:String = "", cb:@escaping(Int,String)->Void){
   
        let mediaMgr = getDevMediaMgr()
        mediaMgr.deleteMediaList(deletingList: ["1","2","3"]) { errCode, undeletedList in
            print("sendCmdSDCtrl---:\(errCode) mediaList:\(undeletedList)")
            cb(errCode,"success")
        }
    
    }
    
    func sendCmdSDQueryCoverImagPCtrl(sessionId:String = "", cb:@escaping(Int,Data)->Void){
   
        let mediaMgr = getDevMediaMgr()
        mediaMgr.getMediaCoverData(imgUrl: "http://jd.com/image1.jpg") { errCode,fileId,result in
            print("sendCmdSDCtrl---:\(errCode) result:\(result)")
            cb(errCode,result)
        }
    
    }
    
    func sendCmdSDPlayCtrl(sessionId:String = ""){
   
        let mediaMgr = getDevMediaMgr()
        mediaMgr.play(globalStartTime: 0, playSpeed: 1, playingCallListener: self)
        
    }
    
    func sendCmdSDStopCtrl(sessionId:String = ""){
   
        let mediaMgr = getDevMediaMgr()
        mediaMgr.stop()
        
    }
    
    
    //SD卡回看命令 仅在通话状态下才能调用
    func sendCmdSDCtrl(sessionId:String = "", cb:@escaping(Int,String)->Void){
        
        let mediaMgr = getDevMediaMgr()
        
//        let param = QueryParam(mFileId: 0, mBeginTimestamp: 12, mEndTimestamp: 20, mPageIndex: 0, mPageSize: 10)
//        mediaMgr.queryMediaList(queryParam: param) { errCode, mediaList in
//            print("sendCmdSDCtrl---:\(errCode) mediaList:\(mediaList)")
//            cb(errCode,"success")
//        }
        
//        mediaMgr.deleteMediaList(deletingList: ["1","2","3"]) { errCode, undeletedList in
//            print("sendCmdSDCtrl---:\(errCode) mediaList:\(undeletedList)")
//            cb(errCode,"success")
//        }
        
//        mediaMgr.queryMediaCoverImage(imgUrl: "http://jd.com/image1.jpg") { errCode, result in
//            print("sendCmdSDCtrl---:\(errCode) mediaList:\(result)")
//            cb(errCode,"success")
//        }
        
        mediaMgr.play(globalStartTime: 0, playSpeed: 1, playingCallListener: self)
        
//          mediaMgr.play(fileId: "1", startPos: 989898989, playSpeed: 1, playingCallListener: self)
        
//        mediaMgr.stop()
        
//          mediaMgr.setPlayingSpeed(speed: 2)
        
    }

    
}

extension SDCardPlayerVC: IPlayingCallbackListener {
    func onDevMediaPlayingDone(fileId: String) {
        
    }
    
    func onDevMediaPauseDone(fileId: String, errCode: Int) {
        
    }
    
    func onDevMediaResumeDone(fileId: String, errCode: Int) {
        
    }
    
    
    func onDevPlayingStateChanged(mediaUrl: String, newState: Int) {
        
    }
    
    func onDevMediaOpenDone(fileId mediaUrl: String, errCode: Int) {
        let sessionId = TDUserInforManager.shared.curSessionId
        let mediaMgr = getDevMediaMgr()
        if errCode == 0 {
            mediaMgr.setDisplayView(displayView: displayView)
        }
    }
    
    func onDevMediaSeekDone(fileId mediaUrl: String, errCode: Int, targetPos: UInt64, seekedPos: UInt64) {
        
    }
    
    func onDevMediaPlayingDone(mediaUrl: String, duration: UInt64) {
        
    }
    
    func onDevPlayingError(fileId mediaUrl: String, errCode: Int) {
        
    }
    
}

extension SDCardPlayerVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaItem = mediaArray[indexPath.row]
        let cell:SDCardMediaViewCell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! SDCardMediaViewCell
        cell.indexPath = indexPath
        cell.mediaItem = mediaItem
        cell.coverImg = curImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mediaItem = mediaArray[indexPath.row]

    }
}
