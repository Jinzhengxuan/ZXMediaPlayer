//
//  ZXMediaPlayer.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/8/15.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXMediaPlayManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ZXDBUtil.h"
#import "ZXMediaPlayer.h"
#import "ZXShowAlert.h"
#import "ZXVideoPlayView.h"
#import "ZXConfig.h"

NSString * const kZXMediaPlayerStateChangedNotification = @"kZXMediaPlayerStateChangedNotification";
NSString * const kZXMediaPlayerPlayProgressNotification = @"kZXMediaPlayerPlayProgressNotification";//播放进度，秒
NSString * const kZXMediaPlayerPlayToEndNotification = @"kZXMediaPlayerPlayToEndNotification";//播放完成
NSString * const kZXMediaPlayerTotalTimeNotification = @"kZXMediaPlayerTotalTimeNotification";
NSString * const kZXMediaPlayerDownloadProgressNotification = @"kZXMediaPlayerDownloadProgressNotification";
NSString * const kZXMediaPlayerRemoteControlNotification = @"kZXMediaPlayerRemoteControlNotification";

@interface ZXMediaPlayer ()<AVAssetResourceLoaderDelegate, ZXVideoPlayViewDelegate>

@property (nonatomic, assign) CGFloat loadedProgress;//缓冲进度
@property (nonatomic, assign) CGFloat duration;//视频总时间

@property (nonatomic, strong) NSObject *playbackTimeObserver;

@property (nonatomic, assign) BOOL isLocalFile;
@property (nonatomic, assign) BOOL neverStarted;

@property (nonatomic, strong) ZXVideoPlayView *videoPlayView;

@end

@implementation ZXMediaPlayer

#pragma mark - public functions

- (void)dealloc {
    if (self.videoPlayView) {
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
    }
    NSLog(@"ZXMediaPlayer[%@] dealloced", self.url);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isPauseByUser = NO;
        _loadedProgress = 0;
        _duration = 0;
        _currentProgress  = 0;
        _state = ZXMediaPlayerStateInit;
        _neverStarted = YES;
    }
    return self;
}

/**
 播放方法
 
 @param mediaInfo 媒体信息
 */
- (void)playWithMediaInfo:(ZXMediaInfoModel *)mediaInfo {
    [self.player pause];
    [self releasePlayer];
    self.isPauseByUser = NO;
    self.loadedProgress = 0;
    self.duration = 0;
    self.currentProgress  = 0;
    self.state = ZXMediaPlayerStateInit;
    self.mediaInfo = mediaInfo;
    self.isLocalFile = NO;
    
    if (!self.mediaInfo.mediaURL.scheme) {
        if (!self.mediaInfo.mediaURL) {
            return;
        }
        self.url = [NSURL fileURLWithPath:self.mediaInfo.mediaURL.absoluteString];
    } else {
        self.url = self.mediaInfo.mediaURL;
    }
    if ([ZXMediaPlayManager.sharedInstance isCacheExisted:self.url]) {
        self.isLocalFile = YES;
        NSString *filePathString = [ZXMediaPlayManager.sharedInstance cachePathWithURL:self.url];
        filePathString = [filePathString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *url = [NSURL fileURLWithPath:filePathString];
        self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
        [self.asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    } else {
        if (self.mediaInfo.playVideoView) {
            [self.videoPlayView removeFromSuperview];
            self.videoPlayView = nil;
            
            self.videoPlayView = [[ZXVideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.mediaInfo.playVideoView.frame.size.width, self.mediaInfo.playVideoView.frame.size.height) imageURL:self.mediaInfo.cover_imageURL];
            self.videoPlayView.delegate = self;
            [self.mediaInfo.playVideoView addSubview:self.videoPlayView];
        }
        
        WEAKIFY_SELF
        [ZXShowAlert showWWANWarningWithAction:^(BOOL isConfirm) {
            STRONGIFY_SELF
            if (isConfirm) {
                strong_self.asset = [AVURLAsset URLAssetWithURL:strong_self.url options:nil];
                [strong_self.asset.resourceLoader setDelegate:strong_self queue:dispatch_get_main_queue()];
                strong_self.playerItem = [AVPlayerItem playerItemWithAsset:strong_self.asset];
                
                if (!strong_self.player) {
                    strong_self.player = [[AVPlayer alloc]initWithPlayerItem:strong_self.playerItem];
                } else {
                    [strong_self.player replaceCurrentItemWithPlayerItem:strong_self.playerItem];
                }
                
                if (strong_self.mediaInfo.playVideoView) {
                    strong_self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:strong_self.player];
                    strong_self.playerLayer.frame = CGRectMake(0, 0, strong_self.mediaInfo.playVideoView.frame.size.width, strong_self.mediaInfo.playVideoView.frame.size.height);
                    strong_self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                    [strong_self.mediaInfo.playVideoView.layer addSublayer:strong_self.playerLayer];
                    [strong_self.mediaInfo.playVideoView bringSubviewToFront:strong_self.videoPlayView];
                    [strong_self.videoPlayView buffering];
                }
                
                strong_self.player.volume = strong_self.mediaInfo.volume;
                
                [strong_self.playerItem addObserver:strong_self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                [strong_self.playerItem addObserver:strong_self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
                [strong_self.playerItem addObserver:strong_self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
                [strong_self.playerItem addObserver:strong_self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:strong_self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:strong_self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
                
                strong_self.state = ZXMediaPlayerStateBuffering;
            } else {
                strong_self.state = ZXMediaPlayerStateStopped;
            }
        }];
        return;
    }
    
    if (!self.player) {
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    
    if (self.mediaInfo.playVideoView) {
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = CGRectMake(0, 0, self.mediaInfo.playVideoView.frame.size.width, self.mediaInfo.playVideoView.frame.size.height);
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.mediaInfo.playVideoView.layer addSublayer:self.playerLayer];
        
        self.videoPlayView = [[ZXVideoPlayView alloc]initWithFrame:CGRectMake(0, 0, self.mediaInfo.playVideoView.frame.size.width, self.mediaInfo.playVideoView.frame.size.height) imageURL:self.mediaInfo.cover_imageURL];
        [self.mediaInfo.playVideoView addSubview:self.videoPlayView];
        [self.mediaInfo.playVideoView bringSubviewToFront:self.videoPlayView];
        self.videoPlayView.delegate = self;
    }
    
    self.player.volume = self.mediaInfo.volume;
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    
    self.state = ZXMediaPlayerStatePlaying;
    [self.player play];
}

- (void)resume {
    if (!self.playerItem) {
        return;
    }
    NSLog(@"恢复播放:%@", self.url);
    self.isPauseByUser = NO;
    self.state = ZXMediaPlayerStatePlaying;
    [self.player play];
}

- (void)pause {
    if (!self.playerItem) {
        return;
    }
    NSLog(@"暂停播放:%@", self.url);
    self.isPauseByUser = YES;
    self.state = ZXMediaPlayerStatePause;
    [self.player pause];
}

- (void)stop {
    NSLog(@"停止播放:%@", self.url);
    self.isPauseByUser = YES;
    self.loadedProgress = 0;
    self.duration = 0;
    self.currentProgress  = 0;
    self.state = ZXMediaPlayerStateStopped;
    self.url = nil;
    [self.player pause];
    [self releasePlayer];
    if (self.videoPlayView) {
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
    }
}

- (void)seekToTime:(CGFloat)seconds {
    if (self.state == ZXMediaPlayerStateStopped) {
        return;
    }
    
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.duration);
    if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        NSLog(@"未准备好，不支持拖动进度");
        return;
    }
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        self.isPauseByUser = NO;
        
        self.state = ZXMediaPlayerStatePlaying;
        [self.player play];
    }];
}

#pragma mark - mark ZXVideoPlayViewDelegate

- (void)prepareToPlay:(BOOL)isPlay {
    if (isPlay) {
        if (self.state == ZXMediaPlayerStatePause) {
            [self resume];
        } else {
            [self playWithMediaInfo:self.mediaInfo];
        }
    } else {
        [self pause];
    }
}

#pragma mark - private functions

- (void)setState:(ZXMediaPlayerState)state {
    if (_state != state) {
        _state = state;
        if (self.url && self.url.absoluteString && state != ZXMediaPlayerStateInit) {
            [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerStateChangedNotification object:@{@"url":self.url.absoluteString, @"state":[NSNumber numberWithInteger:self.state], @"additionalIndex":[NSNumber numberWithInteger:self.mediaInfo.additionalIndex]}];
        }
    }
    if (self.videoPlayView) {
        if (_state == ZXMediaPlayerStateBuffering) {
            [self.videoPlayView buffering];
        } else if (_state == ZXMediaPlayerStatePlaying) {
            [self.videoPlayView play];
        } else {
            [self.videoPlayView pause];
        }
    }
}

- (void)setVolume:(CGFloat)volume {
    self.player.volume = volume;
}

- (void)releasePlayer {
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        self.playerItem = nil;
    }
    if (self.playerLayer) {
        self.playerLayer = nil;
    }
    if (self.player) {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
        self.player = nil;
    }
    if (self.videoPlayView) {
        [self.videoPlayView pause];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    NSLog(@"monitoringPlayback");
    float d = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    if (d != self.duration) {
        self.duration = d;
        [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerTotalTimeNotification object:@{@"url":self.url.absoluteString, @"duration":[NSNumber numberWithFloat:self.duration], @"additionalIndex":[NSNumber numberWithInteger:self.mediaInfo.additionalIndex]}];
        if (self.videoPlayView) {
            [self.videoPlayView updateTotalSeconds:d];
        }
    }
    
    if (!self.isPauseByUser) {
        self.state = ZXMediaPlayerStatePlaying;
        [self.player play];
    }
    
    WEAKIFY_SELF
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        STRONGIFY_SELF
        CGFloat current = playerItem.currentTime.value/playerItem.currentTime.timescale;
        strong_self.currentProgress = current;
        //防止崩溃
        if (strong_self.url.absoluteString) {
            [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerPlayProgressNotification object:@{@"url":strong_self.url.absoluteString, @"progressFloat":@(current), @"duration":[NSNumber numberWithFloat:strong_self.duration], @"additionalIndex":[NSNumber numberWithInteger:strong_self.mediaInfo.additionalIndex]}];
        }
        if (strong_self.videoPlayView) {
            [strong_self.videoPlayView updatePlayProcessSeconds:current];
        }
    }];
}

/**
 监控下载状态
 
 @param playerItem item
 */
- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem {
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    CGFloat timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    self.loadedProgress = MAX(timeInterval/totalDuration, self.loadedProgress);
    NSString *pString = [NSString stringWithFormat:@"%.2f", timeInterval];
    NSString *tString = [NSString stringWithFormat:@"%.2f", totalDuration];
    //1.01是保护只能进一次保存流程
    if ([pString isEqualToString:tString] && self.loadedProgress < 1.01) {
        [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerDownloadProgressNotification object:@{@"url":self.url.absoluteString, @"progress":[NSNumber numberWithFloat:1.0], @"additionalIndex":[NSNumber numberWithInteger:self.mediaInfo.additionalIndex]}];
        self.loadedProgress = 1.01;
        [self saveFileToCache];
    } else if (self.loadedProgress < 1.0) {
        [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerDownloadProgressNotification object:@{@"url":self.url.absoluteString, @"progress":[NSNumber numberWithFloat:self.loadedProgress], @"additionalIndex":[NSNumber numberWithInteger:self.mediaInfo.additionalIndex]}];
    }
    if (self.videoPlayView) {
        [self.videoPlayView updateDownloadProgress:self.loadedProgress];
    }
}

/**
 监控播放器状态等
 
 @param keyPath keyPath
 @param object object
 @param change change
 @param context context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self monitoringPlayback:playerItem];// 给播放器添加计时器
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self stop];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        [self calculateDownloadProgress:playerItem];
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //缓存状态，转loading
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = ZXMediaPlayerStateBuffering;
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        //缓存完成，隐藏loading等
        if (playerItem.isPlaybackLikelyToKeepUp) {
            if (_neverStarted) {
                _neverStarted = NO;
                if (self.mediaInfo.startSecond == 0) {
                    self.state = ZXMediaPlayerStatePlaying;
                    [self.player play];
                } else {
                    [self.player seekToTime:CMTimeMakeWithSeconds(self.mediaInfo.startSecond, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                        self.isPauseByUser = NO;
                        //未缓冲完则置为缓冲状态
                        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
                            self.state = ZXMediaPlayerStateBuffering;
                        } else {
                            self.state = ZXMediaPlayerStatePlaying;
                            [self.player play];
                        }
                    }];
                }
            }
        }
    } else {
        
    }
}

/**
 播放完毕
 
 @param notification notification
 */
- (void)playerItemDidPlayToEnd:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerPlayToEndNotification object:@{@"url":self.url.absoluteString, @"additionalIndex":[NSNumber numberWithInteger:self.mediaInfo.additionalIndex]}];
    self.isPauseByUser = YES;
    self.loadedProgress = 0;
    self.currentProgress  = 0;
    self.state = ZXMediaPlayerStateStopped;
    [self.player pause];
    [self releasePlayer];
    NSLog(@"播放完成，停止播放:%@", self.url);
}

/**
 异常中断
 
 @param notification notification
 */
- (void)playerItemPlaybackStalled:(NSNotification *)notification {
    [ZXShowAlert showNetworkUnreachable];
    [self pause];
}

/**
 保存缓存到文件系统
 */
- (void)saveFileToCache {
    //非本地文件需要把缓存保存下
    if (!self.isLocalFile) {
        NSArray *parts = [self.url.absoluteString componentsSeparatedByString:@"/"];
        NSString *suggestedFilename = [parts lastObject];
        suggestedFilename = [suggestedFilename stringByReplacingOccurrencesOfString:@"mp3" withString:@"m4a"];
        suggestedFilename = [suggestedFilename stringByReplacingOccurrencesOfString:@"wav" withString:@"mp4"];
        suggestedFilename = [suggestedFilename stringByReplacingOccurrencesOfString:@"amr" withString:@"amr"];
        
        NSString *cacheDict = [ZXDBUtil cacheDirectory];
        
        NSURL *outputURL = [NSURL URLWithString:suggestedFilename relativeToURL:[NSURL fileURLWithPath:cacheDict isDirectory:YES]];
        
        NSLog(@"outputURL : %@", outputURL.absoluteString);
        NSString *temp = [outputURL.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        if ([NSFileManager.defaultManager fileExistsAtPath:temp]) {
            NSError *fileDeleteError;
            if (![NSFileManager.defaultManager removeItemAtPath:temp error:&fileDeleteError]) {
                NSLog(@"删除历史文件错误：%@", fileDeleteError);
            } else {
                NSLog(@"删除历史文件成功");
                [self doExportWithOutputURL:outputURL];
            }
        } else {
            [self doExportWithOutputURL:outputURL];
        }
    }
}

- (void)doExportWithOutputURL:(NSURL *)outputURL {
    //下载完成，导出到缓存目录中
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    WEAKIFY_SELF
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        STRONGIFY_SELF
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"导出成功");
            NSString *fileName = [ZXDBUtil fileNameWithPath:outputURL.absoluteString];
            [ZXMediaPlayManager.sharedInstance indexCacheFileWithURL:strong_self.url fileName:fileName];
        } else if (exportSession.status == AVAssetExportSessionStatusCancelled) {
            NSLog(@"导出被取消");
        } else {
            NSLog(@"导出失败:%@", exportSession.error);
        }
    }];
}

@end

