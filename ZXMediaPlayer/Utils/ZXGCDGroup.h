//
//  ZXGCDGroup.h
//  ZXGCD
//
//  Created by JinZhengxuan on 2017/4/21.
//  Copyright © 2017年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXGCDGroup : NSObject

@property (strong, nonatomic, readonly) dispatch_group_t dispatchGroup;

#pragma 初始化
- (instancetype)init;

#pragma mark - 用法
- (void)enter;
- (void)leave;
- (void)wait;
- (BOOL)wait:(int64_t)delta;

@end
