//
//  LJIMManagerListener.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMManagerListener.h"

@implementation LJIMManagerListener

+ (instancetype)sharedInstance {
    static LJIMManagerListener *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LJIMManagerListener alloc] init];
    });
    
    return _instance;
}

// 获取会话（TIMConversation*）列表
-(NSArray*)getConversationList {
    NSArray *list = [[TIMManager sharedInstance] getConversationList];
    self.conversationList = list.mutableCopy;
    TIMConversation *covSlef;
    for (TIMConversation *cov in self.conversationList) {
        NSString *receiver = [cov getReceiver];
        if (!receiver.length) {
            covSlef = cov;
            break;
        }
    }
    [self.conversationList removeObject:covSlef];
    //所有未读消息
    [self updateAllUnreadMessageNum];
    return self.conversationList.copy;
}

// 获取会话
-(TIMConversation*)getConversation:(TIMConversationType)type receiver:(NSString *)receiver {
    self.chattingConversation = [[TIMManager sharedInstance] getConversation:type receiver:receiver];
    //所有未读消息
    [self updateAllUnreadMessageNum];
    return self.chattingConversation;
}

- (void)openNewConversation {
    if ([self.conversationList indexOfObject:self.chattingConversation] != 0) {
        [self.conversationList removeObject:self.chattingConversation];
        [self.conversationList insertObject:self.chattingConversation atIndex:0];
    }
    //设置会话中所有消息为已读状态
    [self.chattingConversation setReadMessage];
    //所有未读消息
    [self updateAllUnreadMessageNum];
    [self updataUIForNotificationCenter];
}

- (BOOL)removeConversationListAtIndex:(NSUInteger)index {
    if (index < self.conversationList.count) {
        TIMConversation *conv = self.conversationList[index];
        [self.conversationList removeObjectAtIndex:index];
        if (conv) {
            //删除会话和消息
            return [[TIMManager sharedInstance] deleteConversationAndMessages:[conv getType] receiver:[conv getReceiver]];
        }
    }
    return NO;
}

- (void)removeAllConversationList {
    [self.conversationList enumerateObjectsUsingBlock:^(TIMConversation * _Nonnull conv, NSUInteger idx, BOOL * _Nonnull stop) {
        //删除会话和消息
        [[TIMManager sharedInstance] deleteConversationAndMessages:[conv getType] receiver:[conv getReceiver]];
    }];
    
    [self.conversationList removeAllObjects];
    self.chattingConversation = nil;
}

#pragma mark - 私有方法

//是当前回话时，更新位置
- (void)updateOnLastMessageChanged:(TIMConversation *)conv {
    if ([_chattingConversation isEqual:conv]) {
        NSUInteger index = [_conversationList indexOfObject:conv];
        if (index == 0) {
            // index == 0 不作处理
            return;
        }
        NSUInteger toindex = [self insertPosition];
        if (index < [_conversationList count]) {
            [_conversationList removeObject:conv];
            [_conversationList insertObject:conv atIndex:toindex];
        } else {
            [_conversationList insertObject:conv atIndex:toindex];
        }
    }
}

- (NSUInteger)insertPosition {
    if (!self.isConnectSucceed) {
        return 1;
    }
    return 0;
}

- (void)updataUIForNotificationCenter {
    [[NSNotificationCenter defaultCenter] postNotificationName:LJIMNotificationCenterUpdataChatUI object:nil];
}

//所有未读消息
- (void)updateAllUnreadMessageNum {
    NSUInteger num = 0;
    for (TIMConversation *conv in self.conversationList) {
        num += [conv getUnReadMessageNum];
    }
    self.allUnreadMessageNum = num;
}

#pragma mark- TIMConnListener

//  网络连接成功
- (void)onConnSucc {
    BJLog(@"网络连接成功");
}

// 网络连接失败
- (void)onConnFailed:(int)code err:(NSString*)err {
    BJLog(@"网络连接失败: code=%d, err=%@", code, err);
}

// 网络连接断开（断线只是通知用户，不需要重新登陆，重连以后会自动上线）
- (void)onDisconnect:(int)code err:(NSString*)err {
    BJLog(@"网络连接断开: code=%d, err=%@", code, err);
}

// 连接中
- (void)onConnecting {
    BJLog(@"连接中");
}

#pragma mark - TIMMessageListener

// 新消息回调通知
- (void)onNewMessage:(NSArray*) msgs {
    for (TIMMessage *msg in msgs) {
        TIMConversation *newConversation = [msg getConversation];
        
        //过滤系统消息
        if ([newConversation getType] == TIM_SYSTEM) return;

        BOOL isNewConversation = YES;
        for (TIMConversation *oldConversation in self.conversationList) {
            if ([newConversation isEqual:oldConversation]) {
                if ([oldConversation isEqual:self.chattingConversation]) {
                    if (!msg.isSelf) {
                        [newConversation setReadMessage];
                        //通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:LJIMNotificationCenterReveicedNewMessage object:msg];
                    }
                    
                    [self updateOnLastMessageChanged:newConversation];
                }
                isNewConversation = NO;
                break;
            }
        }
        if (isNewConversation) {
            [self.conversationList insertObject:newConversation atIndex:0];
        }
    }
    //所有未读消息
    [self updateAllUnreadMessageNum];
    //更新界面
    [self updataUIForNotificationCenter];
}

#pragma mark - TIMUserStatusListener

// 踢下线通知
- (void)onForceOffline {
    self.isConnectSucceed = NO;
    BJLog(@"踢下线通知");
}

// 断线重连失败
- (void)onReConnFailed:(int)code err:(NSString*)err {
    BJLog(@"断线重连失败: code= %d, err=%@",code,err);
}

// 用户登录的userSig过期（用户需要重新获取userSig后登录）
- (void)onUserSigExpired {
    self.isConnectSucceed = NO;
    BJLog(@"用户登录的userSig过期（用户需要重新获取userSig后登录）");
}

@end
