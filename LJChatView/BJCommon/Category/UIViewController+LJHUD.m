//
//  UIViewController+LJHUD.m
//  BuJiong
//
//  Created by 刘俊杰 on 16/6/2.
//  Copyright © 2016年 BuJiong. All rights reserved.
//

#import "UIViewController+LJHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <objc/runtime.h>

static const char LJ_ShowInView_Key;

@implementation UIViewController (LJHUD)

- (UIView *)showInView {
    return objc_getAssociatedObject(self, &LJ_ShowInView_Key);
}

- (void)setShowInView:(UIView *)showInView {
    objc_setAssociatedObject(self, &LJ_ShowInView_Key, showInView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)lj_showHint:(NSString *)hint {
    if (!hint||!hint.length) return;
    //显示提示信息
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (window == nil) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.0];
}

- (void)lj_showHint:(NSString *)hint afterDelay:(NSTimeInterval)delay completionBlock:(void(^)())completionBlock {
    if (!hint||!hint.length) return;
    //显示提示信息
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (window == nil) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.margin = 10.f;
    hud.offset = CGPointMake(hud.offset.x, [UIScreen mainScreen].bounds.size.height * 0.5 - 100);
    hud.removeFromSuperViewOnHide = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        completionBlock?completionBlock():nil;
    });
}

- (void)lj_showHint:(NSString *)hint completionBlock:(void(^)())completionBlock {
    NSTimeInterval delay = 1.5;
    [self lj_showHint:hint afterDelay:delay completionBlock:completionBlock];
}


- (void)lj_showHint:(NSString *)hint yOffset:(CGFloat)yOffset {
    //显示提示信息
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (window == nil) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.margin = 10.f;
    hud.offset = CGPointMake(hud.offset.x, yOffset);
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

#pragma mark 显示风火轮信息
- (void)lj_beginHUDShowMessage:(NSString *)message {
    UIView *view = [[UIApplication sharedApplication].windows firstObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // YES代表需要蒙版效果
    hud.backgroundView.hidden = NO;
}

#pragma mark 隐藏风火轮信息
- (void)lj_endHUDHideMessage {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    // 快速隐藏一个提示信息
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (void)lj_beginHudInView:(UIView *)view message:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // YES代表需要蒙版效果
    hud.backgroundView.hidden = NO;
    [self setShowInView:view];
}

- (void)lj_endHudInView {
    UIView *view = [self showInView];
    // 快速隐藏一个提示信息
    [MBProgressHUD hideHUDForView:view animated:YES];
    objc_removeAssociatedObjects(view);
}

@end
