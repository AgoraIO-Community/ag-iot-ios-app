//
//  ModifyPwdVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/5/12.
//

import UIKit
import IQKeyboardManagerSwift

class ModifyPwdVC: UIViewController {

    fileprivate lazy var loginVM = LoginMainVM()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        
    }
    
    lazy var oldPasswordTextField: LoginInputView = {
        let vew = LoginInputView()
        vew.leftImage = UIImage.init(named: "login_password")
        vew.placeholder = "请输入旧密码"
        vew.textField.tag = 200
        vew.textField.delegate = self
        return vew
    }()


    lazy var newPasswordTextField: LoginInputView = {
        let vew = LoginInputView()
        vew.leftImage = UIImage.init(named: "login_password")
        vew.placeholder = "请输入新密码"
        vew.textField.tag = 300
        vew.textField.delegate = self
        return vew
    }()
    
    private lazy var doneButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(hexRGB: 0x1A1A1A)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickDoneButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        setupUI()
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "修改密码"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 28)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(45)
            make.top.equalTo(160)
            make.height.equalTo(40)
        }
        
        view.addSubview(oldPasswordTextField)
        oldPasswordTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(23)
            make.width.equalTo(ScreenWidth - 90)
            make.height.equalTo(60*ScreenHS)
        }
        
        view.addSubview(newPasswordTextField)
        newPasswordTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(oldPasswordTextField.snp.bottom).offset(26)
            make.width.equalTo(oldPasswordTextField)
            make.height.equalTo(60*ScreenHS)
        }
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(52)
            make.width.equalTo(285)
            make.height.equalTo(56)
        }
        
    }
    
    // 点击完成按钮
    @objc private func didClickDoneButton(){
        
        guard verficationPassword(oldPasswordTextField.textField.text) == true else {
            AGToolHUD.showInfo(info: "旧密码为8至20位大小写字母及数字")
            return
        }
        
        guard verficationPassword(newPasswordTextField.textField.text) == true else {
            AGToolHUD.showInfo(info: "新密码为8至20位大小写字母及数字")
            return
        }
        
        modifyPassword(oldPwd: oldPasswordTextField.textField.text ?? "", newPwd: newPasswordTextField.textField.text ?? "")
    }
}

extension ModifyPwdVC{
    
    //修改密码
    func modifyPassword(oldPwd: String,newPwd: String){
        
        loginVM.changePassword(oldPwd,newPwd) { [weak self] success, msg in
            
            if success {
                AGToolHUD.showInfo(info: "密码修改成功")
                debugPrint("密码重置成功")
                self?.navigationController?.popViewController(animated: true)
            }else{
                AGToolHUD.showInfo(info: msg)
            }
            print("\(msg)")
        }
        
    }
    
    //校验密码格式
    func verficationPassword(_ password:String?) -> Bool{
        guard let text = password, text.count != 0 else {
            return false
        }
        
        if VerifyManager.checkPassword(text: text) == true {
            return true
        }
        
        return false
    }
    
}

extension ModifyPwdVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
