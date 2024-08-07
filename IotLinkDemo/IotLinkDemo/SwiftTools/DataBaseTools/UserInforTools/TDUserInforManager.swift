//
//  TDUserInforManager.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import UIKit
import AgoraIotLink


//登录成功的通知
let cUserLoginSuccessNotify = "cUserLoginSuccessNotify"

//退出登录的通知
let cUserLoginOutNotify = "cUserLoginOutNotify"


let kSSToolkitServiceName = "io.agora.Iot"

let kSSToolkitAccountKeyName = "agora_Iot"

public enum UserAccountType: Int{
    
    ///默认
    case none = 0
    
    ///邮箱
    case email = 1
    
    ///手机号
    case phone = 2

}


class TDUserInforManager: NSObject {
    
    //当前用户选择国家码 86默认为中国
    var currentCountryCode:String = "86"
    var curCountryModel:CountryModel?
    
    ///用户类型
    var userType : UserAccountType = .none
    
    ///当前变声类型
    var curEffectId:AudioEffectId = .NORMAL
    
    ///用户是否登陆
    var isLogin : Bool = false
    
    ///当前设备数（不含分享的）
    var currentDeviceCount : Int = 0
    
    ///当前配网类型（初始状态0  二维码 1 和 蓝牙 2 ）
    var currentMatchNetType : Int = 0
    //当前蓝牙配网成功
    var curBluefiSuc : Bool = false
    
    //本地设备管理
    var markPeerNodeIdArray = [String]()
    
    //当前用户使用的masterAppId
    var curMasterAppId : String = ""
    
    //当前用户使用的custom key
    var curCustomKey : String = ""
    
    //当前用户使用的custom secret
    var curCustomSecret : String = ""
    
    //当前用户使用的 region
    var curRegion : String = ""
    
    //当前用户使用的nodeId
    var mUserNodeId : String = ""
    
 
    fileprivate lazy var loginVM = LoginMainVM()

    
    static let shared: TDUserInforManager = {
        
        let dataBase:TDUserInforManager = TDUserInforManager()
        
        return dataBase
    }()
    
    fileprivate override init() {
        super.init()
    }
    
    
    //MARK: - 退出登录或者token过期调用
    func userSignOut() {
        
        let uDefault = getUserDefault()
        
        uDefault.setValue(nil, forKey: "accountNumber")
        
        uDefault.setValue(nil, forKey: "LoginType")
        
        uDefault.setValue(nil, forKey: "accountPwd")
        
        uDefault.synchronize()
        
        //退出登录,属性置为空
        curEffectId = .NORMAL
        
        isLogin = false
        
        deleteKeyChainInfor()
        
        //退出登录发通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cUserLoginOutNotify), object: nil)

    }
    
    //MARK: - 清除masterAppId
    func clearMasterAppId() {
        
        curMasterAppId = ""
        let uDefault = getUserDefault()
        uDefault.setValue(nil, forKey: "masterAppId")
        uDefault.setValue(nil, forKey: "customkey")
        uDefault.setValue(nil, forKey: "customsecret")
        uDefault.setValue(nil, forKey: "region")
        uDefault.setValue(nil, forKey: KeyCenter.kAuthorizationBase64Key)
        uDefault.synchronize()
        
    }
    
    /// 保存最新的设备id
    ///
    /// - Parameters:
    ///   - peerNodeId: 添加的设备ID
    func savePeerNodeId(_ peerNodeId : String) {
        
        var muIdArray = readMarkPeerNodeId()
        muIdArray.append(peerNodeId)
        
        let uDefault = getUserDefault()
        uDefault.setValue(muIdArray, forKey: getPeerNodeArrKey())
        uDefault.synchronize()
    }
    
    /// 删除选中的设备id
    ///
    /// - Parameters:
    ///   - peerNodeIdArray: 需要保留的设备id数组
    func deletePeerNodeIdArray(_ peerNodeIdArray : [String]) {
        
        let uDefault = getUserDefault()
        uDefault.setValue(peerNodeIdArray, forKey: getPeerNodeArrKey())
        uDefault.synchronize()
    }
    
    func getPeerNodeArrKey()->String{
        var peerKey = "markPeerNodeId"
        let accountInfor = readKeyChainAccountAndPwd()
        if accountInfor.acc != "" {
            peerKey = accountInfor.acc
        }
        print("peerKey: \(peerKey)")
        return peerKey
    }
    
    /// 保存上次登录的账号与上次登录的账号的属性
    ///
    /// - Parameters:
    ///   - account: 上次登陆的账号
    ///   - type: 上次登录账号的属性 true:手机号验证码登录 false：账号密码登录
    func saveAccountNumberAndLoginType(account:String, type:Bool) {

        let uDefault = getUserDefault()
        uDefault.setValue(account, forKey: "accountNumber")
        uDefault.setValue(type, forKey: "LoginType")
        uDefault.synchronize()
    }
    
    /// 保存上次登录的账号对应的密码
    ///
    /// - Parameters:
    ///   - pwd: 上次登陆的账号对应的密码
    func saveAccountPassWord(acc:String, pwd:String) {

        let uDefault = getUserDefault()
        uDefault.setValue(pwd, forKey: "accountPwd")
        uDefault.synchronize()
    }

    /// 保存上次登录的账号对应的密码
    ///
    /// - Parameters:
    ///   - pwd: 上次登陆的账号对应的密码
    func saveKeyChainAccountInfor(acc:String, pwd:String) {
        
        SSKeychain.setPassword(pwd, forService: kSSToolkitServiceName, account: kSSToolkitAccountKeyName+acc)
        
    }
    
    
    func getKeyChainAccount()->String{
        
        guard let  accountArr = SSKeychain.accounts(forService: kSSToolkitServiceName) else {
            return ""
        }
        var tempAccount = ""
        for item in accountArr {
            if let dict = item as? Dictionary<String, Any>, let acct = dict["acct"] as? String , acct.hasPrefix(kSSToolkitAccountKeyName) == true{
                tempAccount = acct.replacingOccurrences(of: kSSToolkitAccountKeyName, with: "")
            }
        }
        return tempAccount
        
    }
    
    func getKeyChainAllAccount()->[String]{
        
        var tempAccountArray = [String]()
        guard let  accountArr = SSKeychain.accounts(forService: kSSToolkitServiceName) else {
            return tempAccountArray
        }
        for item in accountArr {
            if let dict = item as? Dictionary<String, Any>, let acct = dict["acct"] as? String , acct.hasPrefix(kSSToolkitAccountKeyName) == true{
                let tempAcc = acct.replacingOccurrences(of: kSSToolkitAccountKeyName, with: "")
                tempAccountArray.append(tempAcc)
            }
        }
        return tempAccountArray
        
    }
    
    func readKeyChainAccountAndPwd()->(acc:String,pwd:String){
        
        let acc = getKeyChainAccount()
        guard let passWord = SSKeychain.password(forService: kSSToolkitServiceName, account: kSSToolkitAccountKeyName+acc)  else {
            return("","")
        }
        return (acc,passWord)
    }
    
    func deleteKeyChainInfor(){
        
        let accArray = getKeyChainAllAccount()
        for item in accArray{
            SSKeychain.deletePassword(forService: kSSToolkitServiceName, account: kSSToolkitAccountKeyName+item)
        }
        
    }
    
    /// 保存masterAppId
    func saveUserMasterAppId(_ masterAppId: String){
        curMasterAppId = masterAppId
        let uDefault = getUserDefault()
        uDefault.setValue(masterAppId, forKey: "masterAppId")
        uDefault.synchronize()
        
    }
    
    /// 保存customKey he customSecret
    func saveUserCustomKeyAndSecret(_ customKey: String,_ customSecret: String){
        curCustomKey = customKey
        curCustomSecret = customSecret
        let uDefault = getUserDefault()
        uDefault.setValue(customKey, forKey: "customkey")
        uDefault.setValue(customSecret, forKey: "customsecret")
        uDefault.synchronize()
        
    }
    
    func saveUserRegion(_ region: String){
        curRegion = region
        let uDefault = getUserDefault()
        uDefault.setValue(region, forKey: "region")
        uDefault.synchronize()
        
    }
    
    
    /// 保存上次登录账号协议是否阅读状态
    func saveUserProcolState(){
        
        let uDefault = getUserDefault()
        uDefault.setValue(true, forKey: "ProcolType")
        uDefault.synchronize()
        
    }
    
    //读取本地的设备Id
    func readMarkPeerNodeId() -> [String]{
        var idArray = [String]()
        if let nodeIdArray = getUserDefault().object(forKey: getPeerNodeArrKey()) as? [String] {
            idArray = nodeIdArray
        }
        return idArray
    }
    
    //读取上次登录的账号
    func readAccountNumber() -> String{
        var accNum = ""
        if let num = getUserDefault().object(forKey: "accountNumber") as? String {
            accNum = num
        }
        return accNum
    }
    
    //读取上次登录的密码
    func readPasswordNumber() -> String{
        var pwdNum = ""
        if let num = getUserDefault().object(forKey: "accountPwd") as? String {
            pwdNum = num
        }
        return pwdNum
    }
    
    /// 读取上次登录账号的属性
    ///
    /// - Parameter type:邮箱登录还是手机号登录
    func readLoginType() -> Bool {
        var accNum = Bool(true)
        if let num = getUserDefault().object(forKey: "LoginType") as? Bool {
            accNum = num
        }
        return accNum
    }
    
    /// 读取上次登录账号协议是否阅读状态
    func readUserProcolState() -> Bool {
        var accNum = Bool(false)
        if let num = getUserDefault().object(forKey: "ProcolType") as? Bool {
            accNum = num
        }
        return accNum
    }
    
    /// 读取上次保存的masterAppId
    func readUserMasterAppId() -> String {
        var accNum = ""
        if let num = getUserDefault().object(forKey: "masterAppId") as? String {
            accNum = num
        }
        return accNum
    }
    
    /// 读取上次保存的customKey
    func readUserCustomKey() -> String {
        var accNum = ""
        if let num = getUserDefault().object(forKey: "customkey") as? String {
            accNum = num
        }
        return accNum
    }
    
    /// 读取上次保存的customSecert
    func readUserCustomSecert() -> String {
        var accNum = ""
        if let num = getUserDefault().object(forKey: "customsecret") as? String {
            accNum = num
        }
        return accNum
    }
    
    /// 读取上次保存的region
    func readUserRegion() -> String {
        var region = ""
        if let num = getUserDefault().object(forKey: "region") as? String {
            region = num
        }
        return region
    }
    
    //检查用户登陆状态
    func checkLoginState(){
        
        //检查隐私协议状态
        guard checkloginProtocolState() == true else { return }
        
    
//        let accountInfor = readKeyChainAccountAndPwd()
        
        DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
        
//        if accountInfor.acc.isEmpty == false {
//            loginAction(accountInfor.acc,accountInfor.pwd)
//        }else{
//
//            DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
//
////            loginAction(acc,pwd)
////            saveAccountNumberAndLoginType(account: acc, type: false)
////            saveAccountPassWord(pwd: pwd)
//        }
        
    }
    
    //登录
//    func loginAction(_ account : String, _ password : String){
//        
//        loginVM.login2(account, password) { [weak self] success, msg in
//            if (success) {
//                debugPrint("登录成功")
//                self?.isLogin = true
//                //登录成功发通知
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cUserLoginSuccessNotify), object: nil)
//            }else{
//                debugPrint("登录失败")
//                DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
//            }
//            
//        }
//    }
    
    
    fileprivate func getUserDefault() -> UserDefaults {
      
        return UserDefaults.standard
    }
    
    
    fileprivate func saveToUserDefault(value:Any,key:String) {
        
        let uDefault:UserDefaults = getUserDefault()
        
        uDefault.setValue(value, forKey: key)
        
        uDefault.synchronize()
    }
    
}

extension TDUserInforManager{
    
    func checkloginProtocolState() ->Bool{
        
        //协议如果是同意过就不再弹出
        if readUserProcolState() == false{
            showProtocolAlert()
            return false
        }
        return true
        
    }
    //登录注册协议
    func showProtocolAlert(){
        
        let proAlertVC = LoginProtocolAlertVC()
        proAlertVC.proType = .userProtocol
        proAlertVC.pageSource = .loginPage
        proAlertVC.loginProAlertVCBlock = { (type) in
            debugPrint("关闭弹框")
            DispatchCenter.DispatchType(type: .login, vc: nil, style: .present)
        }
        
        proAlertVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        proAlertVC.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(proAlertVC, animated: true, completion: nil)
        
    }
    
    func checkIsHaveMasterAppId() ->Bool{
        
        let masterAppId = readUserMasterAppId()
        //协议如果是同意过就不再弹出
        if masterAppId == ""{
            return false
        }
        curMasterAppId = masterAppId
        
        let customKey = readUserCustomKey()
        if customKey == ""{
            return false
        }
        curCustomKey = customKey
        
        let customScert = readUserCustomSecert()
        if customScert == ""{
            return false
        }
        curCustomSecret = customScert
        
        let region = readUserRegion()
        if region == "" {
            return false
        }
        curRegion = region

        return true
        
    }
    
    func showEditAppIdAlert(){
        AGConfirmEditMultiAlertVC.showTitleTop("Please enter project information".L, editText: "Please enter project information".L) {[weak self] appId,key,secret,region in
            self?.saveUserMasterAppId(appId)
            self?.saveUserCustomKeyAndSecret(key, secret)
            self?.saveUserRegion(region)
            AGToolHUD.showInfo(info: "appId has been reset tip".L)
            print("------重置appId------\(appId)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.exitApplication()
            }
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
}



