//
//  LoginProtocolAlertVC.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/27.
//

import UIKit
import WebKit

public enum ProtocolType: Int{
    
    ///默认
    case none = 0
    ///隐私政策
    case priviteProtocol = 1
    ///用户协议
    case userProtocol = 2
}

public enum SourcePageType: Int{
    
    ///默认
    case none = 0
    ///程序启动
    case loginPage = 1
    ///关于页面
    case aboutPage = 2
}

class LoginProtocolAlertVC: UIViewController {
    
    let  contentVStr = "我们非常重视用户的隐私保护，因此制定了本涵盖如何收集、使用、披露、分享以及存储用户的信息的《隐私条款》。"
    
    let  contentVStr1 = "1、用户在使用我们的服务时，我们可能会收集和使用您的相关信息。我们希望通过本《隐私条款》向您说明，在使用我们的服务时"
    
    let userProtocolUrl = "https://agoralink.sd-rtn.com/terms/termsofuse"
    let privateProUrl = "https://agoralink.sd-rtn.com/terms/privacypolicy"
    
    ///协议类型
    var proType:ProtocolType = .none
    
    ///页面来源
    var pageSource:SourcePageType = .none
    
    
    
    typealias LoginProtocolAlertVCBlock = (_ type:Int) -> ()
    var loginProAlertVCBlock:LoginProtocolAlertVCBlock?
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        debugPrint("回到前台111")
        bgV.isHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bgV.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        var protocolStr = ""
        if proType == .priviteProtocol {
            protocolStr = privateProUrl
        }else if proType == .userProtocol{
            protocolStr = userProtocolUrl
        }
         
        guard let url: URL = URL(string: protocolStr) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        
        if pageSource == .aboutPage {
            refuseBtn.setTitle("取消", for: .normal)
            agreeBtn.setTitle("确定", for: .normal)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(backforeground), name: Notification.Name(cApplicationWillEnterForegroundNotify), object: nil)
    }
    
    @objc private func backforeground(){
        bgV.isHidden = false
    }
    
    func setupUI(){
        
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        
        bgImgV.addSubview(iconImgV)
        iconImgV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80.S)
            make.width.equalTo(140.S)
            make.height.equalTo(63.S)
        }
        
        bgImgV.addSubview(iconTitleLab)
        iconTitleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImgV.snp.bottom).offset(20.S)
            make.width.equalTo(90.S)
            make.height.equalTo(50.S)
        }
        
        
        bgImgV.addSubview(bgV)
        bgV.snp.makeConstraints { (make) in
//            make.width.equalTo(300.S)
//            make.height.equalTo(428.S)
//            make.centerX.centerY.equalToSuperview()
            
            make.top.bottom.left.right.equalToSuperview()
        }
        
        bgV.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(31.S)
            make.centerX.equalToSuperview()
            make.width.equalTo(200.S)
            make.height.equalTo(25.S)
        }
        
        
        bgV.addSubview(privacyLab)
        privacyLab.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-112.VS)
            make.centerX.equalToSuperview().offset(-40.S)
            make.width.equalTo(60.S)
            make.height.equalTo(20.S)
        }
        
        bgV.addSubview(privacyLineV)
        privacyLineV.snp.makeConstraints { (make) in
            make.bottom.equalTo(privacyLab.snp.bottom)
            make.left.equalTo(privacyLab.snp.left).offset(2.S)
            make.right.equalTo(privacyLab.snp.right).offset(-2.S)
            make.height.equalTo(1.5.S)
        }
        
        bgV.addSubview(protocolLab)
        protocolLab.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-112.VS)
            make.centerX.equalToSuperview().offset(40.S)
            make.width.equalTo(60.S)
            make.height.equalTo(20.S)
        }
        
        bgV.addSubview(proLineV)
        proLineV.snp.makeConstraints { (make) in
            make.bottom.equalTo(protocolLab.snp.bottom)
            make.left.equalTo(protocolLab.snp.left).offset(2.S)
            make.right.equalTo(protocolLab.snp.right).offset(-2.S)
            make.height.equalTo(1.5.S)
        }
        
        bgV.addSubview(textLab)
        textLab.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-112.VS)
            make.centerX.equalToSuperview()
            make.width.equalTo(14.S)
            make.height.equalTo(20.S)
        }
        
        bgV.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(20.VS)
            make.left.equalTo(20.S)
            make.right.equalTo(-20.S)
            make.bottom.equalTo(privacyLab.snp.top).offset(-20.VS)
        }
        
//        bgV.addSubview(textView)
//        textView.snp.makeConstraints { (make) in
//            make.top.equalTo(titleLab.snp.bottom).offset(20.VS)
//            make.left.equalTo(20.S)
//            make.right.equalTo(-20.S)
//            make.bottom.equalTo(privacyLab.snp.top).offset(-20.VS)
//        }
        
        bgV.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-29.VS)
            make.centerX.equalToSuperview().offset(55.S)
            make.width.equalTo(90.S)
            make.height.equalTo(40.S)
        }
        
        bgV.addSubview(refuseBtn)
        refuseBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-29.VS)
            make.centerX.equalToSuperview().offset(-55.S)
            make.width.equalTo(90.S)
            make.height.equalTo(40.S)
        }
 
    }
    
    fileprivate lazy var bgImgV : UIImageView = {
        let bgV = UIImageView.init()
        bgV.backgroundColor = UIColor.clear
        bgV.isUserInteractionEnabled = true
        bgV.image = UIImage.init(named: "black_bg")
        return bgV
    }()
    
    fileprivate lazy var iconImgV : UIImageView = {
        let bgV = UIImageView.init()
        bgV.backgroundColor = UIColor.clear
        bgV.image = UIImage.init(named: "app_logo")
        return bgV
    }()
    
    fileprivate lazy var iconTitleLab : UILabel = {
        let label = UILabel.init()
        label.text = "灵隼"
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: "#1A1A1A")
        label.font = FontPFRegularSize(36)
        return label
    }()
    
    fileprivate lazy var bgV : UIView = {
        let bgV = UIView.init()
        bgV.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        bgV.layer.cornerRadius = 10
        bgV.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        bgV.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgV.layer.shadowOpacity = 1
        bgV.layer.shadowRadius = 20
        bgV.isUserInteractionEnabled = true
        return bgV
    }()
    
    fileprivate lazy var textView:UITextView = {
        
        let textView = UITextView.init()
        textView.backgroundColor = .white
        textView.isEditable = false
        textView.isSelectable = false
        textView.showsVerticalScrollIndicator  = false
        textView.font = FontPFRegularSize(14)
        textView.textColor = UIColor.init(hexRGB: 000000, alpha:0.5)
        textView.text = contentVStr
        return textView
        
    }()
    
    fileprivate lazy var webView: WKWebView = {
        
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    fileprivate lazy var titleLab : UILabel = {
        let label = UILabel.init()
        label.text = "用户协议与隐私政策"
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: "#000000")
        label.alpha = 0.85
        label.font = FontPFRegularSize(18)
        return label
    }()
    
    fileprivate lazy var privacyLab : UILabel = {
        let label = UILabel.init()
        label.text = "隐私政策"
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: "#49A0FF")
        label.font = FontPFRegularSize(14)
        label.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(privacyClick))
        label.addGestureRecognizer(tapGes)
        return label
    }()
    
    fileprivate lazy var privacyLineV : UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hexString: "#49A0FF")
        return view
    }()
    
    fileprivate lazy var protocolLab : UILabel = {
        let label = UILabel.init()
        label.text = "用户协议"
        label.textAlignment = .center
        label.textColor = UIColor.init(hexString: "#49A0FF")
        label.font = FontPFRegularSize(14)
        label.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(protocolClick))
        label.addGestureRecognizer(tapGes)
        return label
    }()
    
    fileprivate lazy var proLineV : UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hexString: "#49A0FF")
        return view
    }()
    
    fileprivate lazy var textLab : UILabel = {
        let label = UILabel.init()
        label.text = "与"
        label.textAlignment = .center
        label.textColor = UIColor.init(hexRGB: 000000,alpha: 0.85)
        label.font = FontPFRegularSize(14)
        label.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(privacyClick))
        label.addGestureRecognizer(tapGes)
        return label
    }()
    
    //不同意
    fileprivate lazy var refuseBtn : UIButton = {
        let refuseBtn =  UIButton.init()
        refuseBtn .setTitle("不同意", for: .normal)
        refuseBtn.titleLabel?.font = FontPFMediumSize(16)
        refuseBtn.setTitleColor(UIColor.init(hexRGB:000000, alpha:0.85) , for: .normal)
        refuseBtn.layer.cornerRadius = 20
        refuseBtn.layer.borderWidth = 1
        refuseBtn.layer.borderColor = UIColor.init(hexRGB:000000, alpha:0.85).cgColor
        refuseBtn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        return refuseBtn
    }()
    
    //同意
    fileprivate lazy var agreeBtn : UIButton = {
        let agreeBtn =  UIButton.init()
        agreeBtn.backgroundColor = UIColor.init(hexRGB:000000, alpha:0.85)
        agreeBtn.setTitle("同意", for: .normal)
        agreeBtn.titleLabel?.font = FontPFMediumSize(16)
        agreeBtn.setTitleColor(UIColor.init(hexString: "#FFFFFF") , for: .normal)
        agreeBtn.layer.cornerRadius = 20
        agreeBtn.addTarget(self, action: #selector(confirmClick), for: .touchUpInside)
        return agreeBtn
    }()
    
    @objc func protocolClick(){
        
//        textView.text = contentVStr1
        
        guard let url: URL = URL(string: userProtocolUrl) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    @objc func privacyClick(){
        
//        textView.text = contentVStr
        
        guard let url: URL = URL(string: privateProUrl) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc func closeClick(){
        
        if pageSource == .loginPage {
            
            //退出应用
    //      UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            //退出应用安全过审修改为停留在背景页
//            exitApplication()
            bgV.isHidden = true
            
        }else if pageSource == .aboutPage{
            
            self.dismiss(animated: true) { }
            
        }

        
    }
    
    func exitApplication(){
        
        let window = AppDelegate().window
        UIView.animate(withDuration: 1.0, animations: {
            window?.alpha = 0
        }, completion: { finished in
            exit(0)
        })
    }
    
    @objc func confirmClick(){
        
        if pageSource == .loginPage {
            
            //阅读过协议存取标识
            TDUserInforManager.shared.saveUserProcolState()
            self.dismiss(animated: true) { }
            loginProAlertVCBlock!(1)//回调回去，跳转到该去的地方
            
        }else if pageSource == .aboutPage{
            
            self.dismiss(animated: true) { }
            
        }
        
    }

}

extension LoginProtocolAlertVC : WKNavigationDelegate,WKUIDelegate{
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if (navigationAction.targetFrame?.isMainFrame == nil) {
            webView.load(navigationAction.request)
        }
        return nil
        
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        if navigationAction.targetFrame == nil {
//            webView.load(navigationAction.request)
//        }
//        decisionHandler(.allow)
//
//    }
    
}
