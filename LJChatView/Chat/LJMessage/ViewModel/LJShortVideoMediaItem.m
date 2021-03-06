//
//  LJShortVideoMediaItem.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/9.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJShortVideoMediaItem.h"

#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "LJShortVideoPlayView.h"

@interface LJShortVideoMediaItem ()

@property (nonatomic, strong) LJShortVideoPlayView *playerView;

@property (nonatomic, strong) UIView *cachedVideoView;

@end

@implementation LJShortVideoMediaItem

- (instancetype)initWithVideoPath:(NSString *)videoPath aFrameImage:(UIImage *)aFrameImage {
    self = [super init];
    if (self) {
        _aFrameImage = aFrameImage;
        _videoPath = videoPath;
        _cachedVideoView = nil;
    }
    return self;
}

//开始播放小视频
- (void)play {
    [self.playerView play];
}
//结束播放视频
- (void)pause {
    [self.playerView stop];
}

- (void)clearCachedMediaViews {
    [super clearCachedMediaViews];
    _cachedVideoView = nil;
}

- (void)setVideoPath:(NSString *)videoPath {
    _videoPath = videoPath;
    _cachedVideoView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing {
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVideoView = nil;
}

- (CGSize)mediaViewDisplaySize {
    CGSize size =  [super mediaViewDisplaySize];
    CGFloat height = self.aFrameImage.size.height;
    CGFloat width = self.aFrameImage.size.width;
    
    size.height = size.width/width * height;
    
    return CGSizeMake(240, 180);
}

#pragma mark - JSQMessageMediaData protocol

//JSQ协议方法
- (UIView *)mediaView {
    if (!self.videoPath || !self.videoPath.length) {
        return nil;
    }
    
    if (!self.cachedVideoView) {
        //当前尺寸
        CGSize size = [self mediaViewDisplaySize];
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        self.cachedVideoView = [[UIView alloc] initWithFrame:frame];
        //实例化播放view
        self.playerView = [[LJShortVideoPlayView alloc] initWithFrame:frame videoPath:self.videoPath aFrameImage:self.aFrameImage];
        [self.cachedVideoView addSubview:self.playerView];
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:self.cachedVideoView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    }
    [self.playerView play];
    
    return self.cachedVideoView;
}

- (NSUInteger)mediaHash {
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(LJShortVideoMediaItem *)mediaItem {
    if (![super isEqual:mediaItem]) {
        return NO;
    }
    
    return [self.videoPath isEqualToString:mediaItem.videoPath];
}

- (NSUInteger)hash {
    return super.hash ^ self.videoPath.hash ^ self.aFrameImage.hash;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _aFrameImage = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(aFrameImage))];
        _videoPath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(videoPath))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.aFrameImage forKey:NSStringFromSelector(@selector(aFrameImage))];
    [aCoder encodeObject:self.videoPath forKey:NSStringFromSelector(@selector(videoPath))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    LJShortVideoMediaItem *copy = [[LJShortVideoMediaItem allocWithZone:zone] initWithVideoPath:self.videoPath aFrameImage:self.aFrameImage];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
