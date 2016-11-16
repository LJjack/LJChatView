//
//  LJMessagesController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMessagesController.h"
#import "LJShowImageController.h"
#import "BJMapController.h"

#import "JSQMessages.h"
#import "LJMessageViewStateBtnDelegate.h"

#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>


#import "LJFullVideoView.h"
#import "LJMessageHeaderView.h"

#import "LJSoundPlayer.h"
#import "LJSoundModel.h"


@interface LJMessagesController ()<LJMessageViewStateBtnDelegate, LJSoundPlayerDelegate, LJMessagesModelDelegate, LJMessageHeaderViewDelegate>

@property (nonatomic, strong) LJSoundPlayer *audioPlayer;//播放器

@property (nonatomic, strong) LJSoundMediaItem *audioMediaOldItem;

@property (nonatomic, strong) LJSoundMediaItem *audioMediaNewItem;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSIndexPath *audioIndexPath;

@end

@implementation LJMessagesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgModel.delegate = self;
    
    self.title = self.msgModel.otherName;
    
    /* 语音播放工具 */
    self.audioPlayer = [[LJSoundPlayer alloc]init];
    self.audioPlayer.delegate = self;

    self.collectionView.stateDelegate = self;
    
    [self.collectionView addSubview:self.refreshControl];
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
    }
    //添加点按击手势监听器
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapCollectionView:)];
    [self.collectionView addGestureRecognizer:tap];
}

- (void)addHeaderViewWithModel:(LJGoodsModel *)goodsModel {
    LJMessageHeaderView *headerView = [LJMessageHeaderView headerViewWithModel:goodsModel];
    headerView.delegate = self;
    CGRect frame = headerView.frame;
    CGFloat height = CGRectGetHeight(frame);
    UIEdgeInsets padding = self.collectionView.contentInset;
    padding.top += height;
    frame.origin.y = - height;
    frame.size.width = kScreenWidth;
    headerView.frame = frame;
    [self.collectionView addSubview:headerView];
    self.collectionView.contentInset = padding;
}

- (void)loadMoreMessageData {
    [self.msgModel loadMoreMessageData:^{
        [self.refreshControl endRefreshing];
    } fail:^(int code, NSString * _Nonnull msg) {
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - 播放音频

- (void)startPlayCurrentAudio {
    [self stopOldPlayAudio];

    LJSoundModel *audioModel = [[LJSoundModel alloc] init];
    audioModel.data = self.audioMediaNewItem.soundData;
    [self.audioPlayer playSoundModel:audioModel];
    [self.audioPlayer play];
    [self.audioMediaNewItem startAudioAnimating];
    self.audioMediaOldItem = self.audioMediaNewItem;
}

- (void)stopOldPlayAudio {
    if (self.audioMediaOldItem && [self.audioMediaOldItem isAudioAnimating]) {
        [self.audioPlayer stop];
        [self.audioMediaOldItem stopAudioAnimating];
        self.audioMediaOldItem = nil;
    }
}

- (void)soundPlayer:(LJSoundPlayer *)soundPlayer didOccusError:(NSError *)error {
    [self stopOldPlayAudio];
}

- (void)soundPlayer:(LJSoundPlayer *)soundPlayer didFinishPlayAudio:(LJSoundModel *)audioFile {
    [self stopOldPlayAudio];
    
}

#pragma mark - LJMessageHeaderViewDelegate

- (void)messageHeaderView:(LJMessageHeaderView *)headerView didClickSelf:(LJGoodsModel *)model {
    
}

- (void)messageHeaderView:(LJMessageHeaderView *)headerView didClickSendLinkBtn:(LJGoodsModel *)model {
    [self.msgModel sendGoodsMediaMessageWithModel:model];
}

#pragma mark - 发送 LJMessagesModelDelegate

- (void)messagesModel:(LJMessagesModel *)messagesModel willSendItemAtIndex:(NSUInteger)index {
    [self finishSendingMessageAnimated:YES];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
}

- (void)messagesModel:(LJMessagesModel *)messagesModel didSendFinishItemAtIndex:(NSUInteger)index {
    [self.collectionView reloadData];
}

- (void)messagesModel:(LJMessagesModel *)messagesModel didSendFailItemAtIndex:(NSUInteger)index {
    [self.collectionView reloadData];
}

#pragma mark - 接受 LJMessagesModelDelegate

- (void)messagesModelPrepareWillReveice:(LJMessagesModel *)messagesModel {
    
}

- (void)messagesModel:(LJMessagesModel *)messagesModel willReveiceItemAtIndex:(NSUInteger)index {
    self.showTypingIndicator = !self.showTypingIndicator;
    [self finishReceivingMessage];
     [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
}

- (void)messagesModel:(LJMessagesModel *)messagesModel didReveiceFinishItemAtIndex:(NSUInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:YES];
    });
}

- (void)messagesModel:(LJMessagesModel *)messagesModel didReveiceFailItemAtIndex:(NSUInteger)index {
    
}

#pragma mark - Actions

- (void)closePressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleTapCollectionView:(UIGestureRecognizer *)tap {
    [self reserveChatInputPanelState];
}

#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return @"自己";
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.msgModel.messages objectAtIndex:indexPath.item];
}

//删除某条消息
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    [self.msgModel removeAtIndex:indexPath.item];
}

// 修改对话框的样式
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.msgModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.msgModel.outgoingBubbleImageData;
    }
    return self.msgModel.incomingBubbleImageData;
}

// 修改头像
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.msgModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.msgModel.avatarImgSelf;
    }
    return self.msgModel.avatarImgOther;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.msgModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.msgModel.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        }
    }
    LJMessageStateBtn *stateBtn = cell.cellStateBtn;
    stateBtn.hidden = NO;
    stateBtn.dataState = [msg dataState];
    return cell;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    BJLog(@"点击头像");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.msgModel.messages objectAtIndex:indexPath.row];
    if ([message.media isKindOfClass:[LJSoundMediaItem class]]) {
        BJLog(@"点击音频!");
        
        if ([self.audioIndexPath compare:indexPath] == NSOrderedSame) {
            if (self.audioPlayer.isPlaying) {
                [self stopOldPlayAudio];
                return;
            }
        }
        
        if (self.audioPlayer.isPlaying) {
            [self stopOldPlayAudio];
        }
        self.audioMediaNewItem = (LJSoundMediaItem *)message.media;
        [self startPlayCurrentAudio];
        
    } else if ([message.media isKindOfClass:[LJShortVideoMediaItem class]]) {
        BJLog(@"点击 微 视频!");
        LJShortVideoMediaItem *videoMediaItem = (LJShortVideoMediaItem *)message.media;
        LJFullVideoView *fullVideoView = [[LJFullVideoView alloc] initWithVideoPath:videoMediaItem.videoPath coverImage:videoMediaItem.aFrameImage];
        [fullVideoView showFullVideoView];
    } else if ([message.media isKindOfClass:[LJVideoMediaItem class]]) {
        BJLog(@"点击视频!");
    } else if ([message.media isKindOfClass:[LJLocationMediaItem class]]) {
        BJLog(@"点击地图!");
        LJLocationMediaItem *item = (LJLocationMediaItem *)message.media;
        BJMapController *mapVC = [[BJMapController alloc] init];
        mapVC.location = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        [self presentViewController:mapVC animated:YES completion:nil];
        
    } else if ([message.media isKindOfClass:[LJImageMediaItem class]]) {
        BJLog(@"点击图片!");
        LJImageMediaItem *item = (LJImageMediaItem *)message.media;
        LJShowImageController *showImageC = [LJShowImageController showImageControllerWithImage:item.image];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:showImageC];
        navC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        navC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navC animated:YES completion:nil];
        
    }  else  if ([message.media isKindOfClass:[LJOrderMediaItem class]]){
        BJLog(@"订单消息");
//        LJOrderMediaItem *item = (LJOrderMediaItem *)message.media;
//        NSURL *URL = [NSURL URLWithString:item.model.url];
//        [BJPushTool presentWebController:URL onController:self];
    } else if ([message.media isKindOfClass:[LJGoodsMediaItem class]]) {
        LJGoodsMediaItem *item = (LJGoodsMediaItem *)message.media;
        LJGoodsModel *model = item.model;
        
        if (item.model.type == LJGoodsModelTypeOrderInfo) {
            BJLog(@"订单资讯");
//            NSString *userIdSelf =  [self.msgModel handleGetSelfUserId];
//            //做一下限制：只有当前用户的userId 等于 传入参数的userId 才可以点击跳转链接
//            if ([model.userId isEqualToString:userIdSelf]) {
//                NSURL *URL = [NSURL URLWithString:model.url];
//                [BJPushTool presentWebController:URL onController:self];
//            }
            
        } else {
            BJLog(@"商品信息");
//            NSURL *URL = [NSURL URLWithString:model.url];
//            [BJPushTool presentWebController:URL onController:self];
        }
        
    } else {
        BJLog(@"点击文字!");
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    BJLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    [self reserveChatInputPanelState];
}

#pragma mark - LJMessageViewStateBtnDelegate

/**
 *  运行
 */
- (void)messageView:(JSQMessagesCollectionView *)messageView didTapCellStateBtnRuningAtIndexPath:(NSIndexPath *)indexPath {
    [self.msgModel reSendAtIndex:indexPath.item];
}

/**
 *  停止
 */
- (void)messageView:(JSQMessagesCollectionView *)messageView didTapCellStateBtnStopAtIndexPath:(NSIndexPath *)indexPath {
    
//    [self.msgModel.messages[indexPath.row] setDataState:LJMessageDataStateFailed];
    [self.collectionView reloadData];
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.tintColor = [UIColor lightGrayColor];
        [_refreshControl addTarget:self action:@selector(loadMoreMessageData) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

@end
