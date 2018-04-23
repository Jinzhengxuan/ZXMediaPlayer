//
//  ZXUtils.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ZXUtils.h"

@implementation ZXUtils

+ (NSString *)stringBySeconds:(NSInteger)s {
    NSString *dateString = @"--:--";
    NSInteger minutes = s / 60;
    NSInteger seconds = s % 60;
    if (minutes < 10) {
        if (seconds < 10) {
            dateString = [NSString stringWithFormat:@"0%zd:0%zd", (long)minutes, (long)seconds];
        } else {
            dateString = [NSString stringWithFormat:@"0%zd:%zd", (long)minutes, (long)seconds];
        }
    } else {
        if (seconds < 10) {
            dateString = [NSString stringWithFormat:@"%zd:0%zd", (long)minutes, (long)seconds];
        } else {
            dateString = [NSString stringWithFormat:@"%zd:%zd", (long)minutes, (long)seconds];
        }
    }
    return dateString;
}

@end
