//
//  NSString+ZXUtil.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "NSString+ZXUtil.h"

@implementation NSString (ZXUtil)

/**
 对字符串进行encode，对于已经encode后的字符串不会处理
 
 @return encode后的字符串
 */
- (NSString*)encodingStr {
    if (self && [self isKindOfClass:[NSString class]] && self.length) {
        //判断是否需要encode，如果decode后跟当前一样，说明需要encode
        NSString *decodeString = [self stringByRemovingPercentEncoding];
        if ([decodeString isEqualToString:self]) {
            return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        } else {
            return self;
        }
    } else {
        return @"";
    }
}

@end
