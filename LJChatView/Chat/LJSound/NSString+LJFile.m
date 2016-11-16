//
//  NSString+LJFile.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/21.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "NSString+LJFile.h"

@implementation NSString (LJFile)

+ (NSString *)lj_uuid {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strUuid = CFUUIDCreateString(kCFAllocatorDefault,uuid);
    NSString * str = [NSString stringWithString:(__bridge NSString *)strUuid];
    CFRelease(strUuid);
    CFRelease(uuid);
    return  str;
    
}

@end
