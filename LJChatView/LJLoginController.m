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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indView;

@end

@implementation LJLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)clickLoginBtn:(UIButton *)sender {
    [self.indView startAnimating];
    LJIMLoginParam *loginParam = [LJIMLoginParam loginParamWithUserID:@"1474271948862" userToken:@"eJxVkF1PgzAUhv8Ltxppy7d3bCjjY2bLWDK9acpaWINChW7AjP9dbFiMt89z3pz3nC8tS3cPRAhOMZHYaKn2qAHtXmE2CN4yTArJ2gkjy0MA3OSFtR1v6l8OoAWRAcCf5JTVkhdc5aDpmMiBnum6NpoHOl5OZv30uoy2gX9IhC6G5I3ECyNf*068eg*qJR-18ET7vto7d*U5f96E9jY6*ZvYz2R-CX1RdkHWNSuYV6mw8mHQx13wkliH9HMRXZOi3t*W0QqrE1WZqSVEtufOUvIP9q-kzMnx2JxrieUomPrJ9w-*Ulit"];
    NSLog(@"开始登陆");
   [[LJIMManager sharedInstance] loginIM:loginParam succ:^{
        NSLog(@"登录 成功");
       [self.indView stopAnimating];
       [self performSegueWithIdentifier:@"LoginChat" sender:self];
       
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

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"LoginChat"]) {
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
