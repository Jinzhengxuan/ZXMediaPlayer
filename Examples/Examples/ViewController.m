//
//  ViewController.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ViewController.h"
#import "ZXMediaPlayManager.h"

@interface ViewController ()

@end

@implementation ViewController {
    CGFloat buttonOffsetY;
}

typedef NS_ENUM(NSUInteger, BtnActions) {
    BtnActions_PlayVideo,
    BtnActions_PlayAudio,
    BtnActions_PlayAudioWithCustomUI,
};

#define ScreenWidth UIScreen.mainScreen.bounds.size.width
#define ScreenHeight UIScreen.mainScreen.bounds.size.height

- (UIButton *)createBtnWithTitle:(NSString *)title tag:(BtnActions)tag {
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, buttonOffsetY, ScreenWidth - 20, 40)];
    btn.layer.cornerRadius = 10;
    btn.backgroundColor = UIColor.whiteColor;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.tag = tag;
    
    buttonOffsetY += 80;
    return btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    buttonOffsetY = 80;
    [self.view addSubview:[self createBtnWithTitle:@"Video" tag:BtnActions_PlayVideo]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnAction:(UIButton *)btn {
    switch (btn.tag) {
        case BtnActions_PlayVideo:
        {
            break;
        }
        case BtnActions_PlayAudio:
        {
            break;
        }
        case BtnActions_PlayAudioWithCustomUI:
        {
            break;
        }
        default:
            break;
    }
}

@end
