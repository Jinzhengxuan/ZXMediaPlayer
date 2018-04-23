//
//  ZXMediaPlayer.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/9.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXMediaInfoModel.h"

@interface ZXMediaPlayer : NSObject

@property (nonatomic, assign) ZXMediaPlayerState state;
@property (nonatomic, strong) ZXMediaInfoModel *mediaInfo;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) BOOL isPauseByUser; //是否被用户暂停
@property (nonatomic, assign) CGFloat currentProgress;//当前播放进度

@property (nonatomic, strong) AVURLAsset *asset;//媒体资源
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/**
 播放方法

 @param mediaInfo 媒体信息
 */
- (void)playWithMediaInfo:(ZXMediaInfoModel *)mediaInfo;

/**
 继续播放
 */
- (void)resume;

/**
 暂停播放
 */
- (void)pause;

/**
 停止播放
 */
- (void)stop;

/**
 跳转到进度

 @param seconds 对应的秒
 */
- (void)seekToTime:(CGFloat)seconds;

/**
 更新音量

 @param volume 0~1
 */
- (void)setVolume:(CGFloat)volume;

@end
