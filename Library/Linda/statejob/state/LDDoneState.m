//
//  LDDoneState.m
//  platform
//
//  Created by bujiong on 16/7/4.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDDoneState.h"

#import <YYModel/YYModel.h>

#import "LDStateJob.h"
#import "LDStateJobManager.h"

@implementation LDDoneState

- (void)execute:(LDStateJob *)job {
    
    if (job.request.block) {
        job.request.block(LDStateTypeDone, job.request, job.response);
    }
    
    BJLog(@"请求%@执行完毕", job.request.requestId);
    
    // 执行完毕，移除该job
    [job dispose];
}

@end
