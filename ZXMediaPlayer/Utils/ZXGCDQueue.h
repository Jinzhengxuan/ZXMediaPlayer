//
//  ZXGCDQueue.h
//  ZXGCD
//
//  Created by JinZhengxuan on 2017/4/21.
//  Copyright © 2017年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZXGCDGroup;

@interface ZXGCDQueue : NSObject

@property (strong, readonly, nonatomic) dispatch_queue_t dispatchQueue;

+ (ZXGCDQueue *)mainQueue;
+ (ZXGCDQueue *)globalQueue;
+ (ZXGCDQueue *)highPriorityGlobalQueue;
+ (ZXGCDQueue *)lowPriorityGlobalQueue;
+ (ZXGCDQueue *)backgroundPriorityGlobalQueue;

#pragma mark - 便利的构造方法
+ (void)executeInMainQueue:(dispatch_block_t)block;
+ (void)executeInGlobalQueue:(dispatch_block_t)block;
+ (void)executeInHighPriorityGlobalQueue:(dispatch_block_t)block;
+ (void)executeInLowPriorityGlobalQueue:(dispatch_block_t)block;
+ (void)executeInBackgroundPriorityGlobalQueue:(dispatch_block_t)block;
+ (void)executeInMainQueue:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInGlobalQueue:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInHighPriorityGlobalQueue:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInLowPriorityGlobalQueue:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;
+ (void)executeInBackgroundPriorityGlobalQueue:(dispatch_block_t)block afterDelaySecs:(NSTimeInterval)sec;

#pragma 初始化
- (instancetype)init;
- (instancetype)initSerial;
- (instancetype)initSerialWithLabel:(NSString *)label;
- (instancetype)initConcurrent;
- (instancetype)initConcurrentWithLabel:(NSString *)label;

#pragma mark - 用法
- (void)execute:(dispatch_block_t)block;
- (void)execute:(dispatch_block_t)block afterDelay:(int64_t)delta;
- (void)execute:(dispatch_block_t)block afterDelaySecs:(float)delta;
- (void)waitExecute:(dispatch_block_t)block;
- (void)barrierExecute:(dispatch_block_t)block;
- (void)waitBarrierExecute:(dispatch_block_t)block;
- (void)suspend;
- (void)resume;

#pragma mark - 与ZXGCDGroup相关
- (void)execute:(dispatch_block_t)block inGroup:(ZXGCDGroup *)group;
- (void)notify:(dispatch_block_t)block inGroup:(ZXGCDGroup *)group;

@end
