//
//  ZXGCDTimer.h
//  ZXGCD
//
//  Created by JinZhengxuan on 2017/4/21.
//  Copyright © 2017年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZXGCDQueue;

@interface ZXGCDTimer : NSObject

@property (strong, readonly, nonatomic) dispatch_source_t dispatchSource;

#pragma 初始化
- (instancetype)init;
- (instancetype)initInQueue:(ZXGCDQueue *)queue;

#pragma mark - 用法
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval;
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval delay:(uint64_t)delay;
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs;
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs;
- (void)start;
- (void)destroy;

@end
