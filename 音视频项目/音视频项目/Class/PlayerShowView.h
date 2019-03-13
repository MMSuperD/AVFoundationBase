//
//  PlayerShowView.h
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PlayerShowView : UIView



/**
 根据播放器设置页面

 @param player 播放器
 */
- (void)setVideoPage:(AVPlayer *)player;

@end

@interface ControlShowView : UIView


@end

NS_ASSUME_NONNULL_END
