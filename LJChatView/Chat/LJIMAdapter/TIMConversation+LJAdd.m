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
    
    NSString *name = [lj_lastMessage sender];
    if ([name isEqualToString:@"10000"]) {
        [self setLj_otherName:@"订单消息"];
        [self setLj_otherFaceURL:@"icon-dingdanxinxi"];
        return;
    }
    TIMUserProfile *userProfile = [lj_lastMessage GetSenderProfile];
    if (userProfile) {
        if (userProfile.nickname.length) {
            name = userProfile.nickname;
        }
        [self setLj_otherFaceURL:userProfile.faceURL];

    }
    [self setLj_otherName:name];
    
}

- (TIMMessage *)lj_lastMessage {
   TIMMessage *message = objc_getAssociatedObject(self, "kLastMessage_TIMConversation_LJAdd");
    if (message) {
        [self setLj_lastMessage:message];
        return message;
    }
    
    NSArray *msgs = [self getLastMsgs:1];
    if (msgs.count) {
        [self setLj_lastMessage:msgs.firstObject];
        return msgs.firstObject;
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

- (void)setLj_otherName:(NSString *)lj_otherName {
    objc_setAssociatedObject(self, "kOtherName_TIMConversation_LJAdd", lj_otherName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)lj_otherName {
    NSString *otherName = objc_getAssociatedObject(self, "kOtherName_TIMConversation_LJAdd");
    if (otherName) {
        return otherName;
    }
    
    return nil;
}

- (void)setLj_otherFaceURL:(NSString *)lj_otherFaceURL {
    objc_setAssociatedObject(self, "kOtherFaceUR_TIMConversation_LJAdd", lj_otherFaceURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)lj_otherFaceURL {
    NSString *otherFaceURL = objc_getAssociatedObject(self, "kOtherFaceUR_TIMConversation_LJAdd");
    if (otherFaceURL) {
        return otherFaceURL;
    }
    
    return nil;
}

- (BOOL)isEqual:(TIMConversation *)conv {
    if (self == conv) return YES;
    if (![self isMemberOfClass:[conv class]]) return NO;
    return [self getType] == [conv getType] && [[self getReceiver] isEqualToString:[conv getReceiver]];
}

@end
