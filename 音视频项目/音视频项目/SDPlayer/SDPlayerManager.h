//
//  SDPlayerManager.h
//  音视频项目
//
//  Created by sh-lx on 2019/3/11.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 播放器开始播放的通知
 当存在多个播放器，可使用该通知在其他播放器播放时暂停当前播放器
 */
//extern NSString * const SDPlayerDidStartPlayNotification;

/**
 enum 播放器状态
 
 - SDPlayerStatusUnknown: 未知
 - SDPlayerStatusPlaying: 播放中
 - SDPlayerStatusLoading: 加载中
 - SDPlayerStatusPausing: 暂停中
 - SDPlayerStatusFailed: 播放失败
 - SDPlayerStatusFinished: 播放完成
 */
typedef NS_ENUM(NSInteger, SDPlayerStatus) {
    SDPlayerStatusUnknown,
    SDPlayerStatusPlaying,
    SDPlayerStatusLoading,
    SDPlayerStatusPausing,
    SDPlayerStatusFailed,
    SDPlayerStatusFinished
};

@protocol SDPlayerManagerDelegate <NSObject>

@optional
/**
 得到当前Item  视频总长度

 @param duration 时间总长度
 @param player 播放器
 */
- (void)currentItemDurationTime:(CGFloat)duration player:(AVPlayer *)player;


/**
 得到当前Item 播放进度

 @param time 时间
 @param player 播放器
 */
- (void)currentItemTimeProgress:(CGFloat)time player:(AVPlayer *)player;

/**
 当前Item 缓存进度

 @param time 时间
 @param player 播放器
 */
- (void)currentItemLoadedProgress:(CGFloat)time player:(AVPlayer *)player;


/**
 当前Item 播放状态,播放状态改变的时候会调用这个方法

 @param status 播放状态
 @param player 播放器
 */
- (void)currentItemPlayStatus:(SDPlayerStatus)status player:(AVPlayer *)player;


@end

NS_ASSUME_NONNULL_BEGIN

@interface SDPlayerManager : NSObject

/**
 播放器
 */
@property (nonatomic, strong) AVPlayer *player;

/**
 播放器layer层
 */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/**
 当前PlayerItem
 */
@property (nonatomic, strong) AVPlayerItem *currentItem;

/**
 播放器状态
 */
@property (nonatomic, assign) SDPlayerStatus playStatus;

@property (nonatomic,weak) id<SDPlayerManagerDelegate> delegate;


/**
 创建单例对象
 
 @return SDPlayerMananger单例对象
 */
+ (instancetype)shareManager;



/**
 创建播放管理者

 @param url 路径URL
 @return 返回管理者对象
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 将播放器展示在某个View
 
 @param view 展示播放器的View
 */
- (void)showPlayerInView:(UIView *)view withFrame:(CGRect)frame;

/**
 开始播放
 */
- (void)startPlay;

/**
 结束播放
 */
- (void)stopPlay;

/**
 暂停播放
 */
- (void)pausePlay;


/**
 跳转到指定的时间

 @param time 指定的时间
 */
- (void)seekToTime:(CGFloat)time;

@end

NS_ASSUME_NONNULL_END
