//
//  LJIMLoginParam.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/18.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJIMLoginParam.h"

@implementation LJIMLoginParam

+ (instancetype)loginParamWithUserID:(NSString *)userID userToken:(NSString *)userToken {
    return [[LJIMLoginParam alloc] initWithUserID:userID userToken:userToken];
}

- (instancetype)initWithUserID:(NSString *)userID userToken:(NSString *)userToken {
    if (self = [super init]) {
        self.userID = userID;
        self.userToken = userToken;
    }
    return self;
}

@end
