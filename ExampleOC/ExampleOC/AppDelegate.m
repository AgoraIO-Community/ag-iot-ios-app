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


- (void)activeUserNode {
    
    __weak typeof (self) weakSelf = self;
    [ThirdAccountManager nodeActivateWithAccount:@"" rsp:^(NSInteger success, NSString * _Nonnull msg, ActivateNodeRsp * _Nullable retData) {
        if (success == 0) {
            [weakSelf initAgoraIotWithReqModel:retData];
        }
    }];
}

- (void)initAgoraIotWithReqModel:(ActivateNodeRsp *)retModel {
    InitParam* initParam = [[InitParam alloc] init];
    initParam.mAppId = @"";
    initParam.mRegion = retModel.nodeRegion;
    
    int ret = [IotSdk.shared initializeWithInitParam:initParam];
    if (ret != ErrCode.XOK) {
        NSLog(@"initParam");
    }
    
    [[IotSdk.shared getConnectionMgr] registerListenerWithConnectionMgrListener:self];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    InitParam* initParam = [[InitParam alloc] init];
    initParam.mAppId = @"123456";
    initParam.mRegion = 1;
    
    int ret = [IotSdk.shared initializeWithInitParam:initParam];
    if (ret != ErrCode.XOK) {
        NSLog(@"initParam");
    }
    
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
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


- (void)filterResult:(int)errCode errMessage:(NSString *)errMessage {
    
}

//--------------------IConnectionMgrListener-----------------

- (void)onConnectionCreateDoneWithConnectObj:(id<IConnectionObj> _Nullable)connectObj errCode:(NSInteger)errCode {
    
}

- (void)onPeerAnswerOrRejectWithConnectObj:(id<IConnectionObj> _Nullable)connectObj answer:(BOOL)answer { 
    
}

- (void)onPeerDisconnectedWithConnectObj:(id<IConnectionObj> _Nullable)connectObj errCode:(NSInteger)errCode { 
    
}

//--------------------IConnectionMgrListener-----------------


//--------------------ICallbackListener-----------------------
- (void)onFileTransErrorWithConnectObj:(id<IConnectionObj> _Nullable)connectObj errCode:(NSInteger)errCode {
    
}

- (void)onFileTransRecvDataWithConnectObj:(id<IConnectionObj> _Nullable)connectObj recvedData:(NSData * _Nonnull)recvedData { 
    
}

- (void)onFileTransRecvDoneWithConnectObj:(id<IConnectionObj> _Nullable)connectObj transferEnd:(BOOL)transferEnd doneDescrption:(NSData * _Nonnull)doneDescrption { 
    
}

- (void)onFileTransRecvStartWithConnectObj:(id<IConnectionObj> _Nullable)connectObj startDescrption:(NSData * _Nonnull)startDescrption { 
    
}

- (void)onMessageRecvedWithConnectObj:(id<IConnectionObj> _Nullable)connectObj recvedSignalData:(NSData * _Nonnull)recvedSignalData { 
    
}

- (void)onMessageSendDoneWithConnectObj:(id<IConnectionObj> _Nullable)connectObj errCode:(NSInteger)errCode signalId:(uint32_t)signalId { 
    
}

- (void)onStreamErrorWithConnectObj:(id<IConnectionObj> _Nullable)connectObj subStreamId:(enum StreamId)subStreamId errCode:(NSInteger)errCode { 
    
}

- (void)onStreamFirstFrameWithConnectObj:(id<IConnectionObj> _Nullable)connectObj subStreamId:(enum StreamId)subStreamId videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight { 
    
}

- (void)onStreamVideoFrameWithConnectObj:(id<IConnectionObj> _Nullable)connectObj subStreamId:(enum StreamId)subStreamId pixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight { 
    
}
//--------------------ICallbackListener-----------------------


@end
