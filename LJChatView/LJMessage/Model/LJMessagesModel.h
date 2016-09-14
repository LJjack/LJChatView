//
//  LJMessagesModel.h
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQLocationMediaItem.h"

@class JSQMessage;

@class JSQMessagesBubbleImage;

NS_ASSUME_NONNULL_BEGIN

static NSString * const kJSQDemoAvatarDisplayNameSquires = @"Jesse Squires";
static NSString * const kJSQDemoAvatarDisplayNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarDisplayNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarDisplayNameWoz = @"Steve Wozniak";

static NSString * const kJSQDemoAvatarIdSquires = @"053496-4509-289";
static NSString * const kJSQDemoAvatarIdCook = @"468-768355-23123";
static NSString * const kJSQDemoAvatarIdJobs = @"707-8956784-57";
static NSString * const kJSQDemoAvatarIdWoz = @"309-41802-93823";

@interface LJMessagesModel : NSObject

@property (strong, nonatomic) NSMutableArray<JSQMessage *> *messages;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;

- (void)addPhotoMediaMessageWithImagePath:(nonnull NSString *)imagePath;

- (void)addPhotoMediaMessageWithImage:(nonnull UIImage *)image;
//
- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;
//添加微视频
- (void)addShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage;
//添加视频
- (void)addVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage;
//
- (void)addAudioMediaMessageWithPath:(nonnull NSString *)audioPath audioTime:(NSInteger)audioTime;

@end

NS_ASSUME_NONNULL_END
