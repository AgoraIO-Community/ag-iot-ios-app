//
//  AppDelegate.h
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

#import <UIKit/UIKit.h>
#import "AgoraIotLink-Swift.h"
#import "IotStateDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IotStateDelegate,IotCallbackDelegate>

-(void)DeviceStateUpdate:(BOOL)onoff deviceId:(NSString*)deviceId productId:(NSString*)productId;

-(void)DeviceActionUpdated:(NSString*)deviceId actionType:(NSString*)actionType;

-(void)DevicePropertyUpdated:(NSString*)deviceId deviceNumber:(NSString*)deviceNumber props:(NSDictionary*)props;

-(void)filterResult:(int)errCode errMessage:(NSString*)errMessage;

-(void)didLogin;
-(void)queryProperty;
-(void)queryDevice;
@end

