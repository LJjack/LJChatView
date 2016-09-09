//
//  LJMovieDecoder.h
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LJMovieDecoder;

@protocol LJMovieDecoderDelegate <NSObject>

- (void)moveDecoder:(LJMovieDecoder *)movieDecoder pixelBuffer:(CVImageBufferRef)imageBuffer progress:(CGFloat)progress;

- (void)moveDecoderOnDecoderFinished:(LJMovieDecoder *)movieDecoder transform:(CGAffineTransform)transform duration:(CFTimeInterval)duration;

@end



@interface LJMovieDecoder : NSObject

@property (nonatomic, weak) id<LJMovieDecoderDelegate> delegate;

- (void)analyzedVideoPathToSampBufferRef:(NSString *)videoPath size:(CGSize)size;

- (void)startReading;

- (void)cancelReading;

@end
