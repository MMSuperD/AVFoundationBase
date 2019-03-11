//
//  VideoPlayerViewController.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/11.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <Masonry.h>
#import "SDPlayerManager.h"

@interface VideoPlayerViewController ()<SDPlayerManagerDelegate>


/**
 内容View
 */
@property (weak,nonatomic)UIView *contentView;

/**
 播放View
 */
@property (weak,nonatomic)UIView *playerView;


/**
 播放按钮
 */
@property (weak,nonatomic)UIButton *playerBtn;


/**
 播放进度Slider
 */
@property (weak,nonatomic)UISlider *playProgress;


/**
 加载进度UIProgressView
 */
@property (weak,nonatomic)UIProgressView *loadProgress;


/**
 当前播放时间Label
 */
@property (weak,nonatomic)UILabel  *curTimerLabel;


/**
 总共播放时间Label
 */
@property (weak,nonatomic)UILabel *totalTimerLabel;


/**
 总时间
 */
@property (nonatomic,assign)CGFloat totalTime;

/**
 当前时间
 */
@property (nonatomic,assign)CGFloat currentTime;


/**
 播放管理者
 */
@property (nonatomic, strong) SDPlayerManager *manager;

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self initData];
}

- (void)initData {
   // NSURL *url = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jlzg0226" ofType:@"mp4"]];
    self.manager = [[SDPlayerManager alloc] initWithURL:url];
    self.manager.delegate = self;
}


#pragma 设置UI界面
- (void)setupUI {
     
    UIView *contentView = [UIView new];
    self.contentView = contentView;
    [self.view addSubview:contentView];
    self.contentView.backgroundColor = [UIColor redColor];
    
    UIView *playerView = [UIView new];
    self.playerView = playerView;
    [self.contentView addSubview:playerView];
    self.playerView.backgroundColor = [UIColor greenColor];
    
    UIButton *playerBtn = [UIButton buttonWithType:0];
    self.playerBtn = playerBtn;
    [self.contentView addSubview:playerBtn];
    self.playerBtn.backgroundColor = [UIColor clearColor];
    [playerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playerBtn addTarget:self action:@selector(actionPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(250);
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(220);
    }];
    
    [self.playerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.playerView.mas_centerX);
        make.centerY.mas_equalTo(self.playerView.mas_centerY);
    }];
    
    //进度View
    UILabel *curTimerLabel = [UILabel new];
    curTimerLabel.text = @"00:00:00";
    self.curTimerLabel = curTimerLabel;
    [self.contentView addSubview:curTimerLabel];
    curTimerLabel.textColor = [UIColor blackColor];
    [self.curTimerLabel setFont:[UIFont systemFontOfSize:12]];
    curTimerLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *totalTimerLabel = [UILabel new];
    totalTimerLabel.text = @"00:00:00";
    self.totalTimerLabel = totalTimerLabel;
    [self.contentView addSubview:totalTimerLabel];
    totalTimerLabel.textColor = [UIColor blackColor];
    [self.totalTimerLabel setFont:[UIFont systemFontOfSize:12]];
    totalTimerLabel.textAlignment = NSTextAlignmentCenter;
    
    UIProgressView *loadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadProgress = loadProgress;
    [self.contentView addSubview:loadProgress];
    
    UISlider *playProgress = [UISlider new];
    self.playProgress = playProgress;
    [self.contentView addSubview:playProgress];
    [self.playProgress setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    
    [self.curTimerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.playerView.mas_bottom);
        make.width.mas_equalTo(80);
    }];
    
    [self.totalTimerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.playerView.mas_bottom);
        make.width.mas_equalTo(80);
    }];
    
    [self.loadProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.leading.mas_equalTo(self.curTimerLabel.mas_trailing);
        make.trailing.mas_equalTo(self.totalTimerLabel.mas_leading);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.top.mas_equalTo(self.playerView.mas_bottom);
        
    }];
    
    [self.playProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.loadProgress);
    }];

}

- (void)setVideoPlayer {
    [self.manager showPlayerInView:self.playerView withFrame:self.playerView.bounds];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self setVideoPlayer];
    [self refreshUI];
    
}

- (void)actionPlayBtn:(UIButton *)sender {
    
    switch (self.manager.playStatus) {
        case SDPlayerStatusUnknown:
        {
            
            break;
            
        }
        case SDPlayerStatusPlaying:
        {
            [self.manager pausePlay];
            break;
            
        }
        case SDPlayerStatusLoading:
        {
            
            break;
            
        }
        case SDPlayerStatusPausing:
        {
            [self.manager startPlay];
            break;
            
        }
        case SDPlayerStatusFailed:
        {
            
            break;
            
        }
        case SDPlayerStatusFinished:
        {
            
            break;
            
        }
 
        default:
            break;
    }
    
}

- (void)refreshUI {
    
    //按钮
    switch (self.manager.playStatus) {
        case SDPlayerStatusUnknown:
        {
            
            break;
            
        }
        case SDPlayerStatusPlaying:
        {
            [self.playerBtn setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
            break;
            
        }
        case SDPlayerStatusLoading:
        {
            
            break;
            
        }
        case SDPlayerStatusPausing:
        {
            [self.playerBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
            break;
            
        }
        case SDPlayerStatusFailed:
        {
            
            break;
            
        }
        case SDPlayerStatusFinished:
        {
            
            break;
            
        }
            
        default:
            break;
    }
    
    //刷新Label
    self.totalTimerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.totalTime/60,(int)self.totalTime % 60];
    self.curTimerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.currentTime/60,(int)self.currentTime % 60];
    
    //这里是刷新进度条
    self.playProgress.value = self.currentTime / self.totalTime;
    
}

- (void)dealloc
{
    NSLog(@"%@",NSStringFromClass([self class]));
}

#pragma SDPlayerManagerDelegate

/**
 得到当前Item  视频总长度
 
 @param duration 时间总长度
 @param player 播放器
 */
- (void)currentItemDurationTime:(CGFloat)duration player:(AVPlayer *)player {
    self.totalTime = duration;
    [self refreshUI];
}


/**
 得到当前Item 播放进度
 
 @param time 时间
 @param player 播放器
 */
- (void)currentItemTimeProgress:(CGFloat)time player:(AVPlayer *)player {
    
    self.currentTime = time;
    [self refreshUI];
    
}

/**
 当前Item 缓存进度
 
 @param time 时间
 @param player 播放器
 */
- (void)currentItemLoadedProgress:(CGFloat)time player:(AVPlayer *)player {
    
    
}


/**
 当前Item 播放状态,播放状态改变的时候会调用这个方法
 
 @param status 播放状态
 @param player 播放器
 */
- (void)currentItemPlayStatus:(SDPlayerStatus)status player:(AVPlayer *)player {
    
    [self refreshUI];
}

@end
