//
//  ZXMediaInfoModel.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/9.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//播放器的几种状态
typedef NS_ENUM(NSInteger, ZXMediaPlayerState) {
    ZXMediaPlayerStateInit       = 0,
    ZXMediaPlayerStateBuffering  = 1,
    ZXMediaPlayerStatePlaying    = 2,
    ZXMediaPlayerStateStopped    = 3,
    ZXMediaPlayerStatePause      = 4
};

@interface ZXMediaInfoModel : NSObject

/**
 媒体文件地址
 */
@property (nonatomic, strong) NSURL *mediaURL;
/**
 标题
 */
@property (nonatomic, copy) NSString *title;
/**
 艺术家
 */
@property (nonatomic, copy) NSString *artist;
/**
 封面图片地址
 */
@property (nonatomic, strong) NSURL *cover_imageURL;
/**
 封面图片对象
 */
@property (nonatomic, strong) UIImage *cover_image;
/**
 背景图片地址
 */
@property (nonatomic, strong) NSURL *back_imageURL;
/**
 音量
 */
@property (nonatomic, assign) CGFloat volume;
/**
 播放启动时间
 */
@property (nonatomic, assign) float startSecond;
/**
 视频播放窗口
 */
@property (nonatomic, weak) UIView *playVideoView;
/**
 附加index，防止一个播放列表中包含相同url的情况
 */
@property (nonatomic, assign) NSInteger additionalIndex;

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_imageURL:(NSURL *)cover_imageURL back_imageURL:(NSURL *)back_imageURL volume:(float)volume;

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_image:(UIImage *)cover_image back_imageURL:(NSURL *)back_imageURL startSecond:(float)startSecond;

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_imageURL:(NSURL *)cover_imageURL back_imageURL:(NSURL *)back_imageURL startSecond:(float)startSecond;

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_imageURL:(NSURL *)cover_imageURL back_imageURL:(NSURL *)back_imageURL;

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url;

+ (ZXMediaInfoModel *)defaultMediaInfoWithVideoURL:(NSURL *)url view:(UIView *)view cover_imageURL:(NSURL *)cover_imageURL;

@end
