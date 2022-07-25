//
//  AGEditAlertVC.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/25.
//

import UIKit

class AGEditAlertVC: UIViewController {

    
    
    lazy var textField:UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .always
        textField.placeholder = "请输入分享账号"
        textField.textColor = UIColor.black//修改颜色
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
    
    
    func setTitle(_ title:String?,editText:String,cancelTitle:String,commitTitle:String ,commitAction: ((String)->(Void))?) {
        alertView.titleLabel.text = title
        textField.text = editText
        alertView.cancelButton.setTitle(cancelTitle, for: .normal)
        alertView.commitButton.setTitle(commitTitle, for: .normal)
        alertView.clickCancelButtonAction = {[weak self] in
            self?.dismiss(animated: false)
        }
        alertView.clickCommitButtonAction = {[weak self] in
            commitAction?(self?.textField.text ?? "")
            self?.dismiss(animated: true)
        }
    }
    
    
    static func showTitle(_ title:String?,editText:String,cancelTitle:String = "取消",commitTitle:String = "确定",commitAction: ((String)->(Void))?)  {
        let vc = AGEditAlertVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.setTitle(title,editText:editText, cancelTitle: cancelTitle, commitTitle: commitTitle, commitAction: commitAction)
        currentViewController().present(vc, animated: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }

}
