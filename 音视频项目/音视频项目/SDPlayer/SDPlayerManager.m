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
//    [_currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//      [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    
}

- (void)startPlay {
    
    [self.player play];
}


@end
