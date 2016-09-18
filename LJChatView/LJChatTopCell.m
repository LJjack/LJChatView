//
//  LJChatTopCell.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatTopCell.h"
#import "LJChatTopModel.h"

@interface LJChatTopCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LJChatTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Remove seperator inset
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setModel:(LJChatTopModel *)model {
    _model = model;
    self.iconView.image = [UIImage imageNamed:model.iconName];
    self.titleLabel.text = model.title;
}

@end
