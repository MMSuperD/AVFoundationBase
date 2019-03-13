//
//  PlayerControl.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "PlayerControl.h"

@interface PlayerControl()

/**
 这个是必选字段,需要最先设置
 */
@property (nonatomic,strong)PlayerShowView *showView;

@property (nonatomic,strong)AVPlayer *currentPlayer;

@property (nonatomic,strong)AVPlayerItem *currentPlayerItem;

@property (nonatomic,strong)NSURL *url;

@property (nonatomic, assign) SDPlayerStatus playStatus;

@end

@implementation PlayerControl


- (instancetype)initWithURL:(NSURL *)url withControlView:(nonnull PlayerShowView *)showView
{
    self = [super init];
    if (self) {
        self.url = url;
        self.showView = showView;
        [self initItemAndPlayer];
        [self addNotificationAndObserver];
        [self.showView setVideoPage:self.currentPlayer];
        
    }
    return self;
}

- (void)initItemAndPlayer {
    self.currentPlayerItem = [[AVPlayerItem alloc] initWithURL:self.url];
    self.currentPlayer     = [[AVPlayer alloc] initWithPlayerItem:self.currentPlayerItem];
    self.playStatus        = SDPlayerStatusPausing;
}


/**
 添加监听和通知
 */
- (void)addNotificationAndObserver {
//    // 添加播放完成通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    // 添加打断播放的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionComing:) name:AVAudioSessionInterruptionNotification object:nil];
//    // 添加插拔耳机的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
//    
//    //添加设备旋转通知
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
//    // 添加观察者监控播放器状态
//    [self addObserver:self forKeyPath:@"playStatus" options:NSKeyValueObservingOptionNew context:nil];
}


/**
 移除监听和通知
 */
- (void)removeNotificationAddObserver {
    
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"playStatus"];
    if (_currentPlayerItem) {
        [_currentPlayerItem removeObserver:self forKeyPath:@"status"];
        [_currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
}

#pragma 通知处理




@end
