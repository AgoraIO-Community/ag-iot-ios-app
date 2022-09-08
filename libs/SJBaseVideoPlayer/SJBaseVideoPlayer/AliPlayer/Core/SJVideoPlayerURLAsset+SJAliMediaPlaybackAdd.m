//
//  SJVideoPlayerURLAsset+SJAliMediaPlaybackAdd.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/11/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset+SJAliMediaPlaybackAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerURLAsset (SJAliMediaPlaybackAdd)
- (instancetype)initWithSource:(__kindof AVPSource *)source {
    return [self initWithSource:source playModel:SJPlayModel.new];
}
- (instancetype)initWithSource:(__kindof AVPSource *)source playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithSource:source startPosition:0 playModel:playModel];
}
- (instancetype)initWithSource:(__kindof AVPSource *)source startPosition:(NSTimeInterval)startPosition {
    return [self initWithSource:source startPosition:startPosition playModel:SJPlayModel.new];
}
- (instancetype)initWithSource:(__kindof AVPSource *)source startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel {
    self = [super init];
    if ( self ) {
        self.source = source;
        self.startPosition = startPosition;
        self.playModel = playModel;
    }
    return self;
}

- (void)setSource:(__kindof AVPSource * _Nullable)source {
    objc_setAssociatedObject(self, @selector(source), source, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable __kindof AVPSource *)source {
    __kindof AVPSource *source = objc_getAssociatedObject(self, _cmd);
    if ( source == nil ) {
        if ( self.mediaURL != nil ) {
            source = AVPUrlSource.alloc.init;
            [(AVPUrlSource *)source setPlayerUrl:self.mediaURL];
            [self setSource:source];
        }
    }
    return source;
}

- (void)setAvpConfig:(nullable AVPConfig *)avpConfig {
    objc_setAssociatedObject(self, @selector(avpConfig), avpConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVPConfig *)avpConfig {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAvpCacheConfig:(nullable AVPCacheConfig *)avpCacheConfig {
    objc_setAssociatedObject(self, @selector(avpCacheConfig), avpCacheConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVPCacheConfig *)avpCacheConfig {
    return objc_getAssociatedObject(self, _cmd);
}
@end

/// 切换清晰度时使用
@implementation SJVideoPlayerURLAsset (SJAliMediaSelectTrack)
- (instancetype)initWithSource:(__kindof AVPSource *)source subTrackInfo:(AVPTrackInfo *)trackInfo {
    return [self initWithSource:source subTrackInfo:trackInfo playModel:SJPlayModel.new];
}
- (instancetype)initWithSource:(__kindof AVPSource *)source subTrackInfo:(AVPTrackInfo *)trackInfo playModel:(__kindof SJPlayModel *)playModel {
    self = [self initWithSource:source playModel:playModel];
    if ( self ) {
        objc_setAssociatedObject(self, @selector(avpTrackInfo), trackInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (nullable AVPTrackInfo *)avpTrackInfo {
    return objc_getAssociatedObject(self, _cmd);
}
@end

NS_ASSUME_NONNULL_END
