//
//  LJShowFPS.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/9.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJShowFPS.h"

#define kSize CGSizeMake(55, 20)

@interface  LJShowFPS ()
{
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    UIFont *_font;
    UIFont *_subFont;
    
    NSTimeInterval _llll;
}

@end

@implementation LJShowFPS

+ (instancetype)sharedInstance {
    static LJShowFPS *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LJShowFPS alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    frame.origin.x = 8;
    frame.origin.y = screenSize.height - kSize.height;
    frame.size = kSize;
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
        
        
        _font = [UIFont fontWithName:@"Menlo" size:14];
        if (_font) {
            _subFont = [UIFont fontWithName:@"Menlo" size:4];
        } else {
            _font = [UIFont fontWithName:@"Courier" size:14];
            _subFont = [UIFont fontWithName:@"Courier" size:4];
        }

        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray* windows = [UIApplication sharedApplication].windows;
            UIWindow *window = [windows objectAtIndex:0];
            [window addSubview:self];
        });
    }
    return self;
}

- (void)dealloc {
    if (_link) {
        [_link invalidate];
        _link = nil;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)] attributes:@{NSFontAttributeName : _font}];
    [text addAttributes:@{NSForegroundColorAttributeName : color} range:NSMakeRange(0, text.length - 3)];
    [text addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(text.length - 3, 3)];
    
    [text addAttributes:@{NSFontAttributeName : _subFont} range:NSMakeRange(text.length - 4, 1)];
    
    self.attributedText = text;
}

@end
