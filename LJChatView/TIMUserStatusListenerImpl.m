//
//  TIMUserStatusListenerImpl.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "TIMUserStatusListenerImpl.h"

@implementation TIMUserStatusListenerImpl

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
