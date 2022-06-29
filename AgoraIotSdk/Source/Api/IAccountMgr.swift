/**
 * @file IAccountMgr.java
 * @brief This file define the interface of account management
 * @author zhihe.gu
 * @email guzhihe@agora.io
 * @version 1.0.0.1
 * @date 2022-01-26
 * @license Copyright (C) 2021 AgoraIO Inc. All rights reserved.
 */
import Foundation

public class UserInfo : NSObject{
    @objc public var name:String?
    @objc public var avatar:String?     //用户头像
    @objc public var sex:Int = 0        //性别：【1】男、【2】女  【0】未知
    @objc public var age:Int = 0        //年龄：【0】未知
    @objc public var birthday:String?
    @objc public var height:NSNumber?   //身高，单位：cm
    @objc public var weight:NSNumber?   //体重，单位：kg
    @objc public var countryId:String?
    @objc public var country:String?
    @objc public var provinceId:String?
    @objc public var province:String?
    @objc public var cityId:String?
    @objc public var city:String?
    @objc public var areaId:String?
    @objc public var area:String?
    @objc public var address:String?
    @objc public var background:String?
    
    @objc let email:String?
    @objc let phone:String?
    
    public override init(){
        self.email = ""
        self.phone = ""
    }
    public init( name:String?,
                 avatar:String?,
                 sex:Int,
                 age:Int,
                 birthday:String?,
                 height:UInt?,
                 weight:UInt?,
                 
                 countryId:String?,
                 country:String?,
                 provinceId:String?,
                 province:String?,
                 cityId:String?,
                 city:String?,
                 areaId:String?,
                 area:String?,
                 address:String?,
                 background:String?,
                 
                 email:String?,
                 phone:String?
                 ) {
        
        self.name = name
        self.avatar = avatar
        
        self.age = age
        self.sex = sex
        self.birthday = birthday
        self.height = (height) as? NSNumber
        self.weight = (weight) as? NSNumber

        self.countryId = countryId
        self.country = country
        self.province = province
        self.provinceId = provinceId
        self.cityId = cityId
        self.city = city
        self.areaId = areaId
        self.area = area
        
        self.address = address
        self.background = background
        
        self.email = email
        self.phone = phone
    }
}

/*
 * @brief 账号管理接口
 */
public protocol IAccountMgr{
    typealias AccountInfo = UserInfo
    /*
     * @brief 注册一个新账号
     * @param account : 账号Id
     * @param password : 账号密码
     * @param code : 验证码
     * @param email : 邮箱，邮箱和手机号必须是其中一个
     * @param phone : 手机号，邮箱和手机号两者必须是其中一个,（需要带上国区代码 中国 +86）
     */
    func register(account: String, password: String,code: String, email:String?, phone:String?, result:@escaping (Int,String)->Void)

    /*
     * @brief 注销一个用户账号
     */
    func unregister(result:@escaping(Int,String)->Void)
    
    /*
     * @brief 注册一个新账号
     * @param account : 账号Id
     * @param password : 账号密码
     * @param code : 验证码
     */
    func resetPassword(account: String, password: String,code: String, result:@escaping (Int,String)->Void)
    
    /*
     * @brief 注册接收验证码的手机
     * @param phone : 手机号码，如果手机号是中国（需要带上国区代码 中国 +86）
     * @param type : 验证码类型：REGISTER【注册】、 PWD_RESET【密码找回】
     * @param lang : 支持ZH_CN(简体中文)、EN_US(英文) 默认为ZH_CN
     */
    func getSms(phone:String,type:String,lang:String,result:@escaping(Int,String)->Void)
    /*
     * @brief 注册接收验证码的邮箱
     * @param account : 电子邮箱
     * @param type : 获取验证码方式，“REGISTER”:【注册】，PWD_RESET:【密码找回】
     */
    func getCode(email: String, type: String, result:@escaping (Int,String) -> Void)

    /*
     * @brief 登录一个用户账号，触发 onLoginDone() 回调
     * @param account : 账号Id
     * @param password : 账号密码
     */
    func login(account: String, password: String,result:@escaping (Int,String)->Void)

    /*
     * @brief 登出当前账号
     */
    func logout(result:@escaping (Int,String)->Void)

    /*
     * @brief 更换账号密码，触发 onChangePasswordDone() 回调
     * @param account : 账号Id
     * @param oldPassword : 旧密码
     * @param oldPassword : 新密码
     */
    func changePassword(
        account: String,
        oldPassword: String,
        newPassword: String,
        result:@escaping (Int,String)->Void)
    /*
     * @brief 获取当前用户id
     */
    func getUserId()->String
    /*
     * @brief 更新用户相关信息
     */
    func updateAccountInfo(info:AccountInfo,result:@escaping(Int,String)->Void)
    /*
     * @brief 获取用户相关信息
     */
    func getAccountInfo(result:@escaping(Int,String,AccountInfo?)->Void)
    /*
     * @brief 上传用户头像
     * @param result : 第三个返回参数是上传头像后的URL地址
     */
    func updateHeadIcon(image:UIImage,result:@escaping(Int,String,String?)->Void)
}




