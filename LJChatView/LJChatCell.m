//
//  LJChatCell.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatCell.h"

#import <ImSDK/ImSDK.h>

@interface LJChatCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *destitleLabel;

@end

@implementation LJChatCell

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

- (void)setModel:(TIMConversation *)model {
    _model = model;
    
    if ([model getType] == TIM_C2C) {
        [model getMessage:1 last:nil succ:^(NSArray *msgs) {
            TIMMessage *message = msgs[0];
            self.titleLabel.text = [self showTitleWithMessage:message];
            TIMElem *elem = [message getElem:0];
            if ([elem isKindOfClass:[TIMTextElem class]]) {
                self.destitleLabel.text = [(TIMTextElem *)elem text];
            }
            
        } fail:^(int code, NSString *msg) {
            
        }];
    }
}

- (NSString *)showTitleWithMessage:(TIMMessage *)message {
    if ([message isSelf]) {
        return @"我";
    }
    TIMUserProfile *userProfile = [message GetSenderProfile];
    
    return userProfile.remark ?: userProfile.nickname ?: userProfile.identifier;
}

@end
