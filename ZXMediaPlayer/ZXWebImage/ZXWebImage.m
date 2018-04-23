//
//  ZXWebImage.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ZXWebImage.h"
#import "ZXWebImageDBUtil.h"

@implementation ZXWebImage

+ (instancetype)shared {
    static ZXWebImage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZXWebImage alloc]init];
    });
    return instance;
}

- (BOOL)isCacheExistedWithURLString:(NSString *)urlString {
    BOOL isFound = NO;
    
    return isFound;
}

- (void)downloadImageWithURL:(NSURL *)url progress:(ZXWebImageProgress)progress complete:(ZXWebImageComplete)complete {
    if ([self isCacheExistedWithURLString:url.absoluteString]) {
        NSURL *fileURL = [self filePathWithURLString:url.absoluteString];
        if ([NSFileManager.defaultManager fileExistsAtPath:fileURL.absoluteString]) {
            return;
        }
    }
    [self createWebImageDownloadTaskWithURL:url progress:progress complete:complete];
}

- (void)createWebImageDownloadTaskWithURL:(NSURL *)url progress:(ZXWebImageProgress)progress complete:(ZXWebImageComplete)complete {
    
}

- (NSURL *)filePathWithURLString:(NSString *)urlString {
    NSString *cacheName = [ZXWebImageDBUtil queryRecordWithURL:urlString];
    NSString *cachePath = [NSString stringWithFormat:@"%@%@", [ZXWebImageDBUtil cacheDirectory], cacheName];
    return [NSURL URLWithString:cachePath];
}

@end
