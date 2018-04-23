//
//  ZXMediaDownloader.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/8/18.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 下载音乐的进度
 
 @param progress 进度
 */
typedef void (^MPDownloadProgressBlock) (NSProgress *progress);

/**
 下载音乐的成功
 
 @param isSuccess 是否成功
 @param error 错误
 */
typedef void (^MPDownloadCompleteBlock) (BOOL isSuccess, NSError *error);

@interface ZXMediaDownloader : NSObject

/**
 下载音乐进度
 
 @param url 音乐地址
 @param progressBlock 进度
 @param completeBlock 结果
 @param timeout 超时
 */
- (void)downloadWithURL:(NSURL *)url progressBlock:(MPDownloadProgressBlock)progressBlock completeBlock:(MPDownloadCompleteBlock)completeBlock timeout:(float)timeout;

/**
    
 */
- (void)cancelDownloading;

@end

