//
//  ZXPlayMusicController.m
//  ZXMediaPlayer
//
//  Created by Jinzhengxuan on 2017/9/28.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXPlayMusicController.h"
//Views
#import "ZXPlayMusicView.h"
#import "ZXMediaPlayManager.h"
#import "ZXConfig.h"
#import "ZXShowAlert.h"

@interface ZXPlayMusicController ()

@property (nonatomic, strong) ZXPlayMusicView *musicView;

@end

@implementation ZXPlayMusicController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor blackColor];
    
    if (!self.musicList || self.musicList.count == 0) {
        WEAKIFY_SELF
        [ZXShowAlert showVithTitle:@"参数错误【音乐列表为空】" action:^(BOOL isConfirm) {
            if (isConfirm) {
                STRONGIFY_SELF
                [strong_self.navigationController popViewControllerAnimated:YES];
            }
        }];
        
        return;
    }
    
    WEAKIFY_SELF
    self.musicView = [[ZXPlayMusicView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:self.style];
    [self.musicView playWithMusicList:self.musicList startIndex:self.startIndex titleChangeBlock:^(NSString *title) {
        STRONGIFY_SELF
        strong_self.navigationItem.title = title;
    }];
    [self.view addSubview:self.musicView];
}

@end
