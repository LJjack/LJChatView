//
//  LJIMManager+Chat.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMManager+Chat.h"

@implementation LJIMManager (Chat)

// 获取会话（TIMConversation*）列表
-(NSArray*)getConversationList {
    return [[TIMManager sharedInstance] getConversationList];
}

// 获取会话
-(TIMConversation*)getConversation:(TIMConversationType)type receiver:(NSString *)receiver {
    return [[TIMManager sharedInstance] getConversation:type receiver:receiver];
}

// 删除会话
-(BOOL)deleteConversation:(TIMConversationType)type receiver:(NSString*)receiver {
    return [[TIMManager sharedInstance] deleteConversation:type receiver:receiver];
}

// 删除会话和消息
-(BOOL)deleteConversationAndMessages:(TIMConversationType)type receiver:(NSString*)receiver {
    return [[TIMManager sharedInstance] deleteConversationAndMessages:type receiver:receiver];
}

// 获取会话数量
-(NSUInteger)getConversationCount {
    return [[TIMManager sharedInstance] ConversationCount];
}

// 通过索引获取会话
-(TIMConversation*)getConversationByIndex:(NSUInteger)index {
    return [[TIMManager sharedInstance] getConversationByIndex:(int)index];
}

@end
