//
//  NSString+ZXUtil.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZXUtil)

/**
 对字符串进行encode，对于已经encode后的字符串不会处理
 
 @return encode后的字符串
 */
- (NSString*)encodingStr;

@end
