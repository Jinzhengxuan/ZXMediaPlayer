//
//  ZXPlayMusicView.m
//  ZXMediaPlayer
//
//  Created by Jinzhengxuan on 2017/9/22.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXPlayMusicView.h"

//Views
#import "ZXPlayRoundView.h"
#import "ZXPlayMusicCricleSlider.h"
#import "ZXMediaPlayManager.h"
#import <UserNotifications/UserNotifications.h>
#import "ZXGCD.h"
#import "ZXShowAlert.h"
#import <AVFoundation/AVFoundation.h>
#import "ZXConfig.h"
#import "UIButton+ZXUtil.h"
#import "UILabel+ZXUtil.h"
#import "UIView+ZXRect.h"
#import "ZXDBUtil.h"
#import "ZXReachAbility.h"
#import "ZXWebImage.h"
#import "UIImage+ZXUtil.h"

typedef NS_ENUM(NSInteger, ZXPlaySequenceModeEnum) {
    ZXPlaySequenceModeEnum_Order,
    ZXPlaySequenceModeEnum_Random,
    ZXPlaySequenceModeEnum_SingleCircle
};

typedef NS_ENUM(NSInteger, ZXPlayTimerModeEnum) {
    ZXPlayTimerModeEnum_None,
    ZXPlayTimerModeEnum_15Mins,
    ZXPlayTimerModeEnum_30Mins,
    ZXPlayTimerModeEnum_90Mins
};

@interface ZXPlayMusicView ()<ZXPlayRoundViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;//背景图片
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) ZXPlayRoundView *roundView;//唱片图片
@property (nonatomic, strong) ZXPlayMusicCricleSlider *radioCircleSlider;//进度圆点

@property (nonatomic, strong) UIButton *prevButton;//上一首
@property (nonatomic, strong) UIButton *nextButton;//下一首

@property (nonatomic, strong) UILabel *musicTitleLabel;
@property (nonatomic, strong) UIButton *cycleButton;
@property (nonatomic, strong) UIButton *timeButton;

@property (nonatomic, assign, readwrite) ZXPlayMusicViewStyle style;
@property (nonatomic, strong, readwrite) NSArray <ZXMediaInfoModel *>* musicList;
@property (nonatomic, strong, readwrite) ZXMediaControlModel *controlModel;
@property (nonatomic, assign, readwrite) NSInteger startIndex;
@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, strong) ZXPlayMusicTitleChangeBlock titleChangeBlock;

@property (nonatomic, assign) BOOL isUserWantPlayOrPause;

@property (nonatomic, strong) NSNumber *currentDuration;

@property (nonatomic, assign) ZXPlaySequenceModeEnum sequenceMode;

@property (nonatomic, assign) ZXPlayTimerModeEnum timerMode;

@property (nonatomic, assign) NSInteger timerMinutes;

@property (nonatomic, strong) ZXGCDTimer *timer;

@property (nonatomic, assign) BOOL isTimerStoped;
@property (nonatomic, assign) BOOL isMusicStarted;
@property (nonatomic, assign) BOOL isMusicPlaying;

@property (nonatomic, assign) NSInteger playStatusFlag;

@end

@implementation ZXPlayMusicView

/**
 显示播放音乐界面
 
 @param musicList 音乐列表
 @param startIndex 开始播放的index，默认从第1首开始
 @param titleChangeBlock 更改标题回调
 */
- (void)playWithMusicList:(NSArray <ZXMediaInfoModel *>*)musicList startIndex:(NSInteger)startIndex titleChangeBlock:(ZXPlayMusicTitleChangeBlock)titleChangeBlock {
    self.musicList = musicList;
    self.controlModel = [ZXMediaControlModel defaultControlWithPlayMode:ZXMediaPlayMode_Order supportBackGroundPlay:YES supportNextPrev:(self.style == ZXPlayMusicViewStyle_BlackBackground)?NO:YES supportSeek:(self.style == ZXPlayMusicViewStyle_BlackBackground)?NO:YES supportPlayPause:(self.style == ZXPlayMusicViewStyle_BlackBackground)?NO:YES startIndex:startIndex supportProgressDisplay:YES supportRecordCategory:(self.style == ZXPlayMusicViewStyle_BlackBackground)?YES:NO];
    self.startIndex = startIndex;
    self.titleChangeBlock = titleChangeBlock;
    self.timerMode = ZXPlayTimerModeEnum_None;
    self.sequenceMode = ZXPlaySequenceModeEnum_Order;
    self.timerMinutes = 0;
    [self restoreLocalModes];
    
    if (!self.musicList || self.musicList.count == 0 || self.musicList.count <= self.startIndex) {
        [ZXShowAlert showNetworkUnreachable];
        return;
    }
    
    [self addNotifications];
    self.currentIndex = startIndex;
    [self displayImage];
    [self displayTitles];
    
    if (self.style != ZXPlayMusicViewStyle_BlackBackground) {
        [self prepareToPlay:YES];
    }
}

/**
 初始化界面

 @param frame frame
 @param style 风格
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame style:(ZXPlayMusicViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.style = style;
        if (style != ZXPlayMusicViewStyle_BlackBackground) {
            [self addSubview:self.backgroundImageView];
            [self addSubview:self.subTitleLabel];
        } else {
            [self addSubview:self.musicTitleLabel];
            [self addSubview:self.cycleButton];
            [self addSubview:self.timeButton];
        }
        
        [self addSubview:self.prevButton];
        [self addSubview:self.nextButton];
        [self addSubview:self.radioCircleSlider];
        [self addSubview:self.roundView];
        [self notificationInit];
    }
    return self;
}

- (void)notificationInit {
    if (self.style != ZXPlayMusicViewStyle_BlackBackground) {
        return;
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(routeChangeInterrupt:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}

- (void)interruption:(NSNotification *)notif {
    AVAudioSessionInterruptionType type = [notif.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [ZXGCDQueue executeInMainQueue:^{
            if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
                [ZXMediaPlayManager.sharedInstance releasePlayers];
                if (self.delegate && [self.delegate respondsToSelector:@selector(backgroundRecordInterrupted)]) {
                    [self.delegate backgroundRecordInterrupted];
                }
                //显示本地通知，并退出关灯睡觉界面
                [self pushLocalNotification];
            }
        }];
    }
}

- (void)routeChangeInterrupt:(NSNotification *)notif {
    NSDictionary *interuptionDict = notif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonCategoryChange) {
        if (self.isMusicPlaying) {
            self.playStatusFlag += 1;
        } else {
            self.playStatusFlag += 2;
        }
        if (self.playStatusFlag >= 4) {
            [ZXGCDQueue executeInMainQueue:^{
                if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
                    [ZXMediaPlayManager.sharedInstance releasePlayers];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(backgroundRecordInterrupted)]) {
                        [self.delegate backgroundRecordInterrupted];
                    }
                    //显示本地通知，并退出关灯睡觉界面
                    [self pushLocalNotification];
                }
            }];
        }
    }
}

- (void)cancelNotification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
            [center removePendingNotificationRequestsWithIdentifiers:@[@"LocalNotif"]];
        } else {
            // Fallback on earlier versions
        }
    } else {
        for (UILocalNotification *obj in [UIApplication sharedApplication].scheduledLocalNotifications) {
            if ([obj.category isEqualToString:NSStringFromClass([self class])]) {
                [[UIApplication sharedApplication] cancelLocalNotification:obj];
            }
        }
    }
}

- (void)pushLocalNotification {
    [self cancelNotification];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        [self sendiOS10LocalNotification];
    } else {
        [self sendiOS8LocalNotification];
    }
}

- (void)sendiOS10LocalNotification {
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.body = @"由于与其他音频软件冲突，导致无法持续记录您的睡眠状况，请再次点击\"关灯睡觉\"记录睡眠";
        content.badge = @(1);
        content.categoryIdentifier = NSStringFromClass([self class]);
        content.userInfo = @{@"type":@"breakingSleep"};
        
        //推送类型
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"LocalNotif" content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"iOS 10 发送推送， error：%@", error);
        }];
    }
}

- (void)sendiOS8LocalNotification {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //触发通知时间
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    //重复间隔
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //通知内容
    localNotification.alertBody = @"由于与其他音频软件冲突，导致无法持续记录您的睡眠状况，请再次点击\"关灯睡觉\"记录睡眠";
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //通知参数
    localNotification.userInfo = @{@"type":@"breakingSleep"};
    localNotification.category = NSStringFromClass([self class]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)dealloc {
    [self stopTimer];
    [self removeNotifications];
    [ZXMediaPlayManager.sharedInstance releasePlayers];
    [self storeTimerMode:self.timerMode];
    [self storeSequenceMode:self.sequenceMode];
    [self cancelNotification];
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *effView = [[UIVisualEffectView alloc]initWithEffect:vibrancyEffect];
        effView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_backgroundImageView addSubview:effView];
    }
    return _backgroundImageView;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, ZXWidth(64), SCREEN_WIDTH, 30)];
        _subTitleLabel.font = [UIFont systemFontOfSize:15];
        _subTitleLabel.textColor = UIColor.whiteColor;
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _subTitleLabel;
}

- (ZXPlayRoundView *)roundView {
    if (!_roundView) {
        CGFloat icW = (_style == ZXPlayMusicViewStyle_Pressure)?ZXWidth(160.0f):ZXWidth(120.0f);
        CGFloat icH = icW;
        CGFloat icX = (SCREEN_WIDTH - icW) / 2.0f;
        CGFloat icY = (_style == ZXPlayMusicViewStyle_Pressure)?(SCREEN_HEIGHT/3 - ZXWidth(20.0f)):(SCREEN_HEIGHT/3);
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _roundView = [[ZXPlayRoundView alloc] initWithFrame:icRect];
        _roundView.delegate = self;
    }
    return _roundView;
}

- (ZXPlayMusicCricleSlider *)radioCircleSlider {
    if (!_radioCircleSlider) {
        CGFloat icW = (_style == ZXPlayMusicViewStyle_Pressure)?ZXWidth(205.0f):ZXWidth(165.0f);
        CGFloat icH = icW;
        CGFloat icX = (SCREEN_WIDTH - icW) / 2.0f;
        CGFloat icY = (_style == ZXPlayMusicViewStyle_Pressure)?((SCREEN_HEIGHT/3) - ZXWidth(42.5f)):((SCREEN_HEIGHT/3) - ZXWidth(22.5f));
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _radioCircleSlider = [[ZXPlayMusicCricleSlider alloc]initWithFrame:icRect];
        _radioCircleSlider.enabled = YES;
        [_radioCircleSlider addTarget:self action:@selector(seekToTime:) forControlEvents:UIControlEventValueChanged];
    }
    return _radioCircleSlider;
}

- (UIButton *)prevButton {
    if (!_prevButton) {
        CGFloat icX = ZXWidth(30.0f);
        CGFloat icY = (SCREEN_HEIGHT/3) + ZXWidth(32.0f);
        CGFloat icW = ZXWidth(53.0f);
        CGFloat icH = ZXWidth(56.0f);
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _prevButton = [UIButton buttonWithImageName:@"ms_BT_shangyishang"];
        _prevButton.frame = icRect;
        _prevButton.tag = 0;
        [_prevButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        CGFloat icX = SCREEN_WIDTH - ZXWidth(83.0f);
        CGFloat icY = (SCREEN_HEIGHT/3) + ZXWidth(32.0f);
        CGFloat icW = ZXWidth(53.0f);
        CGFloat icH = ZXWidth(56.0f);
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _nextButton = [UIButton buttonWithImageName:@"ms_BT_xiayishou"];
        _nextButton.frame = icRect;
        _nextButton.tag = 1;
        [_nextButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UILabel *)musicTitleLabel {
    if (!_musicTitleLabel) {
        CGFloat icX = 0;
        CGFloat icY = (SCREEN_HEIGHT/3) + ZXWidth(155.0f);
        CGFloat icW = SCREEN_WIDTH;
        CGFloat icH = ZXWidth(25.0f);
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _musicTitleLabel = [UILabel createWithText:@"" textColor:HexRGB(0xffffff) font:ZXFont(18.0f)];
        _musicTitleLabel.frame = icRect;
        _musicTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _musicTitleLabel;
}

- (UIButton *)cycleButton {
    if (!_cycleButton) {
        CGFloat icW = ZXWidth(37.0f);
        CGFloat icX = self.zx_centerX - ZXWidth(32.0f) - icW;
        CGFloat icY = self.musicTitleLabel.zx_bottom + ZXWidth(32.0f);
        CGFloat icH = icW;
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _cycleButton = [UIButton buttonWithImageName:@"mm_bt_xunhuanbofang"];
        _cycleButton.frame = icRect;
        _cycleButton.tag = 2;
        [_cycleButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cycleButton;
}

- (UIButton *)timeButton {
    if (!_timeButton) {
        CGFloat icW = ZXWidth(37.0f);
        CGFloat icX = self.zx_centerX + ZXWidth(32.0f);
        CGFloat icY = self.cycleButton.zx_y;
        CGFloat icH = icW;
        CGRect icRect = CGRectMake(icX, icY, icW, icH);
        _timeButton = [UIButton buttonWithImageName:@"mm_bt_dingshi"];
        _timeButton.frame = icRect;
        _timeButton.tag = 3;
        [_timeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeButton;
}

- (void)seekToTime:(id)sender {
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    [ZXMediaPlayManager.sharedInstance seekToTimeWithURL:model.mediaURL seconds:self.radioCircleSlider.progress*self.currentDuration.floatValue];
}

- (void)restoreLocalModes {
    //只有睡眠界面需要恢复
    if (self.style != ZXPlayMusicViewStyle_BlackBackground) {
        return;
    }
    
    NSString *sequence = [ZXDBUtil queryModuleRecordWithModule:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Sequence"]];
    if (sequence) {
        self.sequenceMode = ((NSNumber *)sequence).integerValue;
        NSString *imgName = nil;
        if (self.sequenceMode == ZXPlaySequenceModeEnum_Order) {
            imgName = @"mm_bt_xunhuanbofang";
            self.controlModel.playMode = ZXMediaPlayMode_Order;
        } else if (self.sequenceMode == ZXPlaySequenceModeEnum_Random) {
            imgName = @"mm_bt_suijibofang";
            self.controlModel.playMode = ZXMediaPlayMode_Random;
        } else if (self.sequenceMode == ZXPlaySequenceModeEnum_SingleCircle) {
            imgName = @"mm_bt_danquxunhuan";
            self.controlModel.playMode = ZXMediaPlayMode_SingleCircle;
        } else {
            NSLog(@"没理由打印该日志");
        }
        [_cycleButton setImageName:imgName forState:UIControlStateNormal];
        [_cycleButton setImageName:imgName forState:UIControlStateHighlighted];
    }
    
    NSString *timer = [ZXDBUtil queryModuleRecordWithModule:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Timer"]];
    if (timer) {
        self.timerMode = ((NSNumber *)timer).integerValue;
        NSString *imgName = nil;
        if (self.timerMode == ZXPlayTimerModeEnum_None) {
            imgName = @"mm_bt_dingshi";
            self.timerMinutes = 0;
        } else if (self.timerMode == ZXPlayTimerModeEnum_15Mins) {
            imgName = @"mm_15";
            self.timerMinutes = 15;
        } else if (self.timerMode == ZXPlayTimerModeEnum_30Mins) {
            imgName = @"mm_30";
            self.timerMinutes = 30;
        } else if (self.timerMode == ZXPlayTimerModeEnum_90Mins) {
            imgName = @"mm_90";
            self.timerMinutes = 90;
        } else {
            NSLog(@"没理由打印该日志");
        }
        [_timeButton setImageName:imgName forState:UIControlStateNormal];
        [_timeButton setImageName:imgName forState:UIControlStateHighlighted];
    }
}

- (void)storeSequenceMode:(ZXPlaySequenceModeEnum)sequenceMode {
    //只有睡眠界面需要记录
    if (self.style != ZXPlayMusicViewStyle_BlackBackground) {
        return;
    }
    [ZXDBUtil deleteModuleRecordWithModule:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Sequence"]];
    [ZXDBUtil insertModuleRecordWithModule:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Sequence"] value:[NSString stringWithFormat:@"%zd", (long)sequenceMode]];
}

- (void)storeTimerMode:(ZXPlayTimerModeEnum)timerMode {
    //只有睡眠界面需要记录
    if (self.style != ZXPlayMusicViewStyle_BlackBackground) {
        return;
    }
    [ZXDBUtil deleteModuleRecordWithModule:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Timer"]];
    [ZXDBUtil insertModuleRecordWithModule:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"Timer"] value:[NSString stringWithFormat:@"%zd", (long)timerMode]];
}

- (void)changeMusicItemDisplay:(NSInteger)index {
    if (self.sequenceMode == ZXMediaPlayMode_Random || self.sequenceMode == ZXMediaPlayMode_Single) {
        return;
    }
    self.currentIndex = index;
    [self displayImage];
    [self displayTitles];
}

#pragma mark - ZXPlayRoundViewDelegate

- (BOOL)prepareToPlay:(BOOL)isPlaying {
    self.isUserWantPlayOrPause = isPlaying;
    if (!self.musicList || self.musicList.count == 0 || self.musicList.count <= self.startIndex) {
        [ZXShowAlert showWithTitle:@"缓冲中，请稍候"];
        return NO;
    }
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    
    if (![ZXReachAbility isNetworkConnected] && isPlaying && ![ZXMediaPlayManager.sharedInstance isCacheExisted:model.mediaURL]) {
        [ZXShowAlert showNetworkUnreachable];
        return NO;
    }
    
    if (isPlaying) {
        if (!_isMusicStarted) {
            [self displayTitles];
            [self displayImage];
            self.isTimerStoped = YES;
            [ZXMediaPlayManager.sharedInstance playWithInfoList:self.musicList controlInfo:self.controlModel];
        } else {
            [ZXMediaPlayManager.sharedInstance resumeWithURL:model.mediaURL];
        }
        [self startTimer];
        return NO;
    } else {
        [ZXMediaPlayManager.sharedInstance pauseWithURL:model.mediaURL];
    }
    return YES;
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:kZXMediaPlayerDownloadProgressNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(totalTimeChanged:) name:kZXMediaPlayerTotalTimeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playProgressChanged:) name:kZXMediaPlayerPlayProgressNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mediaPlayerChanged:) name:kZXMediaPlayerStateChangedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(remoteCommandHandler:) name:kZXMediaPlayerRemoteControlNotification object:nil];
}

- (void)removeNotifications {
    [NSNotificationCenter.defaultCenter removeObserver:self name:kZXMediaPlayerDownloadProgressNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kZXMediaPlayerTotalTimeNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kZXMediaPlayerPlayProgressNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kZXMediaPlayerStateChangedNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kZXMediaPlayerRemoteControlNotification object:nil];
}

- (void)mediaPlayerChanged:(NSNotification *)notif {
    NSDictionary *dict = notif.object;
    NSNumber *state = (NSNumber *)dict[@"state"];
    NSString *urlString = dict[@"url"];
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    if (![model.mediaURL.absoluteString isEqualToString:urlString] && state.integerValue == ZXMediaPlayerStatePlaying) {
        for (int i = 0; i < self.musicList.count; i++) {
            ZXMediaInfoModel *m = self.musicList[i];
            if ([m.mediaURL.absoluteString isEqualToString:urlString]) {
                _isMusicStarted = YES;
                self.isMusicPlaying = YES;
                self.currentIndex = i;
                [self displayTitles];
                [self displayImage];
                [ZXGCDQueue executeInMainQueue:^{
                    [self.roundView play];
                }];
                break;
            }
        }
        return;
    }
    switch (state.integerValue) {
        case ZXMediaPlayerStateBuffering:
        {
            self.isMusicPlaying = YES;
            WEAKIFY_SELF
            [ZXGCDQueue executeInMainQueue:^{
                STRONGIFY_SELF
                [strong_self.roundView buffering];
            }];
            break;
        }
        case ZXMediaPlayerStatePlaying:
        {
            _isMusicStarted = YES;
            self.isMusicPlaying = YES;
            WEAKIFY_SELF
            [ZXGCDQueue executeInMainQueue:^{
                STRONGIFY_SELF
                strong_self.prevButton.enabled = YES;
                strong_self.nextButton.enabled = YES;
                strong_self.radioCircleSlider.enabled = YES;
                strong_self.roundView.userInteractionEnabled = YES;
                [strong_self.roundView play];
            }];
            break;
        }
        case ZXMediaPlayerStateStopped:
        {
            self.isMusicPlaying = NO;
            WEAKIFY_SELF
            [ZXGCDQueue executeInMainQueue:^{
                STRONGIFY_SELF
                [strong_self.roundView pause];
            }];
            break;
        }
        case ZXMediaPlayerStatePause:
        {
            self.isMusicPlaying = NO;
            WEAKIFY_SELF
            [ZXGCDQueue executeInMainQueue:^{
                STRONGIFY_SELF
                [strong_self.roundView pause];
            }];
            break;
        }
        default:
            break;
    }
}

- (void)remoteCommandHandler:(NSNotification *)notif {
    NSDictionary *dictionary = notif.object;
    if ([dictionary[@"action"] isEqualToString:@"play"]) {
        ZXMediaInfoModel *model = self.musicList[self.currentIndex];
        [ZXMediaPlayManager.sharedInstance resumeWithURL:model.mediaURL];
    } else if ([dictionary[@"action"] isEqualToString:@"pause"]) {
        ZXMediaInfoModel *model = self.musicList[self.currentIndex];
        [ZXMediaPlayManager.sharedInstance pauseWithURL:model.mediaURL];
    } else if ([dictionary[@"action"] isEqualToString:@"next"]) {
        [self changeMusicItemDisplay:[ZXMediaPlayManager.sharedInstance next]];
    } else if ([dictionary[@"action"] isEqualToString:@"prev"]) {
        [self changeMusicItemDisplay:[ZXMediaPlayManager.sharedInstance prev]];
    }
}

- (void)downloadProgress:(NSNotification *)notif {
    NSDictionary *dictionary = notif.object;
    NSString *urlString = dictionary[@"url"];
    NSNumber *progressNumber = (NSNumber *)dictionary[@"progress"];
    
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    if ([model.mediaURL.absoluteString isEqualToString:urlString]) {
        self.radioCircleSlider.downloadProgress = progressNumber.floatValue;
    }
}

- (void)totalTimeChanged:(NSNotification *)notif {
    NSDictionary *dictionary = notif.object;
    NSString *urlString = dictionary[@"url"];
    NSNumber *durationNumber = (NSNumber *)dictionary[@"duration"];
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    if ([model.mediaURL.absoluteString isEqualToString:urlString]) {
        self.currentDuration = durationNumber;
    }
}

- (void)playProgressChanged:(NSNotification *)notif {
    NSDictionary *dictionary = notif.object;
    NSString *urlString = dictionary[@"url"];
    NSNumber *progressNumber = (NSNumber *)dictionary[@"progressFloat"];
    NSNumber *duration = (NSNumber *)dictionary[@"duration"];
    
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    if ([model.mediaURL.absoluteString isEqualToString:urlString]) {
        self.currentDuration = duration;
        self.radioCircleSlider.progress = progressNumber.floatValue/self.currentDuration.floatValue;
    }
}

- (void)buttonClick:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
        {
            //上一首
            if (!_isMusicStarted) {
                //更新index
                if (self.currentIndex > 0) {
                    self.currentIndex -= 1;
                } else {
                    self.currentIndex = self.musicList.count - 1;
                }
                self.controlModel.startIndex = self.currentIndex;
                if ([self prepareToPlay:YES]) {
                    if (self.musicList.count == 1) {
                        [ZXMediaPlayManager.sharedInstance seekToTimeWithURL:self.musicList[0].mediaURL seconds:0];
                    } else {
                        [self changeMusicItemDisplay:[ZXMediaPlayManager.sharedInstance prev]];
                    }
                }
            } else {
                if (self.musicList.count == 1) {
                    [ZXMediaPlayManager.sharedInstance seekToTimeWithURL:self.musicList[0].mediaURL seconds:0];
                } else {
                    [self changeMusicItemDisplay:[ZXMediaPlayManager.sharedInstance prev]];
                    [self startTimer];
                }
            }
            break;
        }
        case 1:
        {
            //下一首
            if (!_isMusicStarted) {
                //更新index
                if (self.currentIndex < self.musicList.count - 1) {
                    self.currentIndex += 1;
                } else {
                    self.currentIndex = 0;
                }
                self.controlModel.startIndex = self.currentIndex;
                if ([self prepareToPlay:YES]) {
                    if (self.musicList.count == 1) {
                        [ZXMediaPlayManager.sharedInstance seekToTimeWithURL:self.musicList[0].mediaURL seconds:0];
                    } else {
                        [self changeMusicItemDisplay:[ZXMediaPlayManager.sharedInstance next]];
                    }
                }
            } else {
                if (self.musicList.count == 1) {
                    [ZXMediaPlayManager.sharedInstance seekToTimeWithURL:self.musicList[0].mediaURL seconds:0];
                } else {
                    [self changeMusicItemDisplay:[ZXMediaPlayManager.sharedInstance next]];
                    [self startTimer];
                }
            }
            break;
        }
        case 2:
        {
            //切换循环模式
            NSString *imgName = nil;
            if (self.sequenceMode == ZXPlaySequenceModeEnum_Order) {
                self.sequenceMode = ZXPlaySequenceModeEnum_Random;
                imgName = @"mm_bt_suijibofang";
                [ZXShowAlert showWithTitle:@"随机播放"];
                self.controlModel.playMode = ZXMediaPlayMode_Random;
                [ZXMediaPlayManager.sharedInstance setPlayMode:ZXMediaPlayMode_Random];
            } else if (self.sequenceMode == ZXPlaySequenceModeEnum_Random) {
                self.sequenceMode = ZXPlaySequenceModeEnum_SingleCircle;
                imgName = @"mm_bt_danquxunhuan";
                [ZXShowAlert showWithTitle:@"单曲循环"];
                self.controlModel.playMode = ZXMediaPlayMode_SingleCircle;
                [ZXMediaPlayManager.sharedInstance setPlayMode:ZXMediaPlayMode_SingleCircle];
            } else if (self.sequenceMode == ZXPlaySequenceModeEnum_SingleCircle) {
                self.sequenceMode = ZXPlaySequenceModeEnum_Order;
                imgName = @"mm_bt_xunhuanbofang";
                [ZXShowAlert showWithTitle:@"顺序播放"];
                self.controlModel.playMode = ZXMediaPlayMode_Order;
                [ZXMediaPlayManager.sharedInstance setPlayMode:ZXMediaPlayMode_Order];
            } else {
                NSLog(@"没理由打印该日志");
            }
            [_cycleButton setImageName:imgName forState:UIControlStateNormal];
            [_cycleButton setImageName:imgName forState:UIControlStateHighlighted];
            
            break;
        }
        case 3:
        {
            //切换倒计时
            NSString *imgName = nil;
            if (self.timerMode == ZXPlayTimerModeEnum_None) {
                self.timerMode = ZXPlayTimerModeEnum_15Mins;
                imgName = @"mm_15";
                self.timerMinutes = 15;
                [ZXShowAlert showWithTitle:@"15分钟后停止"];
            } else if (self.timerMode == ZXPlayTimerModeEnum_15Mins) {
                self.timerMode = ZXPlayTimerModeEnum_30Mins;
                imgName = @"mm_30";
                self.timerMinutes = 30;
                [ZXShowAlert showWithTitle:@"30分钟后停止"];
            } else if (self.timerMode == ZXPlayTimerModeEnum_30Mins) {
                self.timerMode = ZXPlayTimerModeEnum_90Mins;
                imgName = @"mm_90";
                self.timerMinutes = 90;
                [ZXShowAlert showWithTitle:@"90分钟后停止"];
            } else if (self.timerMode == ZXPlayTimerModeEnum_90Mins) {
                self.timerMode = ZXPlayTimerModeEnum_None;
                imgName = @"mm_bt_dingshi";
                self.timerMinutes = 0;
                [ZXShowAlert showWithTitle:@"定时关闭"];
            } else {
                NSLog(@"没理由打印该日志");
            }
            [_timeButton setImageName:imgName forState:UIControlStateNormal];
            [_timeButton setImageName:imgName forState:UIControlStateHighlighted];
            
            self.isTimerStoped = YES;
            [self startTimer];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)startTimer {
    //timer还没停，直接继续
    if (!self.isTimerStoped) {
        return;
    }
    [self stopTimer];
    if (self.timerMinutes > 0) {
        _isTimerStoped = NO;
        _timer = [[ZXGCDTimer alloc]initInQueue:[ZXGCDQueue mainQueue]];
        __block NSInteger counter = 0;
        WEAKIFY_SELF
        [_timer event:^{
            STRONGIFY_SELF
            //只有播放状态才进行计时
            if (strong_self.isMusicPlaying) {
                counter++;
            }
            if (counter >= strong_self.timerMinutes && !strong_self.isTimerStoped) {
                [ZXShowAlert showWithTitle:@"时间到了"];
                ZXMediaInfoModel *model = strong_self.musicList[strong_self.currentIndex];
                [ZXMediaPlayManager.sharedInstance pauseWithURL:model.mediaURL];
                strong_self.isTimerStoped = YES;
            }
        } timeIntervalWithSecs:60];
        [_timer start];
    }
}

- (void)stopTimer {
    if (_timer) {
        [_timer destroy];
        _timer = nil;
    }
}

- (void)displayImage {
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    if (![ZXReachAbility isNetworkConnected]) {
        _roundView.roundImage = [UIImage imageNamed:@"mm_music_bg"];
        _backgroundImageView.image = [UIImage imageNamed:@"mm_music_bg"];
    }
    WEAKIFY_SELF
    [ZXWebImage.shared downloadImageWithURL:model.cover_imageURL progress:nil complete:^(UIImage *image, NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"displayImage download cover error : %@", error);
        } else {
            [ZXGCDQueue executeInMainQueue:^{
                STRONGIFY_SELF
                strong_self.roundView.roundImage = image;
            }];
        }
    }];
    
    [ZXWebImage.shared downloadImageWithURL:model.back_imageURL progress:nil complete:^(UIImage *image, NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"displayImage download back error : %@", error);
        } else {
            [ZXGCDQueue executeInMainQueue:^{
                STRONGIFY_SELF
                UIImage *newImg = [UIImage coreBlurImage:image withBlurNumber:10.0 rect:strong_self.backgroundImageView.frame];
                strong_self.backgroundImageView.image = newImg;
            }];
        }
    }];
    self.radioCircleSlider.downloadProgress = 0;
    self.radioCircleSlider.progress = 0;
}

- (void)displayTitles {
    ZXMediaInfoModel *model = self.musicList[self.currentIndex];
    if (self.titleChangeBlock) {
        self.titleChangeBlock(model.title);
    }
    [ZXGCDQueue executeInMainQueue:^{
        if (self.style == ZXPlayMusicViewStyle_Sleep || self.style == ZXPlayMusicViewStyle_Pressure) {
            self.subTitleLabel.text = [NSString stringWithFormat:@"––––– %@ –––––", model.artist];
        } else {
            self.musicTitleLabel.text = model.title;
        }
    }];
}

@end
