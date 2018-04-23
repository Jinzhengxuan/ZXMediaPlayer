//
//  ZXPlayMusicCricleSlider.m
//  ZXMediaPlayer
//
//  Created by Jinzhengxuan on 2017/8/23.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXPlayMusicCricleSlider.h"
#import "ZXConfig.h"
#import "ZXGCD.h"

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

@interface ZXPlayMusicCricleSlider ()

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, assign) CGFloat trackDistance;

@property (nonatomic, assign) BOOL isDraging;

@property (nonatomic, strong) CAShapeLayer *gradientLayer;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation ZXPlayMusicCricleSlider

//计算中心点到任意点的角度
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return result;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _lineWidth = ZXWidth(3.0f);
    _angle = -90;
    _downloadProgress = 0.0;
    _trackDistance = 50;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setDownloadProgress:(CGFloat)downloadProgress {
    _downloadProgress = downloadProgress;
    
    [ZXGCDQueue executeInMainQueue:^{
        [self setNeedsDisplay];
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    self.radius = self.frame.size.width/2 - _lineWidth / 2.0f - _lineWidth * 1.5f / 2.0f - 9;

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //1.绘制灰色的背景
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.radius, ToRad(-90), ToRad(270), 0);
    [HexRGBAlpha(0x333333, 0.32) setStroke];
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextDrawPath(context, kCGPathStroke);

    //2.绘制下载进度
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.radius, ToRad(-90), ToRad(-90 + _downloadProgress*360), 0);
    [HexRGBAlpha(0x333333, 1.0) setStroke];
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextDrawPath(context, kCGPathStroke);
    
    //3.绘制拖动小块 背景
    CGPoint handleBackgroudCenter = [self pointFromAngle:self.angle offset:8];
    [HexRGB(0x9880e6) setStroke];
    CGContextSetLineWidth(context, 0.5);
    CGContextAddEllipseInRect(context, CGRectMake(handleBackgroudCenter.x, handleBackgroudCenter.y, 16, 16));
    CGContextStrokePath(context);

    //4.绘制拖动小块
    CGPoint handleCenter = [self pointFromAngle:self.angle offset:5.8];
    CGContextAddEllipseInRect(context, CGRectMake(handleCenter.x, handleCenter.y, 11.6, 11.6));
    [HexRGB(0x9880e6) setFill];
    CGContextSetLineWidth(context, 2);
    CGContextFillPath(context);
    
    //5.绘制进度：渐变色，只能放在最后，否则会影响其他部件的显示
    if (self.angle > -85 && self.angle < 270) {
        //偏转5度，为了避免与小球重合
        [self drawProgress:context angle:self.angle - 5];
    }
}

- (void)drawProgress:(CGContextRef)ctx angle:(float)angle {
    // 设置线的宽度
    CGContextSetLineWidth(ctx, _lineWidth);
    
    // 设置线条端点为圆角
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    // 设置画笔颜色
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // 顺时针画一个圆弧
    CGContextAddArc(ctx, self.frame.size.width / 2, self.frame.size.height / 2, self.radius, ToRad(-90), ToRad(angle), 0);
    
    // 2. 创建一个渐变色
    // 创建RGB色彩空间，创建这个以后，context里面用的颜色都是用RGB表示
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 渐变色的颜色
    NSArray *colorArr = @[
                          (id)HexRGB(0x2dd1f4).CGColor,
                          (id)HexRGB(0xa3567f).CGColor
                          ];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr, NULL);
    
    // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    // ----------以下为重点----------
    // 3. "反选路径"
    // CGContextReplacePathWithStrokedPath
    // 将context中的路径替换成路径的描边版本，使用参数context去计算路径（即创建新的路径是原来路径的描边）。用恰当的颜色填充得到的路径将产生类似绘制原来路径的效果。你可以像使用一般的路径一样使用它。例如，你可以通过调用CGContextClip去剪裁这个路径的描边
    CGContextReplacePathWithStrokedPath(ctx);
    // 剪裁路径
    CGContextClip(ctx);
    
    // 4. 用渐变色填充
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, self.frame.size.width / 2), CGPointMake(self.frame.size.width, self.frame.size.height / 2), 0);
    // 释放渐变色
    CGGradientRelease(gradient);
}

- (CGPoint)pointFromAngle:(NSInteger)angleInt offset:(CGFloat)offset {
    //中心点
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - offset, self.frame.size.height/2 - offset);
    //根据角度得到圆环上的坐标
    CGPoint result;
    result.y = centerPoint.y + self.radius * sin(ToRad(angleInt));
    result.x = centerPoint.x + self.radius * cos(ToRad(angleInt));
    
    return result;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    //获取触摸点
    CGPoint lastPoint = [touch locationInView:self];
    
    double dx = fabs(lastPoint.x - self.frame.size.width/2);
    double dy = fabs(lastPoint.y - self.frame.size.height/2);
    double dis = hypot(dx, dy);
    
    if (dis > self.frame.size.width/2) {
        return NO;
    }
    if (dis < self.frame.size.width/2 - self.trackDistance) {
        return NO;
    }
    self.isDraging = YES;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    //获取触摸点
    CGPoint lastPoint = [touch locationInView:self];
    
    double dx = fabs(lastPoint.x - self.frame.size.width/2);
    double dy = fabs(lastPoint.y - self.frame.size.height/2);
    double dis = hypot(dx, dy);
    
    if (dis > self.frame.size.width/2) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(setIsDraging) withObject:nil afterDelay:0.5];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return NO;
    }
    
    CGPoint previousPoint = [touch previousLocationInView:self];
    //获得中心点
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2,
                                      self.frame.size.height/2);
    
    CGRect firstRect = CGRectMake(centerPoint.x , 0, CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    CGRect fouthRect = CGRectMake(0 , 0, CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    
    BOOL clockwise = [self judgeClockwiseWith:lastPoint preP:previousPoint];
    if (clockwise) {
        if (CGRectContainsPoint(fouthRect, previousPoint)&&CGRectContainsPoint(firstRect, lastPoint)) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(setIsDraging) withObject:nil afterDelay:0.5];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            return NO;
        }
    } else {
        if (CGRectContainsPoint(firstRect, previousPoint) && CGRectContainsPoint(fouthRect, lastPoint)) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(setIsDraging) withObject:nil afterDelay:0.5];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            return NO;
        }
    }
    
    //计算中心点到任意点的角度
    CGFloat currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    
    CGFloat angleInt = floor(currentAngle);
    
    if (angleInt < -90 && angleInt >= -180) {
        angleInt = 180 + (180 + angleInt);
    }

    _progress = fabs((angleInt + 90)/360);
    
    //保存新角度
    self.angle = angleInt;
    
    [ZXGCDQueue executeInMainQueue:^{
        [self setNeedsDisplay];
    }];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    //获取触摸点
    CGPoint lastPoint = [touch locationInView:self];
    
    //获得中心点
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2,
                                      self.frame.size.height/2);
    //计算中心点到任意点的角度
    CGFloat currentAngle = AngleFromNorth(centerPoint,
                                          lastPoint,
                                          NO);
    
    CGFloat angleInt = floor(currentAngle);
    
    if (angleInt < -90 && angleInt >= -180) {
        angleInt = 180 + (180 + angleInt);
    }

    _progress = fabs((angleInt + 90)/360);
    
    //保存新角度
    self.angle = angleInt;
    [ZXGCDQueue executeInMainQueue:^{
        [self setNeedsDisplay];
    }];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(setIsDraging) withObject:nil afterDelay:0.5];
}

- (void)setIsDraging {
    self.isDraging = NO;
}

- (void)pppPoint:(CGPoint)previous {
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    CGFloat width = center.x;
    CGRect firstRect = CGRectMake(center.x , 0, width, width);
    CGRect secondRect = CGRectMake(center.x, center.y , width, width);
    CGRect thirdRect = CGRectMake(0, center.y, width, width);
    CGRect fouthRect = CGRectMake(0 , 0, width, width);
    if (CGRectContainsPoint(firstRect, previous)) {
        NSLog(@"前yige点在第一象限");
    }
    if (CGRectContainsPoint(secondRect, previous)) {
        NSLog(@"前yige点在第2象限");
    }
    if (CGRectContainsPoint(thirdRect, previous)) {
        NSLog(@"前yige点在第3象限");
    }
    if (CGRectContainsPoint(fouthRect, previous)) {
        NSLog(@"前yige点在第4象限");
    }
}

- (void)cccPoint:(CGPoint)curr {
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    CGFloat width = center.x;
    CGRect firstRect = CGRectMake(center.x , 0, width, width);
    CGRect secondRect = CGRectMake(center.x, center.y , width, width);
    CGRect thirdRect = CGRectMake(0, center.y, width, width);
    CGRect fouthRect = CGRectMake(0 , 0, width, width);
    if (CGRectContainsPoint(firstRect, curr)) {
        NSLog(@"当前点在第一象限");
    }
    if (CGRectContainsPoint(secondRect, curr)) {
        NSLog(@"当前点在第2象限");
    }
    if (CGRectContainsPoint(thirdRect, curr)) {
        NSLog(@"当前点在第3象限");
    }
    if (CGRectContainsPoint(fouthRect, curr)) {
        NSLog(@"当前点在第4象限");
    }
}

- (BOOL)judgeClockwiseWith:(CGPoint)currP preP:(CGPoint)preP {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGPoint center = CGPointMake(width/2.0,width/ 2.0);
    
//    [self pppPoint:preP];
//    [self cccPoint:currP];
    CGFloat result = (preP.x - center.x) * (currP.y - preP.y) - (preP.y - center.y) *(currP.x - preP.x);
    if (result == 0) {
//        NSLog(@"三点在一条直线上");
        return YES;
    }
    if (result > 0) {
//        NSLog(@"顺时针");
        return YES;
    }
    if (result < 0) {
//        NSLog(@"逆时针");
        return NO;
    }
    return YES;
}

- (void)setProgress:(CGFloat)progress {
    if (self.isDraging) {
        return;
    }

    _progress = progress;
    if (progress < 0.0) {
        _progress = 0.0;
    }
    if (progress > 1.0) {
        _progress = 1.0;
    }

    NSInteger angleInt = 360*progress;
    angleInt -= 90;
    self.angle = angleInt;
    [ZXGCDQueue executeInMainQueue:^{
        [self setNeedsDisplay];
    }];
}

@end
