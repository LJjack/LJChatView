//
//  LDHttpClient.m
//  platform
//
//  Created by bujiong on 16/7/2.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDHttpClient.h"
#import "BJUserManager.h"
#import "BJURLRequestSerialization.h"

@implementation LDHttpClient

+ (instancetype)sharedClient {
    static LDHttpClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[LDHttpClient alloc] init];
    });
    
    return client;
}

- (NSURLSessionDataTask *)sendRequest:(LDRequest *)request
              block:(LDCompletionBlock)block {
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data) {
            BJLog(@"data==nil，网络或服务端可能出现问题.error:%@.", error);
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (block) block(data, httpResponse.statusCode, error);
        
    }];
    [dataTask resume];
    return dataTask;
}

- (void)sendFileData:(NSData *)fileData block:(LDCompletionBlock)block {
    NSString *uploadFileURLString = @"http://pic.8jiong.cn/api/upfiles";
    static NSInteger counter = 0;
    
    NSString *accessToken = [BJUserManager shareManager].currentUser.accessToken;
    
    @synchronized(self) {
        ++counter;
    }
    NSString *uid = [NSString stringWithFormat:@"%@-%@", accessToken, @(counter)];
    NSString *urlString = [NSString stringWithFormat:@"%@/token?uid=%@",uploadFileURLString,uid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable token, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !token) {
            BJLog(@"上传图片令牌错误，网络或服务端可能出现问题.error:%@.", error);
            if (block) {
                block(nil, 0, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"上传图片令牌错误"}]);
            }
        } else {
            NSString *uploadURLString = [NSString stringWithFormat:@"%@?uid=%@&token=%@",uploadFileURLString,uid,[[NSString alloc] initWithData:token encoding:NSUTF8StringEncoding]];
            NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadURLString]];
            fileRequest.HTTPMethod = @"POST";
            NSDictionary *item = @{@"mimeType" : @"binary/any",
                                   @"fileName" : @"33.jpg",
                                   @"data"     : fileData};
            
            [[BJURLRequestSerialization serialization] uploadFileWithRequest:fileRequest fileArray:@[item]];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:fileRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error || !data) {
                    BJLog(@"data==nil，网络或服务端可能出现问题.error:%@.", error);
                }
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (block) block(data, httpResponse.statusCode, error);
            }] resume];
            
        }
    }] resume];
}

@end
