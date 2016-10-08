//
//  LJMessagesModel.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JSQMessage, JSQMessagesBubbleImage, JSQMessagesAvatarImage;

@class TIMConversation, TIMMessage;

@class LJMessagesModel;

NS_ASSUME_NONNULL_BEGIN

@protocol LJMessagesModelDelegate <NSObject>

@optional

/**
 *  消息将要发送
 */
- (void)messagesModel:(LJMessagesModel *)messagesModel willSendItemAtIndex:(NSUInteger)index;

/**
 *  消息发送完成
 */
- (void)messagesModel:(LJMessagesModel *)messagesModel didSendFinishItemAtIndex:(NSUInteger)index;

/**
 *  消息发送失败
 */

- (void)messagesModel:(LJMessagesModel *)messagesModel didSendFailItemAtIndex:(NSUInteger)index;



/**
 *  准备将要接受消息
 */
- (void)messagesModelPrepareWillReveice:(LJMessagesModel *)messagesModel;

/**
 *  将要接受消息
 */
- (void)messagesModel:(LJMessagesModel *)messagesModel willReveiceItemAtIndex:(NSUInteger)index;

/**
 *  完成接受消息
 */
- (void)messagesModel:(LJMessagesModel *)messagesModel didReveiceFinishItemAtIndex:(NSUInteger)index;

/**
 *  失败接受消息
 */
- (void)messagesModel:(LJMessagesModel *)messagesModel didReveiceFailItemAtIndex:(NSUInteger)index;

@end

@interface LJMessagesModel : NSObject

/**
 当前会话
 */
@property (nonatomic, strong) TIMConversation *chatingConversation; 

@property (nonatomic, strong) NSMutableArray<JSQMessage *> *messages;

@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImgOther;

@property (nonatomic, strong) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImgSelf;

@property (nonatomic, weak) id<LJMessagesModelDelegate> delegate;

@property (nonatomic, copy) NSString *otherName;


+ (instancetype)sharedInstance;

#pragma mark - 发送消息

- (void)sendTextMediaMessageWithText:(NSString *)text;

- (void)sendSoundMediaMessageWithData:(nonnull NSData *)soundData
                               second:(int)second ;

- (void)sendPhotoMediaMessageWithImage:(nonnull id)image;

- (void)sendLocationMediaMessageLatitude:(double)latitude
                               longitude:(double)longitude
                       completionHandler:(void (^)())completion;

- (void)sendShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath
                                      showImage:(nonnull UIImage *)showImage;

- (void)sendVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath
                                 showImage:(nonnull UIImage *)showImage;

#pragma mark - 接受消息
/**
 *  接受消息
 *
 *  @param message 消息
 *  @param isAtTop 是否是新消息，是在数组0位置添加，还是在数组最后追加
 */
- (void)reveiceMessage:(TIMMessage *)message isAtTop:(BOOL)isAtTop ;

#pragma mark - 重新发送

- (void)reSendAtIndex:(NSUInteger)index;

#pragma mark - 删除

- (void)removeAtIndex:(NSUInteger)index;

#pragma mark- 加载更多数据

- (void)loadMoreMessageData:(void(^)())succ fail:(void(^)(int code, NSString *msg))fail;

@end

NS_ASSUME_NONNULL_END
