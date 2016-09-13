//
//  LJMessageStateBtn.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/13.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMessageStateBtn.h"

@interface LJMessageStateBtn ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;


@end

@implementation LJMessageStateBtn

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
//    [self addSubview:self.indicatorView];
    [self insertSubview:self.indicatorView atIndex:0];
    
    [self setImage:[UIImage imageNamed:@"Sendfailed"] forState:UIControlStateNormal];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

- (void)startAnimating {
    [self.indicatorView startAnimating];
    [self setImage:nil forState:UIControlStateNormal];
}
- (void)stopAnimating {
    [self.indicatorView stopAnimating];
    [self setImage:[UIImage imageNamed:@"Sendfailed"] forState:UIControlStateNormal];
}
- (BOOL)isAnimating {
    return [self.indicatorView isAnimating];
}
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.userInteractionEnabled = NO;
        _indicatorView.hidesWhenStopped = YES;
        
    }
    return _indicatorView;
}

@end
