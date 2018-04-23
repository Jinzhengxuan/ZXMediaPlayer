//
//  ZXWebImageDownloadTask.h
//  Examples
//
//  Created by Jin Zhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXWebImage.h"

@interface ZXWebImageDownloadTask : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) ZXWebImageProgress progress;
@property (nonatomic, copy) ZXWebImageComplete complete;

- (instancetype)initWithURL:(NSURL *)url progress:(ZXWebImageProgress)progress complete:(ZXWebImageComplete)complete;

@end
