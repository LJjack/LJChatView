//
//  LJIMManagerListener.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMManagerListener.h"

@implementation LJIMManagerListener

#pragma mark- TIMConnListener

/**
 *  网络连接成功
 */
- (void)onConnSucc {
    NSLog(@"网络连接成功");
}

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err {
    NSLog(@"网络连接失败: code=%d, err=%@", code, err);
}

/**
 *  网络连接断开（断线只是通知用户，不需要重新登陆，重连以后会自动上线）
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err {
    NSLog(@"网络连接断开: code=%d, err=%@", code, err);
}


/**
 *  连接中
 */
- (void)onConnecting {
    NSLog(@"连接中");
}

#pragma mark - TIMMessageListener

- (void)onNewMessage:(NSArray*) msgs {
    NSLog(@"NewMessages: %@", msgs);
}


#pragma mark - TIMUserStatusListener

/**
 *  踢下线通知
 */
- (void)onForceOffline {
    NSLog(@"踢下线通知");
}

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err {
    NSLog(@"断线重连失败: code= %d, err=%@",code,err);
}

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired {
    NSLog(@"用户登录的userSig过期（用户需要重新获取userSig后登录）");
}

@end
