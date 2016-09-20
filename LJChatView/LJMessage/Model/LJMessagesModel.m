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

#import <ImSDK/ImSDK.h>

/**
 *  状态转化
 *
 *  @param status IM的状态
 */
LJMessageDataState lj_messageDataStateFormIMStatus(NSInteger status) {
    
    LJMessageDataState state;
    switch (status) {
        case 1: { // 消息发送中
            state = LJMessageDataStateRuning;
        } break;
        case 2: { //消息发送成功
            state = LJMessageDataStateCompleted;
        } break;
        case 3: { //消息发送失败
            state = LJMessageDataStateFailed;
        } break;
            
        default:
            break;
    }
    
    return state;
}

@implementation LJMessagesModel

+ (instancetype)sharedInstance {
    static LJMessagesModel *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LJMessagesModel alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        self.avatarImgSelf = [avatarFactory avatarImageWithUserInitials:@"JSQ"
                                                                      backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                            textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                                 font:[UIFont systemFontOfSize:14.0f]];
        
        self.avatarImgOther = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_cook"]];

        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return self;
}

- (void)setChatingConversation:(TIMConversation *)chatingConversation {
    _chatingConversation = chatingConversation;
    
    self.messages = [NSMutableArray array];
    
    NSArray<TIMMessage *> *msgs =  [chatingConversation getLastMsgs:10];
    [msgs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TIMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        [self reveiceMessage:message];
    }];
}

#pragma mark - 发送消息

#pragma mark 发送文字
- (void)sendTextMediaMessageWithText:(NSString *)text {
    NSAssert(text || text.length , @"文字不能为 nil 或长度为 0");
    TIMMessage *message = [[TIMMessage alloc] init];
    TIMTextElem *textElem = [[TIMTextElem alloc] init];
    textElem.text = text;
    
    JSQMessage *textMessage = [JSQMessage messageWithSenderId:@"123" displayName:@"123" text:text];
    [textMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:textMessage];
    
    [self.chatingConversation sendMessage:message succ:^{
        [textMessage setDataState:LJMessageDataStateRuning];
    } fail:^(int code, NSString *msg) {
        [textMessage setDataState:LJMessageDataStateFailed];
    }];
    
    
}

#pragma mark 发送音频
- (void)sendAudioMediaMessageWithPath:(nonnull NSString *)audioPath audioTime:(NSInteger)audioTime {
    NSAssert(audioPath || audioPath.length , @"音频路径不能为 nil 或长度为 0");
    
    
    JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithPath:audioPath audioTime:audioTime];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
}

#pragma mark 发送照片

- (void)sendPhotoMediaMessageWithImage:(nonnull id)image {
    if ([image isKindOfClass:[NSString class]]) {
        image = [UIImage imageWithContentsOfFile:image];
    }
    if (![image isKindOfClass:[UIImage class]]) {
        NSAssert(NO , @"image获得不了图片或image路径下获得不了图片");
    }
    
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}

#pragma mark 发送当前位置
- (void)sendLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:@"123"
                                                      displayName:@"123"
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

#pragma mark 发送微视频
- (void)sendShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

#pragma mark 发送视频
- (void)sendVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJVideoMediaItem *videoItem = [[LJVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

#pragma mark - 接受消息

- (void)reveiceMessage:(TIMMessage *)message {
    
    [self willReveiceMessage];
    
    int elemCount = [message elemCount];
    TIMUserProfile *user = [message GetSenderProfile];
    
    for (int i = 0 ; i < elemCount; i ++) {
        
        TIMElem *elem = [message getElem:i];
        if ([elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem *textElem = (TIMTextElem *)elem;
            JSQMessage *textMessage = [JSQMessage messageWithSenderId:user.identifier
                                             displayName:user.nickname
                                                    text:[textElem text]];
            [self.messages addObject:textMessage];
            [self didReveiceMessage];
            
        } else if ([elem isKindOfClass:[TIMImageElem class]]) {
            TIMImageElem *imageElem = (TIMImageElem *)elem;
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
            JSQMessage *imageMessage = [JSQMessage messageWithSenderId:user.identifier
                                                           displayName:user.nickname
                                                                 media:photoItem];
            [self.messages addObject:imageMessage];
            
            if (imageElem && imageElem.imageList && imageElem.imageList.count) {
                for (TIMImage *imageModel in imageElem.imageList) {
                    if (imageModel.type == TIM_IMAGE_TYPE_ORIGIN) {
                        if (!(imageModel.uuid && imageModel.uuid.length > 0)) {
                            break;
                        }
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSString *nsTmpDir = NSTemporaryDirectory();
                        NSString *imagePath = [NSString stringWithFormat:@"%@/image_%@", nsTmpDir, imageModel.uuid];
                        BOOL isDirectory;
                        
                        if ([fileManager fileExistsAtPath:imagePath isDirectory:&isDirectory]
                            && isDirectory == NO) {
                            NSData *data = [fileManager contentsAtPath:imagePath];
                            if (data) {
                                photoItem.image = [UIImage imageWithData:data];
                                [self didReveiceMessage];
                            }
                        } else {
                            [imageModel getImage:imagePath succ:^{
                                NSData *data = [fileManager contentsAtPath:imagePath];
                                if (data) {
                                    photoItem.image = [UIImage imageWithData:data];
                                    [self didReveiceMessage];
                                } else {
                                    [self failReviceMessage];
                                    BJLog(@"下载的图片是空的");
                                }
                                
                            } fail:^(int code, NSString *err) {
                                [self failReviceMessage];
                                BJLog(@"下载原图失败");
                            }];
                        }
                        break;
                    }
                }
            }
            
            
            
        } else if ([elem isKindOfClass:[TIMLocationElem class]]) {
            
        } else if ([elem isKindOfClass:[TIMSoundElem class]]) {
            
        } else if ([elem isKindOfClass:[TIMVideoElem class]]) {
            
        }
        
    }
}

- (void)prepareWillReveiceMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelPrepareWillReveice:)]) {
        [self.delegate messagesModelPrepareWillReveice:self];
    }
}

- (void)willReveiceMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelWillReveice:)]) {
        [self.delegate messagesModelWillReveice:self];
    }
}

- (void)didReveiceMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelDidReveice:)]) {
        [self.delegate messagesModelDidReveice:self];
    }
}

- (void)failReviceMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelFailReveice:)]) {
        [self.delegate messagesModelFailReveice:self];
    }
}

#pragma mark 接受音频
- (void)reveiceAudioMediaMessageWithPath:(nonnull NSString *)audioPath audioTime:(NSInteger)audioTime {
    NSAssert(audioPath || audioPath.length , @"音频路径不能为 nil 或长度为 0");
    
    
    JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithPath:audioPath audioTime:audioTime];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:@"456"
                                                   displayName:@"456"
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
}

#pragma mark 接受当前位置
- (void)reveiceLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:@"456"
                                                      displayName:@"456"
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

#pragma mark 接受微视频
- (void)reveiceShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"456"
                                                   displayName:@"456"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

#pragma mark 接受视频
- (void)reveiceVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJVideoMediaItem *videoItem = [[LJVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"456"
                                                   displayName:@"456"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

@end
