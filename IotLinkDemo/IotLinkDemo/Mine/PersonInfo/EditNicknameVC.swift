//
//  EditNicknameVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/18.
//

import UIKit
import AgoraIotLink
import SVProgressHUD

class EditNicknameVC: UIViewController {
    
    private lazy var textFiled: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.borderColor = UIColor(hexRGB: 0xDADADA)
        tf.placeholder = "请输入昵称"
        tf.becomeFirstResponder()
        return tf
    }()
    
    var nickname:String?
    
    var editSuccessAction:((_ nickname:String)->(Void))?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        title = "昵称"
        let item = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(didClickDoneButton))
        item.tintColor = UIColor(hexRGB: 0x1DD6D6)
        navigationItem.rightBarButtonItem = item
        
        textFiled.text = nickname
        view.addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(20)
            make.width.equalTo(285)
            make.height.equalTo(60)
        }
    }

    @objc private func didClickDoneButton(){
        let info = UserInfo()
        if let text = textFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if text.isEmpty {
                return
            }
            info.name = text
            AgoraIotManager.shared.sdk?.accountMgr.updateAccountInfo(info: info, result: { [weak self] ec, msg in
                if(ec == ErrCode.XOK){
                    self?.navigationController?.popViewController(animated: true)
                    self?.editSuccessAction?(text)
                }else{
                    SVProgressHUD.showError(withStatus: "修改昵称失败")
                }
            })
        }
       
    
    }
}
