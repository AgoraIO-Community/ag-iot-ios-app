//
//  SelectWIFIView.swift
//  AgoraIoT
//
//  Created by FanPengpeng on 2022/4/24.
//

import UIKit
import Alamofire

class CustomTextField: UIView {
    
    lazy var leftView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var rightView:UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    lazy var textField:UITextField = {
        let TF = UITextField()
        TF.font = UIFont.systemFont(ofSize: 18.S)
        TF.textColor = UIColor.black
        TF.delegate = self
        return TF
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews(){
        addSubview(leftView)
        addSubview(textField)
        addSubview(rightView)
        textField.snp.makeConstraints { make in
            make.left.equalTo(56.S)
            make.right.equalTo(-56.S)
            make.top.bottom.equalToSuperview()
        }
        
        leftView.snp.makeConstraints { make in
            make.left.equalTo(23.S)
            make.centerY.equalToSuperview()
            make.width.equalTo(23.S)
        }
        
        rightView.snp.makeConstraints { make in
            make.right.equalTo(-20.S)
            make.centerY.equalToSuperview()
            make.width.equalTo(23.S)
            make.height.equalTo(23.S)
        }
        
        layer.cornerRadius = 11.S
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexRGB: 0xDADADA).cgColor
        layer.masksToBounds = true
    }
    
    func setLeftImage(_ leftImage:String,rightImage:String) {
        leftView.image = UIImage(named: leftImage)
        rightView.setImage(UIImage(named: rightImage), for: .normal)
    }
}


class SelectWIFIView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidchange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var clickWifiButtonAction:(()->(Void))?
    var clickNextButtonAction:((_ wifi:String, _ password:String)->(Void))?
    var wifiTextFieldBeginEdit:(()->(Void))?
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.S, weight: .medium)
        label.textColor = UIColor(hexRGB: 0x000000, alpha: 0.85)
        label.text = "选择2.4GHz WiFi网络并输入密码"
        return label
    }()
    
    private lazy var subtitleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.S)
        label.textColor = UIColor(hexRGB: 0xF7B500)
        label.text = "设备WiFi目前仅支持2.4G WiFi"
        return label
    }()

    
    private lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wificonn")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameTextField:CustomTextField = {
        let textField = CustomTextField()
        textField.textField.placeholder = "WiFi名称"
        textField.setLeftImage("ic_wifi", rightImage: "arrow-right")
        textField.textField.keyboardType = .asciiCapable
        textField.rightView.addTarget(self, action: #selector(didClickWifiButton(_:)), for: .touchUpInside)
        textField.textField.delegate = self
        return textField
    }()
    
    private lazy var wifiTipsLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.S)
        label.textColor = .red
        label.numberOfLines = 2
        label.text = "目前手机没有连接WiFi"
        return label
    }()
    
    private lazy var passwordTextField:CustomTextField = {
        let textField = CustomTextField()
        textField.textField.placeholder = "密码"
        textField.setLeftImage("ic_lock", rightImage: "")
        textField.rightView.setImage(UIImage(named: "eyeon"), for: .normal)
        textField.rightView.setImage(UIImage(named: "eyeoff"), for: .selected)
        textField.textField.keyboardType = .asciiCapable
        textField.rightView.addTarget(self, action: #selector(didClickPasswordButton(_:)), for: .touchUpInside)
        textField.textField.delegate = self
        return textField
    }()
    
    private lazy var nextButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor(hexRGB: 0x25DEDE), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.S)
        button.backgroundColor = .gray
        button.isEnabled = false
        button.layer.cornerRadius = 28.S
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didClickNextButton), for: .touchUpInside)
        return button
    }()
    
    
    private func createSubviews(){
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(imageView)
        addSubview(nameTextField)
        addSubview(wifiTipsLabel)
        addSubview(passwordTextField)
        addSubview(nextButton)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(42.S)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(73.S)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(110.S)
            make.width.equalTo(225.S)
            make.height.equalTo(137.S)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(285.S)
            make.height.equalTo(59.S)
            make.top.equalTo(imageView.snp.bottom).offset(56.S)
        }
        
        wifiTipsLabel.snp.makeConstraints { make in
            make.left.equalTo(nameTextField)
            make.width.equalTo(nameTextField)
            make.top.equalTo(nameTextField.snp.bottom).offset(10.S)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(nameTextField)
            make.height.equalTo(nameTextField)
            make.top.equalTo(400.S)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40.S)
            make.centerX.equalToSuperview()
            make.width.equalTo(nameTextField)
            make.height.equalTo(56.S)
        }
    }
    
    @objc private func textDidchange(){
        checkShowWifiTipsLabel()
        checkCanNext()
    }
    
    
    private func checkShowWifiTipsLabel() {
        if let text = self.nameTextField.textField.text {
            if text.contains("5G") || text.contains("5g") {
                wifiTipsLabel.text = "当前WiFi可能是5GHz，请选择2.4G WiFi，或配置路由器打开2.4G 网络"
                wifiTipsLabel.isHidden = false
            }else{
                wifiTipsLabel.isHidden = true
            }
        }
    }
    
    private func checkCanNext(){
        nextButton.isEnabled = false
        nextButton.backgroundColor = .gray
        if let name = nameTextField.textField.text {
            if let pwd = passwordTextField.textField.text {
                if name.count > 0 && pwd.count > 0 {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = UIColor(hexRGB: 0x1A1A1A)
                }
            }
        }
    }

    
    // MARK: - public
    func setWiFiName(_ name:String?) {
        if name == nil {
            wifiTipsLabel.isHidden = false
            wifiTipsLabel.text = "目前手机没有连接WiFi"
        }else{
            nameTextField.textField.text = name
            checkShowWifiTipsLabel()
        }
    }

    // MARK: - actions
    
    // 点击选择wifi按钮
    @objc private func didClickWifiButton(_ button: UIButton){
        clickWifiButtonAction?()
    }
    
    // 点击密码按钮
    @objc private func didClickPasswordButton(_ button: UIButton){
        button.isSelected = !button.isSelected
        passwordTextField.textField.isSecureTextEntry = button.isSelected
    }
    
    @objc private func didClickNextButton(){
        clickNextButtonAction?(nameTextField.textField.text ?? "", passwordTextField.textField.text ?? "")
    }
}

extension SelectWIFIView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isFullScreen{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.titleLabel.isHidden = true
                self?.subtitleLabel.isHidden = true
            }
        }
        
        
        if textField == nameTextField.textField {
            wifiTextFieldBeginEdit?()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isFullScreen{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.titleLabel.isHidden = false
                self?.subtitleLabel.isHidden = false
            }
        }
    }
}


extension CustomTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
