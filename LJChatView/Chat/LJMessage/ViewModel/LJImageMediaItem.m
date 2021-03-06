//
//  LJImageMediaItem.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/20.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJImageMediaItem.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import <MobileCoreServices/UTCoreTypes.h>

@interface LJImageMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;

@end

@implementation LJImageMediaItem

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = [image copy];
        _cachedImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews {
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image {
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing {
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

- (CGSize)mediaViewDisplaySize {
    CGSize size = [super mediaViewDisplaySize];
    if (self.image) {
        CGSize imgSize = self.image.size;
        CGFloat maxWidth = size.width;
        if (imgSize.width > maxWidth) {
            CGFloat height = (maxWidth / imgSize.width) * imgSize.height;
            if (height < 100) {
                maxWidth = size.height;
                height = (maxWidth / imgSize.width) * imgSize.height;
            }
            size.width = ceil(maxWidth);
            size.height = ceil(height);
        }
    }
    
    
    return size;
}
#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView {
    if (self.image == nil) return nil;
    
    if (self.cachedImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    
    return self.cachedImageView;
}

- (NSUInteger)mediaHash {
    return self.hash;
}

- (NSString *)mediaDataType {
    return (NSString *)kUTTypeJPEG;
}

- (id)mediaData {
    return UIImageJPEGRepresentation(self.image, 0.75);
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return super.hash ^ self.image.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    LJImageMediaItem *copy = [[LJImageMediaItem allocWithZone:zone] initWithImage:self.image];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
