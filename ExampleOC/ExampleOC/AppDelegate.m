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
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    InitParam* initParam = [[InitParam alloc] init];
    initParam.rtcAppId = @"d01*****************************6a";
    initParam.publishAudio = true;
    initParam.publishVideo = false;
    initParam.subscribeAudio = true;
    initParam.subscribeVideo = true;
    initParam.ntfAppKey = @"*********#****";
    initParam.ntfApnsCertName = @"**.***.***";
    initParam.slaveServerUrl = @"https://************";
    initParam.masterServerUrl = @"https://***********";
    
//    [IotSdk.shared initializeWithInitParam:initParam netStatus:^(enum NetStatus, NSString * _Nonnull) {
//    }];
    
    //[IotSdk.shared initializeWithInitParam:initParam netStatus:^(enum NetStatus, NSString * _Nonnull) {} callback:(self)];
    
    [IotSdk.shared initializeWithInitParam:initParam sdkStatus:^(enum SdkStatus, NSString * _Nonnull) {} callback:(nil)];
    
    [[IotSdk.shared getDeviceMgr] registerWithListener:(self)];
    
    [[IotSdk.shared getAccountMgr] loginWithAccount:@"****@***" password:@"******" result:^(NSInteger, NSString * _Nonnull) {
        NSDate* date = [[NSDate alloc] init];
        
//        [[IotSdk.shared getAlarmManager] queryByPageWithType:0 status:0 dateBegin:nil dateEnd:date currPage:1 pageSize:5 desc:true device:nil result:^(NSInteger, NSString * _Nonnull, NSArray<IotAlarm *> * _Nullable) {
//    
//        }];
        
        [[IotSdk.shared getDeviceMgr] queryAllDevicesWithResult:^(NSInteger, NSString * _Nonnull, NSArray<IotDevice *> * _Nonnull){
//            [[IotSdk.shared getAccountMgr] logoutWithResult:^(NSInteger, NSString * _Nonnull) {
//                
//            }];
        }];
    }];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
