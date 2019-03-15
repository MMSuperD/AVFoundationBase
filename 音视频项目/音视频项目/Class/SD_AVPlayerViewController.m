//
//  SD_AVPlayerViewController.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/13.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "SD_AVPlayerViewController.h"
#import "PlayerShowView.h"
#import "PlayerControl.h"
#import <Masonry.h>

@interface SD_AVPlayerViewController ()

@property (nonatomic,strong)PlayerShowView *showView;

@property (nonatomic,strong)PlayerControl *manager;

@end

@implementation SD_AVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    self.navigationController.navigationBarHidden = YES;

    //创建View
    PlayerShowView *showView = [PlayerShowView new];
    self.showView            = showView;
    [self.view addSubview:showView];
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.width.mas_equalTo(self.view.bounds.size.width);
        make.height.mas_equalTo(200);
    }];
    
    //创建视屏控制
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jlzg0226" ofType:@"mp4"]];
    PlayerControl *manager = [[PlayerControl alloc] initWithURL:url withControlView:showView];
    self.manager = manager;
    
   NSLog(@"%@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    NSLog(@"%@",self.view.safeAreaLayoutGuide);
    
}





@end
