//
//  LJShortVideoPlayView.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/9.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJShortVideoPlayView.h"
#import "LJMovieDecoder.h"
#import "LJRoundProgressView.h"

@interface LJShortVideoPlayView ()<LJMovieDecoderDelegate>

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, strong) UIImage *aFrameImage;

@property (nonatomic, strong) UIImageView *maskImageView;

@property (nonatomic, strong) LJRoundProgressView *progressView;

@property (nonatomic, strong) LJMovieDecoder *movieDecoder;

@property (nonatomic, strong) CAKeyframeAnimation *animation;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGAffineTransform layerTransform;

@property (nonatomic, assign) CGRect selfFrame;

@end

@implementation LJShortVideoPlayView

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath aFrameImage:(UIImage *)aFrameImage {
    NSParameterAssert(videoPath != nil);
    NSParameterAssert(aFrameImage != nil);
    
    self = [super initWithFrame:frame];
    if (self) {
        _selfFrame = frame;
        _videoPath = videoPath;
        _aFrameImage = aFrameImage;
        
        [self addUpImageView];
        //程序退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)play {
    [self animationImagesWithImageArray:self.imageArray transform:self.layerTransform duration:self.duration];
}

- (void)stop {
    [self.movieDecoder cancelReading];
}

#pragma mark - Actions

- (void)handleImageViewTapGestureRecognizer:(UIGestureRecognizer *)tap {
    [self handelImagesAsset];
}

#pragma mark - Private Methods

- (void)addUpImageView {
    self.maskImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.maskImageView.userInteractionEnabled = YES;
    self.maskImageView.image = self.aFrameImage;
    CGRect progressFrame = CGRectMake((self.bounds.size.width -75 ) * 0.5, (self.bounds.size.height -75 ) * 0.5, 75, 75);
    self.progressView = [[LJRoundProgressView alloc] initWithFrame:progressFrame];
    self.progressView.startImage = [UIImage imageNamed:@"record_playbutton"];
    [self.maskImageView addSubview:self.progressView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTapGestureRecognizer:)];
    [self.maskImageView addGestureRecognizer:tap];
    [self addSubview:self.maskImageView];
    
}

- (void)handelImagesAsset {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.movieDecoder = [[LJMovieDecoder alloc] init];
        self.movieDecoder.delegate = self;
        [self.movieDecoder startReadVideoPathToSampBufferRef:self.videoPath];
    });
}

- (void)animationImagesWithImageArray:(NSArray *)imageArray transform:(CGAffineTransform)transform duration:(CGFloat)duration {
    if (imageArray.count) {
        // 通过动画来播放我们的图片
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.duration = duration;
        animation.values = imageArray;
        animation.repeatCount = MAXFLOAT;
        
        if ([[self.layer animationKeys] containsObject:@"LJShortVideoPlayViewAnimationKey"]) {
            [self.layer removeAnimationForKey:@"LJShortVideoPlayViewAnimationKey"];
        }
        
        [self.layer addAnimation:animation forKey:@"LJShortVideoPlayViewAnimationKey"];
        self.layer.affineTransform = transform;
        self.imageArray = imageArray.copy;
        self.duration = duration;
        self.layerTransform = transform;
        self.frame = self.selfFrame;
    }
}

#pragma mark - LJMovieDecoderDelegate

- (void)moveDecoder:(LJMovieDecoder *)movieDecoder progress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
    
    
}

- (void)moveDecoderOnDecoderFinished:(LJMovieDecoder *)movieDecoder imageArray:(NSArray *)imageArray transform:(CGAffineTransform)transform duration:(CGFloat)duration {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 1;
        self.maskImageView.hidden = YES;
        [self animationImagesWithImageArray:imageArray transform:transform duration:duration];
        
    });
}

#pragma mark - Notification

- (void)didEnterBackgroundNotification:(NSNotification *)notification {
    [self stop];
}

@end
