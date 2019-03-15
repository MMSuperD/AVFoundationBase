//
//  PlayerControl.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "PlayerControl.h"

@interface PlayerControl()<PlayerShowViewDelegate>

/**
 这个是必选字段,需要最先设置
 */
@property (nonatomic,strong)PlayerShowView *showView;

@property (nonatomic,strong)AVPlayer *currentPlayer;

@property (nonatomic,strong)AVPlayerItem *currentPlayerItem;

@property (nonatomic,strong)NSURL *url;

@property (nonatomic, assign) SDPlayerStatus playStatus;

@property (nonatomic,assign)CGFloat totalTimeValue;

@property (nonatomic,copy)ProgressBlock progressBlock;

@end

@implementation PlayerControl


- (instancetype)initWithURL:(NSURL *)url withControlView:(nonnull PlayerShowView *)showView
{
    self = [super init];
    if (self) {
        self.url = url;
        self.showView = showView;
        self.showView.delegate = self;
        [self initItemAndPlayer];
        [self addNotificationAndObserver];
        [self.showView setVideoPage:self.currentPlayer];
        
        self.showView.progressBlock = self.progressBlock;
        
    }
    return self;
}

- (void)initItemAndPlayer {
    self.currentPlayerItem = [[AVPlayerItem alloc] initWithURL:self.url];
    self.currentPlayer     = [[AVPlayer alloc] initWithPlayerItem:self.currentPlayerItem];
    self.playStatus        = SDPlayerStatusPausing;
    __weak PlayerControl *weakSelf = self;
    self.progressBlock = ^(CGFloat currentValue) {
        
        [weakSelf seekToTime:currentValue];
    };
    
}


/**
 添加监听和通知
 */
- (void)addNotificationAndObserver {
    // 添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 添加打断播放的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionComing:) name:AVAudioSessionInterruptionNotification object:nil];
    // 添加插拔耳机的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    // 添加观察者监控播放器状态
    [self addObserver:self forKeyPath:@"playStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    //1.0 这个是播放器的加载URR状态
    [_currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //2.0 这个是播放器缓存的加载的范围
    [_currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //3.0 监听playbackBufferEmpty我们可以获取当缓存不够，视频加载不出来的情况：
    [_currentPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //4.0 playbackLikelyToKeepUp监听缓存足够播放的状态
    [_currentPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
}

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

#pragma Function
- (void)startPlay {
    [self.currentPlayer play];
    self.playStatus = SDPlayerStatusPlaying;

    __weak PlayerControl *weakSelf = self;
    //观察播放进度
    [self.currentPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.showView.progressValue = weakSelf.currentPlayer.currentTime.value / weakSelf.currentPlayer.currentTime.timescale / weakSelf.totalTimeValue;
        weakSelf.showView.currentTimeValue = weakSelf.currentPlayer.currentTime.value / weakSelf.currentPlayer.currentTime.timescale ;
    }];
    

}

- (void)stopPlay {
    [self.currentPlayer pause];
    [self.currentPlayerItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        NSLog(@"finished:%d",finished);
    }];
    [self.currentPlayerItem cancelPendingSeeks];
    self.playStatus = SDPlayerStatusPausing;
    
}

- (void)pausePlay {
    [self.currentPlayer pause];
    self.playStatus = SDPlayerStatusPausing;
}

- (void)seekToTime:(CGFloat)time {
    
    
    [self.currentPlayerItem seekToTime:CMTimeMakeWithSeconds(self.totalTimeValue * time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}


#pragma 通知处理
// 添加播放完成通知
- (void)playbackFinished:(NSNotification *)sender {
    
    AVPlayerItem *playerItem = sender.object;
    
    if (self.currentPlayerItem == playerItem) {
        //self.playStatus = SDPlayerStatusFinished;
        [self stopPlay];
    }
    
    
}
// 添加打断播放的通知(来电,闹铃打断播放通知)
- (void)interruptionComing:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    
    AVAudioSessionInterruptionType type = [userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self pausePlay];
    }
    
}

// 添加插拔耳机的通知
- (void)routeChanged:(NSNotification *)sender {
    
    NSDictionary *dic = sender.userInfo;
    
    AVAudioSessionRouteChangeReason reason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    //旧输出不可用
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
        
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pausePlay];
            });
        }
    }
    
}

- (void)dealloc
{
    [self removeNotificationAddObserver];
}

#pragma PlayerShowViewDelegate

- (void)playShowViewState:(PlayerShowView *)showView {
   
    switch (self.playStatus) {
        case SDPlayerStatusUnknown:
        {
            break;
        }
        case SDPlayerStatusPlaying:
        {
            [self pausePlay];
            self.playStatus = SDPlayerStatusPausing;
            showView.btnState = ButtonStatePause;
            
            break;
        }
        case SDPlayerStatusPausing:
        {
            [self startPlay];
            //self.playStatus = SDPlayerStatusPlaying;
            showView.btnState = ButtonStatePlaying;
            break;
        }
        default:
            break;
    }
}

#pragma mark - 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) { //这个是播放器的状态
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:
            {
                //这里需要获取视频长度
                self.totalTimeValue = CMTimeGetSeconds(self.currentPlayerItem.duration);
                self.showView.totalTimeValue = self.totalTimeValue;
                break;
            }
            case AVPlayerStatusUnknown:
            {
                self.playStatus = SDPlayerStatusUnknown;
                break;
            }
            case AVPlayerStatusFailed:
            {
                self.playStatus = SDPlayerStatusFailed;
                break;
            }
                
            default:
                break;
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {//这个是缓存范围
        
        NSArray *loadedTimeRanges = [_currentPlayerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval loadedTime = startSeconds + durationSeconds;
        
        if (self.playStatus == SDPlayerStatusPlaying && self.currentPlayer.rate <= 0) {
            self.playStatus = SDPlayerStatusLoading;
        }
        
        if (self.playStatus == SDPlayerStatusLoading) {
            NSTimeInterval currentTime = self.currentPlayer.currentTime.value / self.currentPlayer.currentTime.timescale;
            if (loadedTime > currentTime + 5) {
                [self startPlay];
            }
        }
        
//        if ([self.delegate respondsToSelector:@selector(currentItemLoadedProgress:player:)]) {
//            [self.delegate currentItemLoadedProgress:loadedTime player:self.player];
//        }
        
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){//当缓存不够的时候需要做什么自己定,肯定这个时候不会处于播放状态
        NSLog(@"这里是缓存不够的时候,不能播放");
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当缓存足够的时候,可以直接播放
        //  [self.player play];
        NSLog(@"这里是缓存足够的时候,可以直接播放,就是打开这个界面就可以播放");
    } else if ([keyPath isEqualToString:@"playStatus"]) { //这里播放状态的切换
        
//        if ([self.delegate respondsToSelector:@selector(currentItemPlayStatus:player:)]) {
//            [self.delegate currentItemPlayStatus:self.playStatus player:self.player];
//        }
    }
    
}


@end
