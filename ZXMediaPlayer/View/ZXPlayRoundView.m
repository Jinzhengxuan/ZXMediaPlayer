//
//  ZXPlayRoundView.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/30.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXPlayRoundView.h"

#define kRotationDuration 8.0

@interface ZXPlayRoundView ()

@property (strong, nonatomic) UIImageView *roundImageView;
@property (strong, nonatomic) UIImageView *playStateView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation ZXPlayRoundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    CGPoint center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    
    // set ZXPlayRoundView
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    
    self.layer.cornerRadius = center.x;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    
    // set roundImageView
    UIImage *roundImage = self.roundImage;
    self.roundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.roundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.roundImageView setCenter:center];
    [self.roundImageView setImage:roundImage];
    [self addSubview:self.roundImageView];
    
    // set play state
    UIImage *stateImage;
    if (self.isPlaying) {
        stateImage = [UIImage imageNamed:@"ms_bt_zanting"];
    } else {
        stateImage = [UIImage imageNamed:@"ms_bt_bofang"];
    }
    
    self.playStateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, stateImage.size.width, stateImage.size.height)];
    [self.playStateView setCenter:center];
    [self.playStateView setImage:stateImage];
    self.playStateView.userInteractionEnabled = YES;
    [self addSubview:self.playStateView];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    ges.numberOfTapsRequired = 1;
    ges.numberOfTouchesRequired = 1;
    [self.playStateView addGestureRecognizer:ges];
    
    center = CGPointMake(stateImage.size.width / 2.0, stateImage.size.height / 2.0);
    self.indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.indicator setCenter:center];
    [self.indicator setHidden:YES];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.playStateView addSubview:self.indicator];
    
    _isPlaying = NO;
}

- (void)addRotationAnimation {
    //只添加一次动画
    if (self.roundImageView.layer.animationKeys.count > 0) {
        return;
    }
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = kRotationDuration;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO; // No Remove
    [self.roundImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

#pragma mark Setter

- (void)setRoundImage:(UIImage *)aRoundImage {
    _roundImage = aRoundImage;
    self.roundImageView.image = self.roundImage;
}

#pragma mark Action

- (void)tapAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepareToPlay:)]) {
        [self.delegate prepareToPlay:!_isPlaying];
    }
}

- (void)play {
//    [self addRotationAnimation];
    
    CFTimeInterval pausedTime = [self.roundImageView.layer timeOffset];
    self.roundImageView.layer.speed = 1;
    self.roundImageView.layer.timeOffset = 0.0;
    self.roundImageView.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.roundImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.roundImageView.layer.beginTime = timeSincePause;
    
    _isPlaying = YES;
    
    self.playStateView.image = [UIImage imageNamed:@"ms_bt_zanting"];
    [UIView animateWithDuration:0.25 animations:^{
        self.playStateView.alpha = 1.0;
        [self.indicator setHidden:YES];
        [self.indicator stopAnimating];
    }];
}

- (void)pause {
    CFTimeInterval pausedTime = [self.roundImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.roundImageView.layer.speed = 0.0;
    self.roundImageView.layer.timeOffset = pausedTime;
    
    _isPlaying = NO;
    
    self.playStateView.image = [UIImage imageNamed:@"ms_bt_bofang"];
    [UIView animateWithDuration:0.25 animations:^{
        self.playStateView.alpha = 1.0;
        [self.indicator setHidden:YES];
        [self.indicator stopAnimating];
    }];
}

- (void)buffering {
    _isPlaying = NO;
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
}

@end
