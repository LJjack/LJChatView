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


@property (nonatomic, assign) CGSize sizeInPixels;

@property (nonatomic, strong) NSMutableArray *imageRefMArray;

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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

#pragma mark - Private Methods

- (void)handelImagesAsset {
    self.imageRefMArray = [NSMutableArray array];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LJMovieDecoder *movieDecoder = [[LJMovieDecoder alloc] init];
        movieDecoder.delegate = self;
        [movieDecoder analyzedVideoPathToSampBufferRef:self.videoPath size:self.bounds.size];
    });
}

- (void)moveDecoder:(LJMovieDecoder *)movieDecoder pixelBuffer:(CVImageBufferRef)imageBuffer progress:(CGFloat)progress {
    CGImageRef imageRef = [UIImage imageFromPixelBuffer:imageBuffer];
    if (!(__bridge id)(imageRef)) { return; }
    
    [self.imageRefMArray addObject:CFBridgingRelease(imageRef)];
}

- (void)moveDecoderOnDecoderFinished:(LJMovieDecoder *)movieDecoder transform:(CGAffineTransform)transform duration:(CFTimeInterval)duration {
    
    [self animationImagesWithTransform:transform duration:duration];
}

- (void)animationImagesWithTransform:(CGAffineTransform)transform duration:(CFTimeInterval)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.animation) {
            [self.layer removeAnimationForKey:@"LJShortVideoPlayViewAnimationKey"];
            [self.layer addAnimation:self.animation forKey:nil];
        } else {
            if (self.imageRefMArray.count) {
                // 通过动画来播放我们的图片
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
                animation.duration = duration;
                animation.values = self.imageRefMArray;
                animation.repeatCount = MAXFLOAT;
                if ([[self.layer animationKeys] containsObject:@"LJShortVideoPlayViewAnimationKey"]) {
                    [self.layer removeAnimationForKey:@"LJShortVideoPlayViewAnimationKey"];
                }
                
                [self.layer addAnimation:animation forKey:@"LJShortVideoPlayViewAnimationKey"];
                self.transform = transform;
                self.animation = animation;
                NSLog(@"==== %@",NSStringFromCGRect(self.frame));
//                self.sizeInPixels = self.frame.size;
            }
        }
       
    });
}

#pragma mark - Public

- (void)play {
    [self animationImagesWithTransform:CGAffineTransformIdentity duration:0];
}

- (void)stop {
    
    
}

#pragma mark - Notification

- (void)didEnterBackgroundNotification:(NSNotification *)notification {
    [self stop];
}

#pragma mark - Getters

- (CGSize)sizeInPixels {
    if (CGSizeEqualToSize(_sizeInPixels, CGSizeZero)) {
        if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
            CGSize pointSize = self.bounds.size;
            return CGSizeMake(self.contentScaleFactor * pointSize.width, self.contentScaleFactor * pointSize.height);
        }
        else {
            return self.bounds.size;
        }
    } else {
        return _sizeInPixels;
    }
}

@end
