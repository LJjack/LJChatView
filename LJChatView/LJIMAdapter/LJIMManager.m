//
//  LJIMManager.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMManager.h"

#import "LJIMManagerListener.h"

#define kSdkAppId       1400012698
#define kSdkAccountType @"6588"

@implementation LJIMManager


+ (instancetype)sharedInstance {
    static LJIMManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LJIMManager alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        LJIMManagerListener * listener = [[LJIMManagerListener alloc] init];
        [[TIMManager sharedInstance] setMessageListener:listener];
        [[TIMManager sharedInstance] setConnListener:listener];
        [[TIMManager sharedInstance] setUserStatusListener:listener];
        //禁用Crash上报，由用户自己上报，如果需要，必须在initSdk之前调用
        [[TIMManager sharedInstance] disableCrashReport];
        
        //初始化日志设置，必须在initSdk之前调用，在initSdk之后设置无效
        [[TIMManager sharedInstance] initLogSettings:NO logPath:nil];
        //登录时禁止拉取最近联系人列表
        [[TIMManager sharedInstance] disableRecentContact];
        
        [[TIMManager sharedInstance] initSdk:kSdkAppId accountType:kSdkAccountType];
        
        TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
        config.openPush = 1;//开启推送
    }
    return self;
}



- (void)loginIM:(LJIMLoginParam *)param succ:(void(^)())succ fail:(void(^)(NSInteger code, NSString * msg))fail {
    TIMLoginParam *loginPatam = [[TIMLoginParam alloc ]init];
    
    // accountType 和 sdkAppId 通讯云管理平台分配
    // identifier为用户名，userSig 为用户登录凭证
    // appidAt3rd 在私有帐号情况下，填写与sdkAppId 一样
    loginPatam.accountType = kSdkAccountType;
    loginPatam.identifier = param.userID;
    loginPatam.userSig = param.userToken;
    loginPatam.appidAt3rd = [NSString stringWithFormat:@"%d",kSdkAppId];
    loginPatam.sdkAppId = kSdkAppId;
    
    [[TIMManager sharedInstance] login:loginPatam succ:^{
        if (succ) succ();
    } fail:^(int code, NSString *msg) {
        if (fail) fail(code, msg);
    }];
}

- (void)logoutIM:(void(^)())succ fail:(void(^)(NSInteger code, NSString * msg))fail {
    [[TIMManager sharedInstance] logout:^() {
        if (succ) succ();
    } fail:^(int code, NSString * err) {
        if (fail) fail(code, err);
    }];
}

@end
