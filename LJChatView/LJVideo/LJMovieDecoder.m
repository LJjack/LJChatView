//
//  LJMovieDecoder.m
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMovieDecoder.h"
#import <AVFoundation/AVFoundation.h>

#import "UIImage+LJVideo.h"

@interface LJMovieDecoder ()

@property (nonatomic, strong) AVAssetReader *reader;

@property (nonatomic, strong) NSMutableArray *imageRefMArray;

@end

@implementation LJMovieDecoder

- (void)startReadVideoPathToSampBufferRef:(NSString *)videoPath size:(CGSize)size {
    // 获取媒体文件路径的 URL，必须用 fileURLWithPath: 来获取文件 URL
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSError *error = nil;
    self.reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack =[videoTracks objectAtIndex:0];
    //总时间
    Float64 totalTime = CMTimeGetSeconds( asset.duration);
    
    //真实宽高
//    CGSize naturalSize = videoTrack.naturalSize;
    NSDictionary *options = @{
                              (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                              (id)kCVPixelBufferWidthKey:@(size.width),
                              (id)kCVPixelBufferHeightKey:@(size.height)
                              };
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    if ([self.reader canAddOutput:videoReaderOutput]) {
        [self.reader addOutput:videoReaderOutput];
    } else {
        return;
    }
    
    [self.reader startReading];
    self.imageRefMArray = [NSMutableArray array];
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([self.reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        @autoreleasepool {
            // 读取 video sample
            CMSampleBufferRef sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
            if (!sampleBuffer) {
                continue;
            }
            double currentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
            CGImageRef imageRef = [UIImage lj_CGImageRefFromSampleBuffer:sampleBuffer];
            if (imageRef) {
                [self.imageRefMArray addObject:CFBridgingRelease(imageRef)];
                if ([self.delegate respondsToSelector:@selector(moveDecoder:progress:)]) {
                    [self.delegate moveDecoder:self progress:currentTime/totalTime];
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
        // 告诉上层视频解码结束
        if ([self.delegate respondsToSelector:@selector(moveDecoderOnDecoderFinished:imageArray:duration:)]) {
            [self.delegate moveDecoderOnDecoderFinished:self imageArray:self.imageRefMArray.copy duration:totalTime];
        }
    }
}

- (void)cancelReading {
    if (self.reader) {
        [self.reader cancelReading];
    }
}

//需要旋转图片
//- (CGAffineTransform)transformRotateWithTransform:(CGAffineTransform)t {
//    
//    if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
//        // Portrait
//        return CGAffineTransformMakeRotation(M_PI_2);
//    } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
//        // PortraitUpsideDown
//        return CGAffineTransformMakeRotation(-M_PI_2);
//    } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
//        // LandscapeRight
//        return CGAffineTransformMakeRotation(0);
//    } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
//        // LandscapeLeft
//        return CGAffineTransformMakeRotation(M_PI);
//    }
//    return CGAffineTransformMakeRotation(0);
//}

@end
