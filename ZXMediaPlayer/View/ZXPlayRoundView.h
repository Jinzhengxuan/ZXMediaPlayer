//
//  ZXPlayRoundView.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/30.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZXPlayRoundViewDelegate <NSObject>

/**
 点击播放按钮，准备播放

 @param isPlaying 是播放或暂停
 @return 是否准备好了可以播放
 */
- (BOOL)prepareToPlay:(BOOL)isPlaying;

@end

@interface ZXPlayRoundView : UIView

@property (weak, nonatomic) id<ZXPlayRoundViewDelegate> delegate;

/// 中心图像
@property (strong, nonatomic) UIImage *roundImage;

/// 是否播放
@property (assign, nonatomic, readonly) BOOL isPlaying;

/// 继续播放
- (void)play;

/// 暂停
- (void)pause;

/// 缓冲中
- (void)buffering;

@end
