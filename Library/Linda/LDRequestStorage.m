//
//  LDRequestStorage.m
//  platform
//
//  Created by bujiong on 16/7/2.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequestStorage.h"

#import "LDFmdbProvider.h"
#import "LDRequest.h"

@implementation LDRequestStorage

- (void)save:(LDRequest *)request {
    [[LDFmdbProvider sharedInstance] save:@[request]];
}

- (void)remove:(NSNumber *)requestId {
    [[LDFmdbProvider sharedInstance] deleteByKey:[LDRequest class] primaryKeyValue:requestId];
}

- (NSArray<LDRequest *> *)loadAll:(NSString *)groupName {
    [[LDFmdbProvider sharedInstance] createTableIfNotExist:[LDRequest class]];
    return [[LDFmdbProvider sharedInstance] queryMore:[LDRequest class] sqlDict:@{@"groupName":groupName} sortKeys:nil];;
}

@end
