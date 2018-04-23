//
//  UIView+ZXRect.m
//  Jinzhengxuan
//
//  Created by JinZhengxuan on 2017/4/25.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "UIView+ZXRect.h"

@implementation UIView (ZXRect)

- (CGPoint)zx_viewOrigin {

    return self.frame.origin;
}

- (void)setZx_viewOrigin:(CGPoint)viewOrigin {

    CGRect newFrame = self.frame;
    newFrame.origin = viewOrigin;
    self.frame      = newFrame;
}

- (CGSize)zx_viewSize {

    return self.frame.size;
}

- (void)setZx_viewSize:(CGSize)viewSize {

    CGRect newFrame = self.frame;
    newFrame.size   = viewSize;
    self.frame      = newFrame;
}

- (CGFloat)zx_x {
    
    return self.frame.origin.x;
}

- (void)setZx_x:(CGFloat)x {

    CGRect newFrame   = self.frame;
    newFrame.origin.x = x;
    self.frame        = newFrame;
}

- (CGFloat)zx_y {

    return self.frame.origin.y;
}

- (void)setZx_y:(CGFloat)y {

    CGRect newFrame   = self.frame;
    newFrame.origin.y = y;
    self.frame        = newFrame;
}

- (CGFloat)zx_width {

    return CGRectGetWidth(self.bounds);
}

- (void)setZx_width:(CGFloat)width {

    CGRect newFrame     = self.frame;
    newFrame.size.width = width;
    self.frame          = newFrame;
}

- (CGFloat)zx_height {

    return CGRectGetHeight(self.bounds);
}

- (void)setZx_height:(CGFloat)height {

    CGRect newFrame      = self.frame;
    newFrame.size.height = height;
    self.frame           = newFrame;
}

- (CGFloat)zx_top {

    return self.frame.origin.y;
}

- (void)setZx_top:(CGFloat)top {

    CGRect newFrame   = self.frame;
    newFrame.origin.y = top;
    self.frame        = newFrame;
}

- (CGFloat)zx_bottom {

    return self.frame.origin.y + self.frame.size.height;
}

- (void)setZx_bottom:(CGFloat)bottom {

    CGRect newFrame   = self.frame;
    newFrame.origin.y = bottom - self.frame.size.height;
    self.frame        = newFrame;
}

- (CGFloat)zx_left {

    return self.frame.origin.x;
}

- (void)setZx_left:(CGFloat)left {

    CGRect newFrame   = self.frame;
    newFrame.origin.x = left;
    self.frame        = newFrame;
}

- (CGFloat)zx_right {

    return self.frame.origin.x + self.frame.size.width;
}

- (void)setZx_right:(CGFloat)right {

    CGRect newFrame   = self.frame;
    newFrame.origin.x = right - self.frame.size.width;
    self.frame        = newFrame;
}

- (CGFloat)zx_centerX {

    return self.center.x;
}

- (void)setZx_centerX:(CGFloat)centerX {

    CGPoint newCenter = self.center;
    newCenter.x       = centerX;
    self.center       = newCenter;
}

- (CGFloat)zx_centerY {

    return self.center.y;
}

- (void)setZx_centerY:(CGFloat)centerY {

    CGPoint newCenter = self.center;
    newCenter.y       = centerY;
    self.center       = newCenter;
}

- (CGFloat)zx_middleX {

    return CGRectGetWidth(self.bounds) / 2.f;
}

- (CGFloat)zx_middleY {

    return CGRectGetHeight(self.bounds) / 2.f;
}

- (CGPoint)zx_middlePoint {

    return CGPointMake(CGRectGetWidth(self.bounds) / 2.f, CGRectGetHeight(self.bounds) / 2.f);
}

@end
