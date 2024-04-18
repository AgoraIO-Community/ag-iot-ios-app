//
//  AGConfirmEditMultiAlertVC.swift
//  IotLinkDemo
//
//  Created by admin on 2024/4/16.
//

import UIKit
import IQKeyboardManagerSwift


class AGConfirmEditMultiAlertVC: UIViewController,UITextFieldDelegate {

    var alertType : AGEditAlertType = .none
    var hisInputString = ""
    
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .always
        textField.placeholder = "请输入 AppId"
        textField.delegate = self
        textField.textColor = UIColor.black//修改颜色
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hexRGB: 0xDADADA).cgColor
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.keyboardType = .asciiCapable
        textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        return textField
    }()
    
    lazy var textFieldS:UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .always
        textField.placeholder = "请输入 CustomerKey"
        textField.delegate = self
        textField.textColor = UIColor.black//修改颜色
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hexRGB: 0xDADADA).cgColor
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.keyboardType = .asciiCapable
        textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        return textField
    }()
    
    lazy var textFieldT:UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .always
        textField.placeholder = "请输入 CustomerSecret"
        textField.delegate = self
        textField.textColor = UIColor.black//修改颜色
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hexRGB: 0xDADADA).cgColor
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.keyboardType = .asciiCapable
        textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        return textField
    }()
    
    lazy var alertView:AGConfirmAlertBaseView = {
        let alertView = AGConfirmAlertBaseView()
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        return alertView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        setupUI()
    }
    
    private func setupUI(){
        view.addSubview(alertView)
        alertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
        }
        
        let textbgView = UIView()
        alertView.customView = textbgView
        textbgView.snp.makeConstraints { make in
            make.left.equalTo(23)
            make.right.equalTo(-23)
            make.top.equalTo(74)
            make.bottom.equalTo(-105)
            make.height.equalTo(48*4)
        }
        
        textbgView.addSubview(textField)
        textbgView.addSubview(textFieldS)
        textbgView.addSubview(textFieldT)
        
        textFieldS.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(48)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(textFieldS.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(48)
        }
        
        textFieldT.snp.makeConstraints { make in
            make.bottom.equalTo(textFieldS.top).offset(-10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(48)
        }
   
    }
    
    
    func setTitle(_ title:String?,editText:String,commitTitle:String ,commitAction: ((String,String,String)->(Void))?) {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        alertView.titleLabel.text = title
        alertView.commitButton.setTitle(commitTitle, for: .normal)
        alertView.clickCommitButtonAction = {[weak self] in

            guard self?.textField.text != "" else {
                AGToolHUD.showInfo(info: "AppId不能为空!")
                return
            }
            
            guard self?.textFieldS.text != "" else {
                AGToolHUD.showInfo(info: "customerKey不能为空!")
                return
            }
            
            guard self?.textFieldT.text != "" else {
                AGToolHUD.showInfo(info: "customerSecret不能为空!")
                return
            }
            
            IQKeyboardManager.shared.enable = false
            IQKeyboardManager.shared.enableAutoToolbar = false
            IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
            
            commitAction?((self?.textField.text)!,(self?.textFieldS.text)!,(self?.textFieldT.text)!)
            self?.dismiss(animated: true)
        }
    }
    
    
    static func showTitleTop(_ title:String?,editText:String,commitTitle:String = "确定", alertType :AGEditAlertType = .none, commitAction: ((String,String,String)->(Void))?)  {
        let vc = AGConfirmEditMultiAlertVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertType = alertType
        vc.setTitle(title,editText:editText, commitTitle: commitTitle, commitAction: commitAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if alertType == .modifyDeviceName{
            if string == "" {
                return true
            }
            
            if string == "\n" {
                textField.resignFirstResponder()
            }
//            let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
//            debugPrint("---result----:\(result)")
            
//            let ret = (textField.text ?? "") + string
//            let content : String = ret.replaceSpace()
//            //限制长度
//            if content.getToInt() > 20 {
//                return false
//            }
            return true
        }
        return true
    }
    
    @objc func textDidChangeNotification(textField:UITextField)  {
        debugPrint("-------\(textField.text)")
        if alertType == .modifyDeviceName{
            
            guard let ret = textField.text else{
                return
            }
            let content : String = ret.replaceSpace()
            //限制长度
            if content.getToInt() > 80 {
                textField.text = hisInputString
                AGToolHUD.showInfo(info: "最大输入20个字符")
            }else{
                hisInputString = content
            }
            
        }
        
    }
    
}
