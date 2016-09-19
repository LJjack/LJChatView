//
//  LDStateJob.m
//  platform
//
//  Created by bujiong on 16/7/4.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDRequest.h"
#import "LDStateConsts.h"
#import "LDState.h"
#import "LDStateFactory.h"
#import "LDStateJobManager.h"

#import "LDStateJob.h"

@implementation LDStateJob

- (instancetype)initWithRequest:(LDRequest *)request {
    _request = request;
    
    return self;
}

- (BOOL)cancelJob {
    
    _cancelled = YES;
    
    if (_running) {
        BJLog(@"请求[%@]已经开始执行，无法撤销", _request.requestId);
        return NO;
    }
    
    BJLog(@"请求[%@]已被标记为撤销", _request.requestId);
    
    return YES;
}

- (void)execute {
    [[[[LDStateFactory alloc] init] createState:LDStateTypePrepare] execute:self];
}

- (void)dispose {
    [[LDStateJobManager sharedInstance] disposeJob:_request.requestId.integerValue];
}

@end
