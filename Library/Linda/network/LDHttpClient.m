//
//  LDHttpClient.m
//  platform
//
//  Created by bujiong on 16/7/2.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequest.h"
#import "BJURLRequestSerialization.h"

#import "LDHttpClient.h"

@interface LDHttpClient()

@property(nonatomic, copy) NSString *apiAddr;

@property(nonatomic, copy) NSString *uploadAddr;

@end

@implementation LDHttpClient

+ (instancetype)sharedInstance {
    static LDHttpClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[LDHttpClient alloc] init];
        
        // TEST
        client.apiAddr = @"http://192.168.1.17:8081/api/";
    });
    
    return client;
}

- (void)configClient:(NSDictionary *)configs {
    
}

- (NSURLSession *)createSession {
    return [NSURLSession sharedSession];
}

- (void)sendRequest:(LDRequest *)request
              block:(LDCompletionBlock)block {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@?%@", _apiAddr, request.contextPath, request.methodName, request.urlParams]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:request.timeout];
    
    [urlRequest setHTTPShouldHandleCookies:FALSE];
    [urlRequest setHTTPMethod:request.httpMethod];
    
    if ([request.httpMethod isEqualToString:HTTP_METHOD_POST] ||
        [request.httpMethod isEqualToString:HTTP_METHOD_PUT]) {
        [urlRequest setValue:X_FORM_CONTENT_TYPE forHTTPHeaderField:@"Content-Type"];
    }
    
    if (request.formDatas) {
        urlRequest.HTTPBody = [request.formDatas dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // TODO 签名
    
    NSURLSessionDataTask * dataTask = [[self createSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!data) {
            // 网络问题，或服务端没有应答
            block(HTTP_NO_RESPONSE, nil);
            
            BJLog(@"data==nil，网络或服务端可能出现问题.error:%@.", error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            block(httpResponse.statusCode, data);
        }
        
    }];
    [dataTask resume];
}

- (void)uploadFiles:(NSArray *)files
             params:(NSDictionary *)params
              block:(LDCompletionBlock)block {
    
    NSMutableArray *uploadFileArray = [NSMutableArray arrayWithCapacity:files.count];
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:3];
        item[@"mimeType"] = @"binary/any";
        item[@"fileName"] = [obj lastPathComponent];
        item[@"data"] = [NSData dataWithContentsOfFile:obj];
        
        [uploadFileArray addObject:item];
    }];
    
    // 上传
    NSURL *url = [NSURL URLWithString:_uploadAddr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [[BJURLRequestSerialization serialization] uploadFileWithRequest:urlRequest fileArray:uploadFileArray];
    NSURLSessionUploadTask *uploadTask = [[self createSession] uploadTaskWithRequest:urlRequest fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        block(httpResponse.statusCode, data);
        
    }];
    
    [uploadTask resume];
}

- (void)downloadFile:(NSString *)url
               block:(LDCompletionBlock)block {
    
}

@end
