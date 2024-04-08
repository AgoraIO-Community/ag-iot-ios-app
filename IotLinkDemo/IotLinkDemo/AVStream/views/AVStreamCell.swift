//
//  AVStreamCell.swift
//  IotLinkDemo
//
//  Created by admin on 2024/3/15.
//

import UIKit
import AgoraIotLink
import Kingfisher

class AVStreamCell: UITableViewCell {
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    
    var dailBlock:((_ index : IndexPath) -> (Void))?
    var fullScreenBlock:((_ index : IndexPath) -> (Void))?
    var aVStreamBlock:((_ index : IndexPath) -> (Void))?
    
    
    var streamModel: MStreamModel? {
        didSet{
            guard let tempModel = streamModel else {
                return
            }
            logicView.streamModel = tempModel
            let connectObj = tempModel.connectObj
            let streamStatus = connectObj?.getStreamStatus(peerStreamId: tempModel.streamId)
            if streamStatus?.mSubscribed == true {
                streamModel?.isSubcribedAV = true
                logicView.toolBarView.fullHorBtn.isSelected = true
                configPeerView()
            }
            
            if streamStatus?.mAudioMute == true{
                logicView.toolBarView.changeSoundBtn.isSelected = true
            }
            
//            if streamModel?.streamId == .PUBLIC_STREAM_1 {
//                let streamStatus = connectObj?.getStreamStatus(peerStreamId: .PUBLIC_STREAM_1)
//                if streamStatus?.mSubscribed == true {
//                    streamModel?.isSubcribedAV = true
//                    logicView.toolBarView.fullHorBtn.isSelected = true
//                    configPeerView()
//                }
//            }
        }
        
    }
    
    var indexPath : IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    lazy var videoParentView:UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    // 承载操作事件的view
    lazy var logicView: StreamSimpleLogicView = {

        let logicView = StreamSimpleLogicView()
        logicView.logicfullHorBtnBlock = { [weak self] in
            self?.dailBlock?(self?.indexPath ?? IndexPath(row: 0, section: 0))
        }
        logicView.logicFullScreenBlock = { [weak self] in
            self?.fullScreenBlock?(self?.indexPath ?? IndexPath(row: 0, section: 0))
        }
        logicView.logicAVStreamBlock = { [weak self] connectId in
            self?.aVStreamBlock?(self?.indexPath ?? IndexPath(row: 0, section: 0))
        }
        logicView.logicEnableAVStreamBlock = { [weak self] in
            self?.configPeerView()
        }
        
        return logicView

    }()
    
    private func createSubviews(){
        
        contentView.addSubview(videoParentView)
        contentView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        
        contentView.addSubview(logicView)
        
        videoParentView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25))
        }
        
        logicView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25))
        }
        
    }
    
    //设置播放器view
    func configPeerView() {
        guard let connectObj = streamModel?.connectObj else { return }
        let statusCode : Int =  connectObj.setVideoDisplayView(subStreamId: streamModel!.streamId, displayView: videoParentView)
        debugPrint("--- configPeerView：subStreamId：\(streamModel!.streamId) retStatusCode\(statusCode)")
    }
    
    //设置呼叫按钮状态
    func handelCallStateText(_ isCallSuc : Bool?){
        logicView.handelCallStateText(isCallSuc)
    }
    
    //设置按钮回到初始状态
    func handelStateNone(){
        logicView.handelStateNone()
    }
    
}
