//
//  LJMovieDecoder.m
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMovieDecoder.h"

#import <AVFoundation/AVFoundation.h>

@interface LJMovieDecoder ()

@property (nonatomic, strong) AVAssetReader *reader;

@property (nonatomic, assign) Float64 totalTime;

@property (nonatomic, strong) NSMutableArray *imageRefMArray;

@end


@implementation LJMovieDecoder

- (void)startReadVideoPathToSampBufferRef:(NSString *)videoPath {
    // 获取媒体文件路径的 URL，必须用 fileURLWithPath: 来获取文件 URL
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSError *error = nil;
    self.reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    NSArray *trackArray = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track =[trackArray objectAtIndex:0];
    //总时间
    self.totalTime = CMTimeGetSeconds( asset.duration);
    
    //真实宽高
    CGSize naturalSize = track.naturalSize;
    NSDictionary *options = @{
                              (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                              (id)kCVPixelBufferWidthKey:@(naturalSize.width),
                              (id)kCVPixelBufferHeightKey:@(naturalSize.height)
                              };
    AVAssetReaderTrackOutput *readerOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:options];
    
    readerOutput.alwaysCopiesSampleData = NO;
    if ([self.reader canAddOutput:readerOutput]) {
        [self.reader addOutput:readerOutput];
    } else {
        return;
    }
    [self startReadingWithTrack:track readerTrackOutput:readerOutput];
    
}

- (void)startReadingWithTrack:(AVAssetTrack *)track
            readerTrackOutput:(AVAssetReaderTrackOutput *)readerOutput {
    if (![self.reader startReading]) return;
    
    self.imageRefMArray = [NSMutableArray array];
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([self.reader status] == AVAssetReaderStatusReading && track.nominalFrameRate > 0) {
        @autoreleasepool {
            // 读取 video sample
            CMSampleBufferRef sampleBuffer = [readerOutput copyNextSampleBuffer];
            if (!sampleBuffer) {
                continue;
            }
            double currentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
            if ([self.delegate respondsToSelector:@selector(moveDecoder:progress:)]) {
                [self.delegate moveDecoder:self progress:currentTime/self.totalTime];
            }
            CGImageRef imageRef = [self imageRefFromSampleBuffer:sampleBuffer];
            if (imageRef) {
                [self.imageRefMArray addObject:CFBridgingRelease(imageRef)];
                if ([self.delegate respondsToSelector:@selector(moveDecoder:progress:)]) {
                    [self.delegate moveDecoder:self progress:currentTime/self.totalTime];
                }
            }
            
            if (sampleBuffer != NULL) {
                CMSampleBufferInvalidate(sampleBuffer);
                CFRelease(sampleBuffer);
                sampleBuffer = NULL;
            }
        }
        
    }
    if ([self.reader status] == AVAssetReaderStatusCompleted) {
        [self.reader cancelReading];
        // 告诉上层视频解码结束
        if ([self.delegate respondsToSelector:@selector(moveDecoderOnDecoderFinished:imageArray:transform:duration:)]) {
            CGAffineTransform transform = [self transformRotateWithTransform:track.preferredTransform];
            [self.delegate moveDecoderOnDecoderFinished:self imageArray:self.imageRefMArray.copy transform:transform duration:self.totalTime];
        }
        
    }
    
    
}

- (void)cancelReading {
    if (self.reader) {
        [self.reader cancelReading];
    }
}

// AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
- (CGImageRef)imageRefFromSampleBuffer:(CMSampleBufferRef)sampleBufferRef {
    @autoreleasepool {
        
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
        
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the pixel buffer
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        
        // Get the number of bytes per row for the pixel buffer
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent RGB color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        // Create a Quartz image from the pixel data in the bitmap graphics context
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        return quartzImage;
    }
}


//需要旋转图片
- (CGAffineTransform)transformRotateWithTransform:(CGAffineTransform)t {
    
    if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        // Portrait
        return CGAffineTransformMakeRotation(M_PI_2);
    } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        // PortraitUpsideDown
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        // LandscapeRight
        return CGAffineTransformMakeRotation(0);
    } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        // LandscapeLeft
        return CGAffineTransformMakeRotation(M_PI);
    }
    return CGAffineTransformMakeRotation(0);
}



@end
