//
//  BJContainView.m
//  BJTasty
//
//  Created by 刘俊杰 on 16/6/12.
//  Copyright © 2016年 BJ. All rights reserved.
//

#import "BJContainView.h"
#import <SDAutoLayout/SDAutoLayout.h>
@interface BJContainView ()

@property (nonatomic, strong) UIView *selecedView;

@end

@implementation BJContainView

#pragma mark - Life Cycle

- (instancetype)initWithBlock:(BJContainViewBlock) block {
    if (self = [self init]) {
        _block = block;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        //默认设置
        self.perRowNum = 3;
        self.margin = 1.;
        self.containViewHeight = 50.;
        self.isExistBorder = NO;
    }
    return self;
}

#pragma mark - Private Method

- (void)handelViewsRect {
    if (_containArray.count == 0) {
        self.fixedHeight = @(0);
        return;
    }
    CGFloat itemW = [self itemWidthForViewPathArray:_containArray];
    CGFloat itemH = self.containViewHeight;
    
    NSInteger perRowItemCount = [self perRowItemCountForViewPathArray:_containArray];
    CGFloat margin = _margin;
    [_containArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger columnIndex = idx % perRowItemCount;
        NSInteger rowIndex = idx / perRowItemCount;
        obj.frame = CGRectMake(margin + columnIndex * (itemW + margin), margin + rowIndex * (itemH + margin), itemW, itemH);
    }];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    NSInteger columnCount = ceilf(_containArray.count * 1.0 / perRowItemCount);
    CGFloat height = columnCount * itemH + (columnCount + 1) * margin;
    
    self.fixedHeight = @(height);
    self.fixedWidth = @(width);
}

/**
 * 设置 view 的宽度，规则：
 * 1，当数组的个数大于设置的个数，返回 width
 * 2，当数组的个数小于设置的个数，返回计算过的 width
 */
- (CGFloat)itemWidthForViewPathArray:(NSArray *)array {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat width = (screenWidth - (_perRowNum + 1) *  _margin) / _perRowNum;
    NSUInteger arrayCount = array.count;
    if (arrayCount < _perRowNum) {
        width = (screenWidth - (arrayCount + 1) *  _margin) / arrayCount;;
    }
    return round(width);
}

/**
 * 设置每行的个数，规则：
 * 1，当数组的个数小于设置的个数，直接返回数组的个数
 * 2，当数组的个数大于设置的个数，直接返回设置的个数
 */
- (NSInteger)perRowItemCountForViewPathArray:(NSArray *)array {
    NSUInteger arrayCount = array.count;
    if (arrayCount < _perRowNum) {
        return arrayCount;
    } else return _perRowNum;
}

#pragma mark - Action

- (void)handleTapView:(UITapGestureRecognizer *)tap {
    if (self.isExistBorder) {
        if (self.selecedView) {
            self.selecedView.layer.borderColor = [UIColor colorWithRed:206/255. green:206/255. blue:206/255. alpha:1.0].CGColor;
        }
    }
    
    UIView *view = tap.view;
    if (self.isExistBorder) {
        view.layer.borderColor = [UIColor colorWithRed:242/255. green:98/255. blue:28/255. alpha:1.0].CGColor;
        view.layer.borderWidth = 1.0;
    }
    
    NSUInteger index = view.tag;
    if (_block) {
        _block(index);
    }
    if ([_delegate respondsToSelector:@selector(containView:didClickViewIndex:)]) {
        [_delegate containView:self didClickViewIndex:index];
    }
    if (self.isExistBorder) {
        self.selecedView = view;
    }
    
}

#pragma mark - Getters And Setters

- (void)setContainArray:(NSArray<UIView *> *)containArray {
    _containArray = containArray;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        obj.layer.cornerRadius = 2;
        obj.layer.masksToBounds = YES;
        if (self.isExistBorder) {
            obj.layer.borderColor = [UIColor colorWithRed:206/255. green:206/255. blue:206/255. alpha:1.0].CGColor;
            obj.layer.borderWidth = 0.5;
            if (self.selecedNum == idx) {
                obj.layer.borderColor = [UIColor colorWithRed:242/255. green:98/255. blue:28/255. alpha:1.0].CGColor;
                obj.layer.borderWidth = 1.0;
                self.selecedView = obj;
            }
        }
        
        obj.tag = idx;
        [obj addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapView:)]];
        [self addSubview:obj];
    }];
    
    [self handelViewsRect];
}

- (void)setMargin:(CGFloat)margin {
    _margin = margin;
    if (margin == 1.) return;
    [self handelViewsRect];
}

- (void)setPerRowNum:(NSInteger)perRowNum {
    _perRowNum = perRowNum;
    if (perRowNum == 3) return;
    [self handelViewsRect];
}

- (void)setContainViewHeight:(CGFloat)containViewHeight {
    _containViewHeight = containViewHeight;
    if (containViewHeight == 50)  return;
    [self handelViewsRect];
}

@end
