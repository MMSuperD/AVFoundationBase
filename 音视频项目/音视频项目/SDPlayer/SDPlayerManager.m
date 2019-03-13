//
//  SDPlayerManager.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/11.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "SDPlayerManager.h"

@implementation SDPlayerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.player = [[AVPlayer alloc] init];
    }
    return self;
}

- (AVPlayer *)player {
    if (_player == nil) {
        
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        [self replaceCurrentItemWithURL:url];
        self.playStatus = SDPlayerStatusPausing;
        [self addNotificationAndObserver];
    }
    return self;
}

+ (instancetype)shareManager {
    static SDPlayerManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)addNotificationAndObserver {
    // 添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 添加打断播放的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionComing:) name:AVAudioSessionInterruptionNotification object:nil];
    // 添加插拔耳机的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    // 添加观察者监控播放器状态
    [self addObserver:self forKeyPath:@"playStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeNotificationAddObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"playStatus"];
    if (_currentItem) {
        [_currentItem removeObserver:self forKeyPath:@"status"];
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
}


/**
 创建Playerlayer

 @param view 要展示的地方
 @param frame 大小
 */
- (void)showPlayerInView:(UIView *)view withFrame:(CGRect)frame {
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
   // self.playerLayer.backgroundColor = [UIColor purpleColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [view.layer addSublayer:self.playerLayer];
    
    //////////////////////////////////////////////
   // 这里的作用是让视屏启动就可以看到图片,不过这样不太好,最好的还是自己截取一张图片,或是各一张图片良样例,这样用户看起来才会好看
//    [self startPlay];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self pausePlay];
//    });
    /////////////////////////////////////////////
}


/**
 根据本地视屏路径截取第一张图片用来做第一个界面

 @param urlString <#urlString description#>
 @return <#return value description#>
 */
- (UIImage *)getVideoProViewImage:(NSURL *)urlString {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:urlString options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
}


/**
 更新Item
 @param  url 视频路径
 */
- (void)replaceCurrentItemWithURL:(NSURL *)url {
    
//    //移除当前观察者
    if (_currentItem) {
        //这里需要移除以前的监听
        [_currentItem removeObserver:self forKeyPath:@"status"];
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _currentItem = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:_currentItem];
    
    //重新添加观察
    //1.0 这个是播放器的加载URR状态
    [_currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //2.0 这个是播放器缓存的加载的范围
    [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //3.0 监听playbackBufferEmpty我们可以获取当缓存不够，视频加载不出来的情况：
    [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //4.0 playbackLikelyToKeepUp监听缓存足够播放的状态
    [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    
}

- (void)startPlay {
    [self.player play];
    self.playStatus = SDPlayerStatusPlaying;
    if ([self.delegate respondsToSelector:@selector(currentItemPlayStatus:player:)]) {
        [self.delegate currentItemPlayStatus:self.playStatus player:_player];
    }
    __weak SDPlayerManager *weakSelf = self;
    //观察播放进度
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(currentItemTimeProgress:player:)]) {
            CGFloat time = weakSelf.player.currentTime.value / weakSelf.player.currentTime.timescale;
            [weakSelf.delegate currentItemTimeProgress:time player:weakSelf.player];
        }
        
    }];
}

- (void)stopPlay {
    [self.player pause];
    [self.currentItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        NSLog(@"finished:%d",finished);
    }];
    [self.currentItem cancelPendingSeeks];
    self.playStatus = SDPlayerStatusPausing;
    
}

- (void)pausePlay {
    [self.player pause];
    self.playStatus = SDPlayerStatusPausing;
    
    if ([self.delegate respondsToSelector:@selector(currentItemPlayStatus:player:)]) {
        
        [self.delegate currentItemPlayStatus:self.playStatus player:self.player];
    }
}

- (void)seekToTime:(CGFloat)time {
    
    [self.currentItem seekToTime:CMTimeMakeWithSeconds(time, 60) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}

#pragma mark - 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) { //这个是播放器的状态
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:
            {
                //这里需要获取视频长度
                if ([self.delegate respondsToSelector:@selector(currentItemDurationTime:player:)]) {
                    CGFloat duration = CMTimeGetSeconds(self.currentItem.duration);
                    [self.delegate currentItemDurationTime:duration player:self.player];
                }
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
        
        NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval loadedTime = startSeconds + durationSeconds;
        
        if (self.playStatus == SDPlayerStatusPlaying && self.player.rate <= 0) {
            self.playStatus = SDPlayerStatusLoading;
        }
        
        if (self.playStatus == SDPlayerStatusLoading) {
            NSTimeInterval currentTime = self.player.currentTime.value / self.player.currentTime.timescale;
            if (loadedTime > currentTime + 5) {
                [self startPlay];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(currentItemLoadedProgress:player:)]) {
            [self.delegate currentItemLoadedProgress:loadedTime player:self.player];
        }
        
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){//当缓存不够的时候需要做什么自己定,肯定这个时候不会处于播放状态
        NSLog(@"这里是缓存不够的时候,不能播放");
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当缓存足够的时候,可以直接播放
      //  [self.player play];
        NSLog(@"这里是缓存足够的时候,可以直接播放,就是打开这个界面就可以播放");
    } else if ([keyPath isEqualToString:@"playStatus"]) { //这里播放状态的切换
        
        if ([self.delegate respondsToSelector:@selector(currentItemPlayStatus:player:)]) {
            [self.delegate currentItemPlayStatus:self.playStatus player:self.player];
        }
    }
    
}

#pragma Notification
  // 添加播放完成通知
- (void)playbackFinished:(NSNotification *)sender {
    
    AVPlayerItem *playerItem = sender.object;
    
    if (self.currentItem == playerItem) {
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


@end
