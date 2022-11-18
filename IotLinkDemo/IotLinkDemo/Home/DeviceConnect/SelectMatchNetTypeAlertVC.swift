//
//  SelectMatchNetTypeAlertVC.swift
//  IotLinkDemo
//
//  Created by wanghaipeng on 2022/11/17.
//

import UIKit

class SelectMatchNetTypeAlertVC: UIViewController {
    
    typealias SelectMatchNetTypeAlerVCBlock = (_ type:Int) -> ()
    var selectMatchNetTypeVCBlock:SelectMatchNetTypeAlerVCBlock?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI(){
        
        view.backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        view.addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(lineView)
        bgView.addSubview(cameraButton)
        bgView.addSubview(blueFiButton)
        
        bgView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(30.S)
            make.right.equalTo(-30.S)
            make.height.equalTo(160.VS)
        }
        
        titleLabel.snp.makeConstraints{ (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60.VS)
        }
        
        lineView.snp.makeConstraints{ (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5.VS)
        }

        cameraButton.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom)
            make.left.equalTo(30.S)
            make.right.equalTo(-30.S)
            make.height.equalTo(50.VS)
        }
        
        blueFiButton.snp.makeConstraints { (make) in
            make.top.equalTo(cameraButton.snp.bottom)
            make.left.equalTo(30.S)
            make.right.equalTo(-30.S)
            make.height.equalTo(50.VS)
        }
 
    }

    lazy var bgView:UIView = {

       let view = UIView()
        view.backgroundColor = UIColor.white
        view.cornerRadius = 6

       return view
   }()
   
   private lazy var titleLabel:UILabel = {
       let label = UILabel()
       label.font = FontPFMediumSize(18)
       label.textColor = UIColor.black
       label.numberOfLines = 2
       label.textAlignment = .center
       label.text = "请选择配网方式"
       return label
   }()
   

   lazy var lineView:UIView = {

      let view = UIView()
       view.backgroundColor = UIColor.lightGray

      return view
  }()
   
   private lazy var cameraButton:UIButton = {
       
       let button = UIButton(type: .custom)
       button.tag = 1001
       button.setTitle("摄像头", for: .normal)
       button.setTitleColor(UIColor.black, for: .normal)
       button.titleLabel?.font = FontPFRegularSize(15.S)
       button.titleLabel?.textAlignment = .center
       button.isEnabled = true
       button.addTarget(self, action: #selector(didClickNextButton(_:)), for: .touchUpInside)
       return button
       
   }()
   
   private lazy var blueFiButton:UIButton = {
       
       let button = UIButton(type: .custom)
       button.tag = 1002
       button.setTitle("蓝牙", for: .normal)
       button.setTitleColor(UIColor.black, for: .normal)
       button.titleLabel?.font = FontPFRegularSize(15.S)
       button.titleLabel?.textAlignment = .center
       button.isEnabled = true
       button.addTarget(self, action: #selector(didClickNextButton(_:)), for: .touchUpInside)
       return button
       
   }()

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: false) { }
    }
   
   @objc func didClickNextButton(_ button : UIButton){
        
       self.dismiss(animated: false) { }
       selectMatchNetTypeVCBlock?(button.tag)
       
   }

}
