//
//  LJIMManager.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMManager.h"

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
        LJIMManagerListener *listener = [LJIMManagerListener sharedInstance];
        [[TIMManager sharedInstance] setMessageListener:listener];
        [[TIMManager sharedInstance] setConnListener:listener];
        [[TIMManager sharedInstance] setUserStatusListener:listener];
        //禁用Crash上报，由用户自己上报，如果需要，必须在initSdk之前调用
        [[TIMManager sharedInstance] disableCrashReport];
        //初始化日志设置，必须在initSdk之前调用，在initSdk之后设置无效
        [[TIMManager sharedInstance] initLogSettings:NO logPath:nil];
        //初始化SDK
        [[TIMManager sharedInstance] initSdk:kSdkAppId accountType:kSdkAccountType];
        [[TIMManager sharedInstance] setEnv:0];
    }
    return self;
}

- (void)loginIM:(LJIMLoginParam *)param succ:(void(^)())succ fail:(void(^)(NSInteger code, NSString * msg))fail {
    TIMLoginParam *loginPatam = [[TIMLoginParam alloc ]init];
    loginPatam.accountType = kSdkAccountType;
    loginPatam.identifier = param.userID;
    loginPatam.userSig = param.userToken;
    loginPatam.appidAt3rd = [NSString stringWithFormat:@"%d",kSdkAppId];
    loginPatam.sdkAppId = kSdkAppId;
    
    [[TIMManager sharedInstance] login:loginPatam succ:^{
        [LJIMManagerListener sharedInstance].isConnectSucceed = YES;
        [self configAPNS];
        if (succ) succ();
    } fail:^(int code, NSString *msg) {
        [LJIMManagerListener sharedInstance].isConnectSucceed = NO;
        if (fail) fail(code, msg);
    }];
}

- (void)logoutIM:(void(^)())succ fail:(void(^)(NSInteger code, NSString * msg))fail {
    [[TIMManager sharedInstance] logout:^() {
        [LJIMManagerListener sharedInstance].isConnectSucceed = NO;
        if (succ) succ();
    } fail:^(int code, NSString * err) {
        if (fail) fail(code, err);
    }];
}

- (void)configAPNS {
    //设置APNS配置
    TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
    config.openPush = 1;//开启推送
    config.c2cSound = nil;
    [[TIMManager sharedInstance] setAPNS:config succ:^{
        BJLog(@"设置APNS配置 成功");
    } fail:^(int code, NSString *msg) {
        BJLog(@"设置APNS配置失败 code=%d  %@",code,msg);
    }];
}

@end
