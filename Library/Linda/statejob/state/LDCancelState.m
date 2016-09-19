//
//  LDCancelState.m
//  platform
//
//  Created by bujiong on 16/7/4.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDStateJob.h"

#import "LDCancelState.h"

@implementation LDCancelState

- (void)execute:(LDStateJob *)job {
    
    if (job.request.block) {
        job.request.block(LDStateTypeCancel, job.request, nil);
    }
    
    BJLog(@"请求%@被撤销", job.request.requestId);
    
    // 移除
    [job dispose];
}

@end
