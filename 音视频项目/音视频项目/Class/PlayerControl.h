//
//  PlayerControl.h
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "PlayerShowView.h"

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
NS_ASSUME_NONNULL_BEGIN

@interface PlayerControl : NSObject


/**
 创建播放管理者
 
 @param url 路径URL
 @return 返回管理者对象
 */
- (instancetype)initWithURL:(NSURL *)url withControlView:(PlayerShowView *)showView;;


@end

NS_ASSUME_NONNULL_END
