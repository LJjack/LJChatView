//
//  LDPrepareState.m
//  platform
//
//  Created by bujiong on 16/7/4.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDStateJob.h"
#import "LDRequest.h"
#import "LDHttpClient.h"

#import "LDPrepareState.h"

@implementation LDPrepareState

- (void)execute:(LDStateJob *)job {
    
    LDStateFactory *factory = [[LDStateFactory alloc] init];
    
    if (!job.request.uploadFiles) {
        [[factory createState:LDStateTypeRun] execute:job];
        return;
    }
    
    if (job.cancelled) {
        [[factory createState:LDStateTypeCancel] execute:job];
        return;
    }
    
    NSMutableDictionary *uploadFiles = [job.request getInnerUploadFiles];
    
    // TODO 上传参数
    NSString *paramName = uploadFiles.allKeys[0];
    [[LDHttpClient sharedInstance] uploadFiles:uploadFiles.allValues params:nil block:^(NSUInteger status, NSData *data) {
        
        if (job.cancelled) {
            [[factory createState:LDStateTypeCancel] execute:job];
            return;
        }
        
        if (HTTP_OK_STATUS == status) {
            
            BJLog(@"上传成功，转入RUN STATE执行");
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            // 将参数更新到formdata
            NSMutableDictionary *formDatas = [job.request getInnerFormDatas];
            job.request.formDatas = nil;
            formDatas[paramName] = [dict.allValues copy];
            [job.request setInnerFormDatas:formDatas];
            
            LDState *state = [[[LDStateFactory alloc] init] createState:LDStateTypeRun];
            [state execute:job];
        } else {
            BJLog(@"PRAPARE STATE 执行失败，一秒后再执行. %@", data);
            
            // 隔一段时间再做
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                LDState *state = [[[LDStateFactory alloc] init] createState:LDStateTypePrepare];
                [state execute:job];
            });
        }
    }];
}

@end
