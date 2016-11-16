//
//  NSObject+LDProperty.m
//  platform
//
//  Created by bujiong on 16/7/3.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "NSObject+LDProperty.h"

#import <objc/runtime.h>

@implementation NSObject(LDProperty)

+ (void)ld_iterateProperty:(void (^)(NSString *name, NSString *typeName, BOOL *stop))block {
    
    if (!block) return;
    
    static NSDictionary *primitivesNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        primitivesNames = @{@"f":@"float",
                            @"i":@"int",
                            @"d":@"double",
                            @"l":@"long",
                            @"c":@"BOOL",
                            @"s":@"short",
                            @"q":@"long",
                            @"I":@"NSInteger",
                            @"Q":@"NSUInteger",
                            @"B":@"BOOL"};
    });
    
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        NSString *propertyName = nil;
        NSString *propertyType = nil;
        
        objc_property_t property = properties[i];
        propertyName = @(property_getName(property));
        
        //get property attributes
        const char *attrs = property_getAttributes(property);
        NSScanner *scanner = [NSScanner scannerWithString: @(attrs)];
        [scanner scanUpToString:@"T" intoString: nil];
        [scanner scanString:@"T" intoString:nil];
        
        //check if the property is an instance of a class
        if ([scanner scanString:@"@\"" intoString: &propertyType]) {
            
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                    intoString:&propertyType];
            
        } else if ([scanner scanString:@"{" intoString: &propertyType]) {
            //check if the property is a structure
            [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                intoString:&propertyType];
        } else {
            //the property contains a primitive data type
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                    intoString:&propertyType];
            //get the full name of the primitive type
            propertyType = primitivesNames[propertyType];
        }
        BOOL stop = NO;
        block(propertyName, propertyType, &stop);
        if (stop) {
            break;
        }
    }
    free(properties);
}

@end
