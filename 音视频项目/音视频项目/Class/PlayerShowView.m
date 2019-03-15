//
//  PlayerShowView.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "PlayerShowView.h"
#import <Masonry.h>
#import "AppDelegate.h"
#define Device_Width  [[UIScreen mainScreen] bounds].size.width//获取屏幕宽高
#define Device_Height [[UIScreen mainScreen] bounds].size.height
@interface PlayerShowView()<ControlShowViewDelegate>

@property (nonatomic,strong)AVPlayerLayer *playerLayer;

@property (nonatomic,strong)UIImageView *imageView;

@property (nonatomic,strong)ControlShowView *controlView;

@property (nonatomic,assign)BOOL isFullScreen;

@end

@implementation PlayerShowView

//+ (Class)layerClass  {
//    return [AVPlayerLayer class];
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addNotification];
        self.isFullScreen = NO;
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

- (void)setBtnState:(ButtonState)btnState {
    _btnState = btnState;
    self.controlView.btnState = btnState;
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    self.controlView.progressValue = progressValue;
}

- (void)setTotalTimeValue:(CGFloat)totalTimeValue {
    _totalTimeValue = totalTimeValue;
    self.controlView.totalTimeValue = totalTimeValue;
}

- (void)setCurrentTimeValue:(CGFloat)currentTimeValue {
    _currentTimeValue = currentTimeValue;
    self.controlView.currentTimeValue = currentTimeValue;
}

- (void)setProgressBlock:(ProgressBlock)progressBlock {
    _progressBlock = progressBlock;
    self.controlView.progressBlock = progressBlock;
}

- (void)setVideoPage:(AVPlayer *)player {
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //self.playerLayer = (AVPlayerLayer *)self.layer;
  //  [self.playerLayer setPlayer:player];
    //这个属性特别重要设置视频Layer  适配
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
   // self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.layer addSublayer:self.playerLayer];
    ControlShowView *controlView = [ControlShowView new];
    self.controlView = controlView;
    self.controlView.delegate = self;
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

- (void)addNotification {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma 设备旋转通知
- (void)handleDeviceOrientationDidChange:(NSNotification *)sender {
    
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        {
            self.isFullScreen = YES;
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(UIApplication.sharedApplication.keyWindow);
                make.left.mas_equalTo(UIApplication.sharedApplication.keyWindow);
                make.right.mas_equalTo(UIApplication.sharedApplication.keyWindow);
                make.bottom.mas_equalTo(UIApplication.sharedApplication.keyWindow);
            }];
            NSLog(@"%@",NSStringFromUIEdgeInsets(self.superview.safeAreaInsets));
            break;
            
        }
            
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
            
        case UIDeviceOrientationPortrait:
        {
            NSLog(@"屏幕直立");
            self.isFullScreen = NO;
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.centerX.mas_equalTo(self.superview);
                make.centerY.mas_equalTo(self.superview);
                make.width.mas_equalTo(self.superview);
                make.height.mas_equalTo(200);
            }];
            break;
        }
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
}

#pragma ControlShowViewDelegate

- (void)fullScreen {
    AppDelegate  *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 1;
    if (!self.isFullScreen) {
        [UIView animateWithDuration:0.25 animations:^{
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        }];
    }
    
}

- (void)playChangeState:(ControlShowView *)controlViiew {

    if ([self.delegate respondsToSelector:@selector(playShowViewState:)]) {
        [self.delegate playShowViewState:self];
    }
}




@end

@interface ControlShowView()

/**
 播放按钮
 */
@property (weak,nonatomic)UIButton *playerBtn;

@property (weak,nonatomic)ControlShowProgressView *progressView;

@property (strong,nonatomic)UIButton *switchBtn;

@property (strong,nonatomic)UIButton *backBtn;

@end

@implementation ControlShowView

- (UIButton *)switchBtn {
    
    if (_switchBtn == nil) {
        
        _switchBtn = [UIButton buttonWithType:0];
        [_switchBtn setImage:[UIImage imageNamed:@"Screen"] forState:UIControlStateNormal];
        [_switchBtn addTarget:self action:@selector(actionSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _switchBtn;
}

- (UIButton *)backBtn {
    
    if (_backBtn == nil) {
        
        _backBtn = [UIButton buttonWithType:0];
        [_backBtn setImage:[UIImage imageNamed:@"dfs"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(actionSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backBtn;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
        [self initData];
        [self addObserver];
    }
    return self;
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    self.progressView.progressValue = progressValue;
}

- (void)setTotalTimeValue:(CGFloat)totalTimeValue {
    _totalTimeValue = totalTimeValue;
    self.progressView.totalTimeValue = totalTimeValue;
}

- (void)setCurrentTimeValue:(CGFloat)currentTimeValue {
    _currentTimeValue = currentTimeValue;
    self.progressView.currentTimeValue = currentTimeValue;
}

- (void)setProgressBlock:(ProgressBlock)progressBlock {
    _progressBlock = progressBlock;
    self.progressView.progressBlock = progressBlock;
}

- (void)initData {
    self.btnState = ButtonStatePause;
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
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    [self addGestureRecognizer:tap];
    
    ControlShowProgressView *progressView = [ControlShowProgressView new];
    [self addSubview:progressView];
    progressView.backgroundColor = [UIColor clearColor];
    self.progressView = progressView;
    
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_safeAreaLayoutGuideLeft).mas_offset(10);
        make.right.mas_equalTo(self.mas_safeAreaLayoutGuideRight).mas_offset(-10);
        make.bottom.mas_equalTo(self.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(40);
    }];
    
    [self addSubview:self.switchBtn];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_safeAreaLayoutGuideRight).mas_offset(0);
        make.top.mas_equalTo(self.mas_safeAreaLayoutGuideTop).mas_offset(0);
        make.width.height.mas_equalTo(60);
    }];
    
}

- (void)actionTap:(UITapGestureRecognizer *)sender {
    
    if (self.btnState == ButtonStatePause) {
        return;
    }
    self.playerBtn.hidden = !self.playerBtn.hidden;
    
}

- (void)addObserver {
    [self addObserver:self forKeyPath:@"btnState" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver {
    [self removeObserver:self forKeyPath:@"btnState"];
}

- (void)actionPlayBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(playChangeState:)]) {
        [self.delegate playChangeState:self];
    }
//    
//    switch (self.btnState) {
//        case ButtonStatePause:
//        {
//            self.btnState = ButtonStatePlaying;
//            break;
//        }
//        case ButtonStatePlaying:
//        {
//            self.btnState = ButtonStatePause;
//            break;
//        }
//        default:
//            break;
//    }
}

- (void)refreshButtonImage {
    
    switch (self.btnState) {
        case ButtonStatePause:
        {
            [self.playerBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
            self.playerBtn.hidden = NO;
            break;
        }
        case ButtonStatePlaying:
        {
            [self.playerBtn setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
            self.playerBtn.hidden = NO;
            break;
        }
        default:
            break;
    }
}

#pragma 切换横竖屏
- (void)actionSwitchBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(fullScreen)]) {
        [self.delegate fullScreen];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"btnState"]) {
        [self refreshButtonImage];
    }
    
}

- (void)dealloc
{
    [self removeObserver];
}

@end

@interface ControlShowProgressView()

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

@end

@implementation ControlShowProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    self.playProgress.value = progressValue;
}

- (void)setTotalTimeValue:(CGFloat)totalTimeValue {
    _totalTimeValue = totalTimeValue;
    self.totalTimerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)totalTimeValue/60,(int)totalTimeValue % 60];
}

- (void)setCurrentTimeValue:(CGFloat)currentTimeValue {
    _currentTimeValue = currentTimeValue;
    self.curTimerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)currentTimeValue/60,(int)currentTimeValue % 60];
}

- (void)setProgressBlock:(ProgressBlock)progressBlock {
    _progressBlock = progressBlock;
}

- (void)setupUI {
    //进度View
    UILabel *curTimerLabel = [UILabel new];
    curTimerLabel.text = @"00:00:00";
    self.curTimerLabel = curTimerLabel;
    [self addSubview:curTimerLabel];
    curTimerLabel.textColor = [UIColor orangeColor];
    [self.curTimerLabel setFont:[UIFont systemFontOfSize:12]];
    curTimerLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *totalTimerLabel = [UILabel new];
    totalTimerLabel.text = @"00:00:00";
    self.totalTimerLabel = totalTimerLabel;
    totalTimerLabel.textColor = [UIColor orangeColor];
    [self addSubview:totalTimerLabel];
    [self.totalTimerLabel setFont:[UIFont systemFontOfSize:12]];
    totalTimerLabel.textAlignment = NSTextAlignmentCenter;
    
    UIProgressView *loadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadProgress = loadProgress;
    [self addSubview:loadProgress];
    self.loadProgress.progressTintColor = [UIColor greenColor];
    self.loadProgress.trackTintColor = [UIColor clearColor];
    
    UISlider *playProgress = [UISlider new];
    self.playProgress = playProgress;
    [self addSubview:playProgress];
    [self.playProgress setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    playProgress.minimumTrackTintColor = [UIColor redColor];
    [self.playProgress addTarget:self action:@selector(actionSlider:) forControlEvents:UIControlEventValueChanged];
    
    [self.curTimerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.mas_equalTo(self);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(100);
    }];
    
    [self.totalTimerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(100);
    }];
    
    [self.loadProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self.curTimerLabel.mas_trailing);
        make.trailing.mas_equalTo(self.totalTimerLabel.mas_leading);
    }];
    
    [self.playProgress mas_makeConstraints:^(MASConstraintMaker *make) {
     
        make.edges.mas_equalTo(self.loadProgress);
    }];
    
}

- (void)actionSlider:(UISlider *)sender {
    
    if (self.progressBlock) {
         self.progressBlock(sender.value);
    }
   
    
}

@end
