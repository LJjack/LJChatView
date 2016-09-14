//
//  GJCFCachePathManager.m
//  GJCommonFoundation
//
//  Created by ZYVincent on 14-11-19.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import "GJCFCachePathManager.h"
//#import "GJCFUitils.h"

#define GJCFCachePathManagerMainCacheDirectory @"GJCFCachePathManagerMainCacheDirectory"

#define GJCFCachePathManagerMainImageCacheDirectory @"GJCFCachePathManagerMainImageCacheDirectory"

#define GJCFCachePathManagerMainAudioCacheDirectory @"GJCFCachePathManagerMainAudioCacheDirectory"

static NSString *  GJCFAudioFileCacheSubTempEncodeFileDirectory = @"GJCFAudioFileCacheSubTempEncodeFileDirectory";

@implementation GJCFCachePathManager

+ (GJCFCachePathManager *)shareManager
{
    static GJCFCachePathManager *_pathManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pathManager = [[self alloc] init];
    });
    return _pathManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        [self setupCacheDirectorys];
    }
    return self;
}

- (void)setupCacheDirectorys
{
    /* 主缓存目录 */
    if (![self fileExistsAtPath:[self mainCacheDirectory]]) {
        [self createDirectoryAtPath:[self mainCacheDirectory]];
    }
    
    /* 主图片缓存目录 */
    if (![self fileExistsAtPath:[self mainImageCacheDirectory]]) {
        [self createDirectoryAtPath:[self mainImageCacheDirectory]];
    }
    
    /* 主音频缓存目录 */
    if (![self fileExistsAtPath:[self mainAudioCacheDirectory]]) {
        [self createDirectoryAtPath:[self mainAudioCacheDirectory]];
    }
}

- (NSString *)mainCacheDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:GJCFCachePathManagerMainCacheDirectory];
}

- (NSString *)mainImageCacheDirectory
{
    return [[self mainCacheDirectory]stringByAppendingPathComponent:GJCFCachePathManagerMainImageCacheDirectory];
}

- (NSString *)mainAudioCacheDirectory
{
    return [[self mainCacheDirectory]stringByAppendingPathComponent:GJCFCachePathManagerMainAudioCacheDirectory];
}

/* 主图片缓存下文件路径 */
- (NSString *)mainImageCacheFilePath:(NSString *)fileName
{
    if (!fileName || !fileName.length) {
        return nil;
    }
    return [[self mainImageCacheDirectory]stringByAppendingPathComponent:fileName];
}

/* 主音频缓存下文件路径 */
- (NSString *)mainAudioCacheFilePath:(NSString *)fileName
{
    if (!fileName || !fileName.length) {
        return nil;
    }
    return [[self mainAudioCacheDirectory]stringByAppendingPathComponent:fileName];
}

/* 在主缓存目录下面创建或者返回指定名字的目录路径 */
- (NSString *)createOrGetSubCacheDirectoryWithName:(NSString *)dirName
{
    if (!dirName || !dirName.length) {
        return nil;
    }
    NSString *dirPath = [[self mainCacheDirectory] stringByAppendingPathComponent:dirName];
    if ([self fileExistsAtPath:dirPath]) {
        return dirPath;
    }else{
        [self createDirectoryAtPath:dirPath];
        return dirPath;
    }
}

/* 在主图片缓存目录下返回或者创建指定目录名字的目录路径 */
- (NSString *)createOrGetSubImageCacheDirectoryWithName:(NSString *)dirName
{
    if (!dirName || !dirName.length) {
        return nil;
    }
    NSString *dirPath = [[self mainImageCacheDirectory] stringByAppendingPathComponent:dirName];
    if ([self fileExistsAtPath:dirPath]) {
        return dirPath;
    }else{
        [self createDirectoryAtPath:dirPath];
        return dirPath;
    }
}

/* 在主音频缓存目录下返回或者创建指定目录名字的目录路径 */
- (NSString *)createOrGetSubAudioCacheDirectoryWithName:(NSString *)dirName
{
    if (!dirName || !dirName.length) {
        return nil;
    }
    NSString *dirPath = [[self mainAudioCacheDirectory] stringByAppendingPathComponent:dirName];
    if ([self fileExistsAtPath:dirPath]) {
        return dirPath;
    }else{
        [self createDirectoryAtPath:dirPath];
        return dirPath;
    }
}

/* 主图片缓存目录下是否存在名为fileName的文件 */
- (BOOL)mainImageCacheFileExist:(NSString *)fileName
{
    return [self fileExistsAtPath:[self mainImageCacheFilePath:fileName]];
}

/* 主音频缓存目录下是否存在名为fileName的文件 */
- (BOOL)mainAudioCacheFileExist:(NSString *)fileName
{
    return [self fileExistsAtPath:[self mainAudioCacheFilePath:fileName]];
}

/* 为一个图片链接地址返回缓存路径 */
- (NSString *)mainImageCacheFilePathForUrl:(NSString *)url
{
    if (!url || !url.length) {
        return nil;
    }
    NSString *fileName = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return [self mainImageCacheFilePath:fileName];
}

/* 为一个语音地址返回缓存路径 */
- (NSString *)mainAudioCacheFilePathForUrl:(NSString *)url
{
    if (!url || !url.length) {
        return nil;
    }
    NSString *fileName = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return [self mainAudioCacheFilePath:fileName];
}

/* 确定主图片缓存下是否有链接为url的文件缓存  */
- (BOOL)mainImageCacheFileIsExistForUrl:(NSString *)url
{
    return [self fileExistsAtPath:[self mainImageCacheFilePathForUrl:url]];
}

/* 确定主语音缓存下是否有链接为url的文件缓存 */
- (BOOL)mainAudioCacheFileIsExistForUrl:(NSString *)url
{
    return [self fileExistsAtPath:[self mainAudioCacheFilePathForUrl:url]];
}

- (NSString *)mainAudioTempEncodeFile:(NSString *)fileName
{
    return [[self createOrGetSubAudioCacheDirectoryWithName:GJCFAudioFileCacheSubTempEncodeFileDirectory]stringByAppendingPathComponent:fileName];
}

#pragma mark - Private Methods
- (BOOL)fileExistsAtPath:(NSString *)path {
   return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)createDirectoryAtPath:(NSString *)path {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

@end
