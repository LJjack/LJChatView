//
//  Created by Jesse Squires
//  License
//  Copyright (c) 2014 Jesse Squires
//

#import "UIImage+JSQMessages.h"

#import "NSBundle+JSQMessages.h"


@implementation UIImage (JSQMessages)

- (UIImage *)jsq_imageMaskedWithColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)jsq_imageOnCenterAddSmallImage:(UIImage *)smallImage size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0,0, size.width, size.height)];
    [smallImage drawInRect:CGRectMake((size.width - smallImage.size.width) * 0.5, (size.height - smallImage.size.height) * 0.5, smallImage.size.width, smallImage.size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* mergeImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return mergeImage;
}

+ (UIImage *)jsq_bubbleImageFromBundleWithName:(NSString *)name
{
    NSBundle *bundle = [NSBundle jsq_messagesAssetBundle];
    NSString *namePath = [NSString stringWithFormat:@"Images/%@",name];
    NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:namePath];
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)jsq_bubbleCompactImage
{
    return [UIImage jsq_bubbleImageFromBundleWithName:@"bubble_min"];
}


+ (UIImage *)jsq_defaultAccessoryImage
{
    return [UIImage jsq_bubbleImageFromBundleWithName:@"clip"];
}

+ (UIImage *)jsq_defaultTypingIndicatorImage
{
    return [UIImage jsq_bubbleImageFromBundleWithName:@"typing"];
}

+ (UIImage *)jsq_defaultPlayImage
{
    
    return [UIImage jsq_bubbleImageFromBundleWithName:@"play"];
}

+ (UIImage *)jsq_defaultPauseImage
{
    return [UIImage jsq_bubbleImageFromBundleWithName:@"pause"];
}

+ (UIImage *)jsq_shareActionImage
{
    return [UIImage jsq_bubbleImageFromBundleWithName:@"share"];
}
@end
