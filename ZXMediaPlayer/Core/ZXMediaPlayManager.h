//
//  ZXMediaPlayManager.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/8/31.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXMediaPlayManager.h"
#import "ZXMediaControlModel.h"
#import "ZXMediaInfoModel.h"

@interface ZXMediaPlayManager : NSObject

//状态变化通知
FOUNDATION_EXPORT NSString * const kZXMediaPlayerStateChangedNotification;
//播放进度
FOUNDATION_EXPORT NSString * const kZXMediaPlayerPlayProgressNotification;
//播放总时间获取通知
FOUNDATION_EXPORT NSString * const kZXMediaPlayerTotalTimeNotification;
//下载完成通知
FOUNDATION_EXPORT NSString * const kZXMediaPlayerDownloadProgressNotification;
//远程控制通知
FOUNDATION_EXPORT NSString * const kZXMediaPlayerRemoteControlNotification;
//播放完成通知
FOUNDATION_EXPORT NSString * const kZXMediaPlayerPlayToEndNotification;

@property (nonatomic, strong, readonly) NSArray <ZXMediaInfoModel *> *infoList;
@property (nonatomic, strong, readonly) ZXMediaControlModel *mediaControlInfo;
@property (nonatomic, assign, readonly) NSInteger playIndex;//当前index

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedInstance instead")));
- (instancetype)copy __attribute__((unavailable("copy not available, call sharedInstance instead")));

/**
 单例

 @return 单例
 */
+ (instancetype)sharedInstance;

/**
 进行播放
 
 @param infoList 播放信息列表
 @param controlInfo 控制信息
 */
- (void)playWithInfoList:(NSArray <ZXMediaInfoModel *>*)infoList controlInfo:(ZXMediaControlModel *)controlInfo;

/**
 设置Category等
 */
- (void)setAudioSession;

/**
 暂停

 @param url 链接
 */
- (void)pauseWithURL:(NSURL *)url;

/**
 继续

 @param url 链接
 */
- (void)resumeWithURL:(NSURL *)url;

/**
 停止

 @param url 链接
 */
- (void)stopWithURL:(NSURL *)url;

/**
 跳转

 @param url 链接
 @param seconds 秒
 */
- (void)seekToTimeWithURL:(NSURL *)url seconds:(CGFloat)seconds;

/**
 更新音量
 
 @param url 链接
 @param volume 0~1
 */
- (void)setVolumeWithURL:(NSURL *)url volumn:(CGFloat)volume;

/**
 返回当前播放音频的附加index
 如果返回结果跟预期不一样，则不要使用url作为key进行查询或处理
 
 @return 当前播放音频的附加index，提供给任务接口判断多个相同url的情况
 */
- (NSInteger)currentAdditionalIndex;

/**
 下一首
 
 @return 是否能更新显示
 */
- (NSInteger)next;

/**
 上一首
 
 @return 是否能更新显示
 */
- (NSInteger)prev;

/**
 设置播放模式

 @param playMode 播放模式
 */
- (void)setPlayMode:(ZXMediaPlayMode)playMode;

/**
 获取播放链接的状态

 @param url 播放地址
 @return 状态
 */
- (ZXMediaPlayerState)stateWithURL:(NSURL *)url;

/**
 是否存在本地缓存

 @param url 链接
 @return 是否
 */
- (BOOL)isCacheExisted:(NSURL *)url;

/**
 删除缓存文件

 @param url 地址
 */
- (void)removeCacheFile:(NSURL *)url;

/**
 为链接添加本地缓存地址

 @param url 链接
 @param fileName 本地缓存文件名
 */
- (void)indexCacheFileWithURL:(NSURL *)url fileName:(NSString *)fileName;

/**
 获取链接对应的缓存地址

 @param url 链接
 @return 本地缓存地址
 */
- (NSString *)cachePathWithURL:(NSURL *)url;

/**
 释放全部资源
 */
- (void)releasePlayers;

/**
 获取远程资源时长
 
 @param urlStr 远程资源URL
 @return 时长秒
 */
- (float)fetchRemoteMediaTotalSeconds:(NSString *)urlStr;

@end
