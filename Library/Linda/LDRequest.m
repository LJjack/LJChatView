//
//  LDRequest.m
//  platform
//
//  Created by bujiong on 16/6/30.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequest.h"

@interface LDRequest()

@property(nonatomic, strong) NSMutableDictionary *innerUrlParams;

@property(nonatomic, strong) NSMutableDictionary *innerFormDatas;

@property(nonatomic, strong) NSMutableDictionary *innerUploadFiles;

@end

@implementation LDRequest

- (NSString *)dictionaryToString:(NSDictionary *)dictionary {
    
    if (!dictionary) {
        return nil;
    }
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *vals = (NSArray *)obj;
            [vals enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop2) {
                [str appendFormat:@"%@=%@&", key, obj2];
            }];
        } else {
            [str appendFormat:@"%@=%@&", key, obj];
        }
    }];
    
    [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    
    return str;
}

- (NSMutableDictionary *)stringToDictionary:(NSString *)string {
    
    if (!string) {
        return nil;
    }
    
    NSArray *silces = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:silces.count];
    
    [silces enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *kv = [obj componentsSeparatedByString:@"="];
        id key = kv[0];
        id val = kv[1];
        id currVal = [result objectForKey:key];
        if (!currVal) {
            result[key] = val;
        } else {
            // 已经存在，值改为数组
            if ([currVal isKindOfClass:[NSMutableArray class]]) {
                [currVal addObject:val];
            } else {
                [result setObject:@[currVal, val] forKey:key];
            }
        }
    }];

    return result;
}

- (NSString *)getUrlParams {
    if (_urlParams) {
        return _urlParams;
    }
    
    _urlParams = [self dictionaryToString:_innerUrlParams];
    
    return _urlParams;
}

- (void)setUrlParams:(NSString *)urlParams {
    _urlParams = urlParams;
    _innerUrlParams = [self stringToDictionary:urlParams];
}

- (NSString *)getFormDatas {
    if (_formDatas) {
        return _formDatas;
    }
    
    _formDatas = [self dictionaryToString:_innerFormDatas];
    
    return _formDatas;
}

- (void)setFormDatas:(NSString *)formDatas {
    _formDatas = formDatas;
    _innerFormDatas = [self stringToDictionary:formDatas];
}

- (NSString *)getUploadFiles {
    if (_uploadFiles) {
        return _uploadFiles;
    }
    
    _uploadFiles = [self dictionaryToString:_innerUploadFiles];
    
    return _uploadFiles;
}

- (void)setUploadFiles:(NSString *)uploadFiles {
    _uploadFiles = uploadFiles;
    _innerUploadFiles = [self stringToDictionary:uploadFiles];
}

- (NSArray *)getFormDatasByName:(NSString *)name {
    return [_innerFormDatas objectForKey:name];
}

- (NSArray *)getUploadFilesByName:(NSString *)paramName {
    return [_innerUploadFiles objectForKey:paramName];
}

- (NSMutableDictionary *)getInnerUrlParams {
    return _innerUrlParams;
}

- (void)setInnerUrlParams:(NSMutableDictionary *)params {
    _innerUrlParams = params;
}

- (NSMutableDictionary *)getInnerFormDatas {
    return _innerFormDatas;
}

- (NSDictionary *)getSimplifiedInnerFormDatas {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:_innerFormDatas.count];
    [_innerFormDatas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj count] == 1) {
            [result setObject:obj[0] forKey:key];
        }
    }];
    
    return result;
}

- (void)setInnerFormDatas:(NSMutableDictionary *)formDatas {
    _innerFormDatas = formDatas;
}

- (NSMutableDictionary *)getInnerUploadFiles {
    return _innerUploadFiles;
}

- (void)setInnerUploadFiles:(NSMutableDictionary *)files {
    _innerUploadFiles = files;
}
+ (nonnull NSString *)dbPrimaryKey {
    return @"requestId";
}

@end
