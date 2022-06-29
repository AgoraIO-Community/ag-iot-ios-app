//
//  VerficaCodeView.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/26.
//

import UIKit

protocol VerficaCodeViewDelegate : NSObjectProtocol{
    
    func codeBackComplete(_ code : String)
    func reSendCode()
    
}

class VerficaCodeView: UIView {

    weak var delegate : VerficaCodeViewDelegate?
    
    let accontTopSpace:CGFloat = 225.VS-moreSafeAreaTopSpace()
    var verifyCodeV : VerifyInputView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setUpViews()
        showKeyBoard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
    
        let count = 6
        let spacing: CGFloat = 6 //6 + 13.5
        let height: CGFloat = 57
        let singleW : CGFloat = 48
        let width: CGFloat = singleW * CGFloat(count) + spacing * CGFloat(count - 1)
        let verifyCodeView = VerifyInputView.init { [weak self] (code) in
            
            self?.delegate?.codeBackComplete(code)
            print("\(code)")
            
        }
        verifyCodeView.verifyCount = count
        verifyCodeView.spacing = spacing
        verifyCodeV = verifyCodeView
        
        addSubview(verifyCodeView)
        verifyCodeView.snp.makeConstraints { (make) in
            make.top.equalTo(accontTopSpace)
            make.centerX.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(verifyCodeView.snp.top).offset(-25.VS)
            make.left.equalTo(verifyCodeView.snp.left)
            make.height.equalTo(30.S)
        }
        
        addSubview(timeOutLabel)
        timeOutLabel.snp.makeConstraints { (make) in
            make.top.equalTo(verifyCodeView.snp.bottom).offset(18.VS)
            make.left.equalTo(verifyCodeView.snp.left)
            make.height.equalTo(30.S)
        }
        
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hexString: "#000000")
        label.font = FontPFMediumSize(28)
        label.text = "请输入验证码"
        return label
    }()
    
    lazy var timeOutLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hexString: "#F7B500")
        label.font = FontPFRegularSize(12)
        label.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(reSendCode))
        label.addGestureRecognizer(tapGes)
        label.text = ""//验证码已发送(60s)
        return label
    }()
    
    func showKeyBoard(){
        verifyCodeV?.hideTextField.becomeFirstResponder()
    }

}

extension VerficaCodeView{
    
    func configTimeOutLabel(_ textContent:String, _ isResetSend:Bool = false) {
        timeOutLabel.text = textContent
        if isResetSend == true {
            configTimeOutLabelAction(true)
        }
    }
    
    //重发调用
    @objc func reSendCode(){
        self.delegate?.reSendCode()
    }
    
    //重新发送是否可点击
    func configTimeOutLabelAction(_ isAction : Bool = false){
        timeOutLabel.isUserInteractionEnabled = isAction
    }
}


class VerifyCodeSingleView: UILabel{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#F6F6F6")
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 28)
        self.textColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}

class VerifyInputView: UIStackView, UITextFieldDelegate {
    
    var isCompelete : Bool = false
    
    var verifyCodes: [VerifyCodeSingleView]!
    
    /**验证码字体*/
    public var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet{
            for verifyCode in self.verifyCodes{
                verifyCode.font = font
            }
        }
    }
    
    /**验证码数量*/
    public var verifyCount: Int? {
        didSet{
            for i in Range(0...(verifyCount ?? 4) - 1) {
                let singleView = VerifyCodeSingleView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                if i == 0 {
                    singleView.layer.borderWidth = 0.3
                    singleView.layer.borderColor = UIColor.red.cgColor
                }
                verifyCodes.append(singleView)
                self.addArrangedSubview(singleView)
            }
        }
    }
    
    /**验证码输入完成后的回调闭包，返回参数为验证码*/
    var completeHandler: ((_ verifyCode: String) -> Void)!
    
    //隐藏的输入框
    lazy var hideTextField: UITextField = {
        let textfield = UITextField()
        self.addSubview(textfield)
        textfield.isHidden = true
        textfield.keyboardType = .numberPad
        textfield.delegate = self
        if #available(iOS 12.0, *) {
            textfield.textContentType = UITextContentType.oneTimeCode
        } else {
            // Fallback on earlier versions
        }
        return textfield
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.distribution = .fillEqually
        verifyCodes = []
        verifyCount = 4
    }
    
    /**
     - parameter complete: 验证完成回调闭包，返回参数为验证码
     */
    public convenience init(complete: @escaping (_ verifyCode: String) -> Void) {
        self.init()
        setCompleteHandler(complete: complete)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**设置验证码输入完成后的回调闭包*/
    public func setCompleteHandler(complete: @escaping (_ verifyCode: String) -> Void) {
        self.completeHandler = complete
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard textField.text!.count <= (verifyCount ?? 4) else {
            textField.text = String(textField.text!.prefix(4))
            return
        }
        
        var index = 0
        for char in textField.text! {
            verifyCodes[index].text = String(char)
            index += 1
        }
        changeVerifyCoder()
        changeCurrentCheckLabel(textField.text ?? "")
        guard index < (verifyCount ?? 4) else {
            
            self.endEditing(true)
            
            if let complete = self.completeHandler, isCompelete == false {
                isCompelete = true
                complete(textField.text!)
            }
            return
        }
        for i in Range(index...(verifyCount ?? 4) - 1) {
            verifyCodes[i].text = ""
        }
        isCompelete = false
        
    }
    
    func changeVerifyCoder(){
        for index in Range(0...(verifyCount ?? 4) - 1) {
            let lable : UILabel = verifyCodes[index]
            lable.layer.borderWidth = 0
            lable.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func changeCurrentCheckLabel(_ contentText : String) {
        let index = contentText.count
        guard index < verifyCount ?? 4 else { return }
        let lable : UILabel = verifyCodes[index]
        lable.layer.borderWidth = 0.3
        lable.layer.borderColor = UIColor.red.cgColor
    
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideTextField.becomeFirstResponder()
    }
    
}
