//
//  DoorbellAbilityView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit
import AgoraIotSdk
import ZLPhotoBrowser

fileprivate let TDLogisticsItemCollCellID = "TDLogisticsItemCollCellID"

class DoorbellAbilityView: UIView {

    var device: IotDevice?
    
    // 当前选中的移动侦测类型
    private var selectedPirType = 0
    // 当前选中的红外夜视类型
    private var selectedNightMoType = 0
    
    private var curIndexPath: IndexPath?
    
    var dataArr:[DoorbellAbilityModel]?{
        
        didSet{
            
            guard dataArr != nil else { return }
            
            collectionV.reloadData()
            
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hexString: "#000000")
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        
        addSubview(collectionV)
        
        collectionV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    fileprivate lazy var flowLayout:UICollectionViewFlowLayout = {
        
        let flowLay = UICollectionViewFlowLayout()
        
//        flowLay.scrollDirection = .vertical
        
        flowLay.minimumInteritemSpacing = 0
        
        return flowLay
    }()
    
    fileprivate lazy var collectionV:UICollectionView = {
        
        let collectionV = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        collectionV.backgroundColor = .clear
        
        collectionV.showsVerticalScrollIndicator = false
        
        collectionV.showsHorizontalScrollIndicator = false
        
        collectionV.bounces = false
        
        collectionV.delegate = self
        
        collectionV.dataSource = self
        
        collectionV.register(DoorbellAbilityViewCell.self, forCellWithReuseIdentifier: TDLogisticsItemCollCellID)
        
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        
        return collectionV
        
    }()
    
    
}

extension DoorbellAbilityView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TDLogisticsItemCollCellID, for: indexPath) as!DoorbellAbilityViewCell
        cell.model = dataArr?[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{

        return CGSize(width: 60.S, height: 85.VS)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        return UIEdgeInsets(top: 0, left: 30.S, bottom:0 , right: 30.S)

    }
    
    //item间距(竖向布局,此为上下间距)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        
        return 28.S
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        
        return 25.S
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("点击该item")
        curIndexPath = indexPath
        let model : DoorbellAbilityModel = dataArr?[indexPath.row] ?? DoorbellAbilityModel()
        switch model.abilityId {
        case 10000:
            debugPrint("回放")
            AGToolHUD.showInfo(info:"该功能暂未开放，敬请期待！" )
            break
        case 10002:
            debugPrint("相册")
            openPhotoAlbum()
            break
        case 105://Bool
            debugPrint("强拆报警")
            clickFuncBoolAction(indexPath)
            break
        case 101://枚举值 0自动 1关 2开
            debugPrint("红外夜视")
            showNightMotionSheet(model)
            break
        case 115://Bool
            debugPrint("声音检测")
            clickFuncBoolAction(indexPath)
            break
        case 102://Bool
            debugPrint("移动侦测")
            clickFuncBoolAction(indexPath)
            break
        case 103://枚举 0关 1是3米 2是1.5米 3是0.8米
            debugPrint("PIR开关")
            //弹框选择
            showPirSheet(model)
            break
        case 114://Bool
            debugPrint("警笛")
            clickFuncBoolAction(indexPath)
            break
        default:
            break
        }

    }
    
}

extension DoorbellAbilityView {
    
    
    func clickFuncBoolAction(_ indexPath: IndexPath) {
        
        let model : DoorbellAbilityModel = dataArr?[indexPath.row] ?? DoorbellAbilityModel()
        model.isSelected = !model.isSelected
        if model.isSelected == true {
            model.abilityValue = 1
        }else{
            model.abilityValue = 0
        }
        
        if model.abilityId == 114 || model.abilityId == 115 || model.abilityId == 105 || model.abilityId == 102 {
            setDeviceProperty(model)
        }else{
            setSysDeviceProperty(model)
        }
        
        
    }
    
    //单值设置属性操作直接调用接口
    func setDeviceProperty(_ model : DoorbellAbilityModel){
        
        guard let device = device else { return }
        let pointId = String(model.abilityId)
        
        let valueB : Bool = model.abilityValue == 1 ? true:false
        let parmDic = [pointId:valueB] as [String:Any]
        
        AGToolHUD.showNetWorkWait()
        DoorBellManager.shared.setDeviceProperty(device, dict: parmDic) {[weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success == true {
                AGToolHUD.showInfo(info:"设置成功" )
                self?.handelSingleResult()
            }else{
                
                AGToolHUD.showInfo(info: "\(msg)")
                model.isSelected = !model.isSelected
                model.abilityValue = model.lastValue
            }
        }
        
    }
    
    //单值设置属性操作,调用二次封装的接口
    func setSysDeviceProperty(_ model : DoorbellAbilityModel){
        
        guard let device = device else { return }
        let pointId = model.abilityId
        let value = model.abilityValue
        
        AGToolHUD.showNetWorkWait()
        DoorBellManager.shared.setSynDevicecProperty(device,pointId:pointId,value: value) { [weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success == true {
                AGToolHUD.showInfo(info:"设置成功" )
                self?.handelSingleResult()
            }else{
                
                AGToolHUD.showInfo(info: "\(msg)")
                model.isSelected = !model.isSelected
                model.abilityValue = model.lastValue
                
            }
        }
        
    }
    
    //用于单值属性设置返回结果处理
    func handelSingleResult(){
        
        guard let indexPath = curIndexPath else { return }
        let tempCell : DoorbellAbilityViewCell = collectionV.cellForItem(at: indexPath) as! DoorbellAbilityViewCell
        let model : DoorbellAbilityModel = dataArr?[indexPath.row] ?? DoorbellAbilityModel()
        
        //将设置成功的属性值记录下来
        model.lastValue = model.abilityValue
        
        if model.isSelected == true {
            tempCell.IconImgV.image = UIImage.init(named: model.abilitySecectIcon)
        }else{
            tempCell.IconImgV.image = UIImage.init(named: model.abilityIcon)
        }
        
    }
    
    //多值列表设置属性操作直接调用接口
    func setMultiDeviceProperty(_ model : DoorbellAbilityModel){
        
        guard let device = device else { return }
        let pointId = String(model.abilityId)
        
        let parmDic = [pointId:model.abilityValue] as [String:Any]
        
        AGToolHUD.showNetWorkWait()
        DoorBellManager.shared.setDeviceProperty(device, dict: parmDic) { [weak self] success, msg in
            
            AGToolHUD.disMiss()
            if success == true {
                AGToolHUD.showInfo(info:"设置成功" )
                self?.handelPropertyResult()
            }else{
                
                AGToolHUD.showInfo(info: "\(msg)")
                model.abilityValue = model.lastValue
                
            }
        }
        
    }
    
    //多值列表设置属性操作
//    func setSysMultiDeviceProperty(_ model : DoorbellAbilityModel){
//
//        guard let device = device else { return }
//        let pointId = model.abilityId
//        let value = model.abilityValue
//
//        AGToolHUD.showNetWorkWait()
//        DoorBellManager.shared.setSynDevicecProperty(device,pointId:pointId,value: value) { [weak self] success, msg in
//
//            AGToolHUD.disMiss()
//            if success == true {
//                AGToolHUD.showInfo(info:"设置成功" )
//                self?.handelPropertyResult()
//            }else{
//
//                AGToolHUD.showInfo(info: "\(msg)")
//                model.abilityValue = model.lastValue
//
//            }
//        }
//
//    }
    
    //用于多值属性设置成功返回
    func handelPropertyResult(){
        guard let indexPath = curIndexPath else { return }
        let tempCell : DoorbellAbilityViewCell = collectionV.cellForItem(at: indexPath) as! DoorbellAbilityViewCell
        let model : DoorbellAbilityModel = dataArr?[indexPath.row] ?? DoorbellAbilityModel()
        
        //将设置成功的属性值记录下来
        model.lastValue = model.abilityValue
        
        if model.abilityValue == 0 {
            model.isSelected = false
            tempCell.IconImgV.image = UIImage.init(named: model.abilityIcon)
            
        }else{
            model.isSelected = true
            tempCell.IconImgV.image = UIImage.init(named: model.abilitySecectIcon)
        }
        
    }
    
    func openPhotoAlbum(){
        debugPrint("打开相册")
        showImagePickerVC()
    }
    
    func showPirSheet(_ model : DoorbellAbilityModel){
        let itemsCode = [0,1,2,3]
        AGActionSheetVC.showTitle("移动侦测", items: ["关闭","3米","1.5米","0.8米"], selectIndex: self.selectedPirType) {[weak self] item, index in
            if self == nil { return }
            model.abilityValue = itemsCode[index]
            self?.selectedPirType = index
            self?.setMultiDeviceProperty(model)
        }
    }
    
    func showNightMotionSheet(_ model : DoorbellAbilityModel){
        let itemsCode = [0,1,2]
        AGActionSheetVC.showTitle("红外夜视", items: ["自动","关","开"], selectIndex: self.selectedNightMoType) {[weak self] item, index in
            if self == nil { return }
            model.abilityValue = itemsCode[index]
            self?.selectedNightMoType = index
            self?.setMultiDeviceProperty(model)
        }
    }
}

extension DoorbellAbilityView{
    
    private func showImagePickerVC(){
        
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = true
        config.allowSelectImage = true
        config.allowTakePhoto = false
        config.allowRecordVideo = false
        config.maxSelectCount = 1
        config.allowEditImage = false
        config.allowEditVideo = false

        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { (images, assets, isOriginal) in
            debugPrint("获取图片成功")

        }
        ps.showPhotoLibrary(sender: currentViewController())
    }
    
}
