//
//  LJOrderMediaItem.m
//  BJShop
//
//  Created by 刘俊杰 on 16/10/28.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJOrderMediaItem.h"

#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import <UIImageView+WebCache.h>

@interface LJOrderMediaItem ()

@property (nonatomic, strong) UIView *cachedView;

@end

@implementation LJOrderMediaItem

- (instancetype)initWithModel:(LJGoodsModel *)model {
    if (self = [super init]) {
        _model = model;
        _cachedView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews {
    [super clearCachedMediaViews];
    _cachedView = nil;
}

- (CGSize)mediaViewDisplaySize {
    
    CGSize size = [self.model.text boundingRectWithSize:CGSizeMake(kScreenWidth * 0.8f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],} context:NULL].size;
    
    return CGSizeMake(size.width + 20, size.height + 20);
}

#pragma mark - Setters

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing {
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedView = nil;
}

- (void)setModel:(LJGoodsModel *)model {
    _model = model;
    [self clearCachedMediaViews];
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView {
    
    if (!self.cachedView && self.model) {
        CGSize size = [self mediaViewDisplaySize];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.clipsToBounds = YES;
        view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, size.width - 20, size.height - 20)];
        label.numberOfLines = 0;
        label.text = self.model.text;
        label.textColor = kBJRGB(84, 84, 84);
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:view isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedView = view;
    }
    
    return _cachedView;
}

- (NSUInteger)mediaHash {
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return super.hash ^ self.model.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: goods=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.model, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(model))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.model forKey:NSStringFromSelector(@selector(model))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    LJOrderMediaItem *copy = [[LJOrderMediaItem allocWithZone:zone] initWithModel:self.model];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
