//
//  LJMessageViewStateBtnDelegate.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JSQMessagesCollectionView;

@protocol LJMessageViewStateBtnDelegate <NSObject>

/**
 *  运行
 */
- (void)messageView:(JSQMessagesCollectionView *)messageView didTapCellStateBtnRuningAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  停止
 */
- (void)messageView:(JSQMessagesCollectionView *)messageView didTapCellStateBtnStopAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
