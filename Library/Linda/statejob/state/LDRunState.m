//
//  LDRunState.m
//  platform
//
//  Created by bujiong on 16/7/4.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDHttpClient.h"

#import "LDStateJob.h"
#import "LDRunState.h"

@implementation LDRunState

- (void)execute:(LDStateJob *)job {
    
    LDStateFactory *factory = [[LDStateFactory alloc] init];
    
    // 撤销请求
    if (job.cancelled) {
        [[factory createState:LDStateTypeCancel] execute:job];
        job.running = NO;
        return;
    }
    
    job.running = YES;
    
    [[LDHttpClient sharedInstance] sendRequest:job.request block:^(NSUInteger status, NSData *data) {
        
        if (HTTP_OK_STATUS == status) {
            job.response = data;
            
            [[factory createState:LDStateTypeDone] execute:job];
            
        } else {
            // 打印日志
            BJLog(@"RUN STATE 执行失败，十秒后再执行. %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            job.cancelled = NO;
            job.running = NO;
            
            // 隔一阵子再执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                [[factory createState:LDStateTypeRun] execute:job];
            });
        }
        
    }];
}

@end
