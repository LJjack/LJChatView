//
//  GJGCChatInputExpandEmojiPanelMenuBarDataSource.m
//  GJGroupChat
//
//  Created by ZYVincent on 15/6/4.
//  Copyright (c) 2015年 ZYProSoft. All rights reserved.
//

#import "GJGCChatInputExpandEmojiPanelMenuBarDataSource.h"

@implementation GJGCChatInputExpandEmojiPanelMenuBarDataSource

+ (NSArray *)menuBarItems
{
    return @[[GJGCChatInputExpandEmojiPanelMenuBarDataSource simpleEmojiItem]/*,[GJGCChatInputExpandEmojiPanelMenuBarDataSource gifEmojiItem]*/];
}

+ (NSArray *)commentBarItems
{
    return @[[GJGCChatInputExpandEmojiPanelMenuBarDataSource simpleEmojiItem]];
}

+ (GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem *)simpleEmojiItem
{
    GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem *item = [[GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem alloc]init];
    
    item.emojiType = GJGCChatInputExpandEmojiTypeSimple;
    item.emojiListFilePath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
    item.faceEmojiIconName = @"005[微笑]";
    item.isNeedShowSendButton = YES;
    item.isNeedShowRightSideLine = NO;
    
    return item;
}

//+ (GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem *)gifEmojiItem
//{
//    GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem *item = [[GJGCChatInputExpandEmojiPanelMenuBarDataSourceItem alloc]init];
//    
//    item.emojiType = GJGCChatInputExpandEmojiTypeGIF;
//    item.emojiListFilePath = [[NSBundle mainBundle] pathForResource:@"gifEmoji" ofType:@"plist"];
//    item.faceEmojiIconName = @"抠鼻";
//    item.isNeedShowSendButton = NO;
//    item.isNeedShowRightSideLine = YES;
//    
//    return item;
//}

@end
