//
//  AppDelegate.m
//  BJShop
//
//  Created by 刘俊杰 on 16/9/26.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "AppDelegate.h"

#import "LDFmdbProvider.h"
#import "LJIMManager.h"
#import "LJLocationManager.h"

#import <ImSDK/ImSDK.h>


#import "NSString+LJAPPInfo.h"

@interface AppDelegate ()

@property (nonatomic, copy) NSDictionary *userInfo;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BJLog(@"%@",NSHomeDirectory());
    self.window.backgroundColor = kBJRGB(239, 239, 244);
    //创建数据库
    [[LDFmdbProvider sharedInstance] fmdbWithDbName:@"BJShopDB"];
    // 开启定位
    [[LJLocationManager sharedManager] startUpdateLocation];
    [LJIMManager sharedInstance];
    //推送
    [self openAPPPushNotification:application options:launchOptions];
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[LJLocationManager sharedManager] stopUpdateLocation];
    __block UIBackgroundTaskIdentifier bgTaskID;
    bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^{
        //不管有没有完成，结束background_task任务
        [application endBackgroundTask:bgTaskID];
        bgTaskID = UIBackgroundTaskInvalid;
    }];
    
    TIMBackgroundParam *param = [[TIMBackgroundParam alloc] init];
    param.c2cUnread = (int)[LJIMManagerListener sharedInstance].allUnreadMessageNum;
    [[TIMManager sharedInstance] doBackground:param succ:^{
        BJLog(@"进入后台成功");
    } fail:^(int code, NSString *msg) {
        BJLog(@"进入后台失败 code=%i  %@",code,msg);
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[LJLocationManager sharedManager] startUpdateLocation];
    [[TIMManager sharedInstance] doForeground];
    
    //清空通知栏消息
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

//注册用户通知设置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    TIMTokenParam * param = [[TIMTokenParam alloc] init];
    param.token = deviceToken;
    param.busiId = 2345;
    
    [[TIMManager sharedInstance] setToken:param];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    BJLog(@"推送失败 %@",error.localizedDescription);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[TIMManager sharedInstance] doForeground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // 处理推送消息
    BJLog(@"userinfo:%@",userInfo);
    
}


#pragma mark - Private Methods

//推送
- (void)openAPPPushNotification:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    //清空通知栏消息
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    self.userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
}

@end
