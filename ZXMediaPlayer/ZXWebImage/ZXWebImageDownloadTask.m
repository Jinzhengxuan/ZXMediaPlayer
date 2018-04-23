//
//  ZXWebImageDownloadTask.m
//  Examples
//
//  Created by Jin Zhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ZXWebImageDownloadTask.h"

@implementation ZXWebImageDownloadTask

- (instancetype)initWithURL:(NSURL *)url progress:(ZXWebImageProgress)progress complete:(ZXWebImageComplete)complete {
    self = [super init];
    if (self) {
        self.url = url;
        self.progress = progress;
        self.complete = complete;
        [self startTask];
    }
    return self;
}

- (void)startTask {
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    
}

@end
