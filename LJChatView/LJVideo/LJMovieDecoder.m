//
//  LJMovieDecoder.m
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMovieDecoder.h"

@implementation LJMovieDecoder

- (void)analyzedVideoPathToSampBufferRef:(NSString *)videoPath size:(CGSize)size {
    // 获取媒体文件路径的 URL，必须用 fileURLWithPath: 来获取文件 URL
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack =[videoTracks objectAtIndex:0];
    //总时间
    Float64 totalTime = CMTimeGetSeconds( asset.duration);
    
    //设置宽高
    CGSize naturalSize = videoTrack.naturalSize;
    
//    CGSize outputSize = CGSizeZero;
//    if (self.size.width > videoTrack.naturalSize.width) {
//        outputSize = videoTrack.naturalSize;
//    } else {
//        outputSize= self.size;
//    }
    NSDictionary *options = @{
                              (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                              (id)kCVPixelBufferWidthKey:@(naturalSize.width),
                              (id)kCVPixelBufferHeightKey:@(naturalSize.height)
                              };
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    [reader addOutput:videoReaderOutput];
    
    [reader startReading];
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        // 读取 video sample
        CMSampleBufferRef sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
        if (!sampleBuffer) {
            continue;
        }
        double currentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
        
        CVImageBufferRef pixBuff = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        if ([self.delegate respondsToSelector:@selector(moveDecoder:pixelBuffer:progress:)]) {
            [self.delegate moveDecoder:self pixelBuffer:pixBuff progress:currentTime/totalTime];
        }
        if (sampleBuffer != NULL) {
            CMSampleBufferInvalidate(sampleBuffer);
        }
        
    }
    if ([reader status] == AVAssetReaderStatusCompleted) {
        // 告诉上层视频解码结束
        CGAffineTransform transform = [self transformRotateWithTransform:videoTrack.preferredTransform];
        [self.delegate moveDecoderOnDecoderFinished:self transform:transform duration:totalTime];
    }
}

- (void)startReading {
    
}

- (void)cancelReading {
    
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
