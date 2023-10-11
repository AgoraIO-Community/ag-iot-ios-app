//
//  AppDelegate.m
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

#import "AppDelegate.h"
#import "ExampleOC-Swift.h"
#import "ViewController.h"
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

-(ConnectResult *)connectDevice{
    ConnectParam *connectParam = [[ConnectParam alloc] initWithMPeerDevId:@"123456" mLocalRtcUid:123456 mChannelName:@"123456" mRtcToken:@"123456" mRtmUid:@"123456" mRtmToken:@"123456"];
    ConnectResult *conResult = [[IotSdk.shared getDeviceSessionMgr] connectWithConnectParam:connectParam sessionCallback:^(SessionCallback sCallback, NSString * sessionId, NSInteger errCode) {
        
        if (sCallback == SessionCallbackOnConnectDone){
            
        }else if (sCallback == SessionCallbackOnDisconnected){
            
        }else{
            
        }
        
    } memberState:^(MemberState mState, NSArray<NSNumber *> * uidList, NSString * sessionId) {
        if (mState == MemberStateEnter){
            
        }else if(mState == MemberStateLeave){
            
        }
    }] ;
 
    return  conResult;
}

-(void)usePreDevMgr{
    
    ConnectResult *conResult = [self connectDevice];
    IDevPreviewManager *preDevMgr = [[IotSdk.shared getDeviceSessionMgr] getDevPreviewMgrWithSessionId:conResult.mSessionId];
    [preDevMgr previewStartWithBSubAudio:false previewListener:^(NSString * _Nonnull, NSInteger, NSInteger) {
        
    }];
    UIView *peerView = [[UIView alloc] init];
    [preDevMgr setPeerVideoViewWithPeerView:peerView];
    
    
    
    
    
    [[IotSdk.shared getVodPlayerMgr] openWithMediaUrl:@"" callback:^(NSInteger, UIView * _Nonnull) {
        
    }];
}

-(void)sendControlCommand{//发送控制命令
    
    ConnectResult *conResult = [self connectDevice];
    IDevControllerManager *devControlMgr = [[IotSdk.shared getDeviceSessionMgr] getDevControllerWithSessionId:conResult.mSessionId];
    [devControlMgr sendCmdPtzCtrlWithAction:0 direction:1 speed:1 cmdListener:^(NSInteger, NSString * _Nonnull) {
        
    }];
    [devControlMgr sendCmdPtzResetWithCmdListener:^(NSInteger, NSString * _Nonnull) {
        
    }];
}

-(void)sendSDKPlayerControlCommand{//sd卡回看命令
    
    ConnectResult *conResult = [self connectDevice];
    IDevMediaManager *devMediaMgr = [[IotSdk.shared getDeviceSessionMgr] getDevMediaMgrWithSessionId:conResult.mSessionId];
    QueryParam *param = [[QueryParam alloc] initWithMFileId:0 mBeginTimestamp:0 mEndTimestamp:0];
    [devMediaMgr queryMediaListWithQueryParam:param queryListener:^(NSInteger, NSArray<DevMediaItem *> * _Nonnull) {
        
    }];
    [devMediaMgr playWithGlobalStartTime:0 playSpeed:1 playingCallListener:self];
}

//-------IPlayingCallbackListener---------
- (void)onDevPlayingStateChangedWithMediaUrl:(NSString *)mediaUrl newState:(NSInteger)newState{
    
}
- (void)onDevMediaOpenDoneWithMediaUrl:(NSString *)mediaUrl errCode:(NSInteger)errCode{
    NSLog(@"onDevMediaOpenDoneWithMediaUrl:%@",mediaUrl);
}
//-------IPlayingCallbackListener---------


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

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController =  nav;
    [self.window makeKeyAndVisible];
    
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
