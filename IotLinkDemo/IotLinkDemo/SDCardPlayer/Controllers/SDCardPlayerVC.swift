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
    //---进度条---
    var progressSlider: UISlider!
    var playbackTimer: Timer?
    var index : Int = 0
    
    //是否正在播放
    var isPLaying : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    func setUpUI(){
  
        view.addSubview(displayView)
        displayView.snp.makeConstraints { make in
            make.top.equalTo(30)
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
        
        view.addSubview(downLoadBtn)
        downLoadBtn.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.bottom).offset(10)
            make.left.equalTo(playBtn.snp.left)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        view.addSubview(queryTimeBtn)
        queryTimeBtn.snp.makeConstraints { make in
            make.top.equalTo(playBtn.snp.bottom).offset(10)
            make.left.equalTo(downLoadBtn.snp.right).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(downLoadBtn.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(view)
        }
        
        // 设置进度条
        progressSlider = UISlider(frame: CGRect(x: 30, y: view.bounds.height - 150, width: view.bounds.width-60, height: 30))
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(progressSlider)
        
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
    
    lazy var downLoadBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("SD下载", for:.normal)
        btn.tag = 1006
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var queryTimeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.gray
        btn.alpha = 0.8
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.setTitle("查询时间", for:.normal)
        btn.tag = 1007
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    @objc private func updateProgressBar() {

        index += 1
        
        let mediaMgr = getDevMediaMgr()
        // 更新进度条的进度
        let curTime = mediaMgr.getPlayingProgress()
        print("更新进度条:  curTime:\(curTime)")
        let progress = Double(curTime)/Double(60000)
        print("更新进度条:  progress:\(progress)")
        print("index : \(index)")
        progressSlider.value = Float(progress)
        if progress >= 0.99{
            if playbackTimer != nil {
                playbackTimer?.invalidate()
                playbackTimer = nil
            }
//            playBtn.isSelected = !playBtn.isSelected
        }  
    }
    
    // 监听进度条值的变化
    @objc func progressSliderValueChanged(_ slider: UISlider) {
 
    }
    
    func startTimeProgress(){
        
        index = 0
        playbackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        
    }
    
    func endTimeProgress(){
        
        playbackTimer?.invalidate()
        playbackTimer = nil
        
    }
    
    @objc func btnClick(btn : UIButton){//播放
        
        switch btn.tag{
        case 1002:
            
            if isPLaying == false{
                let mediaMgr = getDevMediaMgr()
                let ret = mediaMgr.setDisplayView(displayView: displayView)
                sendCmdSDPlayCtrl()
            }else{
                if btn.isSelected == true{
                    //暂停
                    sendCmdSDPauseCtrl()
                    
                }else{
                    //播放
                    sendCmdSDResumeCtrl()
                }
            }
            
            
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
        case 1006://下载文件
            
            sendCmdSDQueryDownloadFile { [weak self] code, data in

                log.i("sendCmdSDQueryCoverImagPCtrl：\(code)")
            }
            break
        case 1007://查询时间戳
            
            sendCmdSDQueryTimeList { [weak self] code in

                log.i("sendCmdSDQueryTimeList：\(code)")
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
    
    func getDevControlMgr()->IDevControllerMgr{
        let sessionId = TDUserInforManager.shared.curSessionId
        return (sdk?.deviceSessionMgr.getDevController(sessionId: sessionId))!
    }


}

extension SDCardPlayerVC{
    
    func sendCmdSDQueryPCtrl(sessionId:String = "", cb:@escaping(Int,[DevMediaItem])->Void){
   
        let mediaMgr = getDevMediaMgr()
        let param = QueryParam(mFileId: "0", mBeginTimestamp: 0, mEndTimestamp: 20)
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
//        mediaMgr.getMediaCoverData(imgUrl: "http://jd.com/image1.jpg") { errCode,fileId,result in
//            print("sendCmdSDCtrl---:\(errCode) result:\(result)")
//            cb(errCode,result)
//        }
    
    }
    
    func sendCmdSDQueryDownloadFile(sessionId:String = "", cb:@escaping(Int,[DevFileDownloadResult])->Void){
   
        let mediaMgr = getDevMediaMgr()
        mediaMgr.DownloadFileList(filedIdList: ["1","2","3"]) { errCode, downloadFailList in
            print("DownloadMediaList---:\(errCode) downloadFailList:\(downloadFailList)")
            cb(errCode,downloadFailList)
        }
    }
    
    func sendCmdSDQueryTimeList(sessionId:String = "", cb:@escaping(Int)->Void){
   
//        let controlMgr = getDevControlMgr()
//        controlMgr.sendCmdPtzReset { errCode, msg in
//            print("sendCmdPtzCtrl---:\(errCode)---:\(msg)")
//            cb(errCode)
//        }
        
        let mediaMgr = getDevMediaMgr()
        mediaMgr.queryEventTimeline(onQueryEventListener: { errCode, list in
            print("sendCmdSDQueryTimeList---:\(errCode)---:\(list)")
            cb(errCode)
        })
    }
    
    func sendCmdSDPlayCtrl(){
   
        let mediaMgr = getDevMediaMgr()
        let ret = mediaMgr.play(fileId: "file_id1", startPos: 0, playSpeed: 1, playingCallListener: self)
//        mediaMgr.play(globalStartTime: 0, playSpeed: 1, playingCallListener: self)
        
    }
    
    func sendCmdSDStopCtrl(){
   
//        let mediaMgr = getDevMediaMgr()
//        mediaMgr.stop()
        
    }
    
    func sendCmdSDPauseCtrl(){
        let mediaMgr = getDevMediaMgr()
        mediaMgr.pause()
    }
    
    func sendCmdSDResumeCtrl(){
        let mediaMgr = getDevMediaMgr()
        mediaMgr.resume()
    }
    
    
    //SD卡回看命令 仅在通话状态下才能调用
//    func sendCmdSDCtrl(sessionId:String = "", cb:@escaping(Int,String)->Void){
//        
//        let mediaMgr = getDevMediaMgr()
//        
////        let param = QueryParam(mFileId: 0, mBeginTimestamp: 12, mEndTimestamp: 20, mPageIndex: 0, mPageSize: 10)
////        mediaMgr.queryMediaList(queryParam: param) { errCode, mediaList in
////            print("sendCmdSDCtrl---:\(errCode) mediaList:\(mediaList)")
////            cb(errCode,"success")
////        }
//        
////        mediaMgr.deleteMediaList(deletingList: ["1","2","3"]) { errCode, undeletedList in
////            print("sendCmdSDCtrl---:\(errCode) mediaList:\(undeletedList)")
////            cb(errCode,"success")
////        }
//        
////        mediaMgr.queryMediaCoverImage(imgUrl: "http://jd.com/image1.jpg") { errCode, result in
////            print("sendCmdSDCtrl---:\(errCode) mediaList:\(result)")
////            cb(errCode,"success")
////        }
//        
//        mediaMgr.play(globalStartTime: 0, playSpeed: 1, playingCallListener: self)
//        
////          mediaMgr.play(fileId: "1", startPos: 989898989, playSpeed: 1, playingCallListener: self)
//        
////        mediaMgr.stop()
//        
////          mediaMgr.setPlayingSpeed(speed: 2)
//        
//    }

    
}

extension SDCardPlayerVC: IPlayingCallbackListener {
    
    func onDevMediaCreated(fileId:String,errCode:Int){
//        let mediaMgr = getDevMediaMgr()
//        mediaMgr.setDisplayView(displayView: displayView)
    }
    
    func onDevMediaOpenDone(fileId mediaUrl: String, errCode: Int) {
        if errCode == 0 {
            isPLaying = true
            playBtn.isSelected = true
        }
        startTimeProgress()
//        let mediaMgr = getDevMediaMgr()
//        let curTime = mediaMgr.getPlayingProgress()
//        print("更新进度条666:  curTime:\(curTime)")
    }
    
    func onDevMediaPlayingDone(fileId: String) {
        endTimeProgress()
        isPLaying  = false
        playBtn.isSelected = false
    }
    
    func onDevMediaPauseDone(fileId: String, errCode: Int) {
        playBtn.isSelected = false
    }
    
    func onDevMediaResumeDone(fileId: String, errCode: Int) {
        playBtn.isSelected = true
    }
    
    
    func onDevPlayingStateChanged(mediaUrl: String, newState: Int) {
        
    }

    func onDevMediaSeekDone(fileId mediaUrl: String, errCode: Int, targetPos: UInt64, seekedPos: UInt64) {
        
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
