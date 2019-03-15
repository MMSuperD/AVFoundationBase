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

typedef void(^ProgressBlock)(CGFloat currentValue);

typedef NS_ENUM(NSUInteger,ButtonState) {
    ButtonStatePlaying,
    ButtonStatePause,
};

@class ControlShowView;
@class PlayerShowView;

@protocol ControlShowViewDelegate <NSObject>

@optional
- (void)playChangeState:(ControlShowView *)controlViiew;

- (void)fullScreen;

@end

@protocol PlayerShowViewDelegate <NSObject>

@optional
- (void)playShowViewState:(PlayerShowView *)showView;

@end

@interface PlayerShowView : UIView

@property (nonatomic,assign)ButtonState btnState;

@property (nonatomic,assign)CGFloat progressValue;

@property (nonatomic,assign)CGFloat totalTimeValue;

@property (nonatomic,assign)CGFloat currentTimeValue;

@property (nonatomic,weak)id<PlayerShowViewDelegate> delegate;

@property (nonatomic,copy)ProgressBlock progressBlock;

/**
 根据播放器设置页面

 @param player 播放器
 */
- (void)setVideoPage:(AVPlayer *)player;

@end


@interface ControlShowView : UIView

@property (nonatomic,assign)ButtonState btnState;

@property (nonatomic,assign)CGFloat progressValue;

@property (nonatomic,assign)CGFloat totalTimeValue;

@property (nonatomic,assign)CGFloat currentTimeValue;

@property (nonatomic,weak)id<ControlShowViewDelegate> delegate;

@property (nonatomic,copy)ProgressBlock progressBlock;

@end


@interface ControlShowProgressView : UIView

@property (nonatomic,assign)CGFloat progressValue;

@property (nonatomic,assign)CGFloat totalTimeValue;

@property (nonatomic,assign)CGFloat currentTimeValue;

@property (nonatomic,copy)ProgressBlock progressBlock;

@end

NS_ASSUME_NONNULL_END
