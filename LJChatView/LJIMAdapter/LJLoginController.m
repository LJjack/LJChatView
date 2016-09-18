//
//  LJLoginController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJLoginController.h"
#import "LJIMManager.h"

@interface LJLoginController ()

@end

@implementation LJLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)clickLoginBtn:(UIButton *)sender {
    LJIMLoginParam *loginParam = [LJIMLoginParam loginParamWithUserID:@"1472107542932" userToken:@"eJxVkF1PwjAUhv-LbjWmX-sy4WKRZQ4RJExnuGnK1rEqdKV0soX4353NiPH2ec6b855zcbL5*o4pJUrKDMW6dO4d4NxazDslNKesMlwPGLkhAuAqv7g*iUb*cgBdiDAAf1KUXBpRCZuDxEcQ*C5BIUbjwEnsBvMcrx7SR-36npI8OdTxKslequA4BSrpvdbfTrOC4S6opBc8gaPEkYgWqL752PLMa8Q8meVv8Wa9PLfIr0nKF313zsmy3c82exDtJpPrsvKT2hNtmaElRF4YjNKIA-9XcuSsKJpWGmp6xe1Pvn8Agn1Xjg__"];
   [[LJIMManager sharedInstance] loginIM:loginParam succ:^{
        NSLog(@"登录 成功");
   } fail:^(NSInteger code, NSString *msg) {
       NSLog(@"登录 失败: code=%d err=%@", (int)code, msg);
   }];
    
}
- (IBAction)clickLogoutBtn:(UIButton *)sender {
    
    [[LJIMManager sharedInstance] logoutIM:^{
        NSLog(@"logout succ");
    } fail:^(NSInteger code, NSString *msg) {
        NSLog(@"logout fail: code=%d err=%@", (int)code, msg);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
