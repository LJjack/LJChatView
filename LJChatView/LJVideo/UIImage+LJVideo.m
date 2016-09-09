//
//  UIImage+LJVideo.m
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "UIImage+LJVideo.h"
#define clamp(a) (a>255?255:(a<0?0:a))


@implementation UIImage (LJVideo)

// AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
+ (CGImageRef)imageFromPixelBuffer:(CVImageBufferRef)imageBuffer {
    @autoreleasepool {
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        uint8_t *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
        size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
        
        int bytesPerPixel = 4;
        uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
        
        for(int y = 0; y < height; y++) {
            uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
            uint8_t *yBufferLine = &yBuffer[y * yPitch];
            uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
            
            for(int x = 0; x < width; x++) {
                int16_t y = yBufferLine[x];
                int16_t cb = cbCrBufferLine[x & ~1] - 128;
                int16_t cr = cbCrBufferLine[x | 1] - 128;
                
                uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
                
                int16_t r = (int16_t)roundf( y + cr *  1.4 );
                int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
                int16_t b = (int16_t)roundf( y + cb *  1.765);
                
                rgbOutput[0] = 0xff;
                rgbOutput[1] = clamp(b);
                rgbOutput[2] = clamp(g);
                rgbOutput[3] = clamp(r);
            }
        }
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
//        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
//        CGImageRelease(quartzImage);
        free(rgbBuffer);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//        // 锁定 pixel buffer 的基地址
//        CVPixelBufferLockBaseAddress(imageBuffer, 0);
//        
//        // 得到 pixel buffer 的宽和高
//        size_t width = CVPixelBufferGetWidth(imageBuffer);
//        size_t height = CVPixelBufferGetHeight(imageBuffer);
//        // 得到 pixel buffer 的基地址
//        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//        // 得到 pixel buffer 的行字节数
//        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//        
//        // 创建一个依赖于设备的 RGB 颜色空间
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        
//        // 用抽样缓存的数据创建一个位图格式的图形上下文（graphic context）对象
//        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//        
//        //根据这个位图 context 中的像素创建一个 Quartz image 对象
//        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // 解锁 pixel buffer
//        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//        CVPixelBufferRelease(imageBuffer);
//        
//        // 释放 context 和颜色空间
//        CGContextRelease(context);
//        CGColorSpaceRelease(colorSpace);
        
        // 用 Quzetz image 创建一个 UIImage 对象
        // UIImage *image = [UIImage imageWithCGImage:quartzImage];
        
        // 释放 Quartz image 对象
        //    CGImageRelease(quartzImage);
        
        return quartzImage;
    }
}

//视频截图
+ (UIImage *)imageVideoCaptureVideoPath:(NSString *)videoPath {
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
        UIGraphicsBeginImageContext(CGSizeMake(240, 320));
        // 绘制改变大小的图片
        [image drawInRect:CGRectMake(0,0, 240, 320)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
//        NSData *snapshotData = UIImageJPEGRepresentation(scaledImage, 0.75);
//        
//        //保存截图到临时目录
//        NSString *tempDir = NSTemporaryDirectory();
//        NSString *snapshotPath = [NSString stringWithFormat:@"%@%3.f", tempDir, [NSDate timeIntervalSinceReferenceDate]];
//        
//        NSError *err;
//        NSFileManager *fileMgr = [NSFileManager defaultManager];
//        
//        if (![fileMgr createFileAtPath:snapshotPath contents:snapshotData attributes:nil])
//        {
//            DebugLog(@"Upload Image Failed: fail to create uploadfile: %@", err);
//            return nil;
//        }
        return scaledImage;
    }
}

@end
