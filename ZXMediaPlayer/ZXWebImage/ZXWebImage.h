//
//  ZXWebImage.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZXWebImage : NSObject

typedef void(^ZXWebImageProgress)(float progress);
typedef void(^ZXWebImageComplete)(UIImage *image, NSURL *url, NSError *error);

@property (nonatomic, copy) ZXWebImageProgress progress;
@property (nonatomic, copy) ZXWebImageComplete complete;

+ (instancetype)shared;

- (BOOL)isCacheExistedWithURLString:(NSString *)urlString;

- (void)downloadImageWithURL:(NSURL *)url progress:(ZXWebImageProgress)progress complete:(ZXWebImageComplete)complete;

@end
