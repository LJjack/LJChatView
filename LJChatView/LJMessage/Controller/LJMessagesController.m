//
//  LJMessagesController.m
//  LJChatView
//
//  Created by 刘俊杰 on 16/9/14.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

#import "LJMessagesController.h"

#import "JSQMessages.h"

#import "LJMessagesModel.h"

#import "LJMessageViewStateBtnDelegate.h"
#import "UIView+GJCFViewFrameUitil.h"
#import "GJGCChatInputPanel.h"
#import "NSString+LJEmojiParser.h"

#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController/TZImageManager.h>
#import <TZImagePickerController/TZVideoPlayerController.h>

#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>

#import "UIImage+LJVideo.h"
#import "LJRecordVideoView.h"
#import "LJFullVideoView.h"

#import "LJSoundPlayer.h"

#define GJCFSystemScreenHeight [UIScreen mainScreen].bounds.size.height
#define GJCFSystemScreenWidth [UIScreen mainScreen].bounds.size.width

@interface LJMessagesController ()<LJMessageViewStateBtnDelegate, GJGCChatInputPanelDelegate , TZImagePickerControllerDelegate, LJSoundPlayerDelegate, LJRecordVideoViewDelegate, LJMessagesModelDelegate>

@property (strong, nonatomic) GJGCChatInputPanel *inputPanel;

@property (nonatomic, strong) LJSoundPlayer *audioPlayer;//播放器

@property (nonatomic, strong) LJSoundMediaItem *audioMediaOldItem;

@property (nonatomic, strong) LJSoundMediaItem *audioMediaNewItem;

@property (nonatomic, strong) LJSoundModel *currentRecordFile;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation LJMessagesController

#pragma mark - View lifecycle

- (void)dealloc {
    [self.inputPanel removeObserver:self forKeyPath:@"frame"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self jsq_configureMessagesInputPanel];
    
    self.msgModel.delegate = self;
    
    self.title = self.msgModel.otherName;
    
    /* 语音播放工具 */
    self.audioPlayer = [[LJSoundPlayer alloc]init];
    self.audioPlayer.delegate = self;
    
    /* 观察录音工具开始录音 */
    //    NSString *formateNoti = [GJGCChatInputConst panelNoti:GJGCChatInputPanelBeginRecordNoti formateWithIdentifier:self.inputPanel.panelIndentifier];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeChatInputPanelBeginRecord:) name:formateNoti object:nil];

    self.collectionView.stateDelegate = self;
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [self.collectionView addSubview:self.refreshControl];
    self.showLoadEarlierMessagesHeader = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(receiveMessagePressed:)];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closePressed:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    //    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
}


- (void)loadMoreMessageData {
    [self.msgModel loadMoreMessageData:^{
        [self.refreshControl endRefreshing];
    } fail:^(int code, NSString * _Nonnull msg) {
        [self.refreshControl endRefreshing];
    }];
}

//========================   输入键盘工具 开始  ================================

- (void)jsq_configureMessagesInputPanel {
    CGFloat originY = 0;
    /* 输入面板 */
    self.inputPanel = [[GJGCChatInputPanel alloc] initWithPanelDelegate:self];
    self.inputPanel.frame = (CGRect){0,GJCFSystemScreenHeight - self.inputPanel.inputBarHeight-originY,GJCFSystemScreenWidth,self.inputPanel.inputBarHeight+216};
    
    __weak typeof(self) weakSelf = self;
    [self.inputPanel configInputPanelKeyboardFrameChange:^(GJGCChatInputPanel *panel,CGRect keyboardBeginFrame, CGRect keyboardEndFrame, NSTimeInterval duration,BOOL isPanelReserve) {
        /* 不要影响其他不带输入面板的系统视图对话 */
        if (panel.hidden) {
            return ;
        }
        
        [UIView animateWithDuration:duration animations:^{
            CGFloat viewHeight = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight - originY - keyboardEndFrame.size.height;
            if (keyboardEndFrame.origin.y == GJCFSystemScreenHeight) {
                weakSelf.collectionView.transform = CGAffineTransformIdentity;
                if (isPanelReserve) {
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight  - originY;
                } else {
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - 216 - weakSelf.inputPanel.inputBarHeight - originY;
                    weakSelf.collectionView.transform = CGAffineTransformMakeTranslation(0, - 216);
                }
                
            } else {
                weakSelf.inputPanel.gjcf_top = viewHeight;
                weakSelf.collectionView.transform = CGAffineTransformMakeTranslation(0, keyboardEndFrame.origin.y - GJCFSystemScreenHeight);
            }
        }];
    }];
    
    [self.inputPanel configInputPanelRecordStateChange:^(GJGCChatInputPanel *panel, BOOL isRecording) {
        NSLog(@"=======");
        if (isRecording) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //                [weakSelf stopPlayCurrentAudio];
                
                
                
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
    }];
    
    [self.inputPanel configInputPanelInputTextViewHeightChangedBlock:^(GJGCChatInputPanel *panel, CGFloat changeDelta) {
        panel.gjcf_top = panel.gjcf_top - changeDelta;
        
        panel.gjcf_height = panel.gjcf_height + changeDelta;
        
    }];
    
    /* 动作变化 */
    [self.inputPanel setActionChangeBlock:^(GJGCChatInputBar *inputBar, GJGCChatInputBarActionType toActionType) {
        [weakSelf inputBar:inputBar changeToAction:toActionType];
    }];
    [self.view addSubview:self.inputPanel];
    
    /* 观察输入面板变化 */
    [self.inputPanel addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - 恢复输入面板到初始状态

- (void)reserveChatInputPanelState
{
    /* 收起输入键盘 */
    if (self.inputPanel.isFullState) {
        
        CGFloat originY = 0;
        
        self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
        
        self.collectionView.transform = CGAffineTransformIdentity;
        
        [self.inputPanel reserveState];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    if ([self.inputPanel isInputTextFirstResponse]) {
        
        [self.inputPanel inputBarRegsionFirstResponse];
        
    }
    [UIView animateWithDuration:0.26 animations:^{
        [self reserveChatInputPanelState];
    }];
    
}

#pragma mark - 属性变化观察
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] && object == self.inputPanel) {
        
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        
        CGFloat originY = 0;
        
        //50.f 高度是输入条在底部的时候显示的高度，在录音状态下就是50
        if (newFrame.origin.y < GJCFSystemScreenHeight - 50.f - originY) {
            
            self.inputPanel.isFullState = YES;
            
        }else{
            
            self.inputPanel.isFullState = NO;
        }
    }
}


#pragma mark - 输入动作变化

- (void)inputBar:(GJGCChatInputBar *)inputBar changeToAction:(GJGCChatInputBarActionType)actionType
{
    CGFloat originY = 0;
    
    switch (actionType) {
        case GJGCChatInputBarActionTypeRecordAudio:
        {
            if (self.inputPanel.isFullState) {
                
                [UIView animateWithDuration:0.26 animations:^{
                    
                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
                    self.collectionView.transform = CGAffineTransformIdentity;
                }];
            }
        }
            break;
        case GJGCChatInputBarActionTypeChooseEmoji:
        case GJGCChatInputBarActionTypeExpandPanel:
        {
            if (!self.inputPanel.isFullState) {
                
                [UIView animateWithDuration:0.26 animations:^{
                    
                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - (self.inputPanel.inputBarHeight + 216 + originY);
                    self.collectionView.transform = CGAffineTransformMakeTranslation(0, -(216 + originY));
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - GJGCChatInputPanelDelegate

- (void)chatInputPanel:(GJGCChatInputPanel *)panel sendTextMessage:(NSString *)text
{
    [self.msgModel sendTextMediaMessageWithText:text];
    
}

- (void)chatInputPanel:(GJGCChatInputPanel *)panel didFinishRecord:(LJSoundModel *)soundModel {
    self.currentRecordFile = soundModel;
    [self.msgModel sendSoundMediaMessageWithData:soundModel.data second:soundModel.second];
}

- (void)chatInputPanel:(GJGCChatInputPanel *)panel didChooseMenuAction:(GJGCChatInputMenuPanelActionType)actionType {
    switch (actionType) {
        case GJGCChatInputMenuPanelActionTypePhotoLibrary:
        {
            [self openNativePhotoLibrary];
        }
            break;
        case GJGCChatInputMenuPanelActionTypeCamera:
        {
            [self shootCamera];
        }
            break;
        case GJGCChatInputMenuPanelActionTypeSmallVideo:
        {
            [self shootSmallVideo];
        }
            break;
        case GJGCChatInputMenuPanelActionTypeLocation:
        {
            [self obtainCurrentLocation];
        }
            break;
        default:
            break;
    }
}

//========================   输入键盘工具 结束  ================================

//打开本地图片和视频
- (void)openNativePhotoLibrary {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    
    //四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    // 1.如果你需要将拍照按钮放在外面，不要传这个参数
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    for (UIImage *image in photos) {
        [self.msgModel sendPhotoMediaMessageWithImage:image];
    }
    
    
    
}

// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    // 打开这段代码发送视频
    __weak typeof(self) weakSelf = self;
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //         导出完成，在这里写上传代码，通过路径或者通过NSData上传
        [weakSelf.msgModel sendVideoMediaMessageWithVideoPath:outputPath showImage:coverImage];
        [weakSelf finishSendingMessage];
    }];
    
}
//拍摄图片
- (void)shootCamera {
    
}
//拍小视频
- (void)shootSmallVideo {
    // 隐藏键盘
    [self reserveChatInputPanelState];
    
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (videoStatus == 	AVAuthorizationStatusRestricted || videoStatus == AVAuthorizationStatusDenied) {
            // 没有权限
            //            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" cancel:@"确定"];
            return;
        }
        
        AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (audioStatus == 	AVAuthorizationStatusRestricted || audioStatus == AVAuthorizationStatusDenied) {
            // 没有权限
            //            [HUDHelper alertTitle:@"提示" message:@"请在设备的\"设置-隐私-麦克风\"中允许访问麦克风。" cancel:@"确定"];
            return;
        }
        __weak typeof(self) weakSelf = self;
        if (videoStatus == AVAuthorizationStatusNotDetermined) {
            //请求相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if(granted) {
                    AVAuthorizationStatus audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                    if (audio == AVAuthorizationStatusNotDetermined) {
                        //请求麦克风权限
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (granted) {
                                    [weakSelf addRecordVideoView];
                                }
                            });
                        }];
                    } else {//这里一定是有麦克风权限了
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf addRecordVideoView];
                        });
                    }
                }
                
            }];
        } else {//这里一定是有相机权限了
            if (audioStatus == AVAuthorizationStatusNotDetermined) {
                //请求麦克风权限
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            [weakSelf addRecordVideoView];
                        }
                    });
                    
                }];
            } else {//这里一定是有麦克风权限了
                [weakSelf addRecordVideoView];
            }
            
        }
    }
}

- (void)addRecordVideoView {
    CGFloat selfWidth  = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    LJRecordVideoView *videoView = [[LJRecordVideoView alloc] initWithFrame:CGRectMake(0, selfHeight/3, selfWidth, selfHeight * 2/3)];
    videoView.delegate = self;
    [self.view addSubview:videoView];
}
#pragma mark - LJRecordVideoViewDelegate

- (void)recordVideoViewTouchUpDone:(NSString *)savePath {
    
    
    NSError *err = nil;
    NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:savePath] options:NSDataReadingMappedIfSafe error:&err];
    //文件最大不超过28MB
    if(data.length < 28 * 1024 * 1024) {
        //        IMAMsg *msg = [IMAMsg msgWithVideoPath:savePath];
        //        [self sendMsg:msg];
        UIImage *showImage = [UIImage lj_imageVideoCaptureVideoPath:savePath];
        
        UISaveVideoAtPathToSavedPhotosAlbum(savePath, nil, nil, nil);
        [self.msgModel sendShortVideoMediaMessageWithVideoPath:savePath showImage:showImage];
        [self finishSendingMessage];
        NSLog(@"==== %@", savePath);
    } else {
        //        [[HUDHelper sharedInstance] tipMessage:@"发送的文件过大"];
        NSLog(@"发送的文件过大");
    }
}

//获取当前位置
- (void)obtainCurrentLocation {
    [self.msgModel sendLocationMediaMessageLatitude:0 longitude:0 completionHandler:^{
        [self.collectionView reloadData];
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

- (void)receiveMessagePressed:(UIBarButtonItem *)sender {
}

- (void)closePressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.msgModel.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return @"123";
}

- (NSString *)senderDisplayName {
    return @"123";
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

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.msgModel.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.msgModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
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



#pragma mark - UICollectionView Delegate

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 0.0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 18.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击头像");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.msgModel.messages objectAtIndex:indexPath.row];
    
    if ([message.media isKindOfClass:[LJSoundMediaItem class]]) {
        self.audioMediaNewItem = (LJSoundMediaItem *)message.media;
        [self startPlayCurrentAudio];
        
        NSLog(@"点击音频!");
    } else if ([message.media isKindOfClass:[LJShortVideoMediaItem class]]) {
        NSLog(@"点击 微 视频!");
        LJShortVideoMediaItem *videoMediaItem = (LJShortVideoMediaItem *)message.media;
        LJFullVideoView *fullVideoView = [[LJFullVideoView alloc] initWithVideoPath:videoMediaItem.videoPath coverImage:videoMediaItem.aFrameImage];
        [fullVideoView showFullVideoView];
        
    } else if ([message.media isKindOfClass:[LJVideoMediaItem class]]) {
        NSLog(@"点击视频!");
    } else if ([message.media isKindOfClass:[LJLocationMediaItem class]]) {
        NSLog(@"点击地图!");
    } else if ([message.media isKindOfClass:[LJImageMediaItem class]]) {
        NSLog(@"点击图片!");
    }  else  {
        NSLog(@"点击文字!");
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
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
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉加载更多的数据" attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        [_refreshControl addTarget:self action:@selector(loadMoreMessageData) forControlEvents:UIControlEventValueChanged];
        
    }
    return _refreshControl;
}

@end
