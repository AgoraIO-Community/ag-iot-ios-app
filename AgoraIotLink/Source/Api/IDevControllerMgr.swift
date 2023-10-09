//
//  IDevControllerMgr.swift
//  AgoraIotLink
//
//  Created by admin on 2023/6/19.
//

import Foundation


/*
 * @brief 设备控制接口
 */
@objc public protocol IDevControllerMgr {
    
    /**
     * @brief 发送云台控制命令
     * @param action: 动作命令：0-开始，1-停止
     * @param direction: 方向：0-左、1-右、2-上、3-下、4-镜头拉近、5-镜头拉远
     * @param speed: 速度：0-慢，1-适中（默认），2-快
     * @param cmdListener: 命令完成回调
     * @return 返回错误码
     */
    func sendCmdPtzCtrl(action:Int,direction:Int,speed:Int,cmdListener: @escaping (_ errCode:Int,_ result:String) -> Void)
    
    /**
     * @brief 发送云台校准命令
     * @param cmdListener: 命令完成回调
     * @return 返回错误码
     */
    func sendCmdPtzReset(cmdListener: @escaping (_ errCode:Int,_ result:String) -> Void)
    
    
    /**
     * @brief 发送存储卡格式化命令
     * @param cmdListener: 命令完成回调
     * @return 返回错误码
     */
    func sendCmdPtzCtrl(cmdListener: @escaping (_ errCode:Int,_ result:String) -> Void)
    
    /**
     * @brief 发送设备重启命令
     * @param cmdListener: 命令完成回调
     * @return 返回错误码
     */
    func sendCmdDevReset(cmdListener: @escaping (_ errCode:Int,_ result:String) -> Void)
    
    
    /**
     * @brief 发送定制化的命令数据
     * @param customizeData: 上层自定义数据
     * @param cmdListener: 命令完成回调(errCode 返回错误码, result 返回数据)
     * @return
     */
    func sendCmdCustomize(customizeData:String, cmdListener: @escaping (_ errCode:Int,_ result:String) -> Void)
    
}
