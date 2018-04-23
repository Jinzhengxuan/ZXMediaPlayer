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
    alert.title = kGlobalNetworkUnreachable;
    alert.action = nil;
    [alert showMessage];
}

+ (void)dismiss {
    
}

- (void)showAlert {
    
}

- (void)showMessage {
    
}

@end
