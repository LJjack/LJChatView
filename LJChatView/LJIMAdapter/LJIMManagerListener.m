//
//  LJIMManagerListener.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMManagerListener.h"
#import "LJMessagesModel.h"

@implementation LJIMManagerListener

#pragma mark- TIMConnListener

//  网络连接成功
- (void)onConnSucc {
    _isConnectSucceed = YES;
    NSLog(@"网络连接成功");
}

// 网络连接失败
- (void)onConnFailed:(int)code err:(NSString*)err {
    _isConnectSucceed = NO;
    NSLog(@"网络连接失败: code=%d, err=%@", code, err);
}

// 网络连接断开（断线只是通知用户，不需要重新登陆，重连以后会自动上线）
- (void)onDisconnect:(int)code err:(NSString*)err {
    _isConnectSucceed = NO;
    NSLog(@"网络连接断开: code=%d, err=%@", code, err);
}

// 连接中
- (void)onConnecting {
    _isConnectSucceed = NO;
    NSLog(@"连接中");
}

#pragma mark - TIMMessageListener

// 新消息回调通知
- (void)onNewMessage:(NSArray*) msgs {
    for (TIMMessage *msg in msgs) {
        TIMConversation *newConversation = [msg getConversation];
        
        //过滤系统消息
        if ([newConversation getType] == TIM_SYSTEM) return;
        
        BOOL isNewConversation = NO;
        for (TIMConversation *oldConversation in self.conversationList) {
            
            NSString *receiverID = [oldConversation getReceiver];
            if ([oldConversation getType] == [newConversation getType] && [receiverID isEqualToString:[newConversation getReceiver]]) {
                if (oldConversation == self.chattingConversation) {
                    //如果是c2c会话，则更新“对方正在输入...”状态
                    BOOL isInputStatus = NO;
                    
                    if (!msg.isSelf) {
                        if ([self.chattingConversation getType] == TIM_C2C) {
                            int elemCount = [msg elemCount];
                            for (int i = 0; i < elemCount; i++) {
                                TIMElem* elem = [msg getElem:i];
                                if ([elem isKindOfClass:[TIMCustomElem class]]) {
                                     isInputStatus = YES;
                                    // [[NSNotificationCenter defaultCenter] postNotificationName:kUserInputStatus object:elemCmd];
                                    NSLog(@"自定义消息 data.length=%d",(int)[(TIMCustomElem *)elem data].length);
                                }
                            }
                        }
                        
                        if (!isInputStatus) {
                            [newConversation setReadMessage];
//                            oldConversation.lastMessage = imamsg;
//                            [_chattingConversation onReceiveNewMessage:imamsg];
                            [[LJMessagesModel sharedInstance] reveiceMessage:msg];
                        }
                    }
                } else {
                  
                }
                isNewConversation = YES;
                break;
            }
        }
        
        if (!isNewConversation) {
            // 说明会话列表中没有该会话，新生建会话，并更新到
            [[TIMManager sharedInstance] getConversationList];
            [self.conversationList insertObject:newConversation atIndex:0];
           
        }
    }
}

#pragma mark - TIMUserStatusListener

// 踢下线通知
- (void)onForceOffline {
    NSLog(@"踢下线通知");
}

// 断线重连失败
- (void)onReConnFailed:(int)code err:(NSString*)err {
    NSLog(@"断线重连失败: code= %d, err=%@",code,err);
}

// 用户登录的userSig过期（用户需要重新获取userSig后登录）
- (void)onUserSigExpired {
    NSLog(@"用户登录的userSig过期（用户需要重新获取userSig后登录）");
}

@end
