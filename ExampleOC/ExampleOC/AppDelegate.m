//
//  AppDelegate.m
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

#import "AppDelegate.h"
#import "ExampleOC-Swift.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)DeviceStateUpdate:(BOOL)onoff deviceId:(NSString*)deviceId productId:(NSString*)productId{
    
}

-(void)DeviceActionUpdated:(NSString*)deviceId actionType:(NSString*)actionType{
    
}

-(void)DevicePropertyUpdated:(NSString*)deviceId deviceNumber:(NSString*)deviceNumber props:(NSDictionary*)props{
    
}

-(void)filterResult:(int)errCode errMessage:(NSString*)errMessage{
    if(errCode == ErrCode.XERR_INVALID_PARAM){
        NSLog(@"💙💜token过期,退出登录:%@",errMessage);
        [[IotSdk.shared getAccountMgr] logoutWithResult:^(NSInteger, NSString * _Nonnull) {
            
        }];
    }
}

-(void)queryProperty{
    ProductQueryParam* param = [[ProductQueryParam alloc] init];
    [[IotSdk.shared getDeviceMgr] queryProductListWithQuery:param result:^(NSInteger ec, NSString * _Nonnull msg, NSArray<ProductInfo *> * _Nonnull prods) {
        if([prods count] == 0){
            NSLog(@"💙💜未发现产品，请在控制台添加产品信息");
        }
        for( ProductInfo* a in prods){
                [[IotSdk.shared getDeviceMgr] getPropertyDescriptionWithDeviceId:@"" productNumber:a.number result:^(NSInteger, NSString * _Nonnull, NSArray<Property *> * _Nonnull props) {
                    if([prods count] == 0){
                        NSLog(@"💙💜未发现该产品属性，请在控制台添加产品属性信息");
                    }
                    for(Property* p in props){
                        NSLog(@"💙💜dp %@ 产品属性",a.number);
                        NSLog(@"        pointName: %@",p.pointName);
                        NSLog(@"         maxValue: %@",p.maxValue);
                        NSLog(@"           remark: %@",p.remark);
                        NSLog(@"         maxValue: %@",p.maxValue);
                        NSLog(@"         markName: %@",p.markName);
                        NSLog(@"           status: %lu",(unsigned long)p.status);
                    }
                }];
            }
    }];
}

-(void)queryDevice{
    [[IotSdk.shared getDeviceMgr] queryAllDevicesWithResult:^(NSInteger, NSString * _Nonnull, NSArray<IotDevice *> * _Nonnull dev){
        if(dev.count == 0){
            NSLog(@"💙💜未发现设备,请先绑定设备");
            return;
        };
        NSLog(@"💙💜发现设备，开始拨打第一个设备");
        [[IotSdk.shared getCallManager] mutePeerAudioWithMute:false result:^(NSInteger ec, NSString * _Nonnull msg) {
            NSLog(@"💙💜mute 设备:%ld %@",ec,msg);
        }];
        [[IotSdk.shared getCallManager] callDialWithDevice:dev[0] attachMsg:@"" result:^(NSInteger ec, NSString * _Nonnull msg) {
            UIView* uiView = nil; //关联到自己的UIView
            [[IotSdk.shared getCallManager] setPeerVideoViewWithPeerView:uiView];
            NSLog(@"💙💜请求拨打电话结果:%ld,%@",ec,msg);
        } actionAck:^(enum ActionAck ack) {
            NSLog(@"💙💜拨打电话收到响应：%ld",ack);
        } memberState:Nil];
    }];
}

-(void)didLogin{
    NSLog(@"💙💜登录成功");
    [self queryDevice];
    [self queryProperty];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    InitParam* initParam = [[InitParam alloc] init];
    initParam.rtcAppId = @"67f4672937984023bf378863a6c1450e";
    initParam.publishAudio = true;
    initParam.publishVideo = true;
    initParam.subscribeAudio = true;
    initParam.subscribeVideo = true;
    initParam.ntfAppKey = @"81718082#964971";
    initParam.ntfApnsCertName = @"io.agora.iot.prod";
    initParam.masterServerUrl = @"https://app.agoralink-iot-cn.sd-rtn.com";
    initParam.slaveServerUrl = @"https://api.agora.io/agoralink/cn/api" ;//  for release
    //initParam.slaveServerUrl = @"https://iot-api-gateway.sh.agoralab.co/api"; //for debug
    initParam.projectId =@"4OJG85tCF";
    
    [IotSdk.shared initializeWithInitParam:initParam sdkStatus:^(enum SdkStatus status, NSString * _Nonnull hint) {
        NSLog(@"💙💜当前状态:%@,%ld",hint,status);
        if (status == SdkStatusAllReady) {
            NSString* eid = [[IotSdk.shared getNotificationManager] getEid];
            NSLog(@"💙💜获取推送eid:%@",eid);
            [self queryDevice];
        }
    } callback:(self)];
    
    [[IotSdk.shared getDeviceMgr] registerWithListener:(self)];
    [[IotSdk.shared getCallManager] registerWithIncoming:^(NSString * _Nonnull msg, NSString * _Nonnull hint, enum ActionAck act) {
        NSLog(@"💙💜收到来电:%@,%@,%ld",msg,hint,act);
        if(act == ActionAckCallIncoming){
            [[IotSdk.shared getCallManager] callAnswerWithResult:^(NSInteger ec, NSString * _Nonnull msg) {
                UIView* uiView = nil; //关联到自己的UIView
                [[IotSdk.shared getCallManager] setPeerVideoViewWithPeerView:uiView];
                NSLog(@"💙💜接听来电:%@,%ld",msg,ec);
            } actionAck:^(enum ActionAck ack) {
                NSLog(@"💙💜收到响应:%ld",ack);
            } memberState:Nil];
        }
    }];
    
    [[IotSdk.shared getAccountMgr] registerWithAccount:@"youraccount" password:@"88888888" result:^(NSInteger ec, NSString * _Nonnull msg) {
        if(ec != 0){
            NSLog(@"💙💜注册失败:%@,尝试直接用该账号登录",msg);
            [[IotSdk.shared getAccountMgr] loginWithAccount:@"13438383880" password:@"gzh8888" result:^(NSInteger ec, NSString * _Nonnull msg) {
                if(ec == ErrCode.XOK){
                    [self didLogin];
                }
                else{
                    NSLog(@"💙💜%@",msg);
                }
            }];
        }
        else{
            NSLog(@"💙💜注册成功，开始登录");
            [[IotSdk.shared getAccountMgr] loginWithAccount:@"youraccount" password:@"88888888" result:^(NSInteger ec, NSString * _Nonnull msg) {
                if(ec == ErrCode.XOK){
                    [self didLogin];
                }
                else{
                    NSLog(@"💙💜%@",msg);
                }
            }];
        }
    }];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"💙💜注册离线消息推送");
    return; [[IotSdk.shared getNotificationManager] updateToken:deviceToken];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
