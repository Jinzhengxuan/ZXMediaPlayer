//
//  ZXWebImageDBUtil.h
//  Examples
//
//  Created by Jin Zhengxuan on 2018/4/23.
//  Copyright © 2018年 JinZhengxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXWebImageDBUtil : NSObject

//插入
+ (void)insertRecordWithURL:(NSString *)url cacheName:(NSString *)cacheName;

//查询
+ (NSString *)queryRecordWithURL:(NSString *)url;

//删除
+ (void)deleteRecordWithURL:(NSString *)url;

+ (NSString *)cacheDirectory;

@end
