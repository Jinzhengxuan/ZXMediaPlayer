//
//  ZXShowAlert.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZXAlertButton) {
    ZXAlertButton_OK,
    ZXAlertButton_Cancel,
};

typedef void(^ZXAlertAction)(BOOL isConfirm);

@interface ZXShowAlert : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) ZXAlertAction action;

+ (void)showWWANWarningWithAction:(nullable ZXAlertAction)action;

+ (void)showWithTitle:(nonnull NSString *)title action:(nullable ZXAlertAction)action;

+ (void)showWithTitle:(nonnull NSString *)title;

+ (void)showNetworkUnreachable;

+ (void)dismiss;

@end
