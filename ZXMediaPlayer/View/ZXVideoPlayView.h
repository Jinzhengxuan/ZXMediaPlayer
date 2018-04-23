//
//  ZXVideoPlayView.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/30.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZXVideoPlayViewDelegate<NSObject>

@required
- (void)prepareToPlay:(BOOL)isPlay;

@end

@interface ZXVideoPlayView : UIView

@property (nonatomic, weak) id<ZXVideoPlayViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame imageURL:(NSURL *)imageURL;

- (void)buffering;

- (void)play;

- (void)pause;

- (void)updateDownloadProgress:(CGFloat)progress;

- (void)updatePlayProcessSeconds:(CGFloat)seconds;

- (void)updateTotalSeconds:(CGFloat)seconds;

@end
