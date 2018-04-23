//
//  ZXMediaControlModel.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/19.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXMediaControlModel.h"

@implementation ZXMediaControlModel

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay supportNextPrev:(BOOL)supportNextPrev supportSeek:(BOOL)supportSeek supportPlayPause:(BOOL)supportPlayPause startIndex:(NSInteger)startIndex supportProgressDisplay:(BOOL)supportProgressDisplay supportRecordCategory:(BOOL)supportRecordCategory {
    ZXMediaControlModel *model = [[ZXMediaControlModel alloc]init];
    model.playMode = playMode;
    model.supportBackGroundPlay = supportBackGroundPlay;
    model.supportNextPrev = supportNextPrev;
    model.supportSeek = supportSeek;
    model.supportPlayPause = supportPlayPause;
    model.startIndex = startIndex;
    model.supportProgressDisplay = supportProgressDisplay;
    model.supportRecordCategory = supportRecordCategory;
    
    return model;
}

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay supportNextPrev:(BOOL)supportNextPrev supportSeek:(BOOL)supportSeek supportPlayPause:(BOOL)supportPlayPause startIndex:(NSInteger)startIndex supportProgressDisplay:(BOOL)supportProgressDisplay {
    ZXMediaControlModel *model = [[ZXMediaControlModel alloc]init];
    model.playMode = playMode;
    model.supportBackGroundPlay = supportBackGroundPlay;
    model.supportNextPrev = supportNextPrev;
    model.supportSeek = supportSeek;
    model.supportPlayPause = supportPlayPause;
    model.startIndex = startIndex;
    model.supportProgressDisplay = supportProgressDisplay;
    model.supportRecordCategory = NO;
    
    return model;
}

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay supportNextPrev:(BOOL)supportNextPrev supportSeek:(BOOL)supportSeek supportPlayPause:(BOOL)supportPlayPause supportProgressDisplay:(BOOL)supportProgressDisplay {
    return [self defaultControlWithPlayMode:playMode supportBackGroundPlay:supportBackGroundPlay supportNextPrev:supportNextPrev supportSeek:supportSeek supportPlayPause:supportPlayPause startIndex:0 supportProgressDisplay:supportProgressDisplay];
}

+ (ZXMediaControlModel *)defaultControlWithPlayMode:(ZXMediaPlayMode)playMode supportBackGroundPlay:(BOOL)supportBackGroundPlay {
    return [self defaultControlWithPlayMode:playMode supportBackGroundPlay:supportBackGroundPlay supportNextPrev:NO supportSeek:NO supportPlayPause:NO startIndex:0 supportProgressDisplay:YES];
}

@end
