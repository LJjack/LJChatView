//
//  LJMessagesModel.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMessagesModel.h"

#import "JSQMessage.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesBubbleImageFactory.h"

#import "JSQAudioMediaItem.h"
#import "JSQPhotoMediaItem.h"
#import "LJVideoMediaItem.h"
#import "LJShortVideoMediaItem.h"

#import <CoreLocation/CoreLocation.h>

#import "UIColor+JSQMessages.h"

@implementation LJMessagesModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if (/* DISABLES CODE */ (NO)) {
            self.messages = [NSMutableArray new];
        }
        else {
            [self loadFakeMessages];
        }
        
        
        /**
         *  Create avatar images once.
         *
         *  Be sure to create your avatars one time and reuse them for good performance.
         *
         *  If you are not using avatars, ignore this.
         */
        JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *jsqImage = [avatarFactory avatarImageWithUserInitials:@"JSQ"
                                                                      backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                            textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                                 font:[UIFont systemFontOfSize:14.0f]];
        
        JSQMessagesAvatarImage *cookImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_cook"]];
        
        JSQMessagesAvatarImage *jobsImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_jobs"]];
        
        JSQMessagesAvatarImage *wozImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_woz"]];
        
        self.avatars = @{ kJSQDemoAvatarIdSquires : jsqImage,
                          kJSQDemoAvatarIdCook : cookImage,
                          kJSQDemoAvatarIdJobs : jobsImage,
                          kJSQDemoAvatarIdWoz : wozImage };
        
        
        self.users = @{ kJSQDemoAvatarIdJobs : kJSQDemoAvatarDisplayNameJobs,
                        kJSQDemoAvatarIdCook : kJSQDemoAvatarDisplayNameCook,
                        kJSQDemoAvatarIdWoz : kJSQDemoAvatarDisplayNameWoz,
                        kJSQDemoAvatarIdSquires : kJSQDemoAvatarDisplayNameSquires };
        
        
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return self;
}

- (void)loadFakeMessages
{
    /**
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     */
    JSQMessage *msg1 = [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                          senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                       date:[NSDate distantPast]
                                                       text:NSLocalizedString(@"It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com.", nil)];
    [msg1 setDataState:LJMessageDataStateCompleted];
    self.messages = [NSMutableArray arrayWithObject:msg1];
    
    [self addPhotoMediaMessageWithImage:[UIImage imageNamed:@"goldengate"]];
    
    [self.messages[1] setDataState:LJMessageDataStateFailed];
    
    
}

#pragma mark 添加音频
- (void)addAudioMediaMessageWithPath:(nonnull NSString *)audioPath audioTime:(NSInteger)audioTime {
    NSAssert(audioPath || audioPath.length , @"音频路径不能为 nil 或长度为 0");
    
    
    JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithPath:audioPath audioTime:audioTime];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
}

#pragma mark 添加照片
- (void)addPhotoMediaMessageWithImagePath:(nonnull NSString *)imagePath {
    NSAssert(imagePath || imagePath.length , @"照片路径不能为 nil 或长度为 0");
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [self addPhotoMediaMessageWithImage:image];
}

- (void)addPhotoMediaMessageWithImage:(nonnull UIImage *)image {
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}

#pragma mark 添加当前位置
- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                      displayName:kJSQDemoAvatarDisplayNameSquires
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

#pragma mark 添加微视频
- (void)addShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

#pragma mark 添加视频
- (void)addVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJVideoMediaItem *videoItem = [[LJVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

@end