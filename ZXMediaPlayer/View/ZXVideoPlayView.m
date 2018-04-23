//
//  ZXVideoPlayView.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/30.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXVideoPlayView.h"
#import "ZXGCD.h"
#import "ZXConfig.h"
#import "UIView+ZXRect.h"
#import "UIImageView+ZXWebImage.h"
#import "ZXUtils.h"

@interface ZXVideoPlayView ()

@property (nonatomic, strong) UIImageView *backGroundImgView;
@property (nonatomic, strong) UIView *controlBar;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIImageView *stateImgView;
@property (nonatomic, strong) CALayer *totalProgressLayer;
@property (nonatomic, strong) CALayer *downloadProgressLayer;
@property (nonatomic, strong) CALayer *playProgressLayer;
@property (nonatomic, strong) UILabel *currentTime;
@property (nonatomic, strong) UILabel *totalTime;

@property (nonatomic, strong) NSURL *imageURL;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isControlBarShowing;
@property (nonatomic, assign) BOOL canResponseTap;
@property (nonatomic, assign) float totalSeconds;
@property (nonatomic, strong) ZXGCDTimer *controlBarShowingTimer;
@property (nonatomic, assign) NSInteger playSecsCount;

@end

@implementation ZXVideoPlayView {
    float kTotalProgressLength;
}

- (instancetype)initWithFrame:(CGRect)frame imageURL:(NSURL *)imageURL {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageURL = imageURL;
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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [self.controlBarShowingTimer destroy];
}

- (void)commonInit {
    self.totalSeconds = 0;
    self.isControlBarShowing = NO;
    self.isPlaying = NO;
    self.canResponseTap = NO;
    self.backgroundColor = [UIColor clearColor];
    kTotalProgressLength = self.frame.size.width - ZXWidth(80);
    [self addSubview:self.backGroundImgView];
    [self addSubview:self.controlBar];
    [self addSubview:self.indicatorView];
    [self.controlBar addSubview:self.stateImgView];
    [self.controlBar.layer addSublayer:self.totalProgressLayer];
    [self.controlBar.layer addSublayer:self.downloadProgressLayer];
    [self.controlBar.layer addSublayer:self.playProgressLayer];
    [self.controlBar addSubview:self.currentTime];
    [self.controlBar addSubview:self.totalTime];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    
    self.controlBarShowingTimer = [[ZXGCDTimer alloc]init];
    self.playSecsCount = 0;
    [self.controlBarShowingTimer event:^{
        if (self.isControlBarShowing) {
            self.playSecsCount++;
            if (self.playSecsCount >= 5) {
                [ZXGCDQueue executeInMainQueue:^{
                    [UIView animateWithDuration:0.2 animations:^{
                        self.controlBar.alpha = 0;
                        self.isControlBarShowing = NO;
                    }];
                }];
            }
        } else {
            self.playSecsCount = 0;
        }
    } timeIntervalWithSecs:1];
    [self.controlBarShowingTimer start];
    
    if (self.imageURL) {
        [self.backGroundImgView zx_showImageWithURL:self.imageURL];
    }
}

- (UIImageView *)backGroundImgView {
    if (!_backGroundImgView) {
        _backGroundImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backGroundImgView.alpha = 1;
    }
    return _backGroundImgView;
}

- (UIView *)controlBar {
    if (!_controlBar) {
        _controlBar = [[UIView alloc]initWithFrame:CGRectMake(ZXWidth(10), self.frame.size.height - ZXWidth(60), self.frame.size.width - ZXWidth(20), ZXWidth(50))];
        _controlBar.backgroundColor = HexRGBAlpha(0xececee, 1.0);
        _controlBar.layer.cornerRadius = 8;
        _controlBar.alpha = 0;
    }
    return _controlBar;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, ZXWidth(40), ZXWidth(40))];
        _indicatorView.zx_centerX = self.zx_centerX;
        _indicatorView.zx_centerY = self.zx_centerY;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    return _indicatorView;
}

- (UIImageView *)stateImgView {
    if (!_stateImgView) {
        //zx_zanting,zx_bofang
        _stateImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"zx_zanting"]];
        _stateImgView.frame = CGRectMake(ZXWidth(6), ZXWidth(8), ZXWidth(30), ZXWidth(34));
        _stateImgView.userInteractionEnabled = YES;
    }
    return _stateImgView;
}

- (CALayer *)totalProgressLayer {
    if (!_totalProgressLayer) {
        _totalProgressLayer = [CALayer layer];
        _totalProgressLayer.backgroundColor = HexRGB(0xd7d9db).CGColor;
        _totalProgressLayer.frame = CGRectMake(ZXWidth(42), ZXWidth(23), kTotalProgressLength, ZXWidth(4));
        _totalProgressLayer.cornerRadius = 2;
    }
    return _totalProgressLayer;
}

- (CALayer *)downloadProgressLayer {
    if (!_downloadProgressLayer) {
        _downloadProgressLayer = [CALayer layer];
        _downloadProgressLayer.backgroundColor = HexRGB(0xc3c3c4).CGColor;
        _downloadProgressLayer.frame = CGRectMake(ZXWidth(42), ZXWidth(23), kTotalProgressLength * 0, ZXWidth(4));
        _downloadProgressLayer.cornerRadius = 2;
    }
    return _downloadProgressLayer;
}

- (CALayer *)playProgressLayer {
    if (!_playProgressLayer) {
        _playProgressLayer = [CALayer layer];
        _playProgressLayer.backgroundColor = HexRGB(0x987de6).CGColor;
        _playProgressLayer.frame = CGRectMake(ZXWidth(42), ZXWidth(23), kTotalProgressLength * 0, ZXWidth(4));
        _playProgressLayer.cornerRadius = 2;
    }
    return _playProgressLayer;
}

- (UILabel *)currentTime {
    if (!_currentTime) {
        _currentTime = [[UILabel alloc]initWithFrame:CGRectMake(ZXWidth(42), ZXWidth(29), ZXWidth(50), ZXWidth(10))];
        _currentTime.textAlignment = NSTextAlignmentLeft;
        //_currentTime.text = @"--:--";
        _currentTime.text = @"00:00";
        _currentTime.font = [UIFont systemFontOfSize:10];
        _currentTime.textColor = HexRGB(0x535353);
    }
    return _currentTime;
}

- (UILabel *)totalTime {
    if (!_totalTime) {
        _totalTime = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - ZXWidth(87), ZXWidth(29), ZXWidth(50), ZXWidth(10))];
        _totalTime.textAlignment = NSTextAlignmentRight;
        //_totalTime.text = @"--:--";
        _totalTime.text = @"--:--";
        _totalTime.textColor = HexRGB(0x535353);
        _totalTime.font = [UIFont systemFontOfSize:10];
    }
    return _totalTime;
}

- (void)tapAction:(UITapGestureRecognizer *)ges {
    CGPoint point = [ges locationInView:self];
    //响应控制条的显示与否
    if ((point.y < self.frame.size.height - ZXWidth(60)) || (point.y > self.frame.size.height - ZXWidth(10))) {
        //没有显示过则不支持点击切换状态
        if (!self.canResponseTap) {
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            if (!self.isControlBarShowing) {
                self.controlBar.alpha = 1;
                self.isControlBarShowing = YES;
            } else {
                self.controlBar.alpha = 0;
                self.isControlBarShowing = NO;
            }
        }];
    } else {
        //处理暂停播放等
        if (point.x < ZXWidth(50) && self.isControlBarShowing) {
            [self prepareToPlay];
        }
    }
}

- (void)prepareToPlay {
    if (self.isPlaying) {
        //想要暂停
        if (self.delegate) {
            [self.delegate prepareToPlay:NO];
        }
    } else {
        //想要播放
        if (self.delegate) {
            [self.delegate prepareToPlay:YES];
        }
    }
}

- (void)buffering {
    NSLog(@"buffering");
    self.isPlaying = NO;
    [ZXGCDQueue executeInMainQueue:^{
        [self bringSubviewToFront:self.indicatorView];
        [self.indicatorView startAnimating];
    }];
}

- (void)play {
    NSLog(@"play");
    self.isPlaying = YES;
    self.canResponseTap = YES;
    [ZXGCDQueue executeInMainQueue:^{
        [self.indicatorView stopAnimating];
        self.stateImgView.image = [UIImage imageNamed:@"zx_zanting"];
        [UIView animateWithDuration:0.2 animations:^{
            self.backGroundImgView.alpha = 0.0;
            self.controlBar.alpha = 1.0;
            self.isControlBarShowing = YES;
        }];
        [self bringSubviewToFront:self.controlBar];
    }];
}

- (void)pause {
    NSLog(@"pause");
    self.isPlaying = NO;
    
    [ZXGCDQueue executeInMainQueue:^{
        [self.indicatorView stopAnimating];
        self.stateImgView.image = [UIImage imageNamed:@"zx_bofang"];
        [self bringSubviewToFront:self.controlBar];
        [UIView animateWithDuration:0.2 animations:^{
            self.controlBar.alpha = 1;
            self.isControlBarShowing = YES;
        }];
    }];
}

- (void)updateDownloadProgress:(CGFloat)progress {
    float newWidth = progress>1?kTotalProgressLength:kTotalProgressLength*progress;
    CGRect originRect = self.downloadProgressLayer.frame;
    [ZXGCDQueue executeInMainQueue:^{
        self.downloadProgressLayer.frame = CGRectMake(originRect.origin.x, originRect.origin.y, newWidth, originRect.size.height);
    }];
}

- (void)updatePlayProcessSeconds:(CGFloat)seconds {
    [ZXGCDQueue executeInMainQueue:^{
        self.currentTime.text = [ZXUtils stringBySeconds:seconds];
    }];
    if (self.totalSeconds > 0) {
        float progress = seconds/self.totalSeconds;
        if (progress > 1) {
            progress = 1;
        }
        float newWidth = kTotalProgressLength*progress;
        CGRect originRect = self.playProgressLayer.frame;
        [ZXGCDQueue executeInMainQueue:^{
            self.playProgressLayer.frame = CGRectMake(originRect.origin.x, originRect.origin.y, newWidth, originRect.size.height);
        }];
    }
}

- (void)updateTotalSeconds:(CGFloat)seconds {
    self.totalSeconds = seconds;
    [ZXGCDQueue executeInMainQueue:^{
        self.totalTime.text = [ZXUtils stringBySeconds:seconds];
    }];
}

@end
