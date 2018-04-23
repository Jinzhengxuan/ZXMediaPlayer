//
//  ZXWebImage.m
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import "ZXWebImage.h"

@implementation ZXWebImage

+ (instancetype)shared {
    static ZXWebImage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZXWebImage alloc]init];
    });
    return instance;
}

- (void)downloadImageWithURL:(NSURL *)url progress:(ZXWebImageProgress)progress complete:(ZXWebImageComplete)complete {
    
}

@end
