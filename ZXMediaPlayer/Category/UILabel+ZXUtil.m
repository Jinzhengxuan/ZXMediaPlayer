//
//  UILabel+ZXUtil.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "UILabel+ZXUtil.h"

@implementation UILabel (ZXUtil)

+ (instancetype)createWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font {
    UILabel *label = [[UILabel alloc]init];
    label.text = text;
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
