//
//  LJChatCell.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatCell.h"

#import <ImSDK/ImSDK.h>

#import "TIMConversation+LJAdd.h"

@interface LJChatCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *destitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

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
    TIMMessage *message = model.lj_lastMessage;
    self.titleLabel.text = [self showTitleWithMessage:message];
    TIMElem *elem = [message getElem:0];
    if ([elem isKindOfClass:[TIMTextElem class]]) {
        self.destitleLabel.text = [(TIMTextElem *)elem text];
    } else if ([elem isKindOfClass:[TIMImageElem class]]) {
        self.destitleLabel.text = @"[图片]";
    } else if ([elem isKindOfClass:[TIMLocationElem class]]) {
        self.destitleLabel.text = @"[地理位置]";
    } else if ([elem isKindOfClass:[TIMSoundElem class]]) {
        self.destitleLabel.text = @"[语音]";
    } else if ([elem isKindOfClass:[TIMVideoElem class]]) {
        self.destitleLabel.text = @"[微视频]";
    }
    
    int tipNum = [model getUnReadMessageNum];
    if (tipNum <= 0) {
        self.tipLabel.hidden = YES;
    } else {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:@"%d",tipNum];
    }
    
}

- (NSString *)showTitleWithMessage:(TIMMessage *)message {
    if ([message isSelf]) {
        return @"我";
    }
    TIMUserProfile *userProfile = [message GetSenderProfile];
    NSString *name = userProfile.identifier;
    if (userProfile.nickname.length) {
        name = userProfile.nickname;
        if (userProfile.remark.length) {
            name = userProfile.remark;
        }
    }
    return name;
}

@end
