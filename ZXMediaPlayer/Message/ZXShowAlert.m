//
//  ZXShowAlert.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ZXShowAlert.h"
#import <UIKit/UIKit.h>
#import "ZXConfig.h"
#import "ZXUtils.h"
#import "ZXGCD.h"

@implementation ZXShowAlert

+ (void)showWWANWarningWithAction:(ZXAlertAction)action {
    ZXShowAlert *alert = [[ZXShowAlert alloc]init];
    alert.title = kGlobalAlertWhenDownloadByWWANString;
    alert.action = action;
    if (action) {
        [alert showAlert];
    } else {
        [alert showMessage];
    }
}

+ (void)showWithTitle:(NSString *)title action:(ZXAlertAction)action {
    ZXShowAlert *alert = [[ZXShowAlert alloc]init];
    alert.title = title;
    alert.action = action;
    if (action) {
        [alert showAlert];
    } else {
        [alert showMessage];
    }
}

+ (void)showWithTitle:(NSString *)title {
    ZXShowAlert *alert = [[ZXShowAlert alloc]init];
    alert.title = title;
    alert.action = nil;
    [alert showMessage];
}

+ (void)showNetworkUnreachable {
    ZXShowAlert *alert = [[ZXShowAlert alloc]init];
    alert.title = kGlobalAlertNetworkUnreachable;
    alert.action = nil;
    [alert showMessage];
}

+ (void)dismiss {
    for (UIView *msgView in ZXUtils.currentViewController.view.subviews) {
        if (msgView.tag == 9898) {
            [msgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [msgView removeFromSuperview];
        }
    }
}

- (void)showAlert {
    [ZXShowAlert dismiss];
    
    WEAKIFY_SELF
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGIFY_SELF
        if (strong_self.action) {
            strong_self.action(YES);
        }
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        STRONGIFY_SELF
        if (strong_self.action) {
            strong_self.action(NO);
        }
    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [ZXUtils.currentViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showMessage {
    [ZXShowAlert dismiss];
    
    UIView *msgView = [self messageViewWith:_title];
    [ZXUtils.currentViewController.view addSubview:msgView];
    
    [ZXGCDQueue executeInMainQueue:^{
        [msgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [msgView removeFromSuperview];
    } afterDelaySecs:3.0];
}

- (UIView *)messageViewWith:(NSString *)title {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - ZXWidth(50), SCREEN_HEIGHT/2 - ZXWidth(50), ZXWidth(50), ZXWidth(50))];
    view.backgroundColor = HexRGBAlpha(0xf0f0f0, 0.7);
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.tag = 9898;
    
    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, ZXWidth(15), ZXWidth(50), ZXWidth(20))];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.font = ZXFont(20);
    infoLabel.text = title;
    
    return view;
}

@end
