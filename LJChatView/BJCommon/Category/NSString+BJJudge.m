//
//  NSString+BJJudge.m
//  BJShop
//
//  Created by 刘俊杰 on 16/11/4.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "NSString+BJJudge.h"

@implementation NSString (BJJudge)

+ (BOOL)lj_isAllNum:(NSString *)string {
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}
+ (BOOL)lj_isPureInteger:(NSString *)str {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSInteger val;
    return [scanner scanInteger:&val] && [scanner isAtEnd];
}

@end
