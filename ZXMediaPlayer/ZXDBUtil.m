//
//  ZXDBUtil.m
//  ZXMediaPlayer
//
//  Created by JinZhengxuan on 2017/10/10.
//  Copyright © 2017年 Jinzhengxuan. All rights reserved.
//

#import "ZXDBUtil.h"
#import <sqlite3.h>

@implementation ZXDBUtil

static sqlite3 *_db = nil;

#define TBL_MEDIA_DB     @"TBL_MEDIA_DB"
#define TBL_MODULE_DB    @"TBL_MODULE_DB"
#define STRING_MAXLEN    500

// 打开数据库
+ (sqlite3 *)open {
    
    // 此方法的主要作用是打开数据库
    // 返回值是一个数据库指针
    // 因为这个数据库在很多的SQLite API（函数）中都会用到，我们声明一个类方法来获取，更加方便
    
    // 懒加载
    if (_db != nil) {
        return _db;
    }
    
    // 获取Documents路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject];
    
    // 生成数据库文件在沙盒中的路径
    NSString *sqlPath = [docPath stringByAppendingPathComponent:@"zxmediaplayer.sqlite"];
    
    // 创建文件管理对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 判断沙盒路径中是否存在数据库文件，如果不存在才执行拷贝操作，如果存在不在执行拷贝操作
    if ([fileManager fileExistsAtPath:sqlPath] == NO) {
        // 获取数据库文件在包中的路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"zxmediaplayer" ofType:@"sqlite"];
        
        // 使用文件管理对象进行拷贝操作
        // 第一个参数是拷贝文件的路径
        // 第二个参数是将拷贝文件进行拷贝的目标路径
        [fileManager copyItemAtPath:filePath toPath:sqlPath error:nil];
    }
    
    // 打开数据库需要使用一下函数
    // 第一个参数是数据库的路径（因为需要的是C语言的字符串，而不是NSString所以必须进行转换）
    // 第二个参数是指向指针的指针
    sqlite3_open([sqlPath UTF8String], &_db);
    
    return _db;
}

// 关闭数据库
+ (void)close {
    // 关闭数据库
    sqlite3_close(_db);
    
    // 将数据库的指针置空
    _db = nil;
}

+ (void)initialize {
    sqlite3 *db = [ZXDBUtil open];
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE if not exists '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'url' VARCHAR(%zd), 'cachePath' VARCHAR(%zd))", TBL_MEDIA_DB, (long)STRING_MAXLEN, (long)STRING_MAXLEN];
    // 执行sql语句
    int result = sqlite3_exec(db, sql.UTF8String, nil, nil, nil);
    
    if (result == SQLITE_OK) {
        NSLog(@"建表MEDIA成功");
    } else {
        NSLog(@"建表MEDIA失败");
    }
    
    sql = [NSString stringWithFormat:@"CREATE TABLE if not exists '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'module' VARCHAR(%zd), 'value' VARCHAR(%zd))", TBL_MODULE_DB, (long)STRING_MAXLEN, (long)STRING_MAXLEN];
    // 执行sql语句
    result = sqlite3_exec(db, sql.UTF8String, nil, nil, nil);
    
    if (result == SQLITE_OK) {
        NSLog(@"建表MODULE成功");
    } else {
        NSLog(@"建表MODULE失败");
    }

    [ZXDBUtil close];
}

+ (void)insertModuleRecordWithModule:(NSString *)module value:(NSString *)value {
    if (module.length > STRING_MAXLEN) {
        NSLog(@"[fatal]module is too long:%@", module);
        return;
    }
    if (value.length > STRING_MAXLEN) {
        NSLog(@"[fatal]value is too long:%@", value);
        return;
    }
    NSLog(@"[database action]insertDBRecordWithURL url:%@ cachePath:%@", module, value);
    
    sqlite3 * db = [ZXDBUtil open];
    NSString * sql = [NSString stringWithFormat:@"insert into %@ (module, value) values(?, ?) ", TBL_MODULE_DB];
    // 创建一个语句对象
    sqlite3_stmt *stmt = nil;
    // 生成语句对象
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, module.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 2, value.UTF8String, -1, nil);
        
        // 插入与查询不一样，执行结果没有返回值
        sqlite3_step(stmt);
    }
    // 释放语句对象
    sqlite3_finalize(stmt);
    
    [ZXDBUtil close];
}

+ (void)insertDBRecordWithURL:(NSString *)url cacheName:(NSString *)cacheName {
    if (url.length > STRING_MAXLEN) {
        NSLog(@"[fatal]url is too long:%@", url);
        return;
    }
    if (cacheName.length > STRING_MAXLEN) {
        NSLog(@"[fatal]cacheName is too long:%@", cacheName);
        return;
    }
    NSLog(@"[database action]insertDBRecordWithURL url:%@ cachePath:%@", url, cacheName);
    
    sqlite3 * db = [ZXDBUtil open];
    NSString * sql = [NSString stringWithFormat:@"insert into %@ (url, cachePath) values(?, ?) ", TBL_MEDIA_DB];
    // 创建一个语句对象
    sqlite3_stmt *stmt = nil;
    // 生成语句对象
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, url.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 2, cacheName.UTF8String, -1, nil);
        
        // 插入与查询不一样，执行结果没有返回值
        sqlite3_step(stmt);
    }
    // 释放语句对象
    sqlite3_finalize(stmt);
    
    [ZXDBUtil close];
}

+ (NSString *)queryModuleRecordWithModule:(NSString *)module {
    sqlite3 * db = [ZXDBUtil open];
    
    // 创建一个语句对象
    sqlite3_stmt *stmt = nil;
    NSString * sql = [NSString stringWithFormat:@"select * from %@ where module = (?)", TBL_MODULE_DB];
    // 生成语句对象
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    NSString *value = nil;
    if (result == SQLITE_OK) {
        // 如果查询语句或者其他sql语句有条件，在准备语句对象的函数内部，sql语句中用？来代替条件，那么在执行语句之前，一定要绑定
        // 1代表sql语句中的第一个问号，问号的下标是从1开始的
        sqlite3_bind_text(stmt, 1, module.UTF8String, -1, nil);
        
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            // 获取记录中的字段信息
            const unsigned char *cValue = sqlite3_column_text(stmt, 1);
            
            // 将C语言字符串转换成OC字符串
            value = [NSString stringWithUTF8String:(const char *)cValue];
        }
    }
    // 先释放语句对象
    sqlite3_finalize(stmt);
    
    [ZXDBUtil close];
    
    return value;
}

+ (NSString *)queryDBRecordWithURL:(NSString *)url {
    sqlite3 * db = [ZXDBUtil open];
    
    // 创建一个语句对象
    sqlite3_stmt *stmt = nil;
    NSString * sql = [NSString stringWithFormat:@"select * from %@ where url = (?)", TBL_MEDIA_DB];
    // 生成语句对象
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    NSString *cachePath = nil;
    if (result == SQLITE_OK) {
        // 如果查询语句或者其他sql语句有条件，在准备语句对象的函数内部，sql语句中用？来代替条件，那么在执行语句之前，一定要绑定
        // 1代表sql语句中的第一个问号，问号的下标是从1开始的
        sqlite3_bind_text(stmt, 1, url.UTF8String, -1, nil);
        
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            // 获取记录中的字段信息
            const unsigned char *cCachePath = sqlite3_column_text(stmt, 1);
            
            // 将C语言字符串转换成OC字符串
            cachePath = [NSString stringWithUTF8String:(const char *)cCachePath];
        }
    }
    // 先释放语句对象
    sqlite3_finalize(stmt);
    
    [ZXDBUtil close];
    
    return cachePath;
}

+ (void)deleteModuleRecordWithModule:(NSString *)module {
    sqlite3 * db = [ZXDBUtil open];
    NSString * sql = [NSString stringWithFormat:@"delete from %@ where module in (?)", TBL_MODULE_DB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, module.UTF8String, -1, nil);
        sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    [ZXDBUtil close];
}

+ (void)deleteDBRecordWithURL:(NSString *)url {
    sqlite3 * db = [ZXDBUtil open];
    NSString * sql = [NSString stringWithFormat:@"delete from %@ where url in (?)", TBL_MEDIA_DB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, url.UTF8String, -1, nil);
        sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    [ZXDBUtil close];
}

+ (NSString *)cacheDirectory {
    NSString *cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/"];
    return cacheDirectory;
}

+ (NSString *)fileNameWithPath:(NSString *)filePath {
    if ([filePath containsString:@"/"]) {
        NSArray *parts = [filePath componentsSeparatedByString:@"/"];
        if (parts && parts.count > 0) {
            NSString *suggestedFilename = [parts lastObject];
            return suggestedFilename;
        } else {
            return @"";
        }
    } else {
        return filePath;
    }
}

+ (BOOL)copyFileToCacheDictWithPath:(NSString *)path {
    NSString *fileName = [self fileNameWithPath:path];
    if ([NSFileManager.defaultManager isReadableFileAtPath:path]) {
        NSError *error;
        [NSFileManager.defaultManager copyItemAtPath:path toPath:[[self cacheDirectory]stringByAppendingString:fileName] error:&error];
        return YES;
    }
    return NO;
}

@end
