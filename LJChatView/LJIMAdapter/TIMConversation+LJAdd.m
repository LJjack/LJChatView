//
//  TIMConversation+LJAdd.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/22.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "TIMConversation+LJAdd.h"

#import <objc/runtime.h>

@implementation TIMConversation (LJAdd)

- (void)setLj_lsatMessage:(TIMMessage *)lj_lsatMessage {
    objc_setAssociatedObject(self, "TIMConversation_LJAdd_lj_lsatMessage", lj_lsatMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TIMMessage *)lj_lsatMessage {
   TIMMessage *message = objc_getAssociatedObject(self, "TIMConversation_LJAdd_lj_lsatMessage");
    if (message) {
        return message;
    }
    
    NSArray *msgs = [self getLastMsgs:1];
    if (msgs.count) {
        return msgs[0];
    }
    
    return nil;
}

- (BOOL)isEqual:(TIMConversation *)conv {
    NSLog(@"isEqual");
    if (self == conv) return YES;
    if (![self isMemberOfClass:[conv class]]) return NO;
    return [self getType] == [conv getType] && [[self getReceiver] isEqualToString:[conv getReceiver]];
}

@end
