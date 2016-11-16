//
//  LJChatCell.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatCell.h"
#import "LJDateUitilDefine.h"
#import "JSQMessagesTimestampFormatter.h"

#import <ImSDK/ImSDK.h>
#import <UIImageView+WebCache.h>

#import "TIMConversation+LJAdd.h"

@interface LJChatCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *destitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;


@end

@implementation LJChatCell

- (void)setModel:(TIMConversation *)model {
    _model = model;
    
    TIMMessage *message = model.lj_lastMessage;
    [self handleSetupTitleAndFace:message];
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
    } else if ([elem isKindOfClass:[TIMCustomElem class]]) {
        self.destitleLabel.text = @"[商城]";
    }
    
    int tipNum = [model getUnReadMessageNum];
    if (tipNum <= 0) {
        self.tipLabel.hidden = YES;
    } else {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:@"%d",tipNum];
    }
    
    //timestamp
    self.lastTimeLabel.text = [[JSQMessagesTimestampFormatter sharedFormatter] timestampForDate:[message timestamp]];
}

- (void)handleSetupTitleAndFace:(TIMMessage *)message {
    
    NSString *name = [self.model getReceiver];
    if ([name isEqualToString:@"10000"]) {
        self.titleLabel.text = @"订单消息";
        self.iconView.image = [UIImage imageNamed:@"icon-dingdanxinxi"];
        return;
    }
    TIMUserProfile *userProfile = [self.model.lj_lastMessage GetSenderProfile];
    if (userProfile) {
        if (userProfile.nickname.length) {
            name = userProfile.nickname;
        }
        
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:userProfile.faceURL] placeholderImage:[UIImage imageNamed:@"message-touxiang"]];
        
    }
    
    self.titleLabel.text = name;
    
}

@end
