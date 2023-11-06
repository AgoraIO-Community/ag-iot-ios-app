//
//  AGConfirmEditAlertVC.swift
//  IotLinkDemo
//
//  Created by admin on 2023/7/27.
//

import UIKit


class AGConfirmEditAlertVC: UIViewController,UITextFieldDelegate {

    var alertType : AGEditAlertType = .none
    var hisInputString = ""
    
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .always
        textField.placeholder = "请输入"
        textField.delegate = self
        textField.textColor = UIColor.black//修改颜色
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
        textbgView.layer.cornerRadius = 5
        textbgView.layer.borderWidth = 1
        textbgView.layer.borderColor = UIColor(hexRGB: 0xDADADA).cgColor
        textbgView.snp.makeConstraints { make in
            make.left.equalTo(23)
            make.right.equalTo(-23)
            make.top.equalTo(74)
            make.bottom.equalTo(-105)
            make.height.equalTo(48)
        }
        textbgView.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        }
    }
    
    
    func setTitle(_ title:String?,editText:String,commitTitle:String ,commitAction: ((String)->(Void))?) {
        alertView.titleLabel.text = title
        textField.placeholder = editText
        alertView.commitButton.setTitle(commitTitle, for: .normal)
        alertView.clickCommitButtonAction = {[weak self] in
            if self?.textField.text == ""{
                AGToolHUD.showInfo(info: "输入内容不能为空!")
                return
            }
            commitAction?(self?.textField.text ?? "")
            self?.dismiss(animated: true)
        }
    }
    
    
    static func showTitle(_ title:String?,editText:String,commitTitle:String = "确定", alertType :AGEditAlertType = .none, commitAction: ((String)->(Void))?)  {
        let vc = AGConfirmEditAlertVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertType = alertType
        vc.setTitle(title,editText:editText,commitTitle: commitTitle, commitAction: commitAction)
        currentViewController().present(vc, animated: false)
    }
    
    static func showTitleTop(_ title:String?,editText:String,commitTitle:String = "确定", alertType :AGEditAlertType = .none, commitAction: ((String)->(Void))?)  {
        let vc = AGConfirmEditAlertVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertType = alertType
        vc.setTitle(title,editText:editText, commitTitle: commitTitle, commitAction: commitAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
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
            if content.getToInt() > 40 {
                textField.text = hisInputString
                AGToolHUD.showInfo(info: "最大输入20个字符")
            }else{
                hisInputString = content
            }
            
        }
        
    }
    
}