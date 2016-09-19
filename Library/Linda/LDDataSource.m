//
//  LDDataSource.m
//  platform
//
//  Created by bujiong on 16/6/30.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDDataSource.h"

#import <YYModel/YYModel.h>

#import "LDRequest.h"
#import "LDHttpConsts.h"
#import "LDFmdbProvider.h"
#import "LDSilentHttpCaller.h"


#define OutOfBoundGuard(a, b, c) \
do { \
    if (!b || a < 0 || a >= b.count) { \
        BJLog(@"下标越界，%lu-->[0:%lu)", a, b.count); \
        return c; \
    } \
} while(0)

#define NilGuard(a, b) \
do { \
    if (!a) { \
        return b; \
    } \
} while(0)

#define MIN_CAPACITY 4
#define MAX_PERSISTANCE_COUNT   100

@interface LDDataSource()

@property(nonatomic, weak) LDSilentHttpCaller *caller;

@property(nonatomic, assign) Class modelCls;

@property(nonatomic, assign) NSUInteger persistanceCount;

@property(nonatomic, strong) NSMutableArray *models;

@end

@implementation LDDataSource

+ (instancetype)datasourceWithCaller:(LDSilentHttpCaller *)caller
                    persistanceCount:(NSUInteger)persistanceCount {
    LDDataSource *datasource = [[LDDataSource alloc] init];
    datasource.caller = caller;
    datasource.modelCls = [caller valueForKey:@"modelCls"];
    datasource.persistanceCount = MAX_PERSISTANCE_COUNT;
    
    // 加载磁盘中的数据
    LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
    [fmdb enableDeepPolicy];
    [fmdb createTableIfNotExist:datasource.modelCls];
    datasource.models = [fmdb queryMore:datasource.modelCls sqlDict:nil sortKeys:nil].mutableCopy;
    [fmdb disableDeepPolicy];
    
    return datasource;
}

- (id)getAt:(NSUInteger)index {
    OutOfBoundGuard(index, _models, nil);
    return _models[index];
}

- (id)getFirst {
    NilGuard(_models, nil);
    return _models.firstObject;
}

- (id)getLast {
    NilGuard(_models, nil);
    return _models.lastObject;
}

- (NSArray *)getPage:(NSUInteger)offset size:(NSUInteger)size {
    OutOfBoundGuard(offset, _models, nil);
    
    if (offset + size >= _models.count) {
        size = _models.count - offset;
    }
    
    BJLog(@"offset:%lu, page size:%lu, total count:%lu.", offset, size, _models.count);
    
    return [_models subarrayWithRange:NSMakeRange(offset, size)];
}

- (NSInteger)getSize {
    return _models.count;
}

/**
 * 如果没有找到就返回-1，如果找到，返回在数组中的下标
 */
- (NSInteger)getIndexByModelId:(NSArray *)models modelId:(NSNumber *)modelId {
    
    if (!models.count) {
        BJLog(@"目标容器为空，无法根据键值找到在容器中的位置");
        return -1;
    }
    
    NSString *primaryKey = [[LDFmdbProvider sharedInstance] getPrimaryKey:[models[0] class]];
    NSUInteger index = 0;
    for (index = 0; index < models.count; ++index) {
        id model = models[index];
        if ([modelId isEqualToNumber:[model valueForKey:primaryKey]]) {
            return index;
        }
    }
    
    BJLog(@"无法找到id对应的模型%@", modelId);
    return -1;
}

- (void)reset {
    _models = nil;
}

- (id)getModelById:(NSArray *)models modelId:(NSNumber *)modelId {
    
    if (![models isKindOfClass:[NSArray class]] || !models.count) {
        return nil;
    }
    
    NSString *primaryKey = [[LDFmdbProvider sharedInstance] getPrimaryKey:[models.firstObject class]];
    NSUInteger index = 0;
    for (index = 0; index < models.count; ++index) {
        id model = models[index];
        if ([modelId isEqualToNumber:[model valueForKey:primaryKey]]) {
            return model;
        }
    }
    
    return nil;
}

- (NSMutableArray *)getTargetContainer:(Class)cls masterId:(NSNumber *)masterId {
    if (!masterId) {
        return _models;
    }
    
    id masterModel = [self getModelById:_models modelId:masterId];
    
    // 查找model所属的属性值
    __block NSString *propName;
    NSDictionary<NSString *, Class> *classes = [(id<LDFmdbProvider>)[masterModel class] dbRelationContainerPropertyGenericClass];
    [classes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == cls) {
            propName = key;
            *stop = YES;
        }
    }];
    
    if (propName) {
        NSMutableArray *arys = [masterModel valueForKey:propName];
        if (!arys) {
            arys = [NSMutableArray arrayWithCapacity:2];
            [masterModel setValue:arys forKey:propName];
        }
        
        return arys;
    } else {
        BJLog(@"没有找到model class:%@对应的容器", cls);
        return nil;
    }
}

- (id)getModelByClass:(Class)cls masterId:(NSNumber *)masterId modelId:(NSNumber *)modelId {
    if (!masterId) {
        return [self getModelById:_models modelId:modelId];
    }
    
    NSArray *container = [self getTargetContainer:cls masterId:masterId];
    if (container) {
        return [self getModelById:container modelId:modelId];
    } else {
        BJLog(@"没有找到masterId:%@, modelId:%@对应的模型", masterId, modelId);
        return nil;
    }
}

- (NSNumber *)preChangeWithModel:(id)model request:(LDRequest *)request {
    if ([request.httpMethod isEqualToString:HTTP_METHOD_GET]) {
        NSAssert(NO, @"GET请求不应调用preAddModel:withRequest:方法");
        return nil;
    }
    
    NSMutableArray *targetModels = [self getTargetContainer:[_caller modelClassFromRequest:request] masterId:request.masterModelId];
    
    LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
    
    if ([request.httpMethod isEqualToString:HTTP_METHOD_POST]) {
        
        [fmdb save:@[model]];
        [targetModels addObject:model];
        
        return [model valueForKey:[fmdb getPrimaryKey:[model class]]];
        
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
        
        [fmdb save:@[model]];
        NSInteger subIndex = [self getIndexByModelId:targetModels modelId:request.modelId];
        [targetModels replaceObjectAtIndex:subIndex withObject:model];
        
        return request.modelId;
        
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
        
        [fmdb deleteByKey:_modelCls primaryKeyValue:request.modelId];
        NSInteger subIndex = [self getIndexByModelId:targetModels modelId:request.modelId];
        if (subIndex > -1) {
           [targetModels removeObjectAtIndex:subIndex];
        }
        return request.modelId;
        
    } else {
        BJLog(@"不支持的HTTP method");
        return nil;
    }
}

- (NSArray *)responseToModels:(NSData *)response withRequest:(LDRequest *)request {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    
    Class modelCls = [_caller modelClassFromRequest:request];
    id data = [dict objectForKey:@"data"];
    if ([data isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[data count]];
        for (NSDictionary *curr in data) {
            [result addObject:[modelCls yy_modelWithJSON:curr]];
        }
        
        return result;
    } else {
        id model = [modelCls yy_modelWithJSON:data];
        if (model) {
            return @[model];
        } else {
            return @[];
        }
    }
}

- (void)commitChangeWithResponse:(NSData *)response request:(LDRequest *)request {
    
    NSMutableArray *targetModels = [self getTargetContainer:[_caller modelClassFromRequest:request] masterId:request.masterModelId];
    
    LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
    NSArray *models = [self responseToModels:response withRequest:request];
    
    if ([request.httpMethod isEqualToString:HTTP_METHOD_POST]) {
    
        if (models.count != 1) {
             BJLog(@"POST 请求返回的model数量不等于1");
        }
        
        id model = models.firstObject;
        
        // 更新model
        NSInteger subIndex = [self getIndexByModelId:targetModels modelId:request.modelId];
        [targetModels replaceObjectAtIndex:subIndex withObject:model];
        
        // 用新的替换原先的  主键
        
        [fmdb deleteByKey:[model class] primaryKeyValue:request.modelId];
        [fmdb save:@[model]];
        
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
        
        if (models.count != 1) {
            BJLog(@"PUT 请求返回的model数量不等于1");
        }
        
        id model = models.firstObject;
        
        NSInteger subIndex = [self getIndexByModelId:targetModels modelId:request.modelId];
        [targetModels replaceObjectAtIndex:subIndex withObject:model];
        [fmdb save:@[model]];
        
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_GET]) {
        
        if (models && models.count) {
            [targetModels addObjectsFromArray:models];
            
            // 不能超过最大限制
            NSUInteger saveCount = models.count;
            NSString *sql = [NSString stringWithFormat:@"select count(0) from %@",[fmdb getTableName:[models.firstObject class]]];
            
            NSNumber *rowCount = [fmdb querySingledModel:[NSNumber class] sql:sql withArgumentsInArray:nil];;
            
            if (rowCount.integerValue < _persistanceCount) {
                NSUInteger capacity = _persistanceCount - rowCount.integerValue;
                saveCount = capacity > saveCount ? saveCount : capacity;
                [fmdb save:[models subarrayWithRange:NSMakeRange(0, saveCount)]];
            }
        }
        
        
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
        
        // 什么都不做
        
    } else {
        BJLog(@"不支持的HTTP method");
    }
}

- (void)rollbackChangeWithRequest:(LDRequest *)request {
    LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
    NSMutableArray *targetModels = [self getTargetContainer:[_caller modelClassFromRequest:request] masterId:request.masterModelId];
    
    if ([request.httpMethod isEqualToString:HTTP_METHOD_POST]) {
        [fmdb deleteByKey:[request.oldModel class] primaryKeyValue:request.modelId];
        NSInteger index = [self getIndexByModelId:targetModels modelId:request.modelId];
        [targetModels removeObjectAtIndex:index];
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
        // 删除，然后插入原先的。id保持不变
        [fmdb deleteByKey:[request.oldModel class] primaryKeyValue:request.modelId];
        [fmdb save:@[request.oldModel]];
        NSInteger subIndex = [self getIndexByModelId:targetModels modelId:request.modelId];
        [targetModels replaceObjectAtIndex:subIndex withObject:request.oldModel];
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
        // 直接保存原先的
        [fmdb save:@[request.oldModel]];
        NSInteger subIndex = [self getIndexByModelId:targetModels modelId:request.modelId];
        [targetModels insertObject:request.oldModel atIndex:subIndex];
    }
}

@end
