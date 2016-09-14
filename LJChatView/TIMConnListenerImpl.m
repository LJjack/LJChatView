//
//  TIMConnListenerImpl.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "TIMConnListenerImpl.h"

@implementation TIMConnListenerImpl

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

@end
