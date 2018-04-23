//
//  UIImage+ZXUtil.h
//  Examples
//
//  Created by JinZhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZXUtil)

// UIImage+Resize合并，截取中心图片
- (UIImage *)croppedCenterSquareImage;

+ (UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur rect:(CGRect)rect;

@end
