//
//  ZXPlayMusicView.h
//  ZXMediaPlayer
//
//  Created by Jinzhengxuan on 2017/9/22.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXMediaInfoModel.h"

@protocol ZXPlayMusicViewDelegate<NSObject>

- (void)backgroundRecordInterrupted;

@end

@interface ZXPlayMusicView : UIView

typedef void (^ZXPlayMusicTitleChangeBlock) (NSString *title);

typedef NS_ENUM(NSInteger, ZXPlayMusicViewStyle) {
    ZXPlayMusicViewStyle_Sleep,//睡眠
    ZXPlayMusicViewStyle_Pressure,//压力
    ZXPlayMusicViewStyle_BlackBackground,//睡觉时显示专用
};

@property (nonatomic, assign, readonly) ZXPlayMusicViewStyle style;
@property (nonatomic, strong, readonly) NSArray <ZXMediaInfoModel *>* musicList;
@property (nonatomic, assign, readonly) NSInteger startIndex;
@property (nonatomic, weak) id<ZXPlayMusicViewDelegate> delegate;

/**
 初始化界面
 
 @param frame frame
 @param style 风格
 @return instance
 */
- (instancetype)initWithFrame:(CGRect)frame style:(ZXPlayMusicViewStyle)style;

/**
 播放音乐
 
 @param musicList 音乐列表
 @param startIndex 开始播放的index，默认从第1首开始
 @param titleChangeBlock 更改标题回调
 */
- (void)playWithMusicList:(NSArray <ZXMediaInfoModel *>*)musicList startIndex:(NSInteger)startIndex titleChangeBlock:(ZXPlayMusicTitleChangeBlock)titleChangeBlock;

@end
