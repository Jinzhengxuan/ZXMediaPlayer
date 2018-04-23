//
//  UIView+ZXRect.h
//  Jinzhengxuan
//
//  Created by JinZhengxuan on 2017/4/25.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZXRect)

/*----------------------
 * Absolute coordinate *
 ----------------------*/

@property (nonatomic) CGPoint zx_viewOrigin;
@property (nonatomic) CGSize  zx_viewSize;

@property (nonatomic) CGFloat zx_x;
@property (nonatomic) CGFloat zx_y;
@property (nonatomic) CGFloat zx_width;
@property (nonatomic) CGFloat zx_height;

@property (nonatomic) CGFloat zx_top;
@property (nonatomic) CGFloat zx_bottom;
@property (nonatomic) CGFloat zx_left;
@property (nonatomic) CGFloat zx_right;

@property (nonatomic) CGFloat zx_centerX;
@property (nonatomic) CGFloat zx_centerY;

/*----------------------
 * Relative coordinate *
 ----------------------*/

@property (nonatomic, readonly) CGFloat zx_middleX;
@property (nonatomic, readonly) CGFloat zx_middleY;
@property (nonatomic, readonly) CGPoint zx_middlePoint;

@end
