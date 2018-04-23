//
//  ZXDBUtil.h
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/10.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXDBUtil : NSObject

//插入
+ (void)insertDBRecordWithURL:(NSString *)url cacheName:(NSString *)cacheName;

+ (void)insertModuleRecordWithModule:(NSString *)module value:(NSString *)value;

//查询
+ (NSString *)queryDBRecordWithURL:(NSString *)url;

+ (NSString *)queryModuleRecordWithModule:(NSString *)module;

//删除
+ (void)deleteDBRecordWithURL:(NSString *)url;

+ (void)deleteModuleRecordWithModule:(NSString *)module;

//工具
+ (NSString *)cacheDirectory;

+ (NSString *)fileNameWithPath:(NSString *)filePath;

+ (BOOL)copyFileToCacheDictWithPath:(NSString *)path;

@end
