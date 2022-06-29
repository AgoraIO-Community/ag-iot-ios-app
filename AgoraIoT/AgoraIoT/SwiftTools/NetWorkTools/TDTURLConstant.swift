//
//  TDTURLConstant.swift
//  AgoraIoT
//
//  Created by wanghaipeng on 2022/4/18.
//

import Foundation

#if DEBUG   //MARK:测试 Base
let cBaseURL = "https://mobilemall-test.maya1618.com/"

#elseif UAT //MARK:UAT Base
let cBaseURL = "https://mobilemall-dev.maya1618.com/"

#else //MARK:正式 Base
let cBaseURL = "https://mobilemall.maya1618.com/"

#endif


//MARK: - 首页接口
//首页某接口
let URL_HomeUrl = "..."
