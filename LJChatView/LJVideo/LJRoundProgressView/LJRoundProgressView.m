//
//  LJRoundProgressView.m
//  LJRoundProgressView
//
//  Created by 刘俊杰 on 16/8/1.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJRoundProgressView.h"

@interface LJRoundProgressView ()

@property (nonatomic, strong) UIImageView *startImgView;

@end

@implementation LJRoundProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor colorWithWhite:1 alpha:0.45];
        [self addSubview:self.startImgView];
        self.startImgView.frame = self.bounds;
    }
    return self;
}

- (void)dismissWithAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
    
}

#pragma mark - Private Methods

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint centerPoint = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2.0f;
    
    //画一个圆
    CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, (float)(2.0f * M_PI), 0.0f, TRUE);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(trackPath);
    
    _progress = MIN(_progress, 1.0f - FLT_EPSILON);
    CGFloat radians = 0;
    radians = (float)((_progress * 2.0f * M_PI) - M_PI_2);
    
    //画一个饼
    if (_progress > 0.0f) {
        CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius - 4, (float)(3.0f * M_PI_2), radians, YES);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }
}

#pragma mark - Setters

- (void)setProgress:(CGFloat)progress {
    if (progress > 0 && !self.startImgView.hidden) {
        self.startImgView.hidden = YES;
    }
    if (_progress == progress) {
        return;
    }
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)setStartImage:(UIImage *)startImage {
    _startImage = startImage;
    self.startImgView.image = startImage;
}

#pragma mark - Getters

- (UIImageView *)startImgView {
    if (!_startImgView) {
        _startImgView = [[UIImageView alloc] init];
        _startImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _startImgView;
}

@end
