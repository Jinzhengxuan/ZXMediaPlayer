//
//  ZXPlayMusicController.h
//  ZXMediaPlayer
//
//  Created by Jinzhengxuan on 2017/9/28.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXMediaInfoModel.h"
#import "ZXPlayMusicView.h"

@interface ZXPlayMusicController : UIViewController

/**
 音乐列表
 */
@property (nonatomic, strong) NSArray<ZXMediaInfoModel *>* musicList;

/**
 开始播放musicList中的index
 */
@property (nonatomic, assign) NSInteger startIndex;

/**
 界面风格
 */
@property (nonatomic, assign) ZXPlayMusicViewStyle style;

@end
