//
//  LDStateFactory.m
//  platform
//
//  Created by bujiong on 16/7/13.
//  Copyright © 2016年 bujiong. All rights reserved.
//

#import "LDStateFactory.h"

@interface LDStateFactory()

@property(nonatomic, strong) NSDictionary *stateSelectors;

@end

@implementation LDStateFactory

- (LDState *)createState:(LDStateType)stateType {
    LDState *state = nil;
    switch (stateType) {
        case LDStateTypePrepare:
            state = [[NSClassFromString(@"LDPrepareState") alloc] init];
            break;
        case LDStateTypeRun:
            state = [[NSClassFromString(@"LDRunState") alloc] init];
            break;
        case LDStateTypeDone:
            state = [[NSClassFromString(@"LDDoneState") alloc] init];
            break;
        case LDStateTypeCancel:
            state = [[NSClassFromString(@"LDCancelState") alloc] init];
            break;
        default:
            break;
    }
    return state;
}

@end
