//
//  GJGCChatInputExpandMenuPanelItem.h
//  GJGroupChat
//
//  Created by ZYVincent on 14-10-28.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GJGCChatInputConst.h"

@class GJGCChatInputExpandMenuPanelItem;

typedef void (^GJGCChatInputExpandMenuPanelItemDidTapedBlock) (GJGCChatInputExpandMenuPanelItem *item);

@interface GJGCChatInputExpandMenuPanelItem : UIControl

@property (nonatomic,assign)NSInteger index;

@property (nonatomic,strong)NSDictionary *userInfo;

@property (nonatomic,assign)GJGCChatInputMenuPanelActionType actionType;

+ (GJGCChatInputExpandMenuPanelItem *)itemWithTitle:(NSString *)title iconImageNormal:(UIImage *)iconImageNormal actionType:(GJGCChatInputMenuPanelActionType)actionType tapBlock:(GJGCChatInputExpandMenuPanelItemDidTapedBlock)tapBlock;

@end
