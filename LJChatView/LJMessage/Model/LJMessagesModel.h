//
//  LJMessagesModel.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LJMessageDataStateDefine.h"

@class JSQMessage, JSQMessagesBubbleImage, JSQMessagesAvatarImage;

@class TIMConversation, TIMMessage;

@class LJMessagesModel;

NS_ASSUME_NONNULL_BEGIN

@protocol LJMessagesModelDelegate <NSObject>

@optional

/**
 *  将要发送消息
 */
- (void)messagesModelWillSend:(LJMessagesModel *)messagesModel;

/**
 *  完成发送消息
 */
- (void)messagesModelDidSend:(LJMessagesModel *)messagesModel;

/**
 *  失败发送消息
 */

- (void)messagesModelFailSend:(LJMessagesModel *)messagesModel;



/**
 *  准备将要接受消息
 */
- (void)messagesModelPrepareWillReveice:(LJMessagesModel *)messagesModel;

/**
 *  将要接受消息
 */
- (void)messagesModelWillReveice:(LJMessagesModel *)messagesModel;

/**
 *  完成接受消息
 */
- (void)messagesModelDidReveice:(LJMessagesModel *)messagesModel;

/**
 *  失败接受消息
 */

- (void)messagesModelFailReveice:(LJMessagesModel *)messagesModel;

@end

@interface LJMessagesModel : NSObject

@property (nonatomic, strong) TIMConversation *chatingConversation; //<! 当前会话

@property (nonatomic, strong) NSMutableArray<JSQMessage *> *messages;

@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImgOther;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImgSelf;

@property (nonatomic, weak) id<LJMessagesModelDelegate> delegate;


+ (instancetype)sharedInstance;

#pragma mark - 发送消息

- (void)sendTextMediaMessageWithText:(NSString *)text;

- (void)sendSoundMediaMessageWithData:(nonnull NSData *)soundData
                               second:(int)second ;

- (void)sendPhotoMediaMessageWithImage:(nonnull id)image;

- (void)sendLocationMediaMessageLatitude:(double)latitude
                               longitude:(double)longitude completion:(void(^)())completion;

- (void)sendShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath
                                      showImage:(nonnull UIImage *)showImage;

- (void)sendVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath
                                 showImage:(nonnull UIImage *)showImage;

#pragma mark - 接受消息

- (void)reveiceMessage:(TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
