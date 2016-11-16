//
//  LJSubtitleCell.m
//  NewBuJiong
//
//  Created by 刘俊杰 on 16/9/5.
//  Copyright © 2016年 不囧. All rights reserved.
//

#import "LJSubtitleCell.h"

@implementation LJSubtitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    //强制使用
    style = UITableViewCellStyleSubtitle;
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self respondsToSelector:@selector(separatorInset)]) {
            self.separatorInset = UIEdgeInsetsZero;
        }
        
        if ([self respondsToSelector:@selector(preservesSuperviewLayoutMargins)]) {
            self.preservesSuperviewLayoutMargins = NO;
        }
        
        if ([self respondsToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        
        self.textLabel.font = [UIFont systemFontOfSize:15.];
        self.textLabel.textColor = kBJRGB(51, 51, 51);
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.];
        self.detailTextLabel.textColor = kBJRGB(102, 102, 102);
        self.tintColor = kBJRGB(255, 174, 0);
    }
    return self;
}

- (void)setSelectedCell:(BOOL)selectedCell {
    _selectedCell = selectedCell;
    self.accessoryType = selectedCell ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
