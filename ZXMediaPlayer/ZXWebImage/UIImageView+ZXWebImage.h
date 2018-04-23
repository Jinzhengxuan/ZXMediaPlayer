//
//  UIImageView+ZXWebImage.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Progress)(float progress);
typedef void(^Complete)(UIImage *finalImage, NSURL *url);

@interface UIImageView (ZXWebImage)

- (void)zx_showImageWithURL:(NSURL *)url;
- (void)zx_showImageWithURL:(NSURL *)url complete:(Complete)complete;
- (void)zx_showImageWithURL:(NSURL *)url progress:(Progress)progress complete:(Complete)complete;

- (void)zx_showImageWithURLString:(NSString *)urlString;
- (void)zx_showImageWithURLString:(NSString *)urlString complete:(Complete)complete;
- (void)zx_showImageWithURLString:(NSString *)urlString progress:(Progress)progress complete:(Complete)complete;

@end
