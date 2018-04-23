//
//  ZXReachAbility.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ZXReachAbility.h"
#import "Reachability.h"

@interface ZXReachAbility()

@property (nonatomic) Reachability *internetReachability;

@end

@implementation ZXReachAbility

+ (void)load {
    [ZXReachAbility.shared start];
}

+ (ZXReachAbility *)shared {
    static ZXReachAbility *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZXReachAbility alloc]init];
        [instance commonInit];
    });
    return instance;
}

+ (BOOL)isNetworkConnected {
    if (ZXReachAbility.shared.status == ZXReachStatus_WIFI || ZXReachAbility.shared.status == ZXReachStatus_WWAN) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isWWANConnected {
    if (ZXReachAbility.shared.status == ZXReachStatus_WWAN) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isWifiConnected {
    if (ZXReachAbility.shared.status == ZXReachStatus_WIFI) {
        return YES;
    } else {
        return NO;
    }
}

- (void)start {
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)commonInit {
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    switch ([curReach currentReachabilityStatus]) {
        case NotReachable:
        {
            NSLog(@"暂时没有网络连接");
            self.status = ZXReachStatus_None;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"网络连接类型为WIFI");
            self.status = ZXReachStatus_WIFI;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"网络连接类型为WWAN");
            self.status = ZXReachStatus_WWAN;
            break;
        }
        default:
            break;
    }
}

@end
