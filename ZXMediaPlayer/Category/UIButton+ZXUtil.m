//
//  UIButton+ZXUtil.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "UIButton+ZXUtil.h"

@implementation UIButton (ZXUtil)

+ (instancetype)buttonWithImageName:(NSString *)imageName {
    UIButton *btn = [[UIButton alloc]init];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    return btn;
}

- (void)setImageName:(NSString *)imageName forState:(UIControlState)state {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        [self setImage:image forState:state];
    }
}

@end
