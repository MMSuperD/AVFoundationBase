//
//  ViewController.m
//  音视频项目
//
//  Created by sh-lx on 2019/3/11.
//  Copyright © 2019年 WangDan. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)actionPlayerViewControlelr:(UIButton *)sender {
    
    VideoPlayerViewController *vc = [VideoPlayerViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
