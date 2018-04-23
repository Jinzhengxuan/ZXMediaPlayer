//
//  ZXReachAbility.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZXReachStatus) {
    ZXReachStatus_None,
    ZXReachStatus_WIFI,
    ZXReachStatus_WWAN,
};

@interface ZXReachAbility : NSObject

@property (nonatomic, assign) ZXReachStatus status;

+ (ZXReachAbility *)shared;

+ (BOOL)isNetworkConnected;

+ (BOOL)isWWANConnected;

+ (BOOL)isWifiConnected;

@end
