//
//  ViewController.m
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

#import "ViewController.h"
#import "ExampleOC-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self usePreDevMgr];
    // Do any additional setup after loading the view.
}

-(ConnectResult *)connectDevice{
    ConnectParam *connectParam = [[ConnectParam alloc] initWithMUserId:@"123456" mPeerDevId:@"123456" mLocalRtcUid:123456 mChannelName:@"123456" mRtcToken:@"123456" mRtmToken:@"123456"];
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
    
    
    
//    [[IotSdk.shared getVodPlayerMgr] openWithMediaUrl:@"" callback:^(NSInteger errCode, UIView * displayView) {
//        NSLog(@"");
//    }];

}

@end
