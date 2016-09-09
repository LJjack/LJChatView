//
//  GJGCChatInputExpandEmojiPanelGifSubItem.m
//  GJGroupChat
//
//  Created by ZYVincent on 15/6/3.
//  Copyright (c) 2015年 ZYProSoft. All rights reserved.
//

#import "GJGCChatInputExpandEmojiPanelGifSubItem.h"

@interface GJGCChatInputExpandEmojiPanelGifSubItem ()

@property (nonatomic,strong)UIImageView *iconImgView;

@end

@implementation GJGCChatInputExpandEmojiPanelGifSubItem

- (instancetype)initWithIconImageName:(NSString *)iconName withTitle:(NSString *)title
{
    if (self = [super init]) {
        
        self.gjcf_width = [UIScreen mainScreen].bounds.size.width*0.25;
        self.gjcf_height = 69;
        
        CGFloat iconWidth = 50.f;
        CGFloat iconOriginY = 6.f;
        
        self.iconImgView = [[UIImageView alloc]init];
        self.iconImgView.gjcf_width = iconWidth;
        self.iconImgView.gjcf_height = iconWidth;
        self.iconImgView.gjcf_top = iconOriginY;
        self.iconImgView.image = [UIImage imageNamed:iconName];
        self.iconImgView.gjcf_centerX = self.gjcf_width/2;
        self.iconImgView.layer.cornerRadius = 1.5f;
        self.iconImgView.userInteractionEnabled = YES;
        [self addSubview:self.iconImgView];
        
        self.iconNameLabel = [[UILabel alloc]init];
        self.iconNameLabel.gjcf_width = self.iconImgView.gjcf_width;
        self.iconNameLabel.gjcf_height = 13.f;
        self.iconNameLabel.gjcf_top = self.iconImgView.gjcf_bottom;
        self.iconNameLabel.gjcf_centerX = self.iconImgView.gjcf_centerX;
        self.iconNameLabel.backgroundColor = [UIColor clearColor];
        self.iconNameLabel.textAlignment = NSTextAlignmentCenter;
        self.iconNameLabel.text = title;
        self.iconNameLabel.textColor = [UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:1.0];
        self.iconNameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.iconNameLabel];
     
        _iconFrame = self.iconImgView.frame;
    }
    return self;
}

- (void)showHighlighted:(BOOL)state
{
    if(state){
        
        self.iconImgView.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];;
        
        return;
    }
    
    self.iconImgView.backgroundColor = [UIColor clearColor];
}

@end
