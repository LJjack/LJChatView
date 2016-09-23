//
//  LJMessagesController.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "JSQMessagesViewController.h"

@class LJMessagesModel;

@interface LJMessagesController : JSQMessagesViewController

@property (nonatomic, strong) LJMessagesModel *msgModel;

@end
