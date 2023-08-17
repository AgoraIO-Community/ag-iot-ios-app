//
//  AGEditAlertVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

public enum AGEditAlertType: Int{
    ///默认
    case none = 0
    
    ///修改设备名字
    case modifyDeviceName = 1
    ///其他
    case other = 2

}

class AGEditAlertVC: UIViewController,UITextFieldDelegate {

    var alertType : AGEditAlertType = .none
    var hisInputString = ""
    
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .always
        textField.placeholder = "请输入设备nodeId"
        textField.delegate = self
        textField.textColor = UIColor.black//修改颜色
        textField.addTarget(self, action: #selector(textDidChangeNotification(textField:)), for: .editingChanged)
        return textField
    }()
    
    lazy var alertView:AGAlertBaseView = {
        let alertView = AGAlertBaseView()
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
    
    
    func setTitle(_ title:String?,editText:String,cancelTitle:String,commitTitle:String ,commitAction: ((String)->(Void))?, cancelAction: (()->(Void))?) {
        alertView.titleLabel.text = title
        textField.placeholder = editText
        alertView.cancelButton.setTitle(cancelTitle, for: .normal)
        alertView.commitButton.setTitle(commitTitle, for: .normal)
        alertView.clickCancelButtonAction = {[weak self] in
            cancelAction?()
            self?.dismiss(animated: false)
        }
        alertView.clickCommitButtonAction = {[weak self] in
            commitAction?(self?.textField.text ?? "")
            self?.dismiss(animated: true)
        }
    }
    
    
    static func showTitle(_ title:String?,editText:String,cancelTitle:String = "取消",commitTitle:String = "确定", alertType :AGEditAlertType = .none, commitAction: ((String)->(Void))?)  {
        let vc = AGEditAlertVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertType = alertType
        vc.setTitle(title,editText:editText, cancelTitle: cancelTitle, commitTitle: commitTitle, commitAction: commitAction,cancelAction: nil)
        currentViewController().present(vc, animated: false)
    }
    
    static func showTitleTop(_ title:String?,editText:String,cancelTitle:String = "cancel".L,commitTitle:String = "confirm".L, alertType :AGEditAlertType = .none, commitAction: ((String)->(Void))?, cancelAction: (()->(Void))?)  {
        let vc = AGEditAlertVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.alertType = alertType
        vc.setTitle(title,editText:editText, cancelTitle: cancelTitle, commitTitle: commitTitle, commitAction: commitAction,cancelAction: cancelAction)
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
