//
//  VideoPlayerViewController.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/11.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <Masonry.h>

@interface VideoPlayerViewController ()


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

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
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
    self.playerBtn.backgroundColor = [UIColor orangeColor];
    [playerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playerBtn setTitle:@"Play" forState:UIControlStateNormal];
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
    
    
    
}

- (void)actionPlayBtn:(UIButton *)sender {
    
    NSLog(@"Play");
}

@end
