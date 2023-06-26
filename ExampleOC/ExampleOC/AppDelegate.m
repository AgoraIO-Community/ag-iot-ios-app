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


- (void)DeviceActionUpdated:(NSString *)deviceId actionType:(NSString *)actionType {
    
}

- (void)DevicePropertyUpdated:(NSString *)deviceId deviceNumber:(NSString *)deviceNumber props:(NSDictionary *)props {
    
}

- (void)DeviceStateUpdate:(BOOL)onoff deviceId:(NSString *)deviceId productId:(NSString *)productId {
    
}

-(void)filterResult:(int)errCode errMessage:(NSString*)errMessage{
    if(errCode == ErrCode.XERR_INVALID_PARAM){
        NSLog(@"💙💜token过期,退出登录:%@",errMessage);
    }
}

-(void)connectDevice{
    ConnectParam *connectParam = [[ConnectParam alloc] initWithMUserId:@"" mPeerDevId:@"" mLocalRtcUid:123456 mChannelName:@"" mRtcToken:@"" mRtmToken:@""];
    [[IotSdk.shared getDeviceSessionMgr] connectWithConnectParam:connectParam sessionCallback:^(SessionCallback sCallback, NSString * sessionId, NSInteger errCode) {
        
        if (sCallback == SessionCallbackOnConnectDone){
            
        }else if (sCallback == SessionCallbackOnDisconnected){
            
        }else{
            
        }
        
    } memberState:^(MemberState mState, NSArray<NSNumber *> * uidList, NSString * sessionId) {
        if (mState == MemberStateEnter){
            
        }else if(mState == MemberStateLeave){
            
        }
    }] ;
    
    IDevPreviewManager *preDevMgr = [[IotSdk.shared getDeviceSessionMgr] getDevPreviewMgrWithSessionId:@""];
    [preDevMgr previewStartWithPreviewListener:^(NSString * _Nonnull, NSInteger, NSInteger) {
            
    }];
    UIView *peerView = [[UIView alloc] init];
    [preDevMgr setPeerVideoViewWithPeerView:peerView];
    
    
}

-(void)didLogin{
    NSLog(@"💙💜登录成功");
    [self connectDevice];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    InitParam* initParam = [[InitParam alloc] init];
    initParam.rtcAppId = @"67f4672937984023bf378863a6c1450e";
    initParam.projectId =@"4OJG85tCF";
     
    [IotSdk.shared initializeWithInitParam:initParam callback:(self)];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"💙💜注册离线消息推送");
    return;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
