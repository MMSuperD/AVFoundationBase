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

@end

NS_ASSUME_NONNULL_END
