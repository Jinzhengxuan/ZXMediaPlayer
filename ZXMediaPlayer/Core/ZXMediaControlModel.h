//
//  ZXMediaControlModel.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/19.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

//播放模式
typedef NS_ENUM(NSInteger, ZXMediaPlayMode) {
    ZXMediaPlayMode_Order,//顺序播放，循环
    ZXMediaPlayMode_Random,//随机播放
    ZXMediaPlayMode_Single,//单曲播放，不循环
    ZXMediaPlayMode_SingleCircle,//单曲播放，循环
    ZXMediaPlayMode_Together//同时播放
};

@interface ZXMediaControlModel : NSObject

/**
 播放模式
 */
@property (nonatomic, assign) ZXMediaPlayMode playMode;
/**
 后台播放
 */
@property (nonatomic, assign) BOOL supportBackGroundPlay;
/**
 上一首下一首切换
 */
@property (nonatomic, assign) BOOL supportNextPrev;
/**
 拖拽进度
 */
@property (nonatomic, assign) BOOL supportSeek;
/**
 暂停/继续
 */
@property (nonatomic, assign) BOOL supportPlayPause;
/**
 支持显示锁屏进度
 */
@property (nonatomic, assign) BOOL supportProgressDisplay;
/**
 音频/视频
 */
@property (nonatomic, assign) BOOL isAudio;
/**
 是否支持录音功能，支持的话则不需要进行锁屏界面显示
 */
@property (nonatomic, assign) BOOL supportRecordCategory;
/**
 开始播放index
 */
@property (nonatomic, assign) NSInteger startIndex;

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay supportNextPrev:(BOOL)supportNextPrev supportSeek:(BOOL)supportSeek supportPlayPause:(BOOL)supportPlayPause startIndex:(NSInteger)startIndex supportProgressDisplay:(BOOL)supportProgressDisplay supportRecordCategory:(BOOL)supportRecordCategory;

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay supportNextPrev:(BOOL)supportNextPrev supportSeek:(BOOL)supportSeek supportPlayPause:(BOOL)supportPlayPause startIndex:(NSInteger)startIndex supportProgressDisplay:(BOOL)supportProgressDisplay;

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay supportNextPrev:(BOOL)supportNextPrev supportSeek:(BOOL)supportSeek supportPlayPause:(BOOL)supportPlayPause supportProgressDisplay:(BOOL)supportProgressDisplay;

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay;

@end
