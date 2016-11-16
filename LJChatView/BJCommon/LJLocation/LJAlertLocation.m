//
//  LJAlertLocation.m
//  testRoundPlace
//
//  Created by 刘俊杰 on 16/9/2.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJAlertLocation.h"
#import "LJLocationManager.h"

#import <UIKit/UIKit.h>

@implementation LJAlertLocation

+ (BOOL)alertLocationOnController:(UIViewController *)vc {
    
    if (![[LJLocationManager sharedManager] judgeCanLocation]) {
        UIAlertController *alertC =  [UIAlertController alertControllerWithTitle:@"定位不成功" message:@"可能没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            exit(0);
        }]];
        
        [vc presentViewController:alertC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

@end
