//
//  PlayerShowView.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "PlayerShowView.h"
#import <Masonry.h>

@interface PlayerShowView()

@property (nonatomic,strong)AVPlayerLayer *playerLayer;

@property (nonatomic,strong)UIImageView *imageView;

@property (nonatomic,strong)ControlShowView *controlView;

@end

@implementation PlayerShowView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (void)setVideoPage:(AVPlayer *)player {
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [self.layer addSublayer:self.playerLayer];
    ControlShowView *controlView = [ControlShowView new];
    self.controlView = controlView;
    [self addSubview:controlView];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.mas_equalTo(self);
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    
    NSLog(@"showViewFrame:%@",NSStringFromCGRect(self.bounds));
    NSLog(@"playerLayerFrame:%@",NSStringFromCGRect(self.playerLayer.bounds));
}


@end

@interface ControlShowView()

/**
 播放按钮
 */
@property (weak,nonatomic)UIButton *playerBtn;

@end

@implementation ControlShowView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupUI {
    UIButton *playerBtn = [UIButton buttonWithType:0];
    self.playerBtn = playerBtn;
    [self addSubview:playerBtn];
    self.playerBtn.backgroundColor = [UIColor clearColor];
    [playerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playerBtn addTarget:self action:@selector(actionPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    [playerBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    
    [self.playerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(60);
    }];
    
}

- (void)actionPlayBtn:(UIButton *)sender {
    
    NSLog(@"暂停");
}

@end
