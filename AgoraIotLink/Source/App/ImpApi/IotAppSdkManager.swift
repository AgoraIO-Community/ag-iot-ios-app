//
//  IotAppSdkManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/23.
//

import UIKit


/*
 * @brief 本地节点的信息
 */
public class LocalNode : NSObject {
    @objc public var mUserId   : String        //服务器地址
    @objc public var mNodeId   : String
    @objc public var mRegion   : String
    @objc public var mToken    : String
    
    public init(mUserId:String ,
                mNodeId:String,
                mRegion:String,
                mToken:String
    ){
        self.mUserId = mUserId
        self.mNodeId = mNodeId
        self.mRegion = mRegion
        self.mToken = mToken
    }
}

public class IotAppSdkManager: NSObject {

    private var app:Application
    
    var mLocalNode:LocalNode?
    
    init(app:Application){
        self.app = app
    }
    
    func getUserNodeId()->String{
        
        return mLocalNode?.mNodeId ?? ""
        
    }

}
