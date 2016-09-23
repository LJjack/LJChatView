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

#import "TIMConversation+LJAdd.h"

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

@interface LJMessagesModel ()

@property (nonatomic, strong) NSMutableDictionary *failMessages;

@property (nonatomic, strong) NSMutableArray *runMessages;//旧的消息还在运行状态

@end

@implementation LJMessagesModel

+ (instancetype)sharedInstance {
    static LJMessagesModel *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LJMessagesModel alloc] init];
    });
    
    return _instance;
}

- (void)dealloc {
    [self addOrRemoveNotificationCenter:NO];
}

- (instancetype)init {
    if (self = [super init]) {
        JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        self.avatarImgSelf = [avatarFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"message-touxiang"]];
        
        self.avatarImgOther = [avatarFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"message-touxiang"]];

        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor orangeColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
        
        [self addOrRemoveNotificationCenter:YES];
    }
    
    return self;
}

#pragma mark - 发送消息

#pragma mark 发送文字
- (void)sendTextMediaMessageWithText:(NSString *)text {
    NSAssert(text || text.length , @"文字不能为 nil 或长度为 0");
    
    JSQMessage *textMessage = [JSQMessage messageWithSenderId:@"自己" displayName:@"自己" text:text];
    [textMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:textMessage];
    
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
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:@"自己"
                                                   displayName:@"自己"
                                                         media:photoItem];
    [photoMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:photoMessage];
    
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
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:@"自己"
                                                   displayName:@"自己"
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    
    TIMSoundElem *soundElem = [[TIMSoundElem alloc] init];
    soundElem.data = soundData;
    soundElem.second = second;
    [message addElem:soundElem];
    
    [self sendMessage:message jsqMessage:audioMessage];
    
}

#pragma mark 发送当前位置
- (void)sendLocationMediaMessageLatitude:(double)latitude
                   longitude:(double)longitude completionHandler:(void (^)())completion{

    LJLocationMediaItem *locationItem = [[LJLocationMediaItem alloc] init];
    [locationItem setLatitude:37.795313 longitude:-122.393757 completionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:@"自己"
                                                      displayName:@"自己"
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
    
    
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
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"自己"
                                                   displayName:@"自己"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
    
    
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
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:@"自己"
                                                   displayName:@"自己"
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

#pragma mark - 接受消息

- (void)reveiceMessage:(TIMMessage *)message isAtTop:(BOOL)isAtTop {
    [self willPrepareReveiceMessage];
    
    int elemCount = [message elemCount];
    NSString *senderId = @"";
    NSString *displayName = @"";
    BOOL outgoing = YES;
    if ([message isSelf]) {
        senderId = @"自己";
        displayName = @"自己";
    } else {
        TIMUserProfile *user = [message GetSenderProfile];
        senderId = user.identifier;
        displayName = user.nickname.length?user.nickname:senderId;
        NSLog(@"=== %@",user.faceURL);
        outgoing = NO;
    }
    
    for (int i = 0 ; i < elemCount; i ++) {
        
        TIMElem *elem = [message getElem:i];
        if ([elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem *textElem = (TIMTextElem *)elem;
            [self reveiceText:textElem senderId:senderId displayName:displayName isAtTop:isAtTop];
            
        } else if ([elem isKindOfClass:[TIMImageElem class]]) {
            TIMImageElem *imageElem = (TIMImageElem *)elem;
            [self reveiceImage:imageElem
                      senderId:senderId
                   displayName:displayName
                      outgoing:outgoing
                       isAtTop:isAtTop];
            
        } else if ([elem isKindOfClass:[TIMLocationElem class]]) {
            TIMLocationElem *locationElem = (TIMLocationElem *)elem;
            [self reveiceLocation:locationElem
                         senderId:senderId
                      displayName:displayName
                         outgoing:outgoing
                          isAtTop:isAtTop];
        } else if ([elem isKindOfClass:[TIMSoundElem class]]) {
            TIMSoundElem *soundElem = (TIMSoundElem *)elem;
            [self reveiceSound:soundElem
                      senderId:senderId
                   displayName:displayName
                      outgoing:outgoing
                       isAtTop:isAtTop];
        } else if ([elem isKindOfClass:[TIMVideoElem class]]) {
            TIMVideoElem *videoElem = (TIMVideoElem *)elem;
            [self reveiceShortVideo:videoElem
                           senderId:senderId
                        displayName:displayName
                           outgoing:outgoing
                            isAtTop:isAtTop];
        }
        
    }
}

// 接受文字
- (void)reveiceText:(TIMTextElem *)textElem
            senderId:(NSString *)senderId
        displayName:(NSString *)displayName
            isAtTop:(BOOL)isAtTop {
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:senderId
                                                  displayName:displayName
                                                         text:[textElem text]];
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    NSUInteger index = self.messages.count - 1;
    [self willReveiceMessageItemAtIndex:index];
    [self didReveiceFinishMessageItemAtIndex:index];
}

// 接受图片
- (void)reveiceImage:(TIMImageElem *)imageElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
            outgoing:(BOOL)outgoing
             isAtTop:(BOOL)isAtTop {
    LJImageMediaItem *photoItem = [[LJImageMediaItem alloc] initWithImage:nil];
    photoItem.appliesMediaViewMaskAsOutgoing = outgoing;
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:displayName
                                                         media:photoItem];
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
       [self.messages addObject:jsqMessage];
    }
    
    NSUInteger index = [self.messages indexOfObject:jsqMessage];
    [self willReveiceMessageItemAtIndex:index];
    
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
                        [self didReveiceFinishMessageItemAtIndex:index];
                    }
                } else {
                    [imageModel getImage:imagePath succ:^{
                        NSData *data = [fileManager contentsAtPath:imagePath];
                        if (data) {
                            photoItem.image = [UIImage imageWithData:data];
                            [self didReveiceFinishMessageItemAtIndex:index];
                        } else {
                            [self didReviceFailMessageItemAtIndex:index];
                            BJLog(@"下载的图片是空的");
                        }
                        
                    } fail:^(int code, NSString *err) {
                        [self didReviceFailMessageItemAtIndex:index];
                        BJLog(@"下载原图失败");
                    }];
                }
                break;
            }
        }
    } else {//运行状态
        if ([self.runMessages containsObject:@(index)]) {
            [jsqMessage setDataState:LJMessageDataStateRuning];
        }
        
        //展示发送的图片
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *imagePath = imageElem.path;
        BOOL isDirectory;
        
        if ([fileManager fileExistsAtPath:imagePath isDirectory:&isDirectory]
            && isDirectory == NO) {
            NSData *data = [fileManager contentsAtPath:imagePath];
            if (data) {
                photoItem.image = [UIImage imageWithData:data];
            }
        }
        
    }
}

// 接受音频
- (void)reveiceSound:(TIMSoundElem *)soundElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
            outgoing:(BOOL)outgoing
             isAtTop:(BOOL)isAtTop {
    LJSoundMediaItem *soundItem = [[LJSoundMediaItem alloc] initWithData:nil second:soundElem.second];
    
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:senderId
                                                      displayName:displayName
                                                            media:soundItem];
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    
    NSUInteger index = self.messages.count - 1;
    [self willReveiceMessageItemAtIndex:index];
    
    [soundElem getSound:^(NSData *data) {
        soundItem.soundData = data;
        [self didReveiceFinishMessageItemAtIndex:index];
    } fail:^(int code, NSString *msg) {
        [self didReviceFailMessageItemAtIndex:index];
        BJLog(@"下载音频失败, %@",msg);
    }];
}

// 接受当前位置
- (void)reveiceLocation:(TIMLocationElem *)locationElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
               outgoing:(BOOL)outgoing
                isAtTop:(BOOL)isAtTop {

    LJLocationMediaItem *locationItem = [[LJLocationMediaItem alloc] init];
    locationItem.appliesMediaViewMaskAsOutgoing = outgoing;
    [locationItem setLatitude:locationElem.latitude
                    longitude:locationElem.longitude completionHandler:^{
        NSUInteger index = self.messages.count - 1;
        [self didReveiceFinishMessageItemAtIndex:index];
    }];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:senderId
                                                      displayName:displayName
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
    
    NSUInteger index = self.messages.count - 1;
    [self willReveiceMessageItemAtIndex:index];
    
}

#pragma mark 接受微视频
- (void)reveiceShortVideo:(TIMVideoElem *)videoElem
                 senderId:(NSString *)senderId
              displayName:(NSString *)displayName
                 outgoing:(BOOL)outgoing
                  isAtTop:(BOOL)isAtTop {
    
    
    
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] init];
    videoItem.appliesMediaViewMaskAsOutgoing = outgoing;
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:displayName
                                                         media:videoItem];
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    
    NSUInteger index = self.messages.count - 1;
    [self willReveiceMessageItemAtIndex:index];
    
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
            [self didReveiceFinishMessageItemAtIndex:index];
        }
    } else {
        [snapshot getImage:imagePath succ:^{
            NSData *data = [fileManager contentsAtPath:imagePath];
            if (data) {
                videoItem.aFrameImage = [UIImage imageWithData:data];
                [self didReveiceFinishMessageItemAtIndex:index];
            } else {
                [self didReviceFailMessageItemAtIndex:index];
                BJLog(@"下载的小视频截图是空的");
            }
            
        } fail:^(int code, NSString *err) {
            [self didReviceFailMessageItemAtIndex:index];
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

#pragma mark - 重新发送

- (void)reSendAtIndex:(NSUInteger)index {
    TIMMessage * message = self.failMessages[@(index)];
    
    if (message && index < self.messages.count) {
        JSQMessage *jsqMessage = self.messages[index];
        [self.messages removeObjectAtIndex:index];
        [self.messages addObject:jsqMessage];
        
        [jsqMessage setDataState:LJMessageDataStateRuning];
        [self sendMessage:message jsqMessage:jsqMessage];
    }
}

#pragma mark - 删除

// 删除指定位置的消息
- (void)removeAtIndex:(NSUInteger)index {
    NSUInteger totalCount = self.messages.count;
    
    [self.chatingConversation getLocalMessage:(int)totalCount last:nil succ:^(NSArray *msgs) {
        NSInteger num = totalCount - index - 1;
        if (num > -1 && num < msgs.count) {
            TIMMessage *message = msgs[num];
            [message remove];
            [message delFromStorage];
        }
        
        
        
    } fail:^(int code, NSString *msg) {
        
    }];
    if (index < self.messages.count) {
        [self.messages removeObjectAtIndex:index];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LJIMNotificationCenterUpdataChatUI object:nil];
    
}

#pragma mark- 加载更多数据

- (void)loadMoreMessageData:(void(^)())succ fail:(void(^)(int code, NSString *msg))fail {
    TIMMessage *topMessage = self.chatingConversation.lj_TopMessage;
    NSLog(@"=== %@",topMessage);
    if (topMessage) {
        [self.chatingConversation getMessage:20 last:self.chatingConversation.lj_TopMessage succ:^(NSArray *msgs) {
            NSLog(@"加载更多数据 %lu",(unsigned long)msgs.count);
            [self handleReveicedOldMessage:msgs];
            if (succ) succ();
            
        } fail:^(int code, NSString *msg) {
            NSLog(@"== %d   msg=%@",code,msg);
            if (fail) fail(code, msg);
        }];
    } else {
        if (succ) succ();
    }
    
}

#pragma mark - Private Methods

- (void)sendMessage:(TIMMessage*)message
         jsqMessage:(JSQMessage *)jsqMessage{
    
    NSUInteger index = self.messages.count - 1;
    
    [self willSendMessageItemAtIndex:index];
    
    [self.chatingConversation sendMessage:message succ:^{
        [jsqMessage setDataState:LJMessageDataStateCompleted];
        [self didSendFinishMessageItemAtIndex:index];
        NSLog(@"发送 成功");
    } fail:^(int code, NSString *msg) {
        [jsqMessage setDataState:LJMessageDataStateFailed];
        [self didSendFailMessageItemAtIndex:index];
        NSLog(@"发送 失败 mesg=%@",msg);
        self.failMessages[@([self.messages indexOfObject:jsqMessage])] =  message;
    }];
    
    self.chatingConversation.lj_lastMessage = message;
    [[NSNotificationCenter defaultCenter] postNotificationName:LJIMNotificationCenterUpdataChatUI object:nil];
}

#pragma mark - 处理发送消息

- (void)willSendMessageItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(messagesModel:willSendItemAtIndex:)]) {
        [self.delegate messagesModel:self willSendItemAtIndex:index];
    }
}

- (void)didSendFinishMessageItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(messagesModel:didSendFinishItemAtIndex:)]) {
        [self.delegate messagesModel:self didSendFinishItemAtIndex:index];
    }
}

- (void)didSendFailMessageItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(messagesModel:didSendFailItemAtIndex:)]) {
        [self.delegate messagesModel:self didSendFailItemAtIndex:index];
    }
}

#pragma mark - 处理接受消息

- (void)willPrepareReveiceMessage{
    if ([self.delegate respondsToSelector:@selector(messagesModelPrepareWillReveice:)]) {
        [self.delegate messagesModelPrepareWillReveice:self];
    }
}

- (void)willReveiceMessageItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(messagesModel:willReveiceItemAtIndex:)]) {
        [self.delegate messagesModel:self willReveiceItemAtIndex:index];
    }
}

- (void)didReveiceFinishMessageItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(messagesModel:didReveiceFinishItemAtIndex:)]) {
        [self.delegate messagesModel:self didReveiceFinishItemAtIndex:index];
    }
}

- (void)didReviceFailMessageItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(messagesModel:didReveiceFailItemAtIndex:)]) {
        [self.delegate messagesModel:self didReveiceFailItemAtIndex:index];
    }
}

#pragma mark - Setters

- (void)setChatingConversation:(TIMConversation *)chatingConversation {
    _chatingConversation = chatingConversation;
    
    self.messages = [NSMutableArray array];
    self.failMessages = [NSMutableDictionary dictionary];
    self.runMessages = [NSMutableArray array];
    
    self.otherName = [chatingConversation getReceiver];
    
    NSArray<TIMMessage *> *msgs =  [chatingConversation getLastMsgs:20];
    [self handleReveicedOldMessage:msgs];
}


- (void)handleReveicedOldMessage:(NSArray<TIMMessage *> *)msgs {
    
    [msgs enumerateObjectsUsingBlock:^(TIMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        TIMMessageStatus status = [message status];
        if (status == TIM_MSG_STATUS_SENDING) {
            [self.runMessages addObject:@(idx)];
        }
        if (status == TIM_MSG_STATUS_HAS_DELETED) { // 过滤消息被删除
            [message delFromStorage];
        } else {
             self.chatingConversation.lj_TopMessage = message;
            [self reveiceMessage:message isAtTop:YES];
            if (status == TIM_MSG_STATUS_SEND_FAIL) { //记录消息发送失败
                self.failMessages[@(idx)] =  message;
            }
        
        }
    }];
}

- (void)addOrRemoveNotificationCenter:(BOOL)isAdd {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (isAdd) {
        [defaultCenter addObserver:self selector:@selector(hanleReveiceNewMessage:) name:LJIMNotificationCenterReveicedNewMessage object:nil];
    } else {
        [defaultCenter removeObserver:self name:LJIMNotificationCenterReveicedNewMessage object:nil];
    }
}

- (void)hanleReveiceNewMessage:(NSNotification *)info {
    TIMMessage *newMessage = (TIMMessage *)info.object;
    [self reveiceMessage:newMessage isAtTop:NO];
}

@end
