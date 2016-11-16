//
//  NSDictionary+LJURL.m
//  RJ-DIS-FileQuery
//
//  Created by 刘俊杰 on 16/1/4.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import "NSDictionary+LJURL.h"

@implementation NSDictionary (LJURL)
+ (NSDictionary *)lj_dictionaryWithURLParam:(NSString *)param {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *parameters = [param componentsSeparatedByString:@"&"];
    for(NSString *parameter in parameters) {
        NSArray *contents = [parameter componentsSeparatedByString:@"="];
        if([contents count] == 2) {
            NSString *key = [contents objectAtIndex:0];
            NSString *value = [contents objectAtIndex:1];
            value = [value stringByRemovingPercentEncoding];
            if (key && value) {
                [dict setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSString *)lj_toURLString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [self allKeys]) {
        if ([string length]) {
            [string appendString:@"&"];
        }
        id value = [self objectForKey:key];
        //NSArray
        if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *str in value) {
                if (str) {
                    [string appendFormat:@"%@=%@&", key, [self toStringWithString:str]];
                }
            }
            [string deleteCharactersInRange:NSMakeRange(string.length-1, 1)];
        }
        //NSDictionary
        if ([value isKindOfClass:[NSDictionary class]]) {
            [string appendString:[value lj_toURLString]];
        }
        //NSString
        if ([value isKindOfClass:[NSString class]]) {
            NSString *str = value;
            if (str) {
                [string appendFormat:@"%@=%@", key, [self toStringWithString:str]];
            }
        }
        //NSNumber
        if ([value isKindOfClass:[NSNumber class]]) {
            NSString *str = [value stringValue];
            if (str) {
                [string appendFormat:@"%@=%@", key, [value stringValue]];
            }
        }
        
    }
    return string;
}
//转义字符
- (NSString *)toStringWithString:(NSString *)string {
    //去掉两端的空格
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
//    string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    return string;
}
@end
