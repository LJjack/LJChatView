//
//  LDRequest.m
//  platform
//
//  Created by bujiong on 16/6/30.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequest.h"
#import "BJURLRequestSerialization.h"
#import "BJUserManager.h"
#import "NSString+LJHash.h"

@interface LDRequest ()

//上传文件基地址
@property(nonatomic, copy) NSString *uploadBaseAddress;

@end

@implementation LDRequest

- (instancetype)init {
    if (self = [super init]) {
        // 配置默认值
        _baseAddress = kAPPBaseAddress;
        self.uploadBaseAddress = @"http://pic.8jiong.cn/api/upfiles/";
        self.timeout = 30;
    }
    return self;
}

- (NSURLRequest *)request {
    NSString *urlParam = @"";
    if (self.urlParam.length) {
        urlParam = [NSString stringWithFormat:@"?%@",self.urlParam];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@%@",  self.baseAddress, self.contextPath, self.methodName, urlParam]];
    
    BJLog(@"==%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:self.timeout];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:self.httpMethod];
    
    if ([self.httpMethod isEqualToString:@"POST"]) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        if (self.isSignature) {
            [self signPOSTRequest:request];
        }
        if (self.formParam.length) {
            request.HTTPBody = [self.formParam dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    if ([self.httpMethod isEqualToString:@"GET"]) {
        if (self.isSignature) {
            // 签名
            [self signGETRequest:request];
        }
    }
    
    
    return request;
}

//上传请求
- (NSURLRequest *)fileRequest {
    
    NSURL *url = [NSURL URLWithString:self.uploadBaseAddress];
    
    BJLog(@"==%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:self.timeout];
    NSMutableArray *uploadFileArray = [NSMutableArray array];
    [self.uploadFileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[path lastPathComponent]];
        NSAssert(fileName && fileName.length, @"文件路径不能为空");
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        NSAssert1(fileData && fileData.length, @"文件路径 %@ 的文件不能为空", path);
        
        NSDictionary *item = @{@"mimeType" : @"binary/any",
                               @"fileName" : fileName,
                               @"data"     : fileData};
        
        [uploadFileArray addObject:item];
    }];
    
    [[BJURLRequestSerialization serialization] uploadFileWithRequest:request fileArray:uploadFileArray];
    
    return request;
}

/**
 电商签名 POST
 "bb=2&aa=1"排序后形成 aa=1&bb=2

 */
- (void)signPOSTRequest:(NSMutableURLRequest *)request {
    NSString *param = @"";
    if (self.formParam.length) {
        NSArray<NSString *> *array = [self.formParam componentsSeparatedByString:@"&"];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        param = [array componentsJoinedByString:@"&"];
    }
    
    BJUser *user = [BJUserManager shareManager].currentUser;
    
    NSString *signmMD5 = [NSString stringWithFormat:@"%@%@%@",user.secret,param,user.accessToken].lj_md5String;
    
    [request setValue:user.accessToken forHTTPHeaderField:@"Access-Token"];
    [request setValue:signmMD5 forHTTPHeaderField:@"signature"];
}

/**
 电商签名 GET
 "bb=2&aa=1"排序后形成 aa=1bb=2
 */
- (void)signGETRequest:(NSMutableURLRequest *)request {
    NSString *param = @"";
    if (self.urlParam.length) {
        NSArray<NSString *> *array = [self.urlParam componentsSeparatedByString:@"&"];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        param = [array componentsJoinedByString:@""];
    }
    
    BJUser *user = [BJUserManager shareManager].currentUser;
    
    NSString *signmMD5 = [NSString stringWithFormat:@"%@%@%@",user.secret,param,user.accessToken].lj_md5String;
    
    [request setValue:user.accessToken forHTTPHeaderField:@"Access-Token"];
    [request setValue:signmMD5 forHTTPHeaderField:@"signature"];
}

- (Class)modelClass {
    NSAssert(self.modelClassString && self.modelClassString.length, @"必须为modelClassString赋值");
    return NSClassFromString(self.modelClassString);
}

@end
