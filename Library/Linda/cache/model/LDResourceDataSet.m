//
//  LDResourceDataSet.m
//  platform
//
//  Created by bujiong on 16/7/3.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDResourceDataSet.h"

@implementation LDResourceDataSet

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"items": [NSDictionary class]};
}

@end
