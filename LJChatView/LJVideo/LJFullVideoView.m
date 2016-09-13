//
//  LJFullVideoView.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/13.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJFullVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface LJFullVideoView ()

@property (nonatomic,   copy) NSString *videoPath;
@property (nonatomic, strong) UIImage  *coverImage;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playItem;

@property (nonatomic, strong) UILabel *tipLabel;

//@property (nonatomic, assign) BOOL   isPlaying;

@end

@implementation LJFullVideoView

- (instancetype)initWithVideoPath:(NSString *)videoPath coverImage:(UIImage *)coverImage {
    CGRect frame = [UIScreen mainScreen].bounds;
    if (self = [super initWithFrame:frame]) {
        self.videoPath = videoPath;
        self.coverImage = coverImage;
        
        [self setupUI];
        [self setupPlayer];
        [self addObserverOrRemove:YES];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTapBack:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showFullVideoView {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    [window addSubview:self];
    
    [self.player play];
}

#pragma mark - Private Methods

- (void)setupUI {
    self.backgroundColor = [UIColor blackColor];
    //提示
    [self addSubview:self.tipLabel];
    self.tipLabel.frame = CGRectMake(0, self.bounds.size.height - 50, self.bounds.size.width, 20);
    //(640x480)
    CGFloat height = self.bounds.size.width * 480/640;
    CGFloat playerLayerY = (self.bounds.size.height - height) * 0.5;
    CGRect playerLayerFrame = CGRectMake(0, playerLayerY, self.bounds.size.width, height);
    
    if (self.coverImage) {
//        self.layer.contents = (__bridge id _Nullable)(self.coverImage.CGImage);
//        self.layer.frame = playerLayerFrame;
    }
    
    [self.layer addSublayer:self.playerLayer];
    
    
    self.playerLayer.frame = playerLayerFrame;
    
//    self.playerBtn.frame = CGRectMake((self.bounds.size.width - 60) * 0.5, (self.bounds.size.height - 60) * 0.5, 60, 60);
}

- (void)addObserverOrRemove:(BOOL)isAdd {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (isAdd) {
        [center addObserver:self selector:@selector(handelDidPlayToEndTimeNotification:)name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    } else {
        [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

- (void)setupPlayer {
    [self.playerLayer setPlayer:self.player];
}

-(void)handelDidPlayToEndTimeNotification:(NSNotification *)notification {
    AVPlayerItem *item = (AVPlayerItem *)notification.object;
    if (self.playItem == item) {
        //到播放开始位置
        [self.player seekToTime:CMTimeMake(0, 1)];
        [self.player play];
        self.tipLabel.hidden = NO;
    }
}

- (void)handelTapBack:(UIGestureRecognizer *)tap {
    [self removeFromSuperview];
}

- (void)dealloc {
    [self addObserverOrRemove:NO];
}

#pragma mark - Getters

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer layer];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerLayer.masksToBounds = YES;
    }
    return _playerLayer;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:self.playItem];
    }
    return _player;
}

- (AVPlayerItem *)playItem {
    if (!_playItem) {
        if (!self.videoPath || !self.videoPath.length) return nil;
        
        _playItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:self.videoPath]];
    }
    return _playItem;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.hidden = YES;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont systemFontOfSize:13];
        _tipLabel.text = @"轻触退出";
    }
    return _tipLabel;
}

@end
