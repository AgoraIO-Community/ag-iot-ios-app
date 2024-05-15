//
//  HomeMainDeviceCell.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/21.
//

import UIKit
import AgoraIotLink
import Kingfisher

class HomeMainDeviceCell: UITableViewCell {
    
    var sdk:IAgoraIotAppSdk?{get{return iotsdk}}
    
    var customTag : Int = 0
    
    var dailBlock:((_ tag : Int) -> (Void))?
    var fullScreenBlock:((_ tag : Int) -> (Void))?
    var aVStreamBlock:((_ tag : Int) -> (Void))?
    
    var device: MDeviceModel? {
        didSet{
            guard let device = device else {
                return
            }
            nameLabel.text = device.peerNodeId
            logicView.device = device
            
            selectedbutton.isHidden = !device.canEdit
            selectedbutton.isSelected = device.isSelected
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
    lazy var logicView: DoorbellAbilitySimpleLogicView = {

        let logicView = DoorbellAbilitySimpleLogicView()
        logicView.tipType = .none
        logicView.logicfullHorBtnBlock = { [weak self] in
            if let tag = self?.tag {
                self?.dailBlock?(tag)
            }
        }
        logicView.logicFullScreenBlock = { [weak self] in
            if let tag = self?.tag {
                self?.fullScreenBlock?(tag)
            }
            
        }
        logicView.logicAVStreamBlock = { [weak self] in
            if let tag = self?.tag {
                self?.aVStreamBlock?(tag)
            }
        }
        logicView.logicEnableAVStreamBlock = { [weak self] in
            self?.configPeerView(true)
        }
        logicView.logicDisableAVStreamBlock = { [weak self] in
            self?.configPeerView(false)
        }
        logicView.callHunpBtnBlock = { [weak self] in
            
            self?.device?.connectObj = nil
            self?.handelCallTipType(.none)
            self?.handelCallStateText(false)
            self?.handelStateNone()
        }
        
        return logicView

    }()
    
    private lazy var selectedbutton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_unselect"), for: .normal)
        button.setImage(UIImage(named: "country_selected"), for: .selected)
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.blue
        label.text = ""
        return label
    }()
    
    private lazy var statusLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexRGB: 0xF7B500)
        return label
    }()
    
    private lazy var iconImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    
    private func createSubviews(){
        
        contentView.addSubview(videoParentView)
        contentView.backgroundColor = UIColor(hexRGB: 0xF8F8F8)
        
        contentView.addSubview(logicView)
        logicView.addSubview(selectedbutton)
        
        videoParentView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25))
        }
        
        logicView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 25))
        }
        
        // 可编辑标记
        selectedbutton.snp.makeConstraints { make in
            make.top.equalTo(15.S)
            make.right.equalTo(-16)
            make.width.height.equalTo(20)
        }
        
    }
    
    //设置播放器view
    func configPeerView(_ isEnable:Bool) {
        guard let conObj = device?.connectObj else {
            return
        }
        
        let ret =  conObj.setVideoDisplayView(subStreamId: .BROADCAST_STREAM_1, displayView:isEnable == true ? videoParentView : nil)
        debugPrint("--- \(ret)")

    }
    
    //设置呼叫按钮状态
    func handelCallStateText(_ isCallSuc : Bool?){
        logicView.handelCallStateText(isCallSuc)
    }
    
    //设置静音按钮状态
    func handelMuteAudioStateText(_ isCallSuc : Bool?){
        logicView.handelMuteAudioStateText(isCallSuc)
    }
    
    //设置预览按钮状态
    func handelPreviewBtnStateText(_ isCallSuc : Bool?){
        logicView.handePreviewBtnStateText(isCallSuc)
    }
    
    //设置按钮回到初始状态
    func handelStateNone(){
        logicView.handelStateNone()
    }
    
    func handelCallTipType(_ tipType : VideoAlertTipType){
        logicView.tipType = tipType
    }
    
    func handelUserMembers(_ members : Int){
        logicView.handelUserMembers(members)
    }
    
}
