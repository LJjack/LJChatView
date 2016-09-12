//
//  UIImage+LJVideo.m
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "UIImage+LJVideo.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (LJVideo)

//视频截图
+ (UIImage *)lj_imageVideoCaptureVideoPath:(NSString *)videoPath {
    @autoreleasepool {
        if (!videoPath) {
            return nil;
        }
        
        //视频截图
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
        imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
        CMTime time = CMTimeMakeWithSeconds(1.0, 30);   // 1.0为截取视频1.0秒处的图片，30为每秒30帧
        CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        UIGraphicsBeginImageContext(CGSizeMake(240, 180));
        // 绘制改变大小的图片
        [image drawInRect:CGRectMake(0,0, 240, 180)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();

        return scaledImage;
    }
}

@end
