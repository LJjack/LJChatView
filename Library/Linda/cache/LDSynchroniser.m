//
//  LDSynchroniser.m
//  platform
//
//  Created by bujiong on 16/7/2.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDSynchroniser.h"

#import <YYModel/YYModel.h>

#import "LDHttpClient.h"
#import "LDResourcePackage.h"
#import "LDResourceDataSet.h"
#import "LDResourceRef.h"

#import "LDFmdbProvider.h"


@implementation LDSynchroniser

+ (instancetype)sharedInstance {
    static LDSynchroniser *instance;
    static dispatch_once_t token;
    
    if (!instance) {
        dispatch_once(&token, ^{
            instance = [[LDSynchroniser alloc] init];
        });
    }
    
    return instance;
}

- (void)updateResources:(LDResourcePackage *)package {
    LDFmdbProvider *fmdbProvider = [LDFmdbProvider sharedInstance];
    
    for (LDResourceDataSet *set in package.allResData) {
        
        Class modelClass = NSClassFromString(set.resName);
        NSString *primary = [fmdbProvider getPrimaryKey:modelClass];
        
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:set.items.count];
        for (NSDictionary *item in set.items) {
            // 先更新索引表
            LDResourceRef *ref = [[LDResourceRef alloc] init];
            ref.resName = set.resName;
            ref.resId = [item valueForKey:primary];
            ref.resVersion = [[item valueForKey:set.version] longValue];
            ref.refId = [LDResourceRef queryRefId:set.resName resId:ref.resId];
            
            [fmdbProvider save:@[ref]];
            
            // 更新数据到对应的表中
            
            id model = [modelClass yy_modelWithDictionary:item];
            if (model) {
                [models addObject:model];
            } else {
                BJLog(@"无法将数据转换成模型%@", item);
            }
        }
        
        // 保存
        [fmdbProvider enableDeepPolicy];
        [fmdbProvider save:models];
    }
}

- (void)syncResources:(NSString *)encodedResInfos {
    /*[[LDHttpClient sharedInstance] getWithUserContext:@"sync" method:@"sync" params:@{@"res":encodedResInfos} block:^(NSData *data) {
        // 存储数据，并更新版本
        if (data) {
            LDResourcePackage *package = [LDResourcePackage yy_modelWithJSON:data];
            if (package) {
                [self updateResources:package];
            } else {
                BJLog(@"无法将自动同步数据转换成模型:%@", data);
            }
        } else {
            // 再尝试
        }
    }];*/
}

- (void)prepareChangeWithRequest:(LDRequest *)request {
    
}

- (void)commitChangeWithRequest:(LDRequest *)request response:(LDResponse *)response {
    
}

@end
