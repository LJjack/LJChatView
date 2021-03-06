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
    [self addSubview:self.indicatorView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

- (void)runingAnimating {
    if (![self.indicatorView isAnimating]) {
        [self.indicatorView startAnimating];
    }
    [self setImage:nil forState:UIControlStateNormal];
}

- (BOOL)isAnimating {
    return [self.indicatorView isAnimating];
}

- (void)completedState {
    [self.indicatorView stopAnimating];
    [self setImage:nil forState:UIControlStateNormal];
    self.hidden =YES;
}

- (void)failedState {
    self.hidden = NO;
    if ([self.indicatorView isAnimating]) {
        [self.indicatorView stopAnimating];
    }
    [self setImage:[UIImage imageNamed:@"Sendfailed"] forState:UIControlStateNormal];
}

#pragma mark - Setters

- (void)setDataState:(LJMessageDataState)dataState {
    _dataState = dataState;
    switch (dataState) {
        case LJMessageDataStateRuning: {
            [self runingAnimating];
        } break;
        case LJMessageDataStateCompleted: {
            [self completedState];
        } break;
        case LJMessageDataStateFailed: {
            [self failedState];
        } break;
            
        default:
            break;
    }
}

#pragma mark - Getters

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.userInteractionEnabled = NO;
        _indicatorView.hidesWhenStopped = YES;
        
    }
    return _indicatorView;
}

@end
