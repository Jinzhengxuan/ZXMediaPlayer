//
//  ZXMediaInfoModel.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/9.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXMediaInfoModel.h"

@implementation ZXMediaInfoModel

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_imageURL:(NSURL *)cover_imageURL back_imageURL:(NSURL *)back_imageURL volume:(float)volume {
    ZXMediaInfoModel *model = [[ZXMediaInfoModel alloc]init];
    model.mediaURL = url;
    model.title = title;
    model.artist = artist;
    model.cover_imageURL = cover_imageURL;
    model.cover_image = nil;
    model.back_imageURL = back_imageURL;
    model.volume = volume;
    model.startSecond = 0;
    model.playVideoView = nil;
    return model;
}

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_image:(UIImage *)cover_image back_imageURL:(NSURL *)back_imageURL startSecond:(float)startSecond {
    ZXMediaInfoModel *model = [[ZXMediaInfoModel alloc]init];
    model.mediaURL = url;
    model.title = title;
    model.artist = artist;
    model.cover_imageURL = nil;
    model.cover_image = cover_image;
    model.back_imageURL = back_imageURL;
    model.volume = 1.0;
    model.startSecond = startSecond;
    model.playVideoView = nil;
    return model;
}

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_imageURL:(NSURL *)cover_imageURL back_imageURL:(NSURL *)back_imageURL startSecond:(float)startSecond {
    ZXMediaInfoModel *model = [[ZXMediaInfoModel alloc]init];
    model.mediaURL = url;
    model.title = title;
    model.artist = artist;
    model.cover_imageURL = cover_imageURL;
    model.cover_image = nil;
    model.back_imageURL = back_imageURL;
    model.volume = 1.0;
    model.startSecond = startSecond;
    model.playVideoView = nil;
    return model;
}

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist cover_imageURL:(NSURL *)cover_imageURL back_imageURL:(NSURL *)back_imageURL {
    return [self defaultMediaInfoWithURL:url title:title artist:artist cover_imageURL:cover_imageURL back_imageURL:back_imageURL volume:1.0];
}

+ (ZXMediaInfoModel *)defaultMediaInfoWithURL:(NSURL *)url {
    return [self defaultMediaInfoWithURL:url title:@"" artist:@"" cover_imageURL:nil back_imageURL:nil volume:1.0];
}

+ (ZXMediaInfoModel *)defaultMediaInfoWithVideoURL:(NSURL *)url view:(UIView *)view cover_imageURL:(NSURL *)cover_imageURL {
    ZXMediaInfoModel *m = [self defaultMediaInfoWithURL:url title:@"" artist:@"" cover_imageURL:cover_imageURL back_imageURL:nil volume:1.0];
    m.playVideoView = view;
    return m;
}

@end
