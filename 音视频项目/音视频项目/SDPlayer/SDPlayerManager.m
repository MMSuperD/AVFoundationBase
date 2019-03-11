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


/**
 创建Playerlayer

 @param view 要展示的地方
 @param frame 大小
 */
- (void)showPlayerInView:(UIView *)view withFrame:(CGRect)frame {
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.playerLayer.backgroundColor = [UIColor purpleColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [view.layer addSublayer:self.playerLayer];
    
}


/**
 更新Item
 @param URL 路径
 */
- (void)replaceCurrentItemWithURL:(NSURL *)url {
    
//    //移除当前观察者
//    if (_currentItem) {
//        //这里需要移除以前的监听
//        [_currentItem removeObserver:self forKeyPath:@"status"];
//        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    }
    _currentItem = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:_currentItem];
    
//    //重新添加观察
    [_currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    
}

- (void)startPlay {
    [self.player play];
    self.playStatus = SDPlayerStatusPlaying;
    // 发起开始播放的通知
   // [[NSNotificationCenter defaultCenter] postNotificationName:SDPlayerDidStartPlayNotification object:self.player];
    if ([self.delegate respondsToSelector:@selector(currentItemPlayStatus:player:)]) {
        [self.delegate currentItemPlayStatus:self.playStatus player:self.player];
    }
    __weak SDPlayerManager *weakSelf = self;
    //观察播放进度
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(currentItemTimeProgress:player:)]) {
            CGFloat time = self.player.currentTime.value / weakSelf.player.currentTime.timescale;
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
    self.playStatus = SDPlayerStatusFinished;
    
}

- (void)pausePlay {
    [self.player pause];
    self.playStatus = SDPlayerStatusPausing;
    
    if ([self.delegate respondsToSelector:@selector(currentItemPlayStatus:player:)]) {
        
        [self.delegate currentItemPlayStatus:self.playStatus player:self.player];
    }
}

- (void)seekToTime:(CGFloat)time {
    
    [self.currentItem seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
}

#pragma mark - 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
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
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
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
        
        
    }
    
}


@end
