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
    ConnectCreateParam *creatParam = [[ConnectCreateParam alloc] initWithMPeerNodeId:@"111" mEncrypt:true mAttachMsg:@""];
    
    ConnectionObjManager *connectObj = (ConnectionObjManager *)[[IotSdk.shared getConnectionMgr] connectionCreateWithConnectParam:creatParam];
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
