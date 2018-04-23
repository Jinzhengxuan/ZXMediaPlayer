//
//  ZXMediaPlayManager.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/8/31.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXMediaPlayManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZXDBUtil.h"
#import "ZXMediaPlayer.h"
#import "ZXShowAlert.h"
#import "ZXReachAbility.h"
#import "ZXGCD.h"
#import "NSString+ZXUtil.h"
#import "UIImageView+ZXWebImage.h"
#import "ZXConfig.h"
#import "ZXWebImage.h"
#import "UIImage+ZXUtil.h"

@interface ZXMediaPlayManager ()

@property (nonatomic, strong, readwrite) NSArray <ZXMediaInfoModel *> *infoList;
@property (nonatomic, strong, readwrite) ZXMediaControlModel *mediaControlInfo;
@property (nonatomic, assign, readwrite) NSInteger playIndex;//当前index
@property (nonatomic, strong, readwrite) NSDictionary *totalTimeDict;
@property (nonatomic, strong, readwrite) NSURL *currentScreenImageUrl;
@property (nonatomic, strong, readwrite) UIImage *screenImage;

@property (nonatomic, strong, readwrite) NSMutableArray <ZXMediaPlayer *> *mediaPlayerList;

@end

@implementation ZXMediaPlayManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ZXMediaPlayManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[super alloc]initUniqueInstance];
    });
    return instance;
}

- (instancetype)initUniqueInstance {
    if (self = [super init]) {

    }
    return self;
}

- (NSMutableArray <ZXMediaPlayer *>*)mediaPlayerList {
    if (!_mediaPlayerList) {
        _mediaPlayerList = [NSMutableArray array];
    }
    return _mediaPlayerList;
}

/**
 进行播放

 @param infoList 播放列表
 @param controlInfo 控制信息
 */
- (void)playWithInfoList:(NSArray <ZXMediaInfoModel *>*)infoList controlInfo:(ZXMediaControlModel *)controlInfo {
    [self releasePlayers];

    self.infoList = infoList;
    self.mediaControlInfo = controlInfo;
    self.playIndex = controlInfo.startIndex;

    [self setAudioSession];
    [self initSystem];

    switch (controlInfo.playMode) {
        case ZXMediaPlayMode_Order:
        {
            if (!infoList || infoList.count == 0) {
                NSLog(@"param error");
                return;
            }
            if ((controlInfo.startIndex+1) > infoList.count || controlInfo.startIndex < 0) {
                NSLog(@"param startIndex error");
                return;
            }
            ZXMediaInfoModel *info = infoList[controlInfo.startIndex];
            ZXMediaPlayer *player = [[ZXMediaPlayer alloc]init];
            [self.mediaPlayerList addObject:player];
            [player playWithMediaInfo:info];
            break;
        }
        case ZXMediaPlayMode_Together:
        {
            if (!infoList || infoList.count == 0) {
                NSLog(@"param error");
                return;
            }
            for (ZXMediaInfoModel *info in infoList) {
                ZXMediaPlayer *player = [[ZXMediaPlayer alloc]init];
                [self.mediaPlayerList addObject:player];
                [player playWithMediaInfo:info];
            }
            break;
        }
        case ZXMediaPlayMode_Random:
        {
            if (!infoList || infoList.count == 0) {
                NSLog(@"param error");
                return;
            }
            if ((controlInfo.startIndex+1) > infoList.count || controlInfo.startIndex < 0) {
                NSLog(@"param startIndex error");
                return;
            }
            ZXMediaInfoModel *info = infoList[controlInfo.startIndex];
            ZXMediaPlayer *player = [[ZXMediaPlayer alloc]init];
            [self.mediaPlayerList addObject:player];
            [player playWithMediaInfo:info];
            break;
        }
        case ZXMediaPlayMode_Single:
        {
            if (!infoList || infoList.count == 0) {
                NSLog(@"param error");
                return;
            }
            if ((controlInfo.startIndex+1) > infoList.count || controlInfo.startIndex < 0) {
                NSLog(@"param startIndex error");
                return;
            }
            ZXMediaInfoModel *info = infoList[controlInfo.startIndex];
            ZXMediaPlayer *player = [[ZXMediaPlayer alloc]init];
            [self.mediaPlayerList addObject:player];
            [player playWithMediaInfo:info];
            break;
        }
        case ZXMediaPlayMode_SingleCircle:
        {
            if (!infoList || infoList.count == 0) {
                NSLog(@"param error");
                return;
            }
            if ((controlInfo.startIndex+1) > infoList.count || controlInfo.startIndex < 0) {
                NSLog(@"param startIndex error");
                return;
            }
            ZXMediaInfoModel *info = infoList[controlInfo.startIndex];
            ZXMediaPlayer *player = [[ZXMediaPlayer alloc]init];
            [self.mediaPlayerList addObject:player];
            [player playWithMediaInfo:info];
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)setPlayMode:(ZXMediaPlayMode)playMode {
    self.mediaControlInfo.playMode = playMode;
}

- (ZXMediaPlayerState)stateWithURL:(NSURL *)url {
    for (ZXMediaPlayer *player in self.mediaPlayerList) {
        if ([player.mediaInfo.mediaURL.absoluteString isEqualToString:url.absoluteString]) {
            return player.state;
        }
    }

    return 0;
}

/**
 返回当前播放音频的附加index
 如果返回结果跟预期不一样，则不要使用url作为key进行查询或处理

 @return 当前播放音频的附加index，提供给任务接口判断多个相同url的情况
 */
- (NSInteger)currentAdditionalIndex {
    if (self.mediaPlayerList.count != 1) {
        return -1;
    }
    return self.mediaPlayerList[0].mediaInfo.additionalIndex;
}

- (void)initSystem {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mediaPlayerChanged:) name:kZXMediaPlayerStateChangedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(totalTimeChanged:) name:kZXMediaPlayerTotalTimeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playProgressChanged:) name:kZXMediaPlayerPlayProgressNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleInterrupt:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(routeChangeInterrupt:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if (self.mediaControlInfo.supportBackGroundPlay) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    [self createRemoteCommandCenter];
}

- (void)setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    NSError *setCategoryError = nil;
    BOOL success = NO;
    if (self.mediaControlInfo.supportBackGroundPlay) {
        if (self.mediaControlInfo.supportRecordCategory) {
            success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker  error:&setCategoryError];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        } else {
            success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        }
        if (!success) {
            NSLog(@"setCategory failure:%@", setCategoryError);
        }
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success) {
            NSLog(@"setActive failure:%@", activationError);
        }
    } else {
        success = [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&setCategoryError];
        if (!success) {
            NSLog(@"setCategory failure:%@", setCategoryError);
        }
        NSError *activationError = nil;
        success = [audioSession setActive:NO error:&activationError];
        if (!success) {
            NSLog(@"setActive failure:%@", activationError);
        }
    }
}

- (void)pauseWithURL:(NSURL *)url {
    ZXMediaPlayer *player = [self playerWithURL:url];
    if (player) {
        [player pause];
    }
}

- (void)resumeWithURL:(NSURL *)url {
    ZXMediaPlayer *player = [self playerWithURL:url];
    if (!player) {
        return;
    }
    if (player.state == ZXMediaPlayerStateStopped || player.state == 0) {
        for (ZXMediaInfoModel *info in self.infoList) {
            if ([info.mediaURL.absoluteString isEqualToString:url.absoluteString]) {
                [player playWithMediaInfo:info];
                return;
            }
        }
    } else {
        [player resume];
    }
}

- (void)stopWithURL:(NSURL *)url {
    ZXMediaPlayer *player = [self playerWithURL:url];
    if (player) {
        [player stop];
    }
}

- (void)seekToTimeWithURL:(NSURL *)url seconds:(CGFloat)seconds {
    ZXMediaPlayer *player = [self playerWithURL:url];
    if (player) {
        [player seekToTime:seconds];
    }
}

/**
 下一首
 同时播放模式不会进入这里
 */
- (NSInteger)next {
    if (self.mediaControlInfo.playMode == ZXMediaPlayMode_Random) {
        return [self random];
    }
    if (self.mediaControlInfo.playMode == ZXMediaPlayMode_Single) {
        [self single];
        return self.playIndex;
    }
    if (self.mediaPlayerList.count == 0) {
        return -1;
    }
    __block ZXMediaPlayer *currentPlayer = self.mediaPlayerList[0];
    [currentPlayer stop];
    NSInteger tmp = self.playIndex;
    if (self.playIndex < self.infoList.count - 1) {
        tmp += 1;
    } else {
        tmp = 0;
    }
    ZXMediaInfoModel *info = self.infoList[tmp];
    if ([ZXReachAbility isWWANConnected]) {
        //锁屏了则不提示，直接重播；没锁屏则提示，确认后再继续
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            //隐藏可能存在的弹框
            [ZXShowAlert dismiss];
            //此时不切歌播放，需要重播之前的歌曲
            info = self.infoList[self.playIndex];
            [currentPlayer playWithMediaInfo:info];
            return self.playIndex;
        } else {
            self.playIndex = tmp;
            //如果在前台，则进行确认
            if (![self isCacheExisted:info.mediaURL]) {
                [ZXShowAlert showWWANWarningWithAction:^(BOOL isConfirm) {
                    if (isConfirm) {
                        [currentPlayer playWithMediaInfo:info];
                    } else {
                        [currentPlayer stop];
                    }
                }];
            } else {
                [currentPlayer playWithMediaInfo:info];
            }
            return self.playIndex;
        }
    }
    self.playIndex = tmp;
    [currentPlayer playWithMediaInfo:info];
    return self.playIndex;
}

/**
 上一首
 */
- (NSInteger)prev {
    if (self.mediaControlInfo.playMode == ZXMediaPlayMode_Random) {
        return [self random];
    }
    if (self.mediaControlInfo.playMode == ZXMediaPlayMode_Single) {
        [self single];
        return self.playIndex;
    }
    ZXMediaPlayer *currentPlayer = self.mediaPlayerList[0];
    [currentPlayer stop];
    NSInteger tmp = self.playIndex;
    if (self.playIndex > 0) {
        tmp -= 1;
    } else {
        tmp = self.infoList.count - 1;
    }
    ZXMediaInfoModel *info = self.infoList[tmp];
    if ([ZXReachAbility isWWANConnected]) {
        //锁屏了则不提示，直接重播；没锁屏则提示，确认后再继续
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            //隐藏可能存在的弹框
            [ZXShowAlert dismiss];
            //此时不切歌播放，需要重播之前的歌曲
            info = self.infoList[self.playIndex];
            [currentPlayer playWithMediaInfo:info];
            return self.playIndex;
        } else {
            //如果在前台，则进行确认
            self.playIndex = tmp;
            if (![self isCacheExisted:info.mediaURL]) {
                [ZXShowAlert showWWANWarningWithAction:^(BOOL isConfirm) {
                    if (isConfirm) {
                        [currentPlayer playWithMediaInfo:info];
                    } else {
                        [currentPlayer stop];
                    }
                }];
            } else {
                [currentPlayer playWithMediaInfo:info];
            }
            return self.playIndex;
        }
    }
    self.playIndex = tmp;
    [currentPlayer playWithMediaInfo:info];
    return self.playIndex;
}

/**
 随机一首
 */
- (NSInteger)random {
    if (self.mediaPlayerList.count == 0) {
        return -1;
    }
    ZXMediaPlayer *currentPlayer = self.mediaPlayerList[0];
    [currentPlayer stop];
    NSInteger tmp = arc4random() % self.infoList.count;
    ZXMediaInfoModel *info = self.infoList[tmp];
    if ([ZXReachAbility isWWANConnected]) {
        //锁屏了则不提示，直接重播；没锁屏则提示，确认后再继续
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            //隐藏可能存在的弹框
            [ZXShowAlert dismiss];
            //此时不切歌播放，需要重播之前的歌曲
            info = self.infoList[self.playIndex];
            [currentPlayer playWithMediaInfo:info];
            return self.playIndex;
        } else {
            //如果在前台，则进行确认
            self.playIndex = tmp;
            if (![self isCacheExisted:info.mediaURL]) {
                [ZXShowAlert showWWANWarningWithAction:^(BOOL isConfirm) {
                    if (isConfirm) {
                        [currentPlayer playWithMediaInfo:info];
                    } else {
                        [currentPlayer stop];
                    }
                }];
            } else {
                [currentPlayer playWithMediaInfo:info];
            }
            return self.playIndex;
        }
    }
    self.playIndex = tmp;
    [currentPlayer playWithMediaInfo:info];
    return self.playIndex;
}

/**
 单曲循环
 */
- (void)single {
    if (self.mediaPlayerList && self.mediaPlayerList.count > 0) {
        ZXMediaPlayer *currentPlayer = self.mediaPlayerList[0];
        ZXMediaInfoModel *info = self.infoList[self.playIndex];
        [currentPlayer playWithMediaInfo:info];
    }
}

/**
 更新音量

 @param url 链接
 @param volume 0~1
 */
- (void)setVolumeWithURL:(NSURL *)url volumn:(CGFloat)volume {
    for (ZXMediaPlayer *player in self.mediaPlayerList) {
        if ([player.mediaInfo.mediaURL.absoluteString isEqualToString:url.absoluteString]) {
            [player setVolume:volume];
            return;
        }
    }
}

/**
 需要判断是本地文件还是远程文件，如果是本地文件，直接使用即可

 @param url url
 @return 是否存在
 */
- (BOOL)isCacheExisted:(NSURL *)url {
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    if ([actualURLComponents.scheme isEqualToString:@"file"]) {
        if ([NSFileManager.defaultManager fileExistsAtPath:url.path]) {
            //保存到cache目录
            if ([ZXDBUtil copyFileToCacheDictWithPath:url.path]) {
                //插入数据库
                NSString *recordName = [ZXDBUtil queryDBRecordWithURL:url.absoluteString];
                NSString *fileName = [ZXDBUtil fileNameWithPath:url.path];
                if (!recordName) {
                    [ZXDBUtil insertDBRecordWithURL:url.absoluteString cacheName:fileName];
                }

                return YES;
            }
        }
        return NO;
    } else {
        actualURLComponents.scheme = @"http";

        NSString *recordName = [ZXDBUtil queryDBRecordWithURL:actualURLComponents.URL.absoluteString];
        if (recordName && recordName.length > 0) {
            NSString *originName = [ZXDBUtil fileNameWithPath:recordName];
            if (![originName isEqualToString:recordName]) {
                //不相同的情况需要先删除数据库，并重新插入
                [ZXDBUtil deleteDBRecordWithURL:actualURLComponents.URL.absoluteString];
                [ZXDBUtil insertDBRecordWithURL:actualURLComponents.URL.absoluteString cacheName:originName];
            }
            recordName = [[ZXDBUtil cacheDirectory]stringByAppendingString:originName];
            if ([NSFileManager.defaultManager fileExistsAtPath:recordName]) {
                return YES;
            }
        }
        [ZXDBUtil deleteDBRecordWithURL:actualURLComponents.URL.absoluteString];
        return NO;
    }
}

/**
 删除缓存文件
 
 @param url url
 */
- (void)removeCacheFile:(NSURL *)url {
    if (![self isCacheExisted:url]) {
        return;
    }
    NSString *path = [self cachePathWithURL:url];
    NSError *removeError = nil;
    [NSFileManager.defaultManager removeItemAtPath:path error:&removeError];
    if (removeError) {
        NSLog(@"removeCacheFile[%@] error:%@", url, removeError);
    }
}

- (void)indexCacheFileWithURL:(NSURL *)url fileName:(NSString *)fileName {
    if (!url) {
        return;
    }
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";

    [ZXDBUtil insertDBRecordWithURL:actualURLComponents.URL.absoluteString cacheName:fileName];
}

- (NSString *)cachePathWithURL:(NSURL *)url {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    if (![components.scheme isEqualToString:@"file"]) {
        components.scheme = @"http";
    }

    NSString *fileName = [ZXDBUtil queryDBRecordWithURL:components.URL.absoluteString];
    fileName = [[ZXDBUtil cacheDirectory]stringByAppendingString:fileName];
    if ([NSFileManager.defaultManager fileExistsAtPath:fileName]) {
        return fileName;
    } else {
        return nil;
    }
}

- (void)releasePlayers {
    for (ZXMediaPlayer *player in self.mediaPlayerList) {
        [player stop];
    }
    self.mediaPlayerList = nil;
    self.infoList = nil;
    [ZXDBUtil deleteModuleRecordWithModule:kGlobalAlertWhenDownloadByWWANResult];
}

- (ZXMediaPlayer *)playerWithURL:(NSURL *)url {
    if (self.mediaPlayerList.count == 1) {
        return self.mediaPlayerList[0];
    }
    for (ZXMediaPlayer *player in self.mediaPlayerList) {
        if ([player.url.absoluteString isEqualToString:url.absoluteString]) {
            return player;
        }
    }
    return nil;
}

/**
 获取远程资源时长
 
 @param urlStr 远程资源URL
 @return 时长秒
 */
- (float)fetchRemoteMediaTotalSeconds:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr.encodingStr];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    NSLog(@"fetchRemoteMediaTotalSeconds[%@] : %f", url.absoluteString, audioDurationSeconds);
    return audioDurationSeconds;
}

#pragma mark - Notification Handler

- (void)mediaPlayerChanged:(NSNotification *)notif {
    NSDictionary *dict = notif.object;
    NSString *url = (NSString *)dict[@"url"];
    NSNumber *state = (NSNumber *)dict[@"state"];
    switch (state.integerValue) {
        case ZXMediaPlayerStateBuffering:
        {
            NSLog(@"缓冲中[%@]", url);
            break;
        }
        case ZXMediaPlayerStatePlaying:
        {
            NSLog(@"播放中[%@]", url);
            for (ZXMediaInfoModel *model in self.infoList) {
                if ([model.mediaURL.absoluteString isEqualToString:url]) {
                    NSNumber *totalSeconds = [NSNumber numberWithFloat:0];
                    if (self.totalTimeDict) {
                        totalSeconds = (NSNumber *)self.totalTimeDict[@"duration"];
                    }
                    float progress = 0;
                    if (self.mediaPlayerList && self.mediaPlayerList.count > 0) {
                        progress = self.mediaPlayerList[0].currentProgress;
                    }
                    [self setLockScreenInfoWithImageUrl:model.cover_imageURL image:model.cover_image title:model.title artist:model.artist totalSeconds:totalSeconds.floatValue isPlaying:YES progress:progress];
                    break;
                }
            }
            break;
        }
        case ZXMediaPlayerStateStopped:
        {
            NSLog(@"已停止[%@]", url);
            //不止一个音乐则不显示进度
            if (self.mediaControlInfo.playMode == ZXMediaPlayMode_Together) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
                [dict setObject:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
            }
            break;
        }
        case ZXMediaPlayerStatePause:
        {
            NSLog(@"暂停中[%@]", url);
            for (ZXMediaInfoModel *model in self.infoList) {
                if ([model.mediaURL.absoluteString isEqualToString:url]) {
                    NSNumber *totalSeconds = [NSNumber numberWithFloat:0];
                    if (self.totalTimeDict) {
                        totalSeconds = (NSNumber *)self.totalTimeDict[@"duration"];
                    }
                    if (self.mediaPlayerList && self.mediaPlayerList.count > 0) {
                        [self setLockScreenInfoWithImageUrl:model.cover_imageURL image:model.cover_image title:model.title artist:model.artist totalSeconds:totalSeconds.floatValue isPlaying:NO progress:self.mediaPlayerList[0].currentProgress];
                    }
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)totalTimeChanged:(NSNotification *)notif {
    self.totalTimeDict = notif.object;
}

- (void)playProgressChanged:(NSNotification *)notif {
    NSDictionary *playProgressDict = notif.object;
    NSString *url = playProgressDict[@"url"];
    for (ZXMediaInfoModel *model in self.infoList) {
        if ([model.mediaURL.absoluteString isEqualToString:url]) {
            NSNumber *totalSeconds = [NSNumber numberWithFloat:0];
            if (self.totalTimeDict) {
                totalSeconds = (NSNumber *)self.totalTimeDict[@"duration"];
            }
            if (self.mediaControlInfo.playMode != ZXMediaPlayMode_Together) {
                [self setLockScreenInfoWithImageUrl:model.cover_imageURL image:model.cover_image title:model.title artist:model.artist totalSeconds:totalSeconds.floatValue isPlaying:self.mediaPlayerList[0].state == ZXMediaPlayerStatePlaying?YES:NO progress:self.mediaPlayerList[0].currentProgress];
            }
        }
    }
}

- (void)handleInterrupt:(NSNotification *)notif {
    AVAudioSessionInterruptionType type = [notif.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        for (ZXMediaPlayer *player in self.mediaPlayerList) {
            [player pause];
        }
    } else {
        for (ZXMediaPlayer *player in self.mediaPlayerList) {
            if (player.state == ZXMediaPlayerStatePause) {
                [player resume];
            }
        }
    }
}

- (void)routeChangeInterrupt:(NSNotification *)notif {
    NSDictionary *interuptionDict = notif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //插入耳机
            NSLog(@"耳机被插入，不需要停止");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //拔出耳机
            NSLog(@"耳机被拔出，需要停止");
            for (ZXMediaPlayer *player in [ZXMediaPlayManager.sharedInstance mediaPlayerList]) {
                player.state = ZXMediaPlayerStatePause;
                [player pause];
            }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"另一个音乐要播放");
            for (ZXMediaPlayer *player in [ZXMediaPlayManager.sharedInstance mediaPlayerList]) {
                player.state = ZXMediaPlayerStatePause;
                [player pause];
            }
            break;
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notif {
    NSLog(@"playerItemDidPlayToEnd object:%@", notif.object);
    switch (self.mediaControlInfo.playMode) {
        case ZXMediaPlayMode_Order:
        {
            NSLog(@"顺序播放模式，下一首");
            [ZXGCDQueue executeInMainQueue:^{
                [self next];
            } afterDelaySecs:0.2];
            break;
        }
        case ZXMediaPlayMode_Single:
        {
            NSLog(@"单曲单次模式，什么也不做");
            break;
        }
        case ZXMediaPlayMode_Random:
        {
            NSLog(@"随机播放模式，下一首");
            [ZXGCDQueue executeInMainQueue:^{
                [self random];
            } afterDelaySecs:0.2];
            break;
        }
        case ZXMediaPlayMode_SingleCircle:
        {
            NSLog(@"单曲循环播放模式");
            [ZXGCDQueue executeInMainQueue:^{
                [self single];
            } afterDelaySecs:0.2];
            break;
        }
        case ZXMediaPlayMode_Together:
        {
            NSLog(@"混合播放模式");
            AVPlayerItem *item = (AVPlayerItem *)notif.object;
            for (ZXMediaPlayer *player in self.mediaPlayerList) {
                if ([player.playerItem isEqual:item]) {
                    [ZXGCDQueue executeInMainQueue:^{
                        [player playWithMediaInfo:player.mediaInfo];
                    } afterDelaySecs:0.2];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - observer

- (void)appDidEnterBackground {
    if (!self.mediaControlInfo.supportBackGroundPlay) {
        for (ZXMediaPlayer *player in self.mediaPlayerList) {
            if (player.state == ZXMediaPlayerStatePlaying) {
                [player pause];
                player.isPauseByUser = NO;
            }
        }
        [AVAudioSession.sharedInstance setActive:NO error:nil];
    }
}

- (void)appDidEnterPlayGround {
    if (!self.mediaControlInfo.supportBackGroundPlay) {
        [AVAudioSession.sharedInstance setActive:YES error:nil];

        for (ZXMediaPlayer *player in self.mediaPlayerList) {
            if (player.state == ZXMediaPlayerStatePause && !player.isPauseByUser) {
                [player resume];
            }
        }
    }
}

- (void)actionDoNothing:(id)sender {
    NSLog(@"actionDoNothing called");
}

/**
 锁屏界面开启和监控远程控制事件
 */
- (void)createRemoteCommandCenter {
    if (!self.mediaControlInfo.supportBackGroundPlay) {
        MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        remoteCommandCenter.previousTrackCommand.enabled = NO;
        remoteCommandCenter.nextTrackCommand.enabled = NO;
        remoteCommandCenter.skipBackwardCommand.enabled = NO;
        remoteCommandCenter.skipForwardCommand.enabled = NO;
        remoteCommandCenter.bookmarkCommand.enabled = NO;
        remoteCommandCenter.playCommand.enabled = NO;
        remoteCommandCenter.pauseCommand.enabled = NO;

        [remoteCommandCenter.previousTrackCommand addTarget:self action:@selector(actionDoNothing:)];
        [remoteCommandCenter.nextTrackCommand addTarget:self action:@selector(actionDoNothing:)];
        [remoteCommandCenter.skipBackwardCommand addTarget:self action:@selector(actionDoNothing:)];
        [remoteCommandCenter.skipForwardCommand addTarget:self action:@selector(actionDoNothing:)];
        [remoteCommandCenter.bookmarkCommand addTarget:self action:@selector(actionDoNothing:)];
        [remoteCommandCenter.playCommand addTarget:self action:@selector(actionDoNothing:)];
        [remoteCommandCenter.pauseCommand addTarget:self action:@selector(actionDoNothing:)];
        
        [self setDisplayInfoWithDict:nil];
        return;
    }
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    if (self.mediaControlInfo.supportNextPrev) {
        commandCenter.previousTrackCommand.enabled = YES;
        [commandCenter.previousTrackCommand removeTarget:self action:@selector(sendPrevNotif)];
        [commandCenter.previousTrackCommand addTarget:self action:@selector(sendPrevNotif)];
        
        commandCenter.nextTrackCommand.enabled = YES;
        [commandCenter.nextTrackCommand removeTarget:self action:@selector(sendNextNotif)];
        [commandCenter.nextTrackCommand addTarget:self action:@selector(sendNextNotif)];
    } else {
        commandCenter.nextTrackCommand.enabled = NO;
        [commandCenter.nextTrackCommand removeTarget:self action:@selector(actionDoNothing:)];
        [commandCenter.nextTrackCommand addTarget:self action:@selector(actionDoNothing:)];
        commandCenter.previousTrackCommand.enabled = NO;
        [commandCenter.previousTrackCommand removeTarget:self action:@selector(actionDoNothing:)];
        [commandCenter.previousTrackCommand addTarget:self action:@selector(actionDoNothing:)];
    }
    if (!self.mediaControlInfo.supportSeek) {
        if (@available(iOS 9.1, *)) {
            commandCenter.changePlaybackPositionCommand.enabled = NO;
            [commandCenter.changePlaybackPositionCommand removeTarget:self action:@selector(actionDoNothing:)];
            [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(actionDoNothing:)];
        }
    } else {
        if (@available(iOS 9.1, *)) {
            commandCenter.changePlaybackPositionCommand.enabled = YES;
            [commandCenter.changePlaybackPositionCommand removeTarget:self action:@selector(changePlaybackPosition:)];
            [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(changePlaybackPosition:)];
        }
    }
    commandCenter.seekForwardCommand.enabled = NO;
    commandCenter.seekBackwardCommand.enabled = NO;

    if (self.mediaControlInfo.supportPlayPause) {
        commandCenter.pauseCommand.enabled = YES;
        [commandCenter.pauseCommand removeTarget:self action:@selector(sendPauseNotif)];
        [commandCenter.pauseCommand addTarget:self action:@selector(sendPauseNotif)];
    
        commandCenter.playCommand.enabled = YES;
        [commandCenter.playCommand removeTarget:self action:@selector(sendPlayNotif)];
        [commandCenter.playCommand addTarget:self action:@selector(sendPlayNotif)];
    } else {
        commandCenter.pauseCommand.enabled = NO;
        [commandCenter.pauseCommand removeTarget:self action:@selector(actionDoNothing:)];
        [commandCenter.pauseCommand addTarget:self action:@selector(actionDoNothing:)];
        commandCenter.playCommand.enabled = NO;
        [commandCenter.playCommand removeTarget:self action:@selector(actionDoNothing:)];
        [commandCenter.playCommand addTarget:self action:@selector(actionDoNothing:)];
    }
}

- (void)sendNextNotif {
    [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerRemoteControlNotification object:@{@"action":@"next"}];
}

- (void)sendPrevNotif {
    [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerRemoteControlNotification object:@{@"action":@"prev"}];
}

- (void)sendPauseNotif {
    [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerRemoteControlNotification object:@{@"action":@"pause"}];
}

- (void)sendPlayNotif {
    [NSNotificationCenter.defaultCenter postNotificationName:kZXMediaPlayerRemoteControlNotification object:@{@"action":@"play"}];
}

- (void)changePlaybackPosition:(MPChangePlaybackPositionCommandEvent *)event {
    if (self.mediaPlayerList.count == 1) {
        ZXMediaPlayer *player = self.mediaPlayerList[0];
        MPChangePlaybackPositionCommandEvent *playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        [player seekToTime:playbackPositionEvent.positionTime];
    }
}

/**
 显示锁屏音乐信息

 @param imageUrl 音乐封面地址
 @param image 本地封面对象
 @param title 描述文本
 @param artist 演唱者
 @param totalSeconds 总时间
 @param isPlaying 正在播放
 @param progress 播放进度
 */
- (void)setLockScreenInfoWithImageUrl:(NSURL *)imageUrl image:(UIImage *)image title:(NSString *)title artist:(NSString *)artist totalSeconds:(float)totalSeconds isPlaying:(BOOL)isPlaying progress:(float)progress {
    if (!self.mediaControlInfo.supportBackGroundPlay) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
    [dict setObject:title forKey:MPMediaItemPropertyTitle];
    [dict setObject:artist forKey:MPMediaItemPropertyArtist];
    
    if (!isPlaying) {
        [dict setObject:[NSNumber numberWithFloat:0.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    } else if (isPlaying && self.mediaControlInfo.supportProgressDisplay) {
        [dict setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    } else {
        [dict setObject:[NSNumber numberWithFloat:0.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    }
    
    if (self.mediaControlInfo.supportProgressDisplay) {
        [dict setObject:[NSNumber numberWithFloat:progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    }
    if (totalSeconds > 0 && self.mediaControlInfo.supportProgressDisplay) {
        [dict setObject:[NSNumber numberWithFloat:totalSeconds] forKey:MPMediaItemPropertyPlaybackDuration];
    }

    if (imageUrl) {
        //没下载过就去下载，下载过就不下了
        if (![self.currentScreenImageUrl.absoluteString isEqualToString:imageUrl.absoluteString]) {
            WEAKIFY_SELF
            [ZXWebImage.shared downloadImageWithURL:imageUrl progress:nil complete:^(UIImage *image, NSURL *url, NSError *error) {
                STRONGIFY_SELF
                if (!error) {
                    UIImage *scaledImage = [image croppedCenterSquareImage];
                    strong_self.screenImage = scaledImage;
                    strong_self.currentScreenImageUrl = url;
                }
            }];
        }
        if (self.screenImage) {
            MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:self.screenImage];
            [dict setObject:artWork forKey:MPMediaItemPropertyArtwork];
            [self setDisplayInfoWithDict:dict];
        } else {
            [self setDisplayInfoWithDict:dict];
        }
    } else {
        if (image) {
            UIImage *scaledImage = [image croppedCenterSquareImage];
            MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:scaledImage];
            [dict setObject:artWork forKey:MPMediaItemPropertyArtwork];
            [self setDisplayInfoWithDict:dict];
        } else {
            [dict removeObjectForKey:MPMediaItemPropertyArtwork];
            [self setDisplayInfoWithDict:dict];
        }
    }
}

- (void)setDisplayInfoWithDict:(NSMutableDictionary *)dict {
    if (!self.mediaControlInfo.supportBackGroundPlay) {
        dict = nil;
    } else if (self.mediaControlInfo.supportRecordCategory) {
        [dict setValue:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [dict removeObjectForKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [dict removeObjectForKey:MPMediaItemPropertyPlaybackDuration];
    } else {
        if (!self.mediaControlInfo.supportSeek && !self.mediaControlInfo.supportProgressDisplay) {
            [dict setValue:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            [dict removeObjectForKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [dict removeObjectForKey:MPMediaItemPropertyPlaybackDuration];
        }
    }
    [ZXGCDQueue executeInMainQueue:^{
        //更新字典
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }];
}

@end
