//
//  BJURLRequestSerialization.m
//  BJNetworking
//
//  Created by 刘俊杰 on 16/7/13.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "BJURLRequestSerialization.h"

@interface BJURLRequestSerialization ()

@end

NSString * const BJFileBoundary = @"c189x0x0x2xAaB03xx";

@implementation BJURLRequestSerialization

+ (instancetype)serialization {
    return [[BJURLRequestSerialization alloc] init];
}

- (void)uploadJSONWithRequest:(NSMutableURLRequest *)request formData:(NSData *)bodyData {
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    // 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%@", @(bodyData.length)];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    // 设置Content-Type
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPShouldHandleCookies:FALSE];
}

- (void)uploadFileWithRequest:(NSMutableURLRequest *)request
                                 fileArray:(NSArray<NSDictionary *> *)fileArray {
    // 1>
    NSMutableData *bodyData = [NSMutableData data];
    [fileArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *data = dict[@"data"];
        if (![data isKindOfClass:[NSData class]]) {
            *stop = YES;
        }
        [self appendBodyData:bodyData fileData:data name:@"uploadFile" fileName:dict[@"fileName"] mimeType:dict[@"mimeType"]];
    }];
    //声明结束符：--c189x0x0x2xAaB03xx--
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--", BJFileBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.HTTPBody = bodyData;
    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%@", @(bodyData.length)];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BJFileBoundary];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
}

#pragma mark - Private Methods

- (void)appendBodyData:(NSMutableData *)bodyData
                      fileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType {
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    
    NSMutableString *strM = [NSMutableString string];
    //分界线 --c189x0x0x2xAaB03xx
    [strM appendFormat:@"--%@\r\n", BJFileBoundary];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name,fileName];
    [strM appendFormat:@"Content-Type: %@\r\n\r\n", mimeType];
    [bodyData appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:data];
    
}

@end
