//
//  LJShortVideoPlayView.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/9.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJShortVideoPlayView.h"

#import "LJMovieDecoder.h"

#import "UIImage+LJVideo.h"

@interface LJShortVideoPlayView ()<LJMovieDecoderDelegate>

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) UIImage *aFrameImage;

@property (nonatomic, strong) LJMovieDecoder *movieDecoder;

@property (nonatomic, assign) CGSize sizeInPixels;



@property (nonatomic, strong) CAKeyframeAnimation *animation;

@end

@implementation LJShortVideoPlayView

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath aFrameImage:(UIImage *)aFrameImage {
    NSParameterAssert(videoPath != nil);
    NSParameterAssert(aFrameImage != nil);
    
    self = [super initWithFrame:frame];
    if (self) {
        _videoPath = videoPath;
        _aFrameImage = aFrameImage;
        
//        self.layer.contents = (__bridge id _Nullable)(aFrameImage.CGImage);
        [self handelImagesAsset];
        //程序退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)handelImagesAsset {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.movieDecoder = [[LJMovieDecoder alloc] init];
        self.movieDecoder.delegate = self;
        [self.movieDecoder startReadVideoPathToSampBufferRef:self.videoPath size:self.bounds.size];
    });
}

- (void)moveDecoder:(LJMovieDecoder *)movieDecoder progress:(CGFloat)progress {
    
    
}

- (void)moveDecoderOnDecoderFinished:(LJMovieDecoder *)movieDecoder imageArray:(NSArray *)imageArray duration:(CGFloat)duration {
    NSLog(@"333333333");
    [self animationImagesWithImageArray:imageArray duration:duration];
}

- (void)animationImagesWithImageArray:(NSArray *)imageArray duration:(CGFloat)duration {
    NSLog(@"----- %@",[NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.animation) {
            [self play];
        } else {
            if (imageArray.count) {
                // 通过动画来播放我们的图片
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
                animation.duration = duration;
                animation.values = imageArray;
                animation.repeatCount = MAXFLOAT;
                NSLog(@"======== %lu    %.1f",(unsigned long)imageArray.count, duration);
                if ([[self.layer animationKeys] containsObject:@"LJShortVideoPlayViewAnimationKey"]) {
                    [self.layer removeAnimationForKey:@"LJShortVideoPlayViewAnimationKey"];
                }
                
                [self.layer addAnimation:animation forKey:@"LJShortVideoPlayViewAnimationKey"];

                self.animation = animation;
                NSLog(@"==== %@",NSStringFromCGRect(self.frame));
//                self.sizeInPixels = self.frame.size;
            }
        }
       
    });
}



#pragma mark - Public

- (void)play {
    if (self.animation) {
        [self.layer removeAnimationForKey:@"LJShortVideoPlayViewAnimationKey"];
        [self.layer addAnimation:self.animation forKey:nil];
    }
}

- (void)stop {
    
    [self.movieDecoder cancelReading];
}

#pragma mark - Notification

- (void)didEnterBackgroundNotification:(NSNotification *)notification {
    [self stop];
}

@end
