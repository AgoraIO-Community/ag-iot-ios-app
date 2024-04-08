//
//  AgoraIotSdk.swift
//  AgoraIotSdk
//
//  Created by ADMIN on 2022/2/10.
//

import Foundation

public let log = Logger.shared

public class AgoraIotSdk {
    public static let iotsdk:IAgoraIotAppSdk = IotLibrary.shared.sdk
}

public let iotsdk = AgoraIotSdk.iotsdk
