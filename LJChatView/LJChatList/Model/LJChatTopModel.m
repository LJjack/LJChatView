//
//  LJChatTopModel.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatTopModel.h"

@implementation LJChatTopModel

+ (NSArray<LJChatTopModel *> *)topCellModelList {
    
    LJChatTopModel *model0 = [[LJChatTopModel alloc] init];
    model0.iconName = @"message-lianxiren";
    model0.title = @"联系人";
    
    LJChatTopModel *model1 = [[LJChatTopModel alloc] init];
    model1.iconName = @"message-gongzhonghao";
    model1.title = @"公众号";
    
    LJChatTopModel *model2 = [[LJChatTopModel alloc] init];
    model2.iconName = @"message-qunliao";
    model2.title = @"群聊";
    
    return @[model0, model1, model2];
}

@end
