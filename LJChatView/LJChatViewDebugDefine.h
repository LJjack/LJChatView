//
//  LJChatViewDebugDefine.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#ifndef LJChatViewDebugDefine_h
#define LJChatViewDebugDefine_h

    // 日志

    #ifdef DEBUG

        #ifndef LJDebugLog
            #define LJDebugLog(fmt, ...) NSLog((@"[%s Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
        #endif

    #else

        #ifndef LJDebugLog
            #define LJDebugLog(fmt, ...) // NSLog((@"[%s Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
        #endif

        #define NSLog // NSLog

    #endif

#endif /* LJChatViewDebugDefine_h */
