//
//  UIImage+LJVideo.h
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LJVideo)

/**
 *  视频截图, 默认截取 1.0 处的图片
 *
 *  @param videoPath 视频地址
 *
 *  @return UIImage
 */
+ (UIImage *)lj_imageVideoCaptureVideoPath:(NSString *)videoPath;

@end
