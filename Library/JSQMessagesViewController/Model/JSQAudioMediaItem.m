//
//  Created by Jesse Squires
//  License
//  Copyright (c) 2014 Jesse Squires
//

#import "JSQAudioMediaItem.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

@interface JSQAudioMediaItem ()

@property (nonatomic, strong) UIView *cachedMediaView;

@property (nonatomic, strong) UIImageView *audioPlayIndicatorView;

@property (nonatomic, strong) UILabel *audioTimeLabel;

@end


@implementation JSQAudioMediaItem

#pragma mark - Initialization

- (instancetype)initWithPath:(nullable NSString *)audioPath audioTime:(NSInteger)audioTime
{
    if (self = [super init]) {
        _audioPath = [audioPath copy];
        _audioTime = audioTime;
        _cachedMediaView = nil;
    }
    return self;
}
- (instancetype)init {
    return [self initWithPath:nil audioTime:0];
}

- (void)dealloc
{
    _audioPath = nil;
    [self clearCachedMediaViews];
}

- (void)clearCachedMediaViews
{

    _audioTimeLabel = nil;
    _audioPlayIndicatorView = nil;

    _cachedMediaView = nil;
    [super clearCachedMediaViews];
}

#pragma mark - Setters

- (void)setAudioPath:(NSString *)audioPath {
    _audioPath = [audioPath copy];
    [self clearCachedMediaViews];
}

- (void)setAudioTime:(NSInteger)audioTime {
    _audioTime = audioTime;
    [self clearCachedMediaViews];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedMediaView = nil;
}

#pragma mark - Private



- (NSString *)timestampString:(NSInteger)time
{
    //2'24"
    if (time < 60) {
        return [NSString stringWithFormat:@"%@\"", @(time)];
    }
    else {
        return [NSString stringWithFormat:@"%@\':%@\"", @(time / 60), @(time % 60)];
    }
}

- (NSArray *)myAudioPlayIndicatorImages
{
    return @[
             [UIImage imageNamed:@"聊天-icon-语音1-绿"],
             [UIImage imageNamed:@"聊天-icon-语音2-绿"],
             [UIImage imageNamed:@"聊天-icon-语音-绿"],
             ];
}

- (NSArray *)otherAudioPlayIndicatorImages
{
    return @[
             [UIImage imageNamed:@"聊天-icon-语音及切换键盘1-灰"],
             [UIImage imageNamed:@"聊天-icon-语音及切换键盘2-灰"],
             [UIImage imageNamed:@"聊天-icon-语音及切换键盘-灰"],
             
             ];
}

#pragma mark - Pubilc

- (void)startAudioAnimating {
    [self.audioPlayIndicatorView startAnimating];
}

- (void)stopAudioAnimating {
    [self.audioPlayIndicatorView stopAnimating];
}

- (BOOL)isAudioAnimating {
    return [self.audioPlayIndicatorView isAnimating];
}

#pragma mark - JSQMessageMediaData protocol

- (CGSize)mediaViewDisplaySize
{
    NSInteger time = self.audioTime;
    CGFloat width = 80.;
    if (time < 20) {
        width = 80. + time * 9;
    } else {
        width = 280.;
    }
    return CGSizeMake(width, 40.);
}

- (UIView *)mediaView
{
    if (self.audioPath && self.cachedMediaView == nil) {
        
        // create container view for the various controls
        CGSize size = [self mediaViewDisplaySize];
        UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        
        
        playView.contentMode = UIViewContentModeCenter;
        playView.clipsToBounds = NO;
        
        [playView addSubview:self.audioTimeLabel];
        
        self.audioTimeLabel.text = [self timestampString:self.audioTime];
        
        [playView addSubview:self.audioPlayIndicatorView];
    
        if (self.appliesMediaViewMaskAsOutgoing) {
            playView.backgroundColor = [UIColor greenColor];
            UIImage * image = [UIImage imageNamed:@"聊天-icon-语音-绿"];
            self.audioPlayIndicatorView.image = image;
            self.audioPlayIndicatorView.frame = CGRectMake(size.width - size.height - 6, 0, size.height, size.height);
            self.audioTimeLabel.frame = CGRectMake(0, 0, 30, size.height);
            self.audioPlayIndicatorView.animationImages = [self myAudioPlayIndicatorImages];
        } else {
            playView.backgroundColor = [UIColor lightGrayColor];
            playView.backgroundColor = [UIColor greenColor];
            UIImage * image = [UIImage imageNamed:@"聊天-icon-语音及切换键盘-灰"];
            self.audioPlayIndicatorView.image = image;
            self.audioPlayIndicatorView.frame = CGRectMake(6, 0, 30, size.height);
            self.audioTimeLabel.frame = CGRectMake(size.width - size.height, 0, size.height, size.height);
            self.audioPlayIndicatorView.animationImages = [self otherAudioPlayIndicatorImages];
        }
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:playView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedMediaView = playView;
    }

    return self.cachedMediaView;
}

- (UILabel *)audioTimeLabel {
    if (!_audioTimeLabel) {
        _audioTimeLabel = [[UILabel alloc] init];
        _audioTimeLabel.backgroundColor = [UIColor clearColor];
        _audioTimeLabel.textColor = [UIColor colorWithRed:93.f/255.f green:61.f/255.f blue:4.f/255.f alpha:1.f];
        _audioTimeLabel.textAlignment = NSTextAlignmentRight;
        _audioTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _audioTimeLabel;
}

- (UIImageView *)audioPlayIndicatorView {
    if (!_audioPlayIndicatorView) {
        _audioPlayIndicatorView = [[UIImageView alloc] init];
        _audioPlayIndicatorView.contentMode = UIViewContentModeCenter;
        _audioPlayIndicatorView.animationDuration = 0.6;
        [self stopAudioAnimating];
    }
    return _audioPlayIndicatorView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }

    JSQAudioMediaItem *audioItem = (JSQAudioMediaItem *)object;
    if (self.audioPath && ![self.audioPath isEqualToString:audioItem.audioPath]) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash
{
    return super.hash ^ self.audioPath.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: audioPath=%ld bytes, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], (unsigned long)[self.audioPath length],
            @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *string = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(audioPath))];
    NSInteger audioTime = [aDecoder decodeIntForKey:NSStringFromSelector(@selector(audioTime))];
    return [self initWithPath:string audioTime:audioTime];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.audioPath forKey:NSStringFromSelector(@selector(audioPath))];
    [aCoder encodeInt:(int)self.audioTime forKey:NSStringFromSelector(@selector(audioTime))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQAudioMediaItem *copy = [[[self class] allocWithZone:zone] initWithPath:self.audioPath audioTime:self.audioTime];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
