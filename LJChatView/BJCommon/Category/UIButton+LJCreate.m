//
//  UIButton+LJCreate.m
//  BJTasty
//
//  Created by 刘俊杰 on 16/5/30.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "UIButton+LJCreate.h"

@implementation UIButton (LJCreate)

+ (UIButton *)lj_createBtnWithTitle:(NSString *)title  {
    return [self lj_createBtnWithTitle:title normalImg:nil];
}

+ (UIButton *)lj_createBtnWithTitle:(NSString *)title
                          normalImg:(UIImage *)normalImg {
    return [self lj_createBtnWithTitle:title normalImg:normalImg highlightedImg:nil];
}

+ (UIButton *)lj_createBtnWithTitle:(NSString *)title
                          normalImg:(UIImage *)normalImg
                        selectedImg:(UIImage *)selectedImg {
    return [self lj_createBtnWithTitle:title normalImg:normalImg highlightedImg:nil selectedImg:selectedImg];
}

+ (UIButton *)lj_createBtnWithNormalImg:(UIImage *)normalImg {
    return [self lj_createBtnWithNormalImg:normalImg highlightedImg:nil];
}

+ (UIButton *)lj_createBtnWithNormalImg:(UIImage *)normalImg
                     highlightedImg:(UIImage *)highlightedImg {
    return [self lj_createBtnWithTitle:nil normalImg:normalImg highlightedImg:highlightedImg];
}

+ (UIButton *)lj_createBtnWithNormalImg:(UIImage *)normalImg
                            selectedImg:(UIImage *)selectedImg {
    return [self lj_createBtnWithTitle:nil normalImg:normalImg highlightedImg:nil selectedImg:selectedImg];
}

+ (UIButton *)lj_createBtnWithTitle:(NSString *)title
                          normalImg:(UIImage *)normalImg
                     highlightedImg:(UIImage *)highlightedImg {
    return [self lj_createBtnWithTitle:title normalImg:normalImg highlightedImg:highlightedImg selectedImg:nil];
}

+ (UIButton *)lj_createBtnWithTitle:(NSString *)title
                          normalImg:(UIImage *)normalImg
                     highlightedImg:(UIImage *)highlightedImg
                        selectedImg:(UIImage *)selectedImg{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title && title.length) {
        [btn setTitle:title forState:UIControlStateNormal];
        //默认 颜色
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if (normalImg) {
        [btn setImage:normalImg forState:UIControlStateNormal];
    }

    if (highlightedImg) {
        [btn setImage:highlightedImg forState:UIControlStateHighlighted];
    }
    
    if (selectedImg) {
        [btn setImage:selectedImg forState:UIControlStateSelected];
    }
    
    return btn;
}

@end
