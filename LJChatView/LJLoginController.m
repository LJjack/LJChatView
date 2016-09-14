//
//  LJLoginController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJLoginController.h"
#import "TestTim.h"

@interface LJLoginController ()

@end

@implementation LJLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)clickLoginBtn:(UIButton *)sender {
    TestTim *test = [[TestTim alloc] init];
    [test loginTim];
}
- (IBAction)clickLogoutBtn:(UIButton *)sender {
    TestTim *test = [[TestTim alloc] init];
    [test logout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
