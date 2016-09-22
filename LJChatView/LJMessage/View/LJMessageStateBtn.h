//
//  LJMessageStateBtn.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/13.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  消息状态
 */
@interface LJMessageStateBtn : UIButton

- (void)runingAnimating;

- (void)completedState;

- (void)failedState;

@end
