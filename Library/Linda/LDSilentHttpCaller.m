//
//  LDSilentHttpCaller.m
//  platform
//
//  Created by cjh on 16/6/30.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "LDHttpConsts.h"
#import "LDDataSource.h"
#import "LDStateJobManager.h"
#import "LDRequestStorage.h"
#import "LDFmdbProvider.h"
#import "NSObject+LDPropertyIterator.h"

#import "LDSilentHttpCaller.h"

#define DEFAULT_DATASOURCE_PERSISTANCE_COUNT     30

#define LOCAL_MODEL_ID_KEY  @"localModelId"

#define MAX_LOCAL_MODEL_ID  9223372036854775807

#define MIN_LOCAL_MODEL_ID  8223372036854775807

@interface LDSilentHttpCaller()

@property(nonatomic, assign) Class modelCls;

@property(nonatomic, strong) LDDataSource *datasource;

@property(nonatomic, strong) LDRequestStorage *storage;

@property(nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *blockMDict;

@end

@implementation LDSilentHttpCaller

- (instancetype)initWithModelCls:(Class)modelCls
                   hasDataSource:(BOOL)hasDataSource
                            name:(NSString *)name {
    if (self = [super init]) {
        _modelCls = modelCls;
        if (hasDataSource) {
            _datasource = [LDDataSource datasourceWithCaller:self persistanceCount:DEFAULT_DATASOURCE_PERSISTANCE_COUNT];
        }
        
        _storage = [[LDRequestStorage alloc] init];
        
        _name = name;
        
        _blockMDict = [NSMutableDictionary dictionary];
        
        // 加载未完成的请求
        NSArray<LDRequest *> *requests = [_storage loadAll:name];
        for (LDRequest *request in requests) {
            if ([request.httpMethod isEqualToString:HTTP_METHOD_GET]) {
                [self get:request];
            } else if ([request.httpMethod isEqualToString:HTTP_METHOD_POST]) {
                [self post:request];
            } else if ([request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
                [self put:request];
            } else if ([request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
                [self del:request];
            } else {
                BJLog(@"不支持的请求类型");
            }
        }
    }
    
    return self;
}

- (void)handleRequestState:(LDStateType)state
                   request:(LDRequest *)request
                  response:(NSData *)response {
    
    LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
    
    if (LDStateTypeDone == state) {
        [_storage remove:request.requestId];
        if (_datasource) {
            // 根据返回结果更新
            if (![request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
                if (_datasource) {
                    [_datasource commitChangeWithResponse:response request:request];
                } else {
                    id model = [_modelCls yy_modelWithJSON:response];
                    if (![request.httpMethod isEqualToString:HTTP_METHOD_GET]) {
                        [fmdb deleteByKey:_modelCls primaryKeyValue:request.modelId];
                    }
                    [fmdb save:@[model]];
                }
            }
        }
    } else if (LDStateTypeDone == state) {
        // 撤销处理，做还原操作，需要再请求时，把原先的信息记住，放在request中 TODO
        if ([request.httpMethod isEqualToString:HTTP_METHOD_POST]) {
            // 只有数据源支持的情况才会执行POST请求
            [_datasource rollbackChangeWithRequest:request];
        } else if ([request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
            if (_datasource) {
                [_datasource rollbackChangeWithRequest:request];
            } else {
                [fmdb deleteByKey:_modelCls primaryKeyValue:request.modelId];
                [fmdb save:@[request.oldModel]];
            }
        } else if ([request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
            if (_datasource) {
                [_datasource rollbackChangeWithRequest:request];
            } else {
                [fmdb save:@[request.oldModel]];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 通知监听者
        if ([self.delegate respondsToSelector:@selector(handleResponseRequest:response:)]) {
            [self.delegate handleResponseRequest:request response:response];
        }
        
        if ([self.blockMDict.allKeys containsObject:request.description]) {
            LDResponseBlock block = self.blockMDict[request.description];
            if (block) {
                block(request, response);
            }
        }
        
    });
}

- (void)post:(LDRequest *)request {
    
    if (!_datasource) {
        /**
         * 如果没有数据源支持，在POST情况下不保存数据。
         * 也就是说本地不会新增非列表形式的数据，只会
         * 更新非列表形式的数据。
         */
        NSAssert(NO, @"POST请求必须有数据源支持");
        return;
    }
    
    // 使用groupName作为该request有没有存储过的标志
    if (!request.groupName) {
        request.groupName = _name;
        request.httpMethod = HTTP_METHOD_POST;
        
        id model = [self modelFromRequest:request];
        
        // TODO 判断之前有没有添加
        NSNumber *modelId = [_datasource preChangeWithModel:model request:request];
        request.modelId = modelId;
        
        // 有没有重复保存
        [_storage save:request];
    }
    
    [self schedule:request];
}

- (void)post:(LDRequest *)request block:(LDResponseBlock)block {
    self.blockMDict[request.description] = block;
    [self post:request];
}

- (void)get:(LDRequest *)request {
    if (!request.groupName) {
        request.groupName = _name;
        request.httpMethod = HTTP_METHOD_GET;
        
        [_storage save:request];
    }
    
    [self schedule:request];
}

- (void)get:(LDRequest *)request block:(LDResponseBlock)block {
    self.blockMDict[request.description] = block;
    [self get:request];
}

- (void)put:(LDRequest *)request {
    if (!request.groupName) {
        request.groupName = _name;
        request.httpMethod = HTTP_METHOD_PUT;
        
        id model = [self modelFromRequest:request];
        
        if (_datasource) {
            [_datasource preChangeWithModel:model request:request];
        } else {
            LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
            [fmdb save:@[model]];
        }
        
        // 有没有重复保存
        [_storage save:request];
    }
    
    [self schedule:request];
}

- (void)put:(LDRequest *)request block:(LDResponseBlock)block {
    self.blockMDict[request.description] = block;
    [self put:request];
}

- (void)del:(LDRequest *)request {
    if (!request.groupName) {
        request.groupName = _name;
        request.httpMethod = HTTP_METHOD_DELETE;
        
        if (_datasource) {
            [_datasource preChangeWithModel:nil request:request];
        } else {
            LDFmdbProvider *fmdb = [LDFmdbProvider sharedInstance];
            [fmdb deleteByKey:[self modelClassFromRequest:request] primaryKeyValue:request.modelId];
        }
        
        // 有没有重复保存
        [_storage save:request];
    }
    
    [self schedule:request];
}

- (void)del:(LDRequest *)request block:(LDResponseBlock)block {
    self.blockMDict[request.description] = block;
    [self del:request];
}

- (void)schedule:(LDRequest *)request {
    request.block = ^void(LDStateType state, LDRequest *request, NSData *response) {
        [self handleRequestState:state request:request response:response];
    };
    
    [[LDStateJobManager sharedInstance] scheduleRequest:request];
}

- (BOOL)cancelRequestById:(NSInteger)requestId {
    return [[LDStateJobManager sharedInstance] unscheduleRequest:requestId];
}

+ (NSNumber *)createLocalModelId {
    static NSNumber *currentLocalModelId;
    @synchronized(self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (!currentLocalModelId) {
            NSString *savedValue = [userDefaults stringForKey:LOCAL_MODEL_ID_KEY];
            if (!savedValue) {
                currentLocalModelId = [[NSNumber alloc] initWithLongLong:MAX_LOCAL_MODEL_ID];
            } else {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                currentLocalModelId = [formatter numberFromString:savedValue];
            }
        }
        
        currentLocalModelId = @(currentLocalModelId.longLongValue - 1);
    }
    
    return currentLocalModelId;
}

+ (BOOL)isLocalModelId:(NSNumber *)modelId {
    return modelId.longLongValue <= MIN_LOCAL_MODEL_ID;
}

/**
 * 将请求转换成模型
 */
- (id)modelFromRequest:(LDRequest *)request {
    
    if ([request.httpMethod isEqualToString:HTTP_METHOD_GET] ||
        [request.httpMethod isEqualToString:HTTP_METHOD_DELETE]) {
        BJLog(@"GET和DELETE请求无需进行模型转换");
        return nil;
    }
    
    Class modelCls = [self modelClassFromRequest:request];
    if (!modelCls) {
        BJLog(@"没有找到request对应的模型类");
        return nil;
    }
    
    id model = nil;
    
    if ([request.httpMethod isEqualToString:HTTP_METHOD_POST]) {
        model = [modelCls yy_modelWithDictionary:[request getSimplifiedInnerFormDatas]];
        [model setValue:[LDSilentHttpCaller createLocalModelId] forKey:[[LDFmdbProvider sharedInstance] getPrimaryKey:modelCls]];
    } else if ([request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
        
        if (_datasource) {
            model = [_datasource getModelByClass:[self modelClassFromRequest:request] masterId:request.masterModelId modelId:request.modelId];
        } else {
            model = [[LDFmdbProvider sharedInstance] queryByKey:modelCls primaryKeyValue:request.modelId];
        }
        
        [model yy_modelSetWithDictionary:[request getSimplifiedInnerFormDatas]];
    } else {
        BJLog(@"不支持的请求类型");
        return nil;
    }
    
    return model;
}

- (Class)modelClassFromRequest:(LDRequest *)request {
    
    if (!request.masterModelId) {
        return _modelCls;
    }
    
    return NSClassFromString(request.modelCls);
}

@end
