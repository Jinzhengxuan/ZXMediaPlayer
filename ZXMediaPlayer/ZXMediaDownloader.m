//
//  ZXMediaDownloader.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/8/18.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXMediaDownloader.h"
#import "ZXMediaPlayManager.h"
#import "ZXDBUtil.h"

@interface ZXMediaDownloader ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) MPDownloadProgressBlock downloadProgressBlock;
@property (nonatomic, strong) MPDownloadCompleteBlock downloadCompleteBlock;
@property (nonatomic, assign) float timeout;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation ZXMediaDownloader

/**
 下载音乐进度
 
 @param url 音乐地址
 @param progressBlock 进度
 @param completeBlock 结果
 @param timeout 超时
 */
- (void)downloadWithURL:(NSURL *)url progressBlock:(MPDownloadProgressBlock)progressBlock completeBlock:(MPDownloadCompleteBlock)completeBlock timeout:(float)timeout {
    self.url = url;
    self.downloadProgressBlock = progressBlock;
    self.downloadCompleteBlock = completeBlock;
    self.timeout = timeout;
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:timeout];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    
//    [sessionMgr downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        if (self.downloadProgressBlock) {
//            self.downloadProgressBlock(downloadProgress);
//        }
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        NSString *cachePath = [[ZXDBUtil cacheDirectory] stringByAppendingString:response.suggestedFilename];
//        return [NSURL fileURLWithPath:cachePath];
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        if (error) {
//            if (self.downloadCompleteBlock) {
//                self.downloadCompleteBlock(NO, error);
//            }
//        } else {
//            [ZXMediaPlayManager.sharedInstance indexCacheFileWithURL:self.url fileName:response.suggestedFilename];
//            if (self.downloadCompleteBlock) {
//                self.downloadCompleteBlock(YES, nil);
//            }
//        }
//    }];
    
    [downloadTask resume];
    self.downloadTask = downloadTask;
}

- (void)cancelDownloading {
    [self.downloadTask cancel];
}

@end

