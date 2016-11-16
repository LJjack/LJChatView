//
//  NSString+BJHandle.m
//  BJShop
//
//  Created by 刘俊杰 on 16/11/8.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "NSString+BJHandle.h"

@implementation NSString (BJHandle)

+ (NSString *)lj_makeIdValue:(id)value {
    if (!value) return @"";
    
    if (![value isKindOfClass:[NSString class]]) {
        return [value stringValue];
    } else {
        return value;
    }
}

@end
