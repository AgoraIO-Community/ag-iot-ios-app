//
//  PlayerExampleOC.m
//  IotLinkDemo
//
//  Created by admin on 2023/3/2.
//

#import "PlayerExampleOC.h"
#import "SJVideoPlayer.h"
#import "SJBaseVideoPlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <IJKMediaFramework/IJKFFOptions.h>
#import "SJIJKMediaPlaybackController.h"

@interface PlayerExampleOC ()

@property (nonatomic, strong) SJVideoPlayer *player;

@end

@implementation PlayerExampleOC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUpUI];
    [self creatijkVC];

}

// player 对象
- (SJVideoPlayer *)player{
    if(!_player){
        _player = [[SJVideoPlayer alloc] init];
        _player.onlyFitOnScreen = NO;
    }
    return  _player;
}

- (void)setUpUI{
    
    self.player.view.frame = CGRectMake(0, 100, self.view.bounds.size.width, 400);
    [self.view addSubview:self.player.view];
}

//创建ijkVC并播放
- (void)creatijkVC{
    
    NSURL *url = [NSURL URLWithString:_urlString];
    
    SJIJKMediaPlaybackController *ijkVC = [[SJIJKMediaPlaybackController alloc] init];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    ijkVC.options = options;
    self.player.playbackController = ijkVC;
    self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:url];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
