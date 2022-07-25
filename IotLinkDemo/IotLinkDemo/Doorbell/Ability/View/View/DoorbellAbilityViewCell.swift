//
//  DoorbellAbilityViewCell.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/5/6.
//

import UIKit

class DoorbellAbilityViewCell: UICollectionViewCell {
    
    
    var model:DoorbellAbilityModel?{

        didSet{

            guard let model = model else { return }

            nameLab.text = model.abilityName
            
            if model.isSelected {
                IconImgV.image = UIImage.init(named: model.abilitySecectIcon)
            }else{
                IconImgV.image = UIImage.init(named:  model.abilityIcon)
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
    }

    func setUpUI(){
        
        backgroundColor = UIColor(hexString: "#000000")
        
        contentView.addSubview(bigBGV)
        bigBGV.snp.makeConstraints { (make) in
            
           make.edges.equalToSuperview()
                       
        }
        
        bigBGV.addSubview(IconImgV)
        IconImgV.snp.makeConstraints { (make) in
            
            make.top.left.right.equalToSuperview()
            make.size.equalTo(CGSize(width:60.S,height:60.S))
            
        }
        
        bigBGV.addSubview(nameLab)
        nameLab.snp.makeConstraints { (make) in
            
            make.top.equalTo(IconImgV.snp.bottom).offset(8.VS)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width:60.S,height:17.S))
            
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var bigBGV:UIView = {
        
        let bigBGV = UIView()
        
        bigBGV.backgroundColor = UIColor.clear
        
        return bigBGV
    }()
    

     lazy var IconImgV:UIImageView = {
        
        let imgV = UIImageView()
        
        return imgV
        
    }()
    
    fileprivate lazy var nameLab:UILabel = {
        
        let lab = UILabel()
        
        lab.textColor = UIColor(hexString: "#FBFBFB")
        
        lab.font = FontPFRegularSize(12)
        
        lab.textAlignment = .center
        
        return lab
    }()
    
}
