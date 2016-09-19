//
//  LDRequestBuilder.m
//  platform
//
//  Created by bujiong on 16/6/30.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequestBuilder.h"

#define DEFAULT_TIMEOUT_INTERVAL     20

// requestId计数器
static NSNumber *requestIdCounter;

@interface LDRequestBuilder()

@property(nonatomic, strong) NSNumber *requestId;//主键

@property(nonatomic, strong) NSNumber *modelId;

@property(nonatomic, strong) NSNumber *masterModelId;

@property(nonatomic, copy) NSString *modelCls;

@property(nonatomic, copy) NSString *contextPath;

@property(nonatomic, copy) NSString *methodName;

@property(nonatomic, strong) NSMutableDictionary *params;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray*> *formData;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray*> *uploadFiles;

@property(nonatomic, assign) NSInteger timeout;

@end

@implementation LDRequestBuilder

+ (instancetype)createBuilder {
    static dispatch_once_t token;
    if (!requestIdCounter) {
        dispatch_once(&token, ^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger counter = [defaults integerForKey:@"requestIdCounter"];
            requestIdCounter = @(counter + 1);
        });
    }
    
    return [[LDRequestBuilder alloc] init];
}

- (LDRequestBuilder *)addContextPath:(NSString *)path {
    _contextPath = path;
    return self;
}

- (LDRequestBuilder *)addMethodName:(NSString *)name {
    _methodName = name;
    return self;
}

- (LDRequestBuilder *)addParameter:(NSString *)name value:(id)value {
    if (!_params) {
        _params = [[NSMutableDictionary alloc] init];
    }
    _params[name] = value;
    
    return self;
}

- (LDRequestBuilder *)addFormData:(NSString *)name value:(id)value {
    if (!_formData) {
        _formData = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    NSMutableArray *items = [_formData objectForKey:name];
    if (!items) {
        items = [NSMutableArray arrayWithCapacity:2];
        _formData[name] = items;
    }
    
    [items addObject:value];
    
    return self;
}

- (LDRequestBuilder *)addUploadData:(NSString *)paramName path:(NSString *)path {
    if (!_uploadFiles) {
        _uploadFiles = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    NSMutableArray *files = [_uploadFiles objectForKey:paramName];
    if (!files) {
        files = [NSMutableArray arrayWithCapacity:2];
        _uploadFiles[paramName] = files;
    }
    
    [files addObject:path];
    
    return self;
}

- (LDRequestBuilder *)addTimeout:(NSInteger)timeout {
    _timeout = timeout;
    return self;
}

- (LDRequestBuilder *)addModelId:(NSNumber *)modelId {
    _modelId = modelId;
    return self;
}

- (LDRequestBuilder *)addMasterModelId:(NSNumber *)modelId {
    _masterModelId = modelId;
    return self;
}

- (LDRequestBuilder *)addModelCls:(NSString *)modelCls {
    _modelCls = modelCls;
    return self;
}

- (LDRequest *)build {
    LDRequest *request = [[LDRequest alloc] init];
    @synchronized(requestIdCounter) {
        request.requestId = @(requestIdCounter.integerValue + 1);
    }
    
    request.contextPath = _contextPath;
    request.methodName = _methodName;
    [request setInnerUrlParams:_params];
    [request setInnerFormDatas:_formData];
    [request setInnerUploadFiles:_uploadFiles];
    request.timeout = _timeout ?: DEFAULT_TIMEOUT_INTERVAL;
    request.masterModelId = _masterModelId;
    request.modelId = _modelId;
    request.modelCls = _modelCls;
    
    return request;
}

@end
