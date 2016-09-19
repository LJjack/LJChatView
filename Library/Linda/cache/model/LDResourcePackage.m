//
//  LDResourcePackage.m
//  platform
//
//  Created by bujiong on 16/7/3.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDResourceDataSet.h"

#import "LDResourcePackage.h"

@implementation LDResourcePackage

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"allResData": [LDResourceDataSet class]};
}

@end
