//
//  TIMMessageListenerImpl.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "TIMMessageListenerImpl.h"

@implementation TIMMessageListenerImpl

- (void)onNewMessage:(NSArray*) msgs {
    NSLog(@"NewMessages: %@", msgs);
}

@end
