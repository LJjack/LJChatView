//
//  UIImage+LJVideo.h
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (LJVideo)

/**
 *  AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
 *
 *  @param sampleBufferRef CMSampleBufferRef
 *
 *  @return CGImageRef
 */
+ (CGImageRef)lj_CGImageRefFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 *  视频截图, 默认截取 1.0 处的图片
 *
 *  @param videoPath 视频地址
 *
 *  @return UIImage
 */
+ (UIImage *)lj_imageVideoCaptureVideoPath:(NSString *)videoPath;

@end
