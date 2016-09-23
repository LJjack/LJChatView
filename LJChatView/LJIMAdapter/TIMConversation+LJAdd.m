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

- (void)setLj_lastMessage:(TIMMessage *)lj_lastMessage {
    objc_setAssociatedObject(self, "kLastMessage_TIMConversation_LJAdd", lj_lastMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TIMMessage *)lj_lastMessage {
   TIMMessage *message = objc_getAssociatedObject(self, "kLastMessage_TIMConversation_LJAdd");
    if (message) {
        return message;
    }
    
    NSArray *msgs = [self getLastMsgs:1];
    if (msgs.count) {
        return msgs[0];
    }
    
    return nil;
}

- (void)setLj_TopMessage:(TIMMessage *)lj_TopMessage {
    objc_setAssociatedObject(self, "kTopMessage_TIMConversation_LJAdd", lj_TopMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TIMMessage *)lj_TopMessage {
    TIMMessage *message = objc_getAssociatedObject(self, "kTopMessage_TIMConversation_LJAdd");
    if (message) {
        return message;
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
