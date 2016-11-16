//
//  LJGoodsModel.m
//  BJHybrid
//
//  Created by 刘俊杰 on 16/10/25.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJGoodsModel.h"

#import <YYModel/YYModel.h>

@implementation LJGoodsModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}

- (NSData *)modelToData {
    return [self yy_modelToJSONData];
}

@end
