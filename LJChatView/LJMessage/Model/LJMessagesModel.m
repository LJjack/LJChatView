//
//  LJMessagesModel.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMessagesModel.h"

#import "JSQMessages.h"

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
    
    JSQMessage *textMessage = [JSQMessage messageWithSenderId:@"123" displayName:@"123" text:text];
    [textMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:textMessage];
    
    [self willSendMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    TIMTextElem *textElem = [[TIMTextElem alloc] init];
    textElem.text = text;
    [message addElem:textElem];
    
    [self sendMessage:message jsqMessage:textMessage];
}

#pragma mark 发送照片

- (void)sendPhotoMediaMessageWithImage:(nonnull id)image {
    if ([image isKindOfClass:[NSString class]]) {
        image = [UIImage imageWithContentsOfFile:image];
    }
    if (![image isKindOfClass:[UIImage class]]) {
        NSAssert(NO , @"image获得不了图片或image路径下获得不了图片");
    }
    LJImageMediaItem *photoItem = [[LJImageMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:photoItem];
    [photoMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:photoMessage];
    
    [self willSendMessage];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *nsTmpDIr = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@uploadFile%3.f", nsTmpDIr, [NSDate timeIntervalSinceReferenceDate]];
    BOOL isDirectory = NO;
    NSError *err = nil;
    
    // 当前sdk仅支持文件路径上传图片，将图片存在本地
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        if (![fileManager removeItemAtPath:nsTmpDIr error:&err]) {
            NSLog(@"Upload Image Failed: same upload filename: %@", err);
            return ;
        }
    }
    if (![fileManager createFileAtPath:filePath contents:UIImageJPEGRepresentation(image, 0.75) attributes:nil]) {
        NSLog(@"Upload Image Failed: fail to create uploadfile: %@", err);
        return;
    }

    TIMMessage *message = [[TIMMessage alloc] init];
    TIMImageElem *imageElem = [[TIMImageElem alloc] init];
    
    imageElem.path = filePath;
    [message addElem:imageElem];
    
    [self sendMessage:message jsqMessage:photoMessage];
}


#pragma mark 发送音频
- (void)sendSoundMediaMessageWithData:(nonnull NSData *)soundData second:(int)second {
    NSAssert(soundData || soundData.length , @"音频数据不能为 nil 或长度为 0");
    
    
    LJSoundMediaItem *audioItem = [[LJSoundMediaItem alloc] initWithData:soundData second:second];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
    
    [self willSendMessage];
    
    
    TIMMessage *message = [[TIMMessage alloc] init];
    TIMSoundElem *soundElem = [[TIMSoundElem alloc] init];
    soundElem.data = soundData;
    soundElem.second = second;
    [message addElem:soundElem];
    
    [self sendMessage:message jsqMessage:audioMessage];
    
}

#pragma mark 发送当前位置
- (void)sendLocationMediaMessageLatitude:(double)latitude
                   longitude:(double)longitude {

    LJLocationMediaItem *locationItem = [[LJLocationMediaItem alloc] init];
    [locationItem setLatitude:37.795313 longitude:-122.393757 completionHandler:^{
        [self didSendMessage];
    }];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:@"123"
                                                      displayName:@"123"
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
    
    [self willSendMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    TIMLocationElem *locationElem = [[TIMLocationElem alloc] init];
    locationElem.latitude = latitude;
    locationElem.longitude = longitude;
    [message addElem:locationElem];
    
    [self sendMessage:message jsqMessage:locationMessage];
    
    
}

#pragma mark 发送微视频
- (void)sendShortVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"123"
                                                   displayName:@"123"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
    
    [self willSendMessage];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *nsTmpDIr = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@uploadFile%3.f", nsTmpDIr, [NSDate timeIntervalSinceReferenceDate]];
    BOOL isDirectory = NO;
    NSError *err = nil;
    
    // 当前sdk仅支持文件路径上传图片，将图片存在本地
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        if (![fileManager removeItemAtPath:nsTmpDIr error:&err]) {
            NSLog(@"Upload Image Failed: same upload filename: %@", err);
            return ;
        }
    }
    if (![fileManager createFileAtPath:filePath contents:UIImageJPEGRepresentation(showImage, 0.75) attributes:nil]) {
        NSLog(@"Upload Image Failed: fail to create uploadfile: %@", err);
        return;
    }
    
    TIMMessage *message = [[TIMMessage alloc] init];
    TIMVideoElem *videoElem = [[TIMVideoElem alloc] init];
    videoElem.videoPath = videoPath;
    videoElem.snapshotPath = filePath;
    [message addElem:videoElem];
    
    [self sendMessage:message jsqMessage:videoMessage];
    
    
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
    
    NSString *senderId = @"";
    NSString *displayName = @"";
    BOOL outgoing = YES;
    if ([message isSelf]) {
        senderId = @"123";
        displayName = @"123";
    } else {
        TIMUserProfile *user = [message GetSenderProfile];
        senderId = user.identifier;
        displayName = user.nickname.length?user.nickname:senderId;
        outgoing = NO;
    }
    
    for (int i = 0 ; i < elemCount; i ++) {
        
        TIMElem *elem = [message getElem:i];
        if ([elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem *textElem = (TIMTextElem *)elem;
            [self reveiceText:textElem senderId:senderId displayName:displayName];
            
        } else if ([elem isKindOfClass:[TIMImageElem class]]) {
            TIMImageElem *imageElem = (TIMImageElem *)elem;
            [self reveiceImage:imageElem
                      senderId:senderId
                   displayName:displayName
                      outgoing:outgoing];
            
        } else if ([elem isKindOfClass:[TIMLocationElem class]]) {
            TIMLocationElem *locationElem = (TIMLocationElem *)elem;
            [self reveiceLocation:locationElem
                         senderId:senderId
                      displayName:displayName
                         outgoing:outgoing];
        } else if ([elem isKindOfClass:[TIMSoundElem class]]) {
            TIMSoundElem *soundElem = (TIMSoundElem *)elem;
            [self reveiceSound:soundElem
                      senderId:senderId
                   displayName:displayName
                      outgoing:outgoing];
        } else if ([elem isKindOfClass:[TIMVideoElem class]]) {
            
        }
        
    }
}

// 接受文字
- (void)reveiceText:(TIMTextElem *)textElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName {
    JSQMessage *textMessage = [JSQMessage messageWithSenderId:senderId
                                                  displayName:displayName
                                                         text:[textElem text]];
    [self.messages addObject:textMessage];
    [self didReveiceMessage];
}

// 接受图片
- (void)reveiceImage:(TIMImageElem *)imageElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
            outgoing:(BOOL)outgoing {
    LJImageMediaItem *photoItem = [[LJImageMediaItem alloc] initWithImage:nil];
    photoItem.appliesMediaViewMaskAsOutgoing = outgoing;
    JSQMessage *imageMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:displayName
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
}

// 接受音频
- (void)reveiceSound:(TIMSoundElem *)soundElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
            outgoing:(BOOL)outgoing {
    LJSoundMediaItem *soundItem = [[LJSoundMediaItem alloc] initWithData:nil second:soundElem.second];
    
    JSQMessage *soundMessage = [JSQMessage messageWithSenderId:senderId
                                                      displayName:displayName
                                                            media:soundItem];
    [self.messages addObject:soundMessage];
    
    [soundElem getSound:^(NSData *data) {
        soundItem.soundData = data;
        [self didReveiceMessage];
    } fail:^(int code, NSString *msg) {
        [self failReviceMessage];
        BJLog(@"下载音频失败, %@",msg);
    }];
}

// 接受当前位置
- (void)reveiceLocation:(TIMLocationElem *)locationElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
               outgoing:(BOOL)outgoing {

    LJLocationMediaItem *locationItem = [[LJLocationMediaItem alloc] init];
    locationItem.appliesMediaViewMaskAsOutgoing = outgoing;
    [locationItem setLatitude:locationElem.latitude
                    longitude:locationElem.longitude completionHandler:^{
        [self didReveiceMessage];
    }];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:senderId
                                                      displayName:displayName
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
    
}

#pragma mark 接受微视频
- (void)reveiceShortVideo:(TIMVideoElem *)videoElem
                 senderId:(NSString *)senderId
              displayName:(NSString *)displayName
                 outgoing:(BOOL)outgoing {
    
    
    
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] init];
    videoItem.appliesMediaViewMaskAsOutgoing = outgoing;
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:displayName
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *nsTmpDir = NSTemporaryDirectory();
    
    TIMSnapshot * snapshot = videoElem.snapshot;
    if (!(snapshot.uuid && snapshot.uuid.length)) {
        BJLog(@"小视频截图UUID为空");
        return;
    }
    
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/snapshot_image_%@", nsTmpDir, snapshot.uuid];
    BOOL isDirectory;
    
    if ([fileManager fileExistsAtPath:imagePath isDirectory:&isDirectory]
        && isDirectory == NO) {
        NSData *data = [fileManager contentsAtPath:imagePath];
        if (data) {
            videoItem.aFrameImage = [UIImage imageWithData:data];
            [self didReveiceMessage];
        }
    } else {
        [snapshot getImage:imagePath succ:^{
            NSData *data = [fileManager contentsAtPath:imagePath];
            if (data) {
                videoItem.aFrameImage = [UIImage imageWithData:data];
                [self didReveiceMessage];
            } else {
                [self failReviceMessage];
                BJLog(@"下载的小视频截图是空的");
            }
            
        } fail:^(int code, NSString *err) {
            [self failReviceMessage];
            BJLog(@"下载小视频截图失败");
        }];
    }
    
    TIMVideo *video = videoElem.video;
    if (!(video.uuid && video.uuid.length)) {
        BJLog(@"小视频UUID为空");
        return;
    }
    
    NSString *videoPath = [NSString stringWithFormat:@"%@/video_%@.mp4", nsTmpDir, video.uuid];
    
    if ([fileManager fileExistsAtPath:videoPath isDirectory:nil]) {
        videoItem.videoPath = videoPath;
    } else {
        [video getVideo:videoPath succ:^{
            videoItem.videoPath = videoPath;
        } fail:^(int code, NSString *err) {
            BJLog(@"下载视频失败, %@",err);
        }];
    }
}

#pragma mark 接受视频
- (void)reveiceVideoMediaMessageWithVideoPath:(nonnull NSString *)videoPath showImage:(nonnull UIImage *)showImage {
    LJVideoMediaItem *videoItem = [[LJVideoMediaItem alloc] initWithVideoPath:videoPath aFrameImage:showImage];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"456"
                                                   displayName:@"456"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

#pragma mark - Private Methods

- (void)sendMessage:(TIMMessage*)message jsqMessage:(JSQMessage *)jsqMessage {
    [self.chatingConversation sendMessage:message succ:^{
        [jsqMessage setDataState:LJMessageDataStateCompleted];
        [self didSendMessage];
        NSLog(@"发送 成功");
    } fail:^(int code, NSString *msg) {
        [jsqMessage setDataState:LJMessageDataStateFailed];
        [self failSendMessage];
        NSLog(@"发送 失败 mesg=%@",msg);
    }];
}

#pragma mark - 处理发送消息

- (void)willSendMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelWillSend:)]) {
        [self.delegate messagesModelWillSend:self];
    }
}

- (void)didSendMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelDidSend:)]) {
        [self.delegate messagesModelDidSend:self];
    }
}

- (void)failSendMessage {
    if ([self.delegate respondsToSelector:@selector(messagesModelFailSend:)]) {
        [self.delegate messagesModelFailSend:self];
    }
}

#pragma mark - 处理接受消息

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

@end
