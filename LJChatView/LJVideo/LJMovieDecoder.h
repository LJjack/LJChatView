//
//  LJMovieDecoder.h
//  TestAV
//
//  Created by 刘俊杰 on 16/8/5.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LJMovieDecoder;

@protocol LJMovieDecoderDelegate <NSObject>

- (void)moveDecoder:(LJMovieDecoder *)movieDecoder progress:(CGFloat)progress;


- (void)moveDecoderOnDecoderFinished:(LJMovieDecoder *)movieDecoder imageArray:(NSArray *)imageArray transform:(CGAffineTransform)transform duration:(CGFloat)duration;

@end



@interface LJMovieDecoder : NSObject

@property (nonatomic, weak) id<LJMovieDecoderDelegate> delegate;

- (void)startReadVideoPathToSampBufferRef:(NSString *)videoPath;

- (void)cancelReading;

@end
