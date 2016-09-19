//
//  LDStateJobManager.m
//  platform
//
//  Created by bujiong on 16/7/4.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDStateConsts.h"
#import "LDStateJob.h"
#import "LDRequest.h"

#import "LDStateJobManager.h"

@interface LDStateJobManager()

@property(nonatomic, strong) NSMutableArray<LDStateJob *> *jobQueue;

@end

@implementation LDStateJobManager

+ (instancetype)sharedInstance {
    static LDStateJobManager *instance;
    static dispatch_once_t token;
    
    if (!instance) {
        dispatch_once(&token, ^{
            instance = [[LDStateJobManager alloc] init];
            instance.jobQueue = [NSMutableArray arrayWithCapacity:5];
        });
    }
    
    return instance;
}

- (void)scheduleStateJob:(LDStateJob *)job {
    @synchronized(_jobQueue) {
        [_jobQueue addObject:job];
    }
    
    [job execute];
}

- (void)scheduleRequest:(LDRequest *)request {
    LDStateJob *job = [[LDStateJob alloc] initWithRequest:request];
    [self scheduleStateJob:job];
}

- (BOOL)unscheduleRequest:(NSInteger)requestId {
    
    @synchronized(_jobQueue) {
        for (LDStateJob *job in _jobQueue) {
            if (job.request.requestId.integerValue == requestId) {
                
                return [job cancelled];
            }
        }
    }
    
    return NO;
}

- (void)disposeJob:(NSInteger)requestId {
    @synchronized(_jobQueue) {
        for (NSUInteger i = 0; i < _jobQueue.count; ++i) {
            if (_jobQueue[i].request.requestId.integerValue == requestId) {
                [_jobQueue removeObjectAtIndex:i];
                break;
            }
        }
    }
}


@end
