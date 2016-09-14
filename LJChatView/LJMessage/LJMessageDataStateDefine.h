//
//  LJMessageDataStateDefine.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#ifndef LJMessageDataStateDefine_h
#define LJMessageDataStateDefine_h

//消息状态
typedef NS_ENUM(NSUInteger, LJMessageDataState) {
    LJMessageDataStateRuning,
    LJMessageDataStateCompleted,
    LJMessageDataStateFailed,
    LJMessageDataStateStop,//停止状态是运行状态转到失败状态
};

#endif /* LJMessageDataStateDefine_h */
