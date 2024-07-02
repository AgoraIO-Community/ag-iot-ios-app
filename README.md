# AgoraIotLink

[![CI Status](https://img.shields.io/travis/goooon/AgoraIotLink.svg?style=flat)](https://travis-ci.org/goooon/AgoraIotLink)
[![Version](https://img.shields.io/badge/pod-v2.1.0.2-519dd9.svg)](https://cocoapods.org/pods/AgoraIotLink)
[![License](https://img.shields.io/cocoapods/l/AgoraIotLink.svg?style=flat)](https://cocoapods.org/pods/AgoraIotLink)
[![Platform](https://img.shields.io/cocoapods/p/AgoraIotLink.svg?style=flat)](https://cocoapods.org/pods/AgoraIotLink)
[![Platform](https://img.shields.io/badge/language-swift-orange.svg)](https://cocoapods.org/pods/AgoraIotLink)

## 应用说明

该应用是灵隼系统iOS端Demo程序 必须要使用配套的 device_sdk_ver2.1.2 版本的设备SDK使用

## 软件架构

1.IotLinkDemo目录 ：应用层demo程序代码
2.iot_libs目录 ：iot库文件

## 功能列表

2.1.0是一个极致简化版本，只包含了最基本的链接管理功能

设备管理：在主界面可以浏览多个设备，并且收发消息
流的操作：可以对于任意一路订阅的流，进行预览、音放禁音、录像、截图操作

## 编译调试

1.安装xcode开发工具(推荐最新版本)，iOS13.0或以上版本的Apple设备
2.在'灵隼'官网平台申请相应的开发者账号，获取相关信息，主要是 appId，key，secret等信息 https://docs.agora.io/cn/iot-apaas/enable_agora_link?platform=All%20Platforms
3.联系声网获取iot库文件，放入 iot_libs 文件夹中
4.cd 至 IotLinkDemo，执行 pod install
5.连接上 iOS 设备后，点击 .xcworkspace 文件打开项目，进行编译和调试

## APP使用说明

1.首次运行时，需要输入appId，key，secret等信息

2.设备管理： 在主界面上通过输入输入设备的 NodeId可以进行设备添加； 设备列表界面，对应的总是 PUBLIC_STREAM_1 这路流操作

3.设备列表的提示信息: 设备没有连接："Disconnected" 设备正在连接中: "Connecting..." 设备已经连接，但是还没有订阅："Connected" 设备已经连接，已经订阅播放视频："Subscribed" 设备已经连接和订阅

