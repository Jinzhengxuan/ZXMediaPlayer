//
//  UIButton+ZXUtil.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ZXUtil)

+ (instancetype)buttonWithImageName:(NSString *)imageName;

- (void)setImageName:(NSString *)imageName forState:(UIControlState)state;

@end
