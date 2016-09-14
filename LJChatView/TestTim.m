//
//  TestTim.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "TestTim.h"

#import <ImSDK/ImSDK.h>
#import "TIMMessageListenerImpl.h"
#import "TIMConnListenerImpl.h"

#import "TIMUserStatusListenerImpl.h"

//==============================

// 用户更新为自己的app配置
// TLS，以及IMSDK相关的配置

#define kTLSAppid       1400001533
#define kSdkAppId       1400001533
#define kSdkAccountType @"792"





@implementation TestTim

- (void)startTestTim {
    TIMManager * manager = [TIMManager sharedInstance];
    
    TIMMessageListenerImpl * msgImpl = [[TIMMessageListenerImpl alloc] init];
    [manager setMessageListener:msgImpl];
    TIMConnListenerImpl *connImpl = [[TIMConnListenerImpl alloc] init];
    
    [manager setConnListener:connImpl];
    //禁用Crash上报，由用户自己上报，如果需要，必须在initSdk之前调用
    [manager disableCrashReport];
    
    //初始化日志设置，必须在initSdk之前调用，在initSdk之后设置无效
    [manager initLogSettings:NO logPath:nil];
    
    [manager initSdk:kSdkAppId accountType:kSdkAccountType];
    

    TIMUserStatusListenerImpl * impl = [[TIMUserStatusListenerImpl alloc] init];
    [[TIMManager sharedInstance] setUserStatusListener : impl];
    
}

- (void)loginTim {
    TIMLoginParam *loginPatam = [[TIMLoginParam alloc ]init];
    
    // accountType 和 sdkAppId 通讯云管理平台分配
    // identifier为用户名，userSig 为用户登录凭证
    // appidAt3rd 在私有帐号情况下，填写与sdkAppId 一样
    loginPatam.accountType = @"107";
    loginPatam.identifier = @"iOS_001";
    loginPatam.userSig = @"usersig";
    loginPatam.appidAt3rd = @"123456";
    
    loginPatam.sdkAppId = 123456;
    
    [[TIMManager sharedInstance] login:loginPatam succ:^{
        NSLog(@"登录 成功");
    } fail:^(int code, NSString *msg) {
         NSLog(@"登录 失败: code=%d err=%@", code, msg);
    }];
}

- (void)logout {
    [[TIMManager sharedInstance] logout:^() {
        NSLog(@"logout succ");
    } fail:^(int code, NSString * err) {
        NSLog(@"logout fail: code=%d err=%@", code, err);
    }];
}
@end
