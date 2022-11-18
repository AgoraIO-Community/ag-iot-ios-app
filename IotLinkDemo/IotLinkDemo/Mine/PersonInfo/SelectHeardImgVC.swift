//
//  SelectHeardImgVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/6/23.
//

import UIKit
import AgoraIotLink


class SelectHeardImgVC: UIViewController {
    
    fileprivate let selectImgAlertViewCellID = "selectImgAlertViewCellID"
    
    fileprivate var  doorbellVM = DoorBellManager.shared
    fileprivate var dataArr = [UserHeardImgModel]()
    
    typealias SelectHeardImgAlertVCBlock = (_ image:UIImage?) -> ()
    var selectHeardImgAlertBlock:SelectHeardImgAlertVCBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
    }
    
    deinit {
        debugPrint("头像选择类销毁了")
    }
    
    func setupUI(){
        
        view.addSubview(bgV)
        bgV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(222.VS)
            make.bottom.equalToSuperview()
        }
        
        bgV.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(18.S)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 100.S, height: 22.VS))
        }
        
        bgV.addSubview(collectionV)
        collectionV.snp.makeConstraints { (make) in
            make.top.equalTo(66.VS)
            make.left.right.equalToSuperview()
            make.height.equalTo(120.VS)
        }
 
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //设置左上右上圆角
        let leftCorners: UIRectCorner = [.topLeft,.topRight]
        
        let leftPath =  UIBezierPath.init(roundedRect: bgV.bounds, byRoundingCorners: leftCorners, cornerRadii: CGSize(width: 30.0,height: 30.0))
        
        let shapeLayer = CAShapeLayer.init()
        
        shapeLayer.frame = bgV.bounds
        
        shapeLayer.path = leftPath.cgPath
        
        bgV.layer.mask = shapeLayer
        
        bgV.clipsToBounds = true
    }
    
    func loadData() {
        
        doorbellVM.loadHeardImgPropertyData {[weak self] modelArr, isSuccess in
            if isSuccess {
                guard let dataArray = modelArr else { return }
                self?.dataArr = dataArray
            }
        }
        
//        for i in 0..<4 {
//            let tempModel = DoorbellChangeSoundModel()
//
//            if i == 0 {
//                tempModel.soundName = "原生"
//                tempModel.soundIcon = "voice1"
//                tempModel.soundId = 101
//            }
//            if i == 1 {
//                tempModel.soundName = "大叔"
//                tempModel.soundIcon = "voice2"
//                tempModel.soundId = 102
//            }
//            if i == 2 {
//                tempModel.soundName = "萝莉"
//                tempModel.soundIcon = "voice3"
//                tempModel.soundId = 103
//            }
//            if i == 3 {
//                tempModel.soundName = "少年"
//                tempModel.soundIcon = "voice4"
//                tempModel.soundId = 104
//            }
//
//            dataArr.append(tempModel)
//
//        }

    }
    

    fileprivate lazy var titleLab:UILabel = {
        
        let lab = UILabel()
        
        lab.textColor = UIColor(hexRGB: 000000, alpha: 0.85)
        
        lab.font = FontPFMediumSize(16)
        
        lab.textAlignment = .center
        
        lab.text = "请选择头像"
        
        return lab
    }()
    
    
    fileprivate lazy var flowLayout:UICollectionViewFlowLayout = {
        
        let flowLay = UICollectionViewFlowLayout()
        
        flowLay.scrollDirection = .horizontal
        
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
        
        collectionV.register(selectImgAlertViewCell.self, forCellWithReuseIdentifier: selectImgAlertViewCellID)
        
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        
        return collectionV
        
    }()
    
    fileprivate lazy var bgV : UIView = {
        let bgV = UIView.init()
        bgV.backgroundColor = UIColor.init(hexString: "#FFFFFF")
//        bgV.layer.cornerRadius = 30
        bgV.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        bgV.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgV.layer.shadowOpacity = 1
        bgV.layer.shadowRadius = 20
        bgV.isUserInteractionEnabled = true
        return bgV
    }()
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeClick()
    }
    
    @objc func closeClick(){
        self.dismiss(animated: true) { }
    }

}

extension SelectHeardImgVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectImgAlertViewCellID, for: indexPath) as!selectImgAlertViewCell
        cell.model = dataArr[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{

        return CGSize(width: 80.S, height: 110.VS)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        return UIEdgeInsets(top: 0, left: 14.S, bottom:0 , right: 14.S)

    }
    
    //item间距(竖向布局,此为上下间距)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        
        return 10.S
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        
        return 0.001.S
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let tempCell = collectionView.cellForItem(at:indexPath ) as? selectImgAlertViewCell
        
        tempCell?.bigBGV.backgroundColor = UIColor.init(hexadecimal: "ECECEE")
        tempCell?.bigBGV.cornerRadius = 10
  
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.closeClick()
            self.selectHeardImgAlertBlock!(tempCell?.IconImgV.image)
        }
    }
    
}

class selectImgAlertViewCell: UICollectionViewCell {
    
    
    var model:UserHeardImgModel?{

        didSet{

            guard let model = model else { return }
            
            IconImgV.image = UIImage.init(named:  model.heardIcon)

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
    }

    func setUpUI(){
        
        backgroundColor = UIColor.clear
        
        contentView.addSubview(bigBGV)
        bigBGV.snp.makeConstraints { (make) in
            
           make.edges.equalToSuperview()
                       
        }
        
        bigBGV.addSubview(IconImgV)
        IconImgV.snp.makeConstraints { (make) in
            
            make.left.equalTo(12.S)
            make.right.equalTo(-12.S)
            make.top.equalTo(15.VS)
            make.size.equalTo(CGSize(width:56.S,height:56.S))
            
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bigBGV:UIView = {
        
        let bigBGV = UIView()
        
        bigBGV.backgroundColor = UIColor.clear
   
        return bigBGV
    }()
    

     lazy var IconImgV:UIImageView = {
        
        let imgV = UIImageView()
         
        imgV.backgroundColor = UIColor.clear
        
        return imgV
        
    }()
    
    
}
