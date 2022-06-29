//
//  AGDatePickerVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/10.
//

import UIKit

private let buttonHeight:CGFloat = 44

class AGDatePickerVC: UIViewController {

    var defaultDate:Date?
    
    // 选择结束回调
    var selectedAction: ((_ selectedDate:Date)->(Void))?
    
    lazy var cancelButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
        return button
    }()
    
    lazy var commitButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(didClickCommitButton(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var toolBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(cancelButton)
        view.addSubview(commitButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
            make.width.equalTo(60)
            make.height.equalTo(buttonHeight)
        }
        
        commitButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
            make.width.equalTo(60)
            make.height.equalTo(buttonHeight)
        }
        return view
    }()
    
    private lazy var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        /*
        let cornerRadius = 30
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width:cornerRadius,height:cornerRadius)).cgPath
        datePicker.layer.mask = maskLayer
         */
        return datePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    
    private func setupUI(){
        datePicker.date = defaultDate ?? Date()
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(datePicker.snp.top).offset(buttonHeight)
            make.height.equalTo(50)
        }
    }
    
    static func show(defaultDate:Date = Date(),selectAction: ((_ selectedDate:Date)->(Void))?)  {
        let vc = AGDatePickerVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.defaultDate = defaultDate
        vc.selectedAction = selectAction
        currentViewController().present(vc, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    // MARK: - actions
    
    // 点击取消
    @objc private func didClickCancelButton(){
        self.dismiss(animated: true)
    }

    // 点击听到提示音
    @objc private func didClickCommitButton(_ button:UIButton){
        self.dismiss(animated: true) {[weak self] in
            if self == nil { return }
            self!.selectedAction?(self!.datePicker.date)
        }
    }

}
