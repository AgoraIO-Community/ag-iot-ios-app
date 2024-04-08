//
//  IotAppSdkManager.swift
//  AgoraIotLink
//
//  Created by admin on 2023/3/23.
//

import UIKit

public class IotAppSdkManager: NSObject {

    private var _onPrepareListener:(Int,String)->Void = {s,msg in log.w("mqtt _onActionAck not inited")}
    
    private var app:IotLibrary
    
    init(app:IotLibrary){
        self.app = app
    }
    
}
