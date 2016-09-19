//
//  LDResourceRef.m
//  platform
//
//  Created by bujiong on 16/7/3.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDFmdbProvider.h"

#import "LDResourceRef.h"

@implementation LDResourceRef

+ (NSNumber *)queryRefId:(NSString *)resName resId:(NSNumber *)resId {
    LDFmdbProvider *fmdbProvider = [LDFmdbProvider sharedInstance];
    
    NSNumber *refId = [fmdbProvider querySingledModel:[NSNumber class] sql:@"select refId from ? where resName='?' and resId=?" withArgumentsInArray:@[[fmdbProvider getTableName:[self class]],resName, resId]];
    
    return refId;
}

@end
