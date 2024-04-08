//
//  EventManager.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/3/26.
//

import Foundation
import AgoraRtmKit

class StateListener : NSObject{

    let app:IotLibrary
    var _signalingStatusHandler:(Bool)->Void = {s in}
    
    init(_ app:IotLibrary){
        self.app = app;
    }

    func do_Invalid() {
        app.sdkState = .invalid
    }
    
    func do_Initialized() {
        app.sdkState = .running
    }

}
