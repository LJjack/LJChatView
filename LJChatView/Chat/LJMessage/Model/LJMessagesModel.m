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
#import <YYModel/YYModel.h>
#import <SDWebImageManager.h>

#import "LJIMManagerListener.h"
//#import "BJUserManager.h"

#import "TIMConversation+LJAdd.h"

@interface LJMessagesModel ()

@property (nonatomic, strong) NSMutableDictionary *failMessages;

@property (nonatomic, strong) NSMutableArray *runMessages;//旧的消息还在运行状态

@end

@implementation LJMessagesModel

+ (instancetype)sharedInstance {
    return  [[LJMessagesModel alloc] init];
}

- (void)dealloc {
    [self addOrRemoveNotificationCenter:NO];
    [LJIMManagerListener sharedInstance].chattingConversation = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor orangeColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
        
        JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        self.avatarImgSelf = [avatarFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"message-touxiang"]];
        self.avatarImgOther = [avatarFactory avatarImageWithPlaceholder:[UIImage imageNamed:@"message-touxiang"]];
        
        [self addOrRemoveNotificationCenter:YES];
    }
    
    return self;
}

#pragma mark - 发送消息

#pragma mark 发送文字
- (void)sendTextMediaMessageWithText:(NSString *)text {
    NSAssert(text || text.length , @"文字不能为 nil 或长度为 0");
    
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:@"自己" displayName:@"自己" text:text];
    [jsqMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:jsqMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    [self messageSetOfflinePushInfo:message];
    TIMTextElem *textElem = [[TIMTextElem alloc] init];
    textElem.text = text;
    [message addElem:textElem];
    
    [self sendMessage:message jsqMessage:jsqMessage];
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
    

    TIMMessage *message = [[TIMMessage alloc] init];
    [self messageSetOfflinePushInfo:message];
    TIMImageElem *imageElem = [[TIMImageElem alloc] init];
    
    imageElem.path = [self createdUploadImagePathWith:image];
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
    [self messageSetOfflinePushInfo:message];
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
    [locationItem setLatitude:latitude longitude:longitude completionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:@"自己"
                                                      displayName:@"自己"
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    [self messageSetOfflinePushInfo:message];
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
    
    TIMMessage *message = [[TIMMessage alloc] init];
    [self messageSetOfflinePushInfo:message];
    TIMVideoElem *videoElem = [[TIMVideoElem alloc] init];
    TIMVideo* video = [[TIMVideo alloc] init];
    video.type = @"mp4";
    TIMSnapshot* snapshot = [[TIMSnapshot alloc] init];
    videoElem.video = video;
    videoElem.snapshot = snapshot;
    videoElem.videoPath = videoPath;
    videoElem.snapshotPath = [self createdUploadImagePathWith:showImage];
    [message addElem:videoElem];
    
    [self sendMessage:message jsqMessage:videoMessage];
}

#pragma mark 商品信息
- (void)sendGoodsMediaMessageWithModel:(LJGoodsModel *)model {
    model.type = LJGoodsModelTypeProduct;
    LJGoodsMediaItem *goodsItem = [[LJGoodsMediaItem alloc] initWithModel:model];
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:@"自己" displayName:@"自己" media:goodsItem];
    [jsqMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:jsqMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    [self messageSetOfflinePushInfo:message];
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    elem.data = [model modelToData];
    [message addElem:elem];
    
    [self sendMessage:message jsqMessage:jsqMessage];
}

#pragma mark 订单咨询
- (void)sendOrderInfoMediaMessageWithModel:(LJGoodsModel *)model {
    model.type = LJGoodsModelTypeOrderInfo;
    LJGoodsMediaItem *goodsItem = [[LJGoodsMediaItem alloc] initWithModel:model];
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:@"自己" displayName:@"自己" media:goodsItem];
    [jsqMessage setDataState:LJMessageDataStateRuning];
    [self.messages addObject:jsqMessage];
    
    TIMMessage *message = [[TIMMessage alloc] init];
    [self messageSetOfflinePushInfo:message];
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    elem.data = [model modelToData];
    [message addElem:elem];
    
    [self sendMessage:message jsqMessage:jsqMessage];
}

#pragma mark - 接受消息

- (void)reveiceMessage:(TIMMessage *)message isAtTop:(BOOL)isAtTop {
    [self willPrepareReveiceMessage];
    
    BJLog(@"昵称= %@",[[message GetSenderProfile] nickname]);
    
    int elemCount = [message elemCount];
    NSString *senderId = @"";
    NSString *displayName = @"";
    BOOL outgoing = YES;
    if ([message isSelf]) {
        senderId = @"自己";
        displayName = @"自己";
    } else {
        senderId = [message sender];
        TIMUserProfile *user = [message GetSenderProfile];
        
        displayName = user.nickname.length?user.nickname:senderId;
        outgoing = NO;
    }
    
    for (int i = 0 ; i < elemCount; i ++) {
        TIMElem *elem = [message getElem:i];
        if ([elem isKindOfClass:[TIMTextElem class]]) {
            [self reveiceText:(TIMTextElem *)elem
                     senderId:senderId
                  displayName:displayName
                         date:message.timestamp
                      isAtTop:isAtTop
                        state:(NSUInteger)[message status]];
            
        } else if ([elem isKindOfClass:[TIMImageElem class]]) {
            [self reveiceImage:(TIMImageElem *)elem
                      senderId:senderId
                   displayName:displayName
                          date:message.timestamp
                      outgoing:outgoing
                       isAtTop:isAtTop
                         state:(NSUInteger)[message status]];
            
        } else if ([elem isKindOfClass:[TIMLocationElem class]]) {
            [self reveiceLocation:(TIMLocationElem *)elem
                         senderId:senderId
                      displayName:displayName
                             date:message.timestamp
                         outgoing:outgoing
                          isAtTop:isAtTop
                            state:(NSUInteger)[message status]];
        } else if ([elem isKindOfClass:[TIMSoundElem class]]) {
            [self reveiceSound:(TIMSoundElem *)elem
                      senderId:senderId
                   displayName:displayName
                          date:message.timestamp
                      outgoing:outgoing
                       isAtTop:isAtTop
                         state:(NSUInteger)[message status]];
        } else if ([elem isKindOfClass:[TIMVideoElem class]]) {
            [self reveiceShortVideo:(TIMVideoElem *)elem
                           senderId:senderId
                        displayName:displayName
                               date:message.timestamp
                           outgoing:outgoing
                            isAtTop:isAtTop
                              state:(NSUInteger)[message status]];
        } else if ([elem isKindOfClass:[TIMCustomElem class]]) {
            [self reveiceGoods:(TIMCustomElem *)elem
                      senderId:senderId
                   displayName:displayName
                          date:message.timestamp
                      outgoing:outgoing
                       isAtTop:isAtTop
                         state:(NSUInteger)[message status]];
        }
        
    }
}

// 接受文字
- (void)reveiceText:(TIMTextElem *)textElem
            senderId:(NSString *)senderId
        displayName:(NSString *)displayName
               date:(NSDate *)date
            isAtTop:(BOOL)isAtTop
              state:(LJMessageDataState)state {
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:displayName
                                                             date:date
                                                             text:[textElem text]];
    jsqMessage.dataState = state;
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    NSUInteger index = [self.messages indexOfObject:jsqMessage];
    [self willReveiceMessageItemAtIndex:index];
    [self didReveiceFinishMessageItemAtIndex:index];
}

// 接受图片
- (void)reveiceImage:(TIMImageElem *)imageElem
            senderId:(NSString *)senderId
         displayName:(NSString *)displayName
                date:(NSDate *)date
            outgoing:(BOOL)outgoing
             isAtTop:(BOOL)isAtTop
               state:(LJMessageDataState)state {
    LJImageMediaItem *photoItem = [[LJImageMediaItem alloc] initWithImage:nil];
    photoItem.appliesMediaViewMaskAsOutgoing = outgoing;
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:displayName
                                                             date:date
                                                            media:photoItem];
    jsqMessage.dataState = state;
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
                date:(NSDate *)date
            outgoing:(BOOL)outgoing
             isAtTop:(BOOL)isAtTop
               state:(LJMessageDataState)state {
    LJSoundMediaItem *soundItem = [[LJSoundMediaItem alloc] initWithData:nil second:soundElem.second];
    soundItem.appliesMediaViewMaskAsOutgoing = outgoing;
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:displayName
                                                             date:date
                                                            media:soundItem];
    jsqMessage.dataState = state;
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    
    NSUInteger index = [self.messages indexOfObject:jsqMessage];
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
                   date:(NSDate *)date
               outgoing:(BOOL)outgoing
                isAtTop:(BOOL)isAtTop
               state:(LJMessageDataState)state {

    LJLocationMediaItem *locationItem = [[LJLocationMediaItem alloc] init];
    locationItem.appliesMediaViewMaskAsOutgoing = outgoing;
    [locationItem setLatitude:locationElem.latitude
                    longitude:locationElem.longitude completionHandler:^{
        NSUInteger index = self.messages.count - 1;
        [self didReveiceFinishMessageItemAtIndex:index];
    }];
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:displayName
                                                             date:date
                                                            media:locationItem];
    jsqMessage.dataState = state;
    [self.messages addObject:jsqMessage];
    
    NSUInteger index = [self.messages indexOfObject:jsqMessage];
    [self willReveiceMessageItemAtIndex:index];
    
}

// 接受微视频
- (void)reveiceShortVideo:(TIMVideoElem *)videoElem
                 senderId:(NSString *)senderId
              displayName:(NSString *)displayName
                     date:(NSDate *)date
                 outgoing:(BOOL)outgoing
                  isAtTop:(BOOL)isAtTop
               state:(LJMessageDataState)state {
    LJShortVideoMediaItem *videoItem = [[LJShortVideoMediaItem alloc] init];
    videoItem.appliesMediaViewMaskAsOutgoing = outgoing;
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:displayName
                                                             date:date
                                                            media:videoItem];
    jsqMessage.dataState = state;
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    
    NSUInteger index = [self.messages indexOfObject:jsqMessage];
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
    
    NSString *videoPath = [NSString stringWithFormat:@"%@video_%@.mp4", nsTmpDir, video.uuid];
    
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

// 接受商品
- (void)reveiceGoods:(TIMCustomElem *)elem
                 senderId:(NSString *)senderId
              displayName:(NSString *)displayName
                     date:(NSDate *)date
                 outgoing:(BOOL)outgoing
                  isAtTop:(BOOL)isAtTop
               state:(LJMessageDataState)state {
    LJGoodsModel *model = [LJGoodsModel yy_modelWithJSON:elem.data];
    JSQMediaItem *item;
    if (model.type == LJGoodsModelTypeOrderMsg) {
        item = [[LJOrderMediaItem alloc] initWithModel:nil];
        
    } else {
        item = [[LJGoodsMediaItem alloc] initWithModel:nil];
    }
    item.appliesMediaViewMaskAsOutgoing = outgoing;
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                senderDisplayName:displayName
                                                             date:date
                                                            media:item];
    jsqMessage.dataState = state;
    if (isAtTop) {
        [self.messages insertObject:jsqMessage atIndex:0];
    } else {
        [self.messages addObject:jsqMessage];
    }
    NSUInteger index = [self.messages indexOfObject:jsqMessage];
    [self willReveiceMessageItemAtIndex:index];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (model.type == LJGoodsModelTypeOrderMsg) {
            [(LJOrderMediaItem *)item setModel:model];
            
        } else {
            [(LJGoodsMediaItem *)item setModel:model];
        }
        
        [self didReveiceFinishMessageItemAtIndex:index];
    });
    
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
    BJLog(@"=== %@",topMessage);
    if (topMessage) {
        [self.chatingConversation getMessage:20 last:self.chatingConversation.lj_TopMessage succ:^(NSArray *msgs) {
            BJLog(@"加载更多数据 %lu",(unsigned long)msgs.count);
            [self handleReveicedOldMessage:msgs];
            if (succ) succ();
            
        } fail:^(int code, NSString *msg) {
            BJLog(@"== %d   msg=%@",code,msg);
            if (fail) fail(code, msg);
        }];
    } else {
        if (succ) succ();
    }
    
}

#pragma mark - 获取自己的userId

- (NSString *)handleGetSelfUserId {
    return [self.chatingConversation getSelfIdentifier];
}

#pragma mark - Private Methods

- (void)sendMessage:(TIMMessage*)message
         jsqMessage:(JSQMessage *)jsqMessage{
    
    NSUInteger index = self.messages.count - 1;
    
    [self willSendMessageItemAtIndex:index];
    
    [self.chatingConversation sendMessage:message succ:^{
        [jsqMessage setDataState:LJMessageDataStateCompleted];
        [self didSendFinishMessageItemAtIndex:index];
        BJLog(@"发送 成功");
    } fail:^(int code, NSString *msg) {
        [jsqMessage setDataState:LJMessageDataStateFailed];
        [self didSendFailMessageItemAtIndex:index];
        BJLog(@"发送 失败 msg = %@",msg);
        self.failMessages[@([self.messages indexOfObject:jsqMessage])] =  message;
    }];
    
    self.chatingConversation.lj_lastMessage = message;
    [[NSNotificationCenter defaultCenter] postNotificationName:LJIMNotificationCenterUpdataChatUI object:nil];
}

//创建上传图片路径
- (NSString *)createdUploadImagePathWith:(UIImage *)image {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *nsTmpDIr = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@uploadFile%3.f", nsTmpDIr, [NSDate timeIntervalSinceReferenceDate]];
    BOOL isDirectory = NO;
    NSError *err = nil;
    
    // 当前sdk仅支持文件路径上传图片，将图片存在本地
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        if (![fileManager removeItemAtPath:nsTmpDIr error:&err]) {
            BJLog(@"Upload Image Failed: same upload filename: %@", err);
            return nil;
        }
    }
    if (![fileManager createFileAtPath:filePath contents:UIImageJPEGRepresentation(image, 0.75) attributes:nil]) {
        BJLog(@"Upload Image Failed: fail to create uploadfile: %@", err);
        return nil;
    }
    return filePath;
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

//配置推送发送者
- (void)messageSetOfflinePushInfo:(TIMMessage *)message {
    TIMOfflinePushInfo *info = [[TIMOfflinePushInfo alloc] init];
    info.ext = [NSString stringWithFormat:@"{\"fromUserId\":\"%@\"}",[self handleGetSelfUserId]];
    [message setOfflinePushInfo:info];
}

#pragma mark - Setters

- (void)setChatingConversation:(TIMConversation *)chatingConversation {
    _chatingConversation = chatingConversation;
    
    
    JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    NSString *receiver = [chatingConversation getReceiver];
    self.otherName = receiver;
    
    [[TIMFriendshipManager sharedInstance] GetFriendsProfile:@[receiver] succ:^(NSArray *friends) {
        TIMUserProfile *friend = [friends firstObject];
        if (friend.nickname.length) {
            self.otherName = [receiver isEqualToString:@"10000"] ? @"订单消息" :friend.nickname;
        }
        NSURL *faceURL = [NSURL URLWithString:friend.faceURL];
        [[SDWebImageManager sharedManager] downloadImageWithURL:faceURL
                                                        options:0
                                                       progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (image) {
              self.avatarImgOther = [avatarFactory avatarImageWithImage:image];
             }
            
        }];
        
    } fail:^(int code, NSString *msg) {
        
    }];
//    NSString *avatar = [BJUserManager shareManager].currentUser.avatar;
    
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:avatar]
//                                                    options:0
//                                                   progress:nil
//                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
//    {
//        if (image) {
//            self.avatarImgSelf = [avatarFactory avatarImageWithImage:image];
//        }
//    }];
    
    self.messages = [NSMutableArray array];
    self.failMessages = [NSMutableDictionary dictionary];
    self.runMessages = [NSMutableArray array];
    
    
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
