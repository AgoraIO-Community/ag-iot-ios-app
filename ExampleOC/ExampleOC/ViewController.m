//
//  ViewController.m
//  ExampleOC
//
//  Created by ADMIN on 2022/5/6.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int ret = [[IotSdk.shared getConnectionMgr] registerListenerWithConnectionMgrListener:self];
//    ConnectCreateParam *creatParam = [[ConnectCreateParam alloc] initWithMPeerNodeId:@"111" mEncrypt:true mAttachMsg:@""];
//    ConnectionObjManager *connectObj = (ConnectionObjManager *)[[IotSdk.shared getConnectionMgr] connectionCreateWithConnectParam:creatParam];
    
    CustomConnectCreateParam *creatParam = [[CustomConnectCreateParam alloc] init];
    creatParam.mPeerNodeId = @"test_666";
    creatParam.mEncrypt = false;
    creatParam.mToken = @"asfasdfa";
    creatParam.mCname = @"123456";
    creatParam.mUid = 1;
    creatParam.mEncryptMode = 7;
    creatParam.mSecretKey = @"asdfsadfadsf";
    creatParam.mTraceId = @"112233aassd";
    
    ConnectionObjManager *connectObj = (ConnectionObjManager *)[[IotSdk.shared getConnectionMgr] connectionCreateWithCustomConnectParam:creatParam];
                                        
    bool ret1 = [connectObj isStreamRecordingWithSubStreamId:1];
    [connectObj streamSubscribeStartWithPeerStreamId:1 attachMsg:@"" result:^(NSInteger, NSString * _Nonnull) {
        
    }];
    [connectObj streamSubscribeStopWithPeerStreamId:1];
    
}


- (void)onConnectionCreateDoneWithConnectObj:(id<IConnectionObj> _Nullable)connectObj errCode:(NSInteger)errCode {
    NSLog(@"------onConnectionCreateDoneWithConnectObj: %ld",errCode);
}

- (void)onPeerAnswerOrRejectWithConnectObj:(id<IConnectionObj> _Nullable)connectObj answer:(BOOL)answer { 
    
}

- (void)onPeerDisconnectedWithConnectObj:(id<IConnectionObj> _Nullable)connectObj errCode:(NSInteger)errCode { 
    
}

@end
