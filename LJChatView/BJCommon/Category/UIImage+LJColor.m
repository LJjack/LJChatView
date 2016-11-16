//
//  UIImage+LJColor.m
//  BuJiong
//
//  Created by 刘俊杰 on 16/4/11.
//  Copyright © 2016年 BuJiong. All rights reserved.
//

#import "UIImage+LJColor.h"

@implementation UIImage (LJColor)
+ (UIImage *)lj_imageWithColor:(UIColor *)color {
    return [self lj_imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)lj_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)lj_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    CGContextAddPath(context, path.CGPath);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGFloat cap = cornerRadius;
    if (size.width > cap&&size.height > cap) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(cap, cap, cap, cap)];
    }
    return image;
}
@end
