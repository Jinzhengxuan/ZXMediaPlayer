//
//  ZXConfig.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#ifndef ZXConfig_h
#define ZXConfig_h

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define ZXWidthScale SCREEN_WIDTH/375
#define ZXHeightScale SCREEN_HEIGHT/667
#define ZXFont(size) [UIFont systemFontOfSize:(size * ZXWidthScale)]
#define ZXBoldFont(size) [UIFont boldSystemFontOfSize:(size * ZXWidthScale)]
#define ZXWidth(size) (size * ZXWidthScale)

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define WEAKIFY_SELF   @ZXWeakify(self)
#define STRONGIFY_SELF @ZXStrongify(self)

#ifndef    ZXWeakify
#if __has_feature(objc_arc)
#define ZXWeakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define ZXWeakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif

#ifndef    ZXStrongify
#if __has_feature(objc_arc)
#define ZXStrongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
#else
#define ZXStrongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
#endif
#endif

//全局3/4G缓存确认弹出框
#define kGlobalAlertWhenDownloadByWWANResult @"kGlobalAlertWhenDownloadByWWANResult"
#define kGlobalAlertWhenDownloadByWWANString @"当前网络无Wi-Fi，继续下载可能会被运营商收取流量费用"
#define kGlobalAlertNetworkUnreachable @"网络连接异常，请检查您的设置"

//保证主线程执行block
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#endif /* ZXConfig_h */
