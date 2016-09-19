//
//  NSObject+LDPropertyIterator.m
//  platform
//
//  Created by bujiong on 16/7/3.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+LDPropertyIterator.h"

@implementation NSObject(LDPropertyIterator)

+ (instancetype)iterateProperty:(LDNextPropertyBlock)block {
    
    if (!block) {
        return nil;
    }
    
    static NSDictionary *primitivesNames = nil;
    if (!primitivesNames) {
        primitivesNames = @{@"f":@"float", @"i":@"int", @"d":@"double", @"l":@"long",
                            @"c":@"BOOL", @"s":@"short", @"q":@"long",
                            @"I":@"NSInteger", @"Q":@"NSUInteger", @"B":@"BOOL",
                            @"@?":@"Block"};
    }
    
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
        
        if (!block(propertyName, propertyType, propertyCount)) {
            break;
        }
    }
    
    free(properties);
    
    return nil;
}

@end
