//
//  LDRequestBuilder.m
//  platform
//
//  Created by bujiong on 16/6/30.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequestBuilder.h"
#import "NSDictionary+LJURL.h"

// requestId计数器
static NSNumber *requestIdCounter;

@interface LDRequestBuilder()

@property (nonatomic, strong) NSNumber *requestId;//主键

@property (nonatomic, strong) LDRequest *request;

@property (nonatomic, strong) NSMutableDictionary *URLParamDicts;
@property (nonatomic, strong) NSMutableDictionary *formDataDicts;
@end

@implementation LDRequestBuilder

@synthesize HTTPPOST = _HTTPPOST;
@synthesize HTTPGET = _HTTPGET;
@synthesize HTTPSign = _HTTPSign;
@synthesize path = _path;
@synthesize method = _method;
@synthesize URLParam = _URLParam;
@synthesize formParam = _formParam;
@synthesize uploadFiles = _uploadFiles;
@synthesize timeout = _timeout;
@synthesize request = _request;

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

- (instancetype)init {
    if (self = [super init]) {
        self.request = [[LDRequest alloc] init];
        self.URLParamDicts = [NSMutableDictionary dictionary];
        self.formDataDicts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (AddNotParam)HTTPPOST {
    if (!_HTTPPOST) {
        __weak typeof(self) weakSelf = self;
        _HTTPPOST = ^() {
                weakSelf.request.httpMethod = @"POST";
            return weakSelf;
        };
    }
    return _HTTPPOST;
}

- (AddNotParam)HTTPGET {
    if (!_HTTPGET) {
        __weak typeof(self) weakSelf = self;
        _HTTPGET = ^() {
                weakSelf.request.httpMethod = @"GET";
            return weakSelf;
        };
    }
    return _HTTPGET;
}

- (AddNotParam)HTTPSign {
    if (!_HTTPSign) {
        __weak typeof(self) weakSelf = self;
        _HTTPSign = ^() {
                weakSelf.request.isSignature = YES;
            return weakSelf;
        };
    }
    return _HTTPSign;
}

- (AddOneStringParam)path {
    if (!_path) {
        __weak typeof(self) weakSelf = self;
        _path = ^(NSString *name) {
               weakSelf.request.contextPath = name;
            return weakSelf;
        };
    }
    return _path;
}

- (AddOneStringParam)method {
    if (!_method) {
        __weak typeof(self) weakSelf = self;
        _method = ^(NSString *name) {
                weakSelf.request.methodName = name;
            return weakSelf;
        };
    }
    return _method;
}

- (AddKeyValue)URLParam {
    if (!_URLParam) {
        __weak typeof(self) weakSelf = self;
        _URLParam = ^(NSString *key, id value) {
            weakSelf.URLParamDicts[key] = value;
            return weakSelf;
        };
    }
    return _URLParam;
}

- (AddKeyValue)formParam {
    if (!_formParam) {
        __weak typeof(self) weakSelf = self;
        _formParam = ^(NSString *key, id value) {
            weakSelf.formDataDicts[key] = value;
            return weakSelf;
        };
    }
    return _formParam;
}

- (AddOneArrayParam)uploadFiles {
    if (!_uploadFiles) {
        __weak typeof(self) weakSelf = self;
        _uploadFiles = ^(NSArray *array) {
                weakSelf.request.uploadFileArray = array;
            return weakSelf;
        };
    }
    return _uploadFiles;
}

- (AddOneIntParam)timeout {
    if (!_timeout) {
        __weak typeof(self) weakSelf = self;
        _timeout = ^(NSInteger num) {
                weakSelf.request.timeout = num;
            return weakSelf;
        };
    }
    return _timeout;
}


- (LDRequest *)buildRequest {
    @synchronized(requestIdCounter) {
        self.request.requestId = requestIdCounter.integerValue + 1;
    }
    if (self.URLParamDicts.allKeys.count) {
        self.request.urlParam = [self.URLParamDicts lj_toURLString];
    }
    
    if (self.formDataDicts.allKeys.count) {
        
        self.request.formParam = [self.formDataDicts lj_toURLString];
    }
    return self.request;
}

@end
