//
//  ConnectItemLabel.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/9/22.
//

import UIKit


private let kIndexHeight:CGFloat = 18.S

class ConnectItemLabel: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var indexLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10.S)
        label.textColor = .white
        label.backgroundColor = UIColor(hexString: "6c6c6c")
        label.layer.cornerRadius = kIndexHeight * 0.5
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var textLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.S)
        label.textColor =  UIColor(hexString: "6c6c6c")
        return label
    }()
    
    lazy var selectButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "msg_unselect"), for: .normal)
        button.setImage(UIImage(named: "country_selected"), for: .selected)
        return button
    }()

    private func createSubviews(){
//        addSubview(indexLabel)
        addSubview(selectButton)
        addSubview(textLabel)
        selectButton.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(kIndexHeight)
        }
        
//        indexLabel.snp.makeConstraints { make in
//            make.left.centerY.equalToSuperview()
//            make.width.height.equalTo(kIndexHeight)
//        }
        
        textLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: kIndexHeight + 10.S, bottom: 0, right: 0))
        }
    }
    
    func setText(_ text: String, index: Int){
//        indexLabel.text = "\(index)"
        textLabel.text = text
    }
}
