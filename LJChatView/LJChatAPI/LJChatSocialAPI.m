//
//  LJChatSocialAPI.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/19.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJChatSocialAPI.h"


#import "LJFollowModel.h"

@interface LJChatSocialAPI()



@end

@implementation LJChatSocialAPI

+ (instancetype)sharedInstance {
    static LJChatSocialAPI *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LJChatSocialAPI alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

/**
 *  添加关注
 *
 *  @param targetId 目标用户ID
 *  @param isFriend 是否作为密友
 */
- (void)postFollowWithTargetId:(NSInteger)targetId isFriend:(BOOL)isFriend {
    
}

/**
 *  取消关注
 *
 *  @param targetId 目标用户ID
 */
- (void)deleteUnfollowWithTargetId:(NSInteger)targetId {
    
}

/**
 *  解除密友关系/添加密友关系
 *
 *  @param targetUserId 密友ID
 *  @param isFriend     是否是密友 false 解除密友 true 添加密友
 */
- (void)postAddOrRemoveFriendWithTargetUserId:(NSInteger)targetUserId isFriend:(BOOL)isFriend {
    
}


/**
 *  修改备注名称
 *
 *  @param targetUserId 目标用户
 *  @param memo         备注名称
 */

- (void)postModifyFollowRemarkWithTargetUserId:(NSInteger)targetUserId memo:(NSString *)memo {
    
}

/**
 *  获取我的粉丝
 *
 *  @param offset 偏移量
 */
- (void)GETGetFollowersWithOffset:(NSInteger)offset {
    
}

/**
 *  获取我关注的人
 */
- (void)GETGetFollowees {
    
}

/**
 *  获取相互关注的人
 */
- (void)GETGetEachFollow {
    
}

/**
 *  获取我的密友
 */
- (void)GETGetMiFriends {
    
}

/**
 *  获取好友的好友
 *
 *  @param offset 偏移量
 */
- (void)GETGetSecondFriendWithOffset:(NSInteger)offset {
    
}

/**
 *  获取二维码
 */
- (void)GETGetQrCode {
    
}

/**
 *  一键相互关注
 *
 *  @param qrCode 二维码
 */
- (void)postQuicklyEachFollowWithQrCode:(NSString *)qrCode {
    
}

@end
